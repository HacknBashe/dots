#!/usr/bin/env python3
"""
SilverBullet Task Processor

Watches the notes directory for file changes and processes tasks:

0. Runs prettier to normalize markdown formatting

1. Transforms :YYYY-MM-DD shorthand to native [due: YYYY-MM-DD] attributes
   - Converts: - [ ] Task name :2026-02-10 every 2 days
   - To:       - [ ] Task name [due: 2026-02-10 every 2 days]

2. Transforms relative date syntax to absolute dates
   - Converts: - [ ] Task name :tomorrow
   - To:       - [ ] Task name [due: 2026-02-11]
   - Supports: today, tomorrow, next monday, in 3 days, etc.

3. Routes tagged tasks to other note pages
   - A task with #sanc moves to the first note matching "sanc*" (e.g. sanctuary.md)
   - A task with #sanc/nova moves to the "Nova" section of that note
   - Prefix matching is case-insensitive for both page and section
   - If no match is found, the tag is marked with ! (e.g. #sanc!) and left in place

4. Handles completed recurring tasks
   - When a recurring task is checked off, creates a new task with updated date
   - Preserves completion history in HTML comments

5. Sorts tasks by due date within each section
   - Tasks with [due: YYYY-MM-DD] are sorted to the top (earliest first)
   - Tasks without due dates keep their original order below
   - Sub-tasks stay attached to their parent during sorting
"""

import os
import re
import subprocess
import time
from datetime import datetime, timedelta
from pathlib import Path

import dateparser
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler, FileModifiedEvent

NOTES_DIR = "/home/nick/notes"
DEBOUNCE_SECONDS = 0.5

# Regex to match :YYYY-MM-DD shorthand syntax for transformation
# Matches: - [ ] Task name :2026-02-10 every 2 days
# Captures the date and everything after it
ABSOLUTE_DUE_PATTERN = re.compile(
    r'^(\s*-\s*\[[x ]\]\s+.+?)\s*:(\d{4}-\d{2}-\d{2}[^\]]*?)\s*$',
    re.IGNORECASE | re.MULTILINE
)

# Regex to match relative date syntax like :tomorrow, :today, :next monday
# Matches: - [ ] Task name :tomorrow
# Matches: - [ ] Task name :next monday
RELATIVE_DUE_PATTERN = re.compile(
    r'^(\s*-\s*\[[x ]\]\s+.+?)\s*:(today|tomorrow|next\s+\w+|in\s+\d+\s+\w+)\s*$',
    re.IGNORECASE | re.MULTILINE
)

# Regex to match completed recurring tasks with native [due:] syntax
# Matches: - [x] Task name [due: 2026-02-10 every 2 days]
# Groups: (indent)(task_name)(deadline)(recurrence)
TASK_PATTERN = re.compile(
    r'^(\s*)-\s*\[x\]\s+(.+?)\s*\[due:\s*(\d{4}-\d{2}-\d{2})\s+(.+?)\]\s*$',
    re.IGNORECASE
)

# Also match :YYYY-MM-DD shorthand for completed recurring tasks
SHORTHAND_TASK_PATTERN = re.compile(
    r'^(\s*)-\s*\[x\]\s+(.+?)\s*:(\d{4}-\d{2}-\d{2})\s+(.+?)\s*$',
    re.IGNORECASE
)

# Regex to match #page or #page/section tags in task lines (but not #tag! which marks a failed match)
TAG_PATTERN = re.compile(r'(?<=\s)#([a-zA-Z0-9_-]+)(?:/([a-zA-Z0-9_-]+))?(?![\w/!])')

# Regex to detect a task line (any checkbox state)
TASK_LINE_RE = re.compile(r'^(\s*)-\s*\[[x >\-]\]\s+', re.IGNORECASE)

# Regex to extract due date from [due: YYYY-MM-DD ...]
DUE_DATE_RE = re.compile(r'\[due:\s*(\d{4}-\d{2}-\d{2})')

# Track pending file processing for debouncing
pending_files: dict[str, float] = {}


