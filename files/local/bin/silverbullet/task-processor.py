#!/usr/bin/env python3
"""
SilverBullet Task Processor

Watches the notes directory for file changes and processes tasks:

1. Transforms legacy :YYYY-MM-DD syntax to native [due: YYYY-MM-DD] attributes
   - Converts: - [ ] Task name :2026-02-10 every 2 days
   - To:       - [ ] Task name [due: 2026-02-10 every 2 days]

2. Transforms relative date syntax to absolute dates
   - Converts: - [ ] Task name :tomorrow
   - To:       - [ ] Task name [due: 2026-02-11]
   - Supports: today, tomorrow, next monday, in 3 days, etc.

3. Handles completed recurring tasks
   - When a recurring task is checked off, creates a new task with updated date
   - Preserves completion history in HTML comments

Task syntax: - [x] Task name [due: 2026-02-10 every 2 days]
When completed, creates:
  - [ ] Task name [due: 2026-02-12 every 2 days]
  <!-- - [x] Task name [due: 2026-02-10 every 2 days] -->
"""

import os
import re
import time
from datetime import datetime, timedelta
from pathlib import Path

import dateparser
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler, FileModifiedEvent

NOTES_DIR = "/home/nick/notes"
DEBOUNCE_SECONDS = 0.5

# Regex to match legacy :YYYY-MM-DD syntax for transformation
# Matches: - [ ] Task name :2026-02-10 every 2 days
# Captures the date and everything after it
LEGACY_DUE_PATTERN = re.compile(
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

# Also match legacy syntax for completed tasks (for backwards compatibility during migration)
LEGACY_TASK_PATTERN = re.compile(
    r'^(\s*)-\s*\[x\]\s+(.+?)\s*:(\d{4}-\d{2}-\d{2})\s+(.+?)\s*$',
    re.IGNORECASE
)

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


def transform_legacy_due_syntax(content: str) -> tuple[str, bool]:
    """
    Transform legacy :YYYY-MM-DD syntax to native [due: YYYY-MM-DD] attributes.
    
    Converts: - [ ] Task name :2026-02-10 every 2 days
    To:       - [ ] Task name [due: 2026-02-10 every 2 days]
    
    Returns tuple of (transformed_content, was_modified)
    """
    def replace_match(match: re.Match) -> str:
        task_prefix = match.group(1)  # "- [ ] Task name" part
        due_content = match.group(2)  # "2026-02-10 every 2 days" part
        return f'{task_prefix} [due: {due_content}]'
    
    new_content = LEGACY_DUE_PATTERN.sub(replace_match, content)
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


def process_file(filepath: str) -> None:
    """Process a markdown file: transform due syntax and handle recurring tasks."""
    try:
        path = Path(filepath)
        if not path.exists() or not path.suffix == '.md':
            return
        
        content = path.read_text()
        modified = False
        
        # Step 1: Transform legacy :YYYY-MM-DD syntax to [due: YYYY-MM-DD]
        content, was_transformed = transform_legacy_due_syntax(content)
        if was_transformed:
            modified = True
            print(f"Transformed legacy due syntax in: {filepath}")
        
        # Step 1b: Transform relative dates like :tomorrow to [due: YYYY-MM-DD]
        content, was_transformed = transform_relative_due_syntax(content)
        if was_transformed:
            modified = True
            print(f"Transformed relative due syntax in: {filepath}")
        
        # Step 2: Process completed recurring tasks
        lines = content.split('\n')
        new_lines: list[str] = []
        today = datetime.now().strftime('%Y-%m-%d')
        
        for line in lines:
            # Try native [due:] syntax first
            match = TASK_PATTERN.match(line)
            
            # Fall back to legacy syntax (in case transformation missed something)
            if not match:
                match = LEGACY_TASK_PATTERN.match(line)
            
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
        
        if modified:
            path.write_text('\n'.join(new_lines))
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