def parse_recurrence(recurrence: str, base_date: datetime) -> datetime | None:
    """Parse a recurrence pattern and return the next occurrence date."""
    lower = recurrence.lower().strip()
    
    # Handle common patterns manually for reliability
    if lower in ("daily", "every day"):
        return base_date + timedelta(days=1)
    
    if lower in ("weekly", "every week"):
        return base_date + timedelta(weeks=1)
    
    if lower in ("monthly", "every month"):
        # Add one month (handle month boundaries)
        year = base_date.year
        month = base_date.month + 1
        if month > 12:
            month = 1
            year += 1
        day = min(base_date.day, 28)  # Safe day for all months
        return base_date.replace(year=year, month=month, day=day)
    
    if lower == "every other day":
        return base_date + timedelta(days=2)
    
    # Handle "every N days"
    match = re.match(r'^every\s+(\d+)\s+days?$', lower)
    if match:
        days = int(match.group(1))
        return base_date + timedelta(days=days)
    
    # Handle "every N weeks"
    match = re.match(r'^every\s+(\d+)\s+weeks?$', lower)
    if match:
        weeks = int(match.group(1))
        return base_date + timedelta(weeks=weeks)
    
    # Handle "every monday", "every tuesday", etc.
    match = re.match(
        r'^every\s+(monday|tuesday|wednesday|thursday|friday|saturday|sunday)$',
        lower
    )
    if match:
        weekday_name = match.group(1)
        # Parse "next monday" relative to the day after base_date
        next_day = base_date + timedelta(days=1)
        result = dateparser.parse(
            f"next {weekday_name}",
            settings={
                'RELATIVE_BASE': next_day,
                'PREFER_DATES_FROM': 'future'
            }
        )
        if result:
            return result
    
    # Fallback: try dateparser for other patterns
    next_day = base_date + timedelta(days=1)
    result = dateparser.parse(
        recurrence,
        settings={
            'RELATIVE_BASE': next_day,
            'PREFER_DATES_FROM': 'future'
        }
    )
    if result and result > base_date:
        return result
    
    print(f"Warning: Could not parse recurrence: '{recurrence}'")
    return None


def run_prettier(filepath: str) -> bool:
    """Run prettier on a markdown file. Returns True if the file was modified."""
    try:
        result = subprocess.run(
            ["prettier", "--write", filepath],
            capture_output=True, text=True, timeout=10
        )
        if result.returncode != 0:
            print(f"Warning: prettier failed on {filepath}: {result.stderr.strip()}")
            return False
        # prettier prints the filename to stdout when it modifies a file
        return True
    except FileNotFoundError:
        print("Warning: prettier not found in PATH, skipping formatting")
        return False
    except subprocess.TimeoutExpired:
        print(f"Warning: prettier timed out on {filepath}")
        return False


def transform_absolute_due_syntax(content: str) -> tuple[str, bool]:
    """
    Transform :YYYY-MM-DD shorthand to native [due: YYYY-MM-DD] attributes.
    
    Converts: - [ ] Task name :2026-02-10 every 2 days
    To:       - [ ] Task name [due: 2026-02-10 every 2 days]
    
    Returns tuple of (transformed_content, was_modified)
    """
    def replace_match(match: re.Match) -> str:
        task_prefix = match.group(1)  # "- [ ] Task name" part
        due_content = match.group(2)  # "2026-02-10 every 2 days" part
        return f'{task_prefix} [due: {due_content}]'
    
    new_content = ABSOLUTE_DUE_PATTERN.sub(replace_match, content)
    return new_content, new_content != content


def transform_relative_due_syntax(content: str) -> tuple[str, bool]:
    """
    Transform relative date syntax like :tomorrow to [due: YYYY-MM-DD].
    
    Converts: - [ ] Task name :tomorrow
    To:       - [ ] Task name [due: 2026-02-11]
    
    Returns tuple of (transformed_content, was_modified)
    """
    def replace_match(match: re.Match) -> str:
        task_prefix = match.group(1)  # "- [ ] Task name" part
        relative_date = match.group(2)  # "tomorrow", "next monday", etc.
        
        # Parse the relative date
        parsed = dateparser.parse(
            relative_date,
            settings={
                'PREFER_DATES_FROM': 'future',
                'RELATIVE_BASE': datetime.now()
            }
        )
        
        if parsed:
            date_str = parsed.strftime('%Y-%m-%d')
            return f'{task_prefix} [due: {date_str}]'
        else:
            # If parsing fails, leave unchanged
            print(f"Warning: Could not parse relative date: '{relative_date}'")
            return match.group(0)
    
    new_content = RELATIVE_DUE_PATTERN.sub(replace_match, content)
    return new_content, new_content != content


def find_note_file(prefix: str) -> str | None:
    """Find the first .md file in NOTES_DIR whose stem starts with prefix (case-insensitive)."""
    prefix_lower = prefix.lower()
    matches = []
    for entry in os.scandir(NOTES_DIR):
        if entry.is_file() and entry.name.endswith('.md'):
            stem = entry.name[:-3]  # strip .md
            if stem.lower().startswith(prefix_lower):
                matches.append(entry.path)
    matches.sort()  # alphabetical for determinism
    return matches[0] if matches else None


def find_section_insert_pos(lines: list[str], section_prefix: str) -> int | None:
    """
    Find the insert position at the bottom of a ## section matching section_prefix.
    Returns the line index to insert before, or None if no matching section found.
    """
    prefix_lower = section_prefix.lower()
    section_start = None

    for i, line in enumerate(lines):
        if line.startswith('## '):
            heading_text = line[3:].strip()
            if section_start is not None:
                # We found the next heading after our section — insert before it
                # Back up past any trailing blank lines in our section
                pos = i
                while pos > section_start and lines[pos - 1].strip() == '':
                    pos -= 1
                return pos
            if heading_text.lower().startswith(prefix_lower):
                section_start = i

    if section_start is not None:
        # Section runs to end of file — insert before trailing blank lines
        pos = len(lines)
        while pos > section_start and lines[pos - 1].strip() == '':
            pos -= 1
        return pos

    return None


def collect_task_group(lines: list[str], start: int) -> list[str]:
    """
    Collect a task line and all its indented children starting at lines[start].
    Returns the group as a list of lines.
    """
    if start >= len(lines):
        return []

    group = [lines[start]]
    task_match = TASK_LINE_RE.match(lines[start])
    if not task_match:
        return group

    base_indent = len(task_match.group(1))
    i = start + 1
    while i < len(lines):
        line = lines[i]
        # Empty lines between sub-tasks — include if next non-empty line is still indented
        if line.strip() == '':
            # Peek ahead
            j = i + 1
            while j < len(lines) and lines[j].strip() == '':
                j += 1
            if j < len(lines) and len(lines[j]) - len(lines[j].lstrip()) > base_indent:
                group.append(line)
                i += 1
                continue
            break
        # Check indentation
        stripped = line.lstrip()
        indent = len(line) - len(stripped)
        if indent > base_indent:
            group.append(line)
            i += 1
        else:
            break

    return group


def route_tagged_tasks(filepath: str, content: str) -> tuple[str, bool]:
    """
    Find tasks with #page or #page/section tags and move them to the target note.
    Tags ending with ! are skipped (previously failed matches).
    Returns (modified_content, was_modified).
    """
    lines = content.split('\n')
    lines_to_remove: set[int] = set()
    # Each pending move: (dest_path, group_lines, section_prefix_or_None, source_line_indices)
    pending_moves: list[tuple[str, list[str], str | None, list[int]]] = []
    modified = False

    i = 0
    while i < len(lines):
        line = lines[i]

        # Only process task lines
        if not TASK_LINE_RE.match(line):
            i += 1
            continue

        tag_match = TAG_PATTERN.search(line)
        if not tag_match:
            i += 1
            continue

        page_prefix = tag_match.group(1)
        section_prefix = tag_match.group(2)  # None if no /section

        # Resolve destination file
        dest_path = find_note_file(page_prefix)
        if not dest_path:
            # No match — mark with ! so we don't retry
            full_tag = tag_match.group(0).strip()
            lines[i] = line[:tag_match.end()] + '!' + line[tag_match.end():]
            print(f"Warning: No note matching '{page_prefix}', marked {full_tag}!")
            modified = True
            i += 1
            continue

        # Don't move to self
        if os.path.abspath(dest_path) == os.path.abspath(filepath):
            i += 1
            continue

        # Collect task group (parent + children)
        group = collect_task_group(lines, i)
        source_indices = list(range(i, i + len(group)))

        # Strip the tag from the first line of the group
        first_line = group[0]
        tag_start = tag_match.start()
        tag_end = tag_match.end()
        cleaned = first_line[:tag_start] + first_line[tag_end:]
        # Collapse any double spaces left behind
        cleaned = re.sub(r'  +', ' ', cleaned).rstrip()
        group[0] = cleaned

        pending_moves.append((dest_path, group, section_prefix, source_indices))
        i += len(group)

    # Process moves: validate destinations, then commit
    for dest_path, group_lines, section_prefix, source_indices in pending_moves:
        if section_prefix:
            # Pre-validate that the section exists in the destination
            dest_content = Path(dest_path).read_text()
            dest_lines = dest_content.split('\n')
            if find_section_insert_pos(dest_lines, section_prefix) is None:
                # Section not found — mark with ! on the source line, don't move
                orig_line = lines[source_indices[0]]
                orig_tag = TAG_PATTERN.search(orig_line)
                if orig_tag:
                    lines[source_indices[0]] = (orig_line[:orig_tag.end()] + '!'
                                                + orig_line[orig_tag.end():])
                print(f"Warning: No section matching '{section_prefix}' "
                      f"in {os.path.basename(dest_path)}, marked with !")
                modified = True
                continue

        lines_to_remove.update(source_indices)
        modified = True
        print(f"Routing task to {os.path.basename(dest_path)}"
              f"{('/' + section_prefix) if section_prefix else ''}: "
              f"{group_lines[0].strip()}")

    # Write tasks to destination files (grouped by dest)
    dest_groups: dict[str, list[tuple[list[str], str | None]]] = {}
    for dest_path, group_lines, section_prefix, source_indices in pending_moves:
        if any(idx in lines_to_remove for idx in source_indices):
            # This move was approved (lines are being removed)
            if dest_path not in dest_groups:
                dest_groups[dest_path] = []
            dest_groups[dest_path].append((group_lines, section_prefix))

    for dest_path, task_groups in dest_groups.items():
        dest_content = Path(dest_path).read_text()
        dest_lines = dest_content.split('\n')

        for group_lines, section_prefix in task_groups:
            if section_prefix:
                insert_pos = find_section_insert_pos(dest_lines, section_prefix)
                # Already validated above, but guard anyway
                if insert_pos is None:
                    continue
                for gl in group_lines:
                    dest_lines.insert(insert_pos, gl)
                    insert_pos += 1
            else:
                # Append to bottom of the top-level section (before first ## heading)
                insert_pos = None
                for k, dl in enumerate(dest_lines):
                    if dl.startswith('## '):
                        insert_pos = k
                        # Back up past blank lines before the heading
                        while insert_pos > 0 and dest_lines[insert_pos - 1].strip() == '':
                            insert_pos -= 1
                        break
                if insert_pos is None:
                    # No headings — append to bottom of file
                    insert_pos = len(dest_lines)
                    while insert_pos > 0 and dest_lines[insert_pos - 1].strip() == '':
                        insert_pos -= 1
                for gl in group_lines:
                    dest_lines.insert(insert_pos, gl)
                    insert_pos += 1

        Path(dest_path).write_text('\n'.join(dest_lines))

    # Remove moved lines from source
    if lines_to_remove:
        new_lines = [line for i, line in enumerate(lines) if i not in lines_to_remove]
        content = '\n'.join(new_lines)

    return content, modified


def sort_tasks_in_sections(content: str) -> tuple[str, bool]:
    """
    Sort tasks by due date within each section of a note file.
    Tasks with due dates are moved to the top of their section (earliest first).
    Tasks without due dates keep their original order and appear after dated tasks.
    Sub-tasks stay attached to their parent.
    Returns (modified_content, was_modified).
    """
    lines = content.split('\n')

    # Find frontmatter end
    content_start = 0
    if lines and lines[0].strip() == '---':
        for i in range(1, len(lines)):
            if lines[i].strip() == '---':
                content_start = i + 1
                break

    # Find ## heading positions
    heading_positions: list[int] = []
    for i in range(content_start, len(lines)):
        if lines[i].startswith('## '):
            heading_positions.append(i)

    # Build chunks: [(start, end)] where each chunk is a sortable section body
    # We reconstruct the file as: frontmatter + [heading_line + sorted_body]*
    # The top-level section (before first heading) is also a sortable chunk
    chunks: list[tuple[int, int]] = []

    first_heading = heading_positions[0] if heading_positions else len(lines)
    if content_start < first_heading:
        chunks.append((content_start, first_heading))

    for idx, hpos in enumerate(heading_positions):
        body_start = hpos + 1
        body_end = heading_positions[idx + 1] if idx + 1 < len(heading_positions) else len(lines)
        chunks.append((body_start, body_end))

    # Sort each chunk independently, then rebuild the full file
    result_lines: list[str] = list(lines[:content_start])  # frontmatter
    was_modified = False

    prev_end = content_start
    for chunk_start, chunk_end in chunks:
        # Add any heading line between prev_end and chunk_start
        result_lines.extend(lines[prev_end:chunk_start])

        section_lines = lines[chunk_start:chunk_end]
        sorted_section = _sort_section_tasks(section_lines)
        if sorted_section != section_lines:
            was_modified = True
        result_lines.extend(sorted_section)
        prev_end = chunk_end

    # Add any remaining lines after the last chunk
    result_lines.extend(lines[prev_end:])

    if was_modified:
        return '\n'.join(result_lines), True
    return content, False


def _sort_section_tasks(section_lines: list[str]) -> list[str]:
    """
    Sort task groups within a section. Tasks with due dates come first (sorted by date),
    followed by tasks without due dates (original order preserved).
    Non-task lines at the start of the section are preserved in place.
    """
    # Split into: leading non-task lines, task groups, and trailing non-task lines
    leading: list[str] = []
    task_groups: list[list[str]] = []
    i = 0

    # Collect leading blank lines / non-task content
    while i < len(section_lines):
        line = section_lines[i]
        if TASK_LINE_RE.match(line):
            break
        leading.append(line)
        i += 1

    # Collect task groups (skip blank lines between them but track them)
    blank_buffer: list[str] = []
    while i < len(section_lines):
        line = section_lines[i]

        if line.strip() == '':
            blank_buffer.append(line)
            i += 1
            continue

        # If we hit a non-task, non-blank line, stop — rest is trailing content
        if not TASK_LINE_RE.match(line):
            break

        # Discard blank lines between top-level task groups (they'll be between sorted groups)
        blank_buffer = []

        group = collect_task_group(section_lines, i)
        task_groups.append(group)
        i += len(group)

    # Trailing content: any buffered blank lines + everything after the last task group
    trailing = blank_buffer + section_lines[i:]

    if not task_groups:
        return section_lines

    # Separate task groups into dated and undated
    dated: list[tuple[str, list[str]]] = []  # (date_str, group)
    undated: list[list[str]] = []

    for group in task_groups:
        date_match = DUE_DATE_RE.search(group[0])
        if date_match:
            dated.append((date_match.group(1), group))
        else:
            undated.append(group)

    # Sort dated tasks by date (ascending)
    dated.sort(key=lambda x: x[0])

    # Reassemble: leading + sorted dated + undated + trailing
    result: list[str] = list(leading)
    for _, group in dated:
        result.extend(group)
    for group in undated:
        result.extend(group)
    result.extend(trailing)

    return result


def process_file(filepath: str) -> None:
    """Process a markdown file: format, transform syntax, route tags, handle recurrence, sort."""
    try:
        path = Path(filepath)
        if not path.exists() or not path.suffix == '.md':
            return
        
        # Step 0: Run prettier to normalize formatting
        run_prettier(filepath)
        
        content = path.read_text()
        modified = False
        
        # Step 1: Transform :YYYY-MM-DD shorthand to [due: YYYY-MM-DD]
        content, was_transformed = transform_absolute_due_syntax(content)
        if was_transformed:
            modified = True
            print(f"Transformed absolute due syntax in: {filepath}")
        
        # Step 2: Transform relative dates like :tomorrow to [due: YYYY-MM-DD]
        content, was_transformed = transform_relative_due_syntax(content)
        if was_transformed:
            modified = True
            print(f"Transformed relative due syntax in: {filepath}")
        
        # Step 3: Route tagged tasks (#page or #page/section) to other note files
        content, was_routed = route_tagged_tasks(filepath, content)
        if was_routed:
            modified = True
        
        # Step 4: Process completed recurring tasks
        lines = content.split('\n')
        new_lines: list[str] = []
        
        for line in lines:
            # Try native [due:] syntax first
            match = TASK_PATTERN.match(line)
            
            # Fall back to :YYYY-MM-DD shorthand (in case transformation missed it)
            if not match:
                match = SHORTHAND_TASK_PATTERN.match(line)
            
            if not match:
                new_lines.append(line)
                continue
            
            indent, task_name, deadline, recurrence = match.groups()
            task_name = task_name.strip()
            recurrence = recurrence.strip()
            
            try:
                base_date = datetime.strptime(deadline, '%Y-%m-%d')
            except ValueError:
                print(f"Warning: Could not parse deadline date: '{deadline}'")
                new_lines.append(line)
                continue
            
            next_date = parse_recurrence(recurrence, base_date)
            
            if not next_date:
                new_lines.append(line)
                continue
            
            new_deadline = next_date.strftime('%Y-%m-%d')
            
            # Add new unchecked task with updated deadline (using native [due:] syntax)
            new_lines.append(
                f'{indent}- [ ] {task_name} [due: {new_deadline} {recurrence}]'
            )
            
            # Add comment with completed task info (preserving original schedule)
            new_lines.append(f'<!-- - [x] {task_name} [due: {deadline} {recurrence}] -->')
            
            modified = True
            print(f"Processed recurring: '{task_name}' - next deadline: {new_deadline}")
        
        # Step 5: Sort tasks by due date within each section
        final_content = '\n'.join(new_lines)
        final_content, was_sorted = sort_tasks_in_sections(final_content)
        if was_sorted:
            modified = True
            print(f"Sorted tasks by due date in: {filepath}")
        
        if modified:
            path.write_text(final_content)
            print(f"Updated: {filepath}")
    
    except Exception as e:
        print(f"Error processing {filepath}: {e}")


def scan_existing_files() -> None:
    """Scan all existing markdown files on startup."""
    print(f"Scanning existing files in {NOTES_DIR}...")
    
    for root, dirs, files in os.walk(NOTES_DIR):
        # Skip hidden directories
        dirs[:] = [d for d in dirs if not d.startswith('.')]
        
        for filename in files:
            if filename.endswith('.md'):
                filepath = os.path.join(root, filename)
                process_file(filepath)
    
    print("Initial scan complete.")


class DebouncedHandler(FileSystemEventHandler):
    """File system event handler with debouncing."""
    
    def on_modified(self, event: FileModifiedEvent) -> None:
        if event.is_directory:
            return
        
        filepath = event.src_path
        
        if not filepath.endswith('.md'):
            return
        
        # Skip hidden files/directories
        if any(part.startswith('.') for part in Path(filepath).parts):
            return
        
        # Debounce: only process if enough time has passed
        current_time = time.time()
        last_time = pending_files.get(filepath, 0)
        
        if current_time - last_time < DEBOUNCE_SECONDS:
            return
        
        pending_files[filepath] = current_time
        
        # Small delay to let file writes complete
        time.sleep(DEBOUNCE_SECONDS)
        process_file(filepath)


def main() -> None:
    print(f"Starting recurring tasks watcher for {NOTES_DIR}")
    
    # Process existing files on startup
    scan_existing_files()
    
    # Set up file watcher
    event_handler = DebouncedHandler()
    observer = Observer()
    observer.schedule(event_handler, NOTES_DIR, recursive=True)
    observer.start()
    
    print("Watching for file changes...")
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("Shutting down...")
        observer.stop()
    
    observer.join()


if __name__ == "__main__":
    main()
