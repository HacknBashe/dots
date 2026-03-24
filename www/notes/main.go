package main

import (
	"bytes"
	"embed"
	"encoding/json"
	"fmt"
	"html/template"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
	"sync"
	"time"

	"github.com/yuin/goldmark"
	"github.com/yuin/goldmark/extension"
	"github.com/yuin/goldmark/parser"
	"github.com/yuin/goldmark/renderer/html"
)

//go:embed templates/*
var templateFS embed.FS

//go:embed static/*
var staticFS embed.FS

// --- Models ---

type Note struct {
	ID      string
	Name    string
	Tags    []string
	Sort    int
	Color   string // hex color, e.g. "#e06c75"
	ModTime time.Time
}

type Block struct {
	Index    int
	Type     string // "heading", "task", "text", "list-item"
	Raw      string // original markdown lines
	Level    int    // heading level or indent level
	Checked  int    // 0=unchecked, 1=checked, 2=cancelled (-1=not a task)
	Children []int  // indices of child blocks (for sub-tasks)
}

type NavGroup struct {
	Name     string
	Color    string // hex color for this group's icon/title (inherited from parent if empty)
	Notes    []Note
	Children []NavGroup
}

// --- App State ---

type App struct {
	notesDir  string
	mu        sync.RWMutex
	notes     []Note
	templates *template.Template
	md        goldmark.Markdown
}

func NewApp(notesDir string) *App {
	md := goldmark.New(
		goldmark.WithExtensions(extension.GFM),
		goldmark.WithParserOptions(parser.WithAutoHeadingID()),
		goldmark.WithRendererOptions(html.WithUnsafe()),
	)

	funcMap := template.FuncMap{
		"toTitle":    toTitle,
		"renderHTML": func(s string) template.HTML { return template.HTML(s) },
		"join":       strings.Join,
		"hasPrefix":  strings.HasPrefix,
		"contains":   strings.Contains,
		"lower":      strings.ToLower,
		"add":        func(a, b int) int { return a + b },
		"sub":        func(a, b int) int { return a - b },
		"dueLabel": func(days int) string {
			if days == 0 {
				return "today"
			} else if days == -1 {
				return "1 day overdue"
			} else if days < -1 {
				return fmt.Sprintf("%d days overdue", -days)
			} else if days == 1 {
				return "tomorrow"
			}
			return fmt.Sprintf("in %d days", days)
		},
		"abs": func(n int) int {
			if n < 0 {
				return -n
			}
			return n
		},
		"taskText": func(s string) template.HTML {
			// Strip checkbox prefix and due tag
			s = taskRegex.ReplaceAllString(s, "$3")
			s = dueRegex.ReplaceAllString(s, "")
			s = strings.TrimSpace(s)
			// Render inline markdown (links etc)
			var buf bytes.Buffer
			md.Convert([]byte(s), &buf)
			// Strip wrapping <p> tags
			out := strings.TrimSpace(buf.String())
			out = strings.TrimPrefix(out, "<p>")
			out = strings.TrimSuffix(out, "</p>")
			return template.HTML(out)
		},
		"formatDate": func(t time.Time) string {
			return t.Format("Jan 2")
		},
		"map": func(pairs ...any) map[string]any {
			m := make(map[string]any)
			for i := 0; i+1 < len(pairs); i += 2 {
				key, _ := pairs[i].(string)
				m[key] = pairs[i+1]
			}
			return m
		},
		"seq": func(n int) []int {
			s := make([]int, n)
			for i := range s {
				s[i] = i
			}
			return s
		},
	}

	tmpl := template.Must(template.New("").Funcs(funcMap).ParseFS(templateFS, "templates/*"))

	app := &App{
		notesDir:  notesDir,
		templates: tmpl,
		md:        md,
	}
	app.refreshNotes()
	return app
}

// --- Frontmatter Parsing ---

func parseFrontmatter(content string) (id string, tags []string, sortOrder int, color string, body string) {
	if !strings.HasPrefix(content, "---\n") {
		return "", nil, 0, "", content
	}
	end := strings.Index(content[4:], "\n---")
	if end == -1 {
		return "", nil, 0, "", content
	}
	fm := content[4 : 4+end]
	body = content[4+end+4:] // skip past closing ---\n
	inTags := false

	for _, line := range strings.Split(fm, "\n") {
		trimmed := strings.TrimSpace(line)
		if strings.HasPrefix(trimmed, "id:") {
			id = strings.Trim(strings.TrimPrefix(trimmed, "id:"), " \"")
			inTags = false
		} else if strings.HasPrefix(trimmed, "sort:") {
			fmt.Sscanf(strings.TrimSpace(strings.TrimPrefix(trimmed, "sort:")), "%d", &sortOrder)
			inTags = false
		} else if strings.HasPrefix(trimmed, "color:") {
			color = strings.Trim(strings.TrimSpace(strings.TrimPrefix(trimmed, "color:")), " \"'")
			inTags = false
		} else if strings.HasPrefix(trimmed, "tags:") {
			val := strings.TrimSpace(strings.TrimPrefix(trimmed, "tags:"))
			if val == "[]" {
				tags = []string{}
			} else if strings.HasPrefix(val, "[") {
				val = strings.Trim(val, "[]")
				for _, t := range strings.Split(val, ",") {
					t = strings.TrimSpace(t)
					if t != "" {
						tags = append(tags, t)
					}
				}
			} else {
				inTags = true
			}
		} else if inTags && strings.HasPrefix(trimmed, "- ") {
			tags = append(tags, strings.TrimSpace(strings.TrimPrefix(trimmed, "- ")))
		} else {
			inTags = false
		}
	}
	return id, tags, sortOrder, color, body
}

func buildFrontmatter(id string, tags []string, sortOrder int, color string) string {
	var sb strings.Builder
	sb.WriteString("---\n")
	sb.WriteString(fmt.Sprintf("id: \"%s\"\n", id))
	if len(tags) == 0 {
		sb.WriteString("tags: []\n")
	} else {
		sb.WriteString("tags:\n")
		for _, t := range tags {
			sb.WriteString(fmt.Sprintf("  - %s\n", t))
		}
	}
	if sortOrder > 0 {
		sb.WriteString(fmt.Sprintf("sort: %d\n", sortOrder))
	}
	if color != "" {
		sb.WriteString(fmt.Sprintf("color: \"%s\"\n", color))
	}
	sb.WriteString("---\n")
	return sb.String()
}

// --- Block Parsing ---

var taskRegex = regexp.MustCompile(`^(\s*)- \[([ x\-])\] (.*)$`)
var headingRegex = regexp.MustCompile(`^(#{1,6}) (.*)$`)
var listRegex = regexp.MustCompile(`^(\s*)- (.*)$`)
var dueRegex = regexp.MustCompile(`\[due:\s*(\d{4}-\d{2}-\d{2})(?:\s+(.+?))?\]`)

// DueTask represents an unchecked task with a due date.
type DueTask struct {
	NoteID     string
	NoteName   string
	NoteColor  string
	Block      Block
	HTML       template.HTML
	DueDate    time.Time
	Recurrence string
	DaysAway   int // negative = overdue, 0 = today, positive = upcoming
}

func parseBlocks(body string) []Block {
	lines := strings.Split(body, "\n")
	var blocks []Block
	var textBuf []string

	flushText := func() {
		if len(textBuf) > 0 {
			raw := strings.Join(textBuf, "\n")
			if strings.TrimSpace(raw) != "" {
				blocks = append(blocks, Block{
					Index:   len(blocks),
					Type:    "text",
					Raw:     raw,
					Checked: -1,
				})
			}
			textBuf = nil
		}
	}

	for _, line := range lines {
		// Heading
		if m := headingRegex.FindStringSubmatch(line); m != nil {
			flushText()
			blocks = append(blocks, Block{
				Index:   len(blocks),
				Type:    "heading",
				Raw:     line,
				Level:   len(m[1]),
				Checked: -1,
			})
			continue
		}

		// Task
		if m := taskRegex.FindStringSubmatch(line); m != nil {
			flushText()
			checked := -1
			switch m[2] {
			case " ":
				checked = 0
			case "x":
				checked = 1
			case "-":
				checked = 2
			}
			blocks = append(blocks, Block{
				Index:   len(blocks),
				Type:    "task",
				Raw:     line,
				Level:   len(m[1]),
				Checked: checked,
			})
			continue
		}

		// List item (non-task)
		if listRegex.MatchString(line) {
			flushText()
			m := listRegex.FindStringSubmatch(line)
			blocks = append(blocks, Block{
				Index:   len(blocks),
				Type:    "list-item",
				Raw:     line,
				Level:   len(m[1]),
				Checked: -1,
			})
			continue
		}

		// Regular text — accumulate into paragraph blocks
		textBuf = append(textBuf, line)
	}
	flushText()
	return blocks
}

func blocksToMarkdown(blocks []Block) string {
	var lines []string
	for _, b := range blocks {
		lines = append(lines, b.Raw)
	}
	return strings.Join(lines, "\n")
}

// --- Note Scanning ---

func (app *App) refreshNotes() {
	entries, err := os.ReadDir(app.notesDir)
	if err != nil {
		log.Printf("Error reading notes dir: %v", err)
		return
	}

	var notes []Note
	for _, e := range entries {
		if e.IsDir() || !strings.HasSuffix(e.Name(), ".md") {
			continue
		}
		if strings.HasPrefix(e.Name(), ".") {
			continue
		}
		// Skip conflicted files
		if strings.Contains(e.Name(), ".conflicted:") {
			continue
		}

		name := strings.TrimSuffix(e.Name(), ".md")
		info, _ := e.Info()
		modTime := time.Time{}
		if info != nil {
			modTime = info.ModTime()
		}

		// Read frontmatter for tags
		content, err := os.ReadFile(filepath.Join(app.notesDir, e.Name()))
		if err != nil {
			continue
		}
		id, tags, sortOrder, color, _ := parseFrontmatter(string(content))
		if id == "" {
			id = name
		}

		notes = append(notes, Note{
			ID:      id,
			Name:    name,
			Tags:    tags,
			Sort:    sortOrder,
			Color:   color,
			ModTime: modTime,
		})
	}

	app.mu.Lock()
	app.notes = notes
	app.mu.Unlock()
}

func (app *App) getNotes() []Note {
	app.mu.RLock()
	defer app.mu.RUnlock()
	result := make([]Note, len(app.notes))
	copy(result, app.notes)
	return result
}

func (app *App) readNote(id string) (string, error) {
	if strings.Contains(id, "/") || strings.Contains(id, "..") {
		return "", fmt.Errorf("invalid note id")
	}
	path := filepath.Join(app.notesDir, id+".md")
	data, err := os.ReadFile(path)
	if err != nil {
		return "", err
	}
	return string(data), nil
}

func (app *App) writeNote(id string, content string) error {
	if strings.Contains(id, "/") || strings.Contains(id, "..") {
		return fmt.Errorf("invalid note id")
	}
	path := filepath.Join(app.notesDir, id+".md")
	err := os.WriteFile(path, []byte(content), 0644)
	if err == nil {
		app.refreshNotes()
	}
	return err
}

// --- Markdown Rendering ---

func (app *App) renderMarkdown(md string) string {
	// Rewrite relative .md links to internal app links
	re := regexp.MustCompile(`\[([^\]]+)\]\(([^)]+)\.md\)`)
	md = re.ReplaceAllString(md, `[$1](/note/$2)`)

	var buf bytes.Buffer
	if err := app.md.Convert([]byte(md), &buf); err != nil {
		return "<p>Error rendering markdown</p>"
	}
	return buf.String()
}

func (app *App) renderBlockHTML(noteID string, b Block) string {
	switch b.Type {
	case "task":
		// Strip "- [x] " prefix so goldmark doesn't render a second checkbox;
		// the interactive checkbox is added by the template.
		s := taskRegex.ReplaceAllString(b.Raw, "$3")
		out := app.renderMarkdown(s)
		// Strip wrapping <p> tags to avoid extra margin inside the flex row.
		out = strings.TrimSpace(out)
		out = strings.TrimPrefix(out, "<p>")
		out = strings.TrimSuffix(out, "</p>")
		return out
	case "heading":
		return app.renderMarkdown(b.Raw)
	case "list-item":
		return app.renderMarkdown(b.Raw)
	default:
		return app.renderMarkdown(b.Raw)
	}
}

// --- Tag Hierarchy ---
//
// Simple rule: if a note's tag matches another note's ID, it's a child
// of that note. A note can't be its own parent. That's it.

func tagToID(tag string) string {
	return strings.ToLower(strings.ReplaceAll(tag, " ", "-"))
}

func buildChildTree(parentID string, inheritColor string, childrenOf map[string][]Note, visited map[string]bool) []NavGroup {
	if visited[parentID] {
		return nil
	}
	visited[parentID] = true

	kids := childrenOf[parentID]
	if len(kids) == 0 {
		return nil
	}

	sorted := make([]Note, len(kids))
	copy(sorted, kids)
	sort.Slice(sorted, func(i, j int) bool {
		si, sj := sorted[i].Sort, sorted[j].Sort
		if si > 0 && sj > 0 {
			return si < sj
		}
		if si > 0 {
			return true
		}
		if sj > 0 {
			return false
		}
		return sorted[i].Name < sorted[j].Name
	})

	var result []NavGroup
	for _, kid := range sorted {
		color := kid.Color
		if color == "" {
			color = inheritColor
		}
		group := NavGroup{
			Name:     kid.Name,
			Color:    color,
			Notes:    []Note{kid},
			Children: buildChildTree(kid.ID, color, childrenOf, visited),
		}
		result = append(result, group)
	}
	return result
}

func appearsInSubtree(rootID, targetID string, childrenOf map[string][]Note, visited map[string]bool) bool {
	if visited[rootID] {
		return false
	}
	visited[rootID] = true
	for _, kid := range childrenOf[rootID] {
		if kid.ID == targetID {
			return true
		}
		if appearsInSubtree(kid.ID, targetID, childrenOf, visited) {
			return true
		}
	}
	return false
}

func (app *App) buildNavGroups() (groups []NavGroup, uncategorized []Note) {
	notes := app.getNotes()

	noteByID := make(map[string]Note)
	for _, n := range notes {
		noteByID[n.ID] = n
	}

	skipTags := map[string]bool{"daily-notes": true}

	// Step 1: Build parent->children map.
	// If a note's tag matches another note's ID, it's a child of that note.
	childrenOf := make(map[string][]Note)
	for _, n := range notes {
		for _, tag := range n.Tags {
			if skipTags[strings.ToLower(tag)] {
				continue
			}
			pid := tagToID(tag)
			if pid == n.ID {
				continue // can't be own parent
			}
			if _, ok := noteByID[pid]; ok {
				childrenOf[pid] = append(childrenOf[pid], n)
			}
		}
	}

	// Dedup children
	for pid, kids := range childrenOf {
		seen := make(map[string]bool)
		var deduped []Note
		for _, k := range kids {
			if !seen[k.ID] {
				seen[k.ID] = true
				deduped = append(deduped, k)
			}
		}
		childrenOf[pid] = deduped
	}

	// Step 2: Resolve correct parents. If a note is tagged with both a
	// parent and that parent's ancestor (e.g. gifts tagged [todo, charity]
	// where charity is under todo), only keep it under the most specific
	// parent (charity). Remove it from the ancestor's direct children.
	for pid := range childrenOf {
		var keep []Note
		for _, kid := range childrenOf[pid] {
			deeper := false
			for _, sibling := range childrenOf[pid] {
				if sibling.ID == kid.ID {
					continue
				}
				if appearsInSubtree(sibling.ID, kid.ID, childrenOf, map[string]bool{pid: true}) {
					deeper = true
					break
				}
			}
			if !deeper {
				keep = append(keep, kid)
			}
		}
		childrenOf[pid] = keep
	}

	// Step 3: Find root parents (have children, are not a child of anyone).
	isChild := make(map[string]bool)
	for _, kids := range childrenOf {
		for _, k := range kids {
			isChild[k.ID] = true
		}
	}

	inTree := make(map[string]bool)
	for pid := range childrenOf {
		if isChild[pid] {
			continue
		}
		parent := noteByID[pid]
		color := parent.Color
		group := NavGroup{
			Name:     parent.Name,
			Color:    color,
			Notes:    []Note{parent},
			Children: buildChildTree(pid, color, childrenOf, map[string]bool{}),
		}
		groups = append(groups, group)
		var mark func(string)
		mark = func(id string) {
			if inTree[id] {
				return
			}
			inTree[id] = true
			for _, k := range childrenOf[id] {
				mark(k.ID)
			}
		}
		mark(pid)
	}

	// Step 3: Flat tag groups for tags that don't match any page.
	flatGroups := make(map[string][]Note)
	flatLabel := make(map[string]string)
	for _, n := range notes {
		if inTree[n.ID] {
			continue
		}
		for _, tag := range n.Tags {
			if skipTags[strings.ToLower(tag)] || tagToID(tag) == n.ID {
				continue
			}
			tid := tagToID(tag)
			if _, isPage := noteByID[tid]; isPage {
				continue
			}
			flatGroups[tid] = append(flatGroups[tid], n)
			if _, ok := flatLabel[tid]; !ok {
				flatLabel[tid] = tag
			}
		}
	}

	placed := make(map[string]bool)
	for tid, gNotes := range flatGroups {
		seen := make(map[string]bool)
		var deduped []Note
		for _, n := range gNotes {
			if !seen[n.ID] {
				seen[n.ID] = true
				deduped = append(deduped, n)
			}
		}
		sort.Slice(deduped, func(i, j int) bool { return deduped[i].Name < deduped[j].Name })
		groups = append(groups, NavGroup{
			Name:  flatLabel[tid],
			Notes: deduped,
		})
		for _, n := range deduped {
			placed[n.ID] = true
		}
	}

	// Step 4: Uncategorized.
	for _, n := range notes {
		if !inTree[n.ID] && !placed[n.ID] {
			uncategorized = append(uncategorized, n)
		}
	}

	// Step 5: Sort groups.
	sort.Slice(groups, func(i, j int) bool {
		si, sj := 0, 0
		if len(groups[i].Notes) > 0 {
			si = groups[i].Notes[0].Sort
		}
		if len(groups[j].Notes) > 0 {
			sj = groups[j].Notes[0].Sort
		}
		if si > 0 && sj > 0 {
			return si < sj
		}
		if si > 0 {
			return true
		}
		if sj > 0 {
			return false
		}
		return strings.ToLower(groups[i].Name) < strings.ToLower(groups[j].Name)
	})
	sort.Slice(uncategorized, func(i, j int) bool { return uncategorized[i].Name < uncategorized[j].Name })

	return groups, uncategorized
}

// getDueTasks scans all notes for unchecked tasks with [due: YYYY-MM-DD] and
// returns them bucketed into overdue, today, and upcoming (next 7 days).
// buildColorMap returns a map of noteID -> resolved color (including inherited).
func (app *App) buildColorMap() map[string]string {
	groups, _ := app.buildNavGroups()
	colors := make(map[string]string)
	var walk func([]NavGroup)
	walk = func(gs []NavGroup) {
		for _, g := range gs {
			if g.Color != "" {
				colors[tagToID(g.Name)] = g.Color
			}
			walk(g.Children)
		}
	}
	walk(groups)
	return colors
}

func (app *App) getDueTasks() (overdue, upcoming []DueTask) {
	notes := app.getNotes()
	colorMap := app.buildColorMap()
	now := time.Now()
	todayDate := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, now.Location())
	cutoff := todayDate.AddDate(0, 0, 8) // 7 days out (exclusive)

	for _, n := range notes {
		content, err := app.readNote(n.ID)
		if err != nil {
			continue
		}
		_, _, _, _, body := parseFrontmatter(content)
		blocks := parseBlocks(body)

		for _, b := range blocks {
			if b.Type != "task" || b.Checked != 0 {
				continue
			}
			m := dueRegex.FindStringSubmatch(b.Raw)
			if m == nil {
				continue
			}
			dueDate, err := time.ParseInLocation("2006-01-02", m[1], now.Location())
			if err != nil {
				continue
			}
			if dueDate.After(cutoff) {
				continue
			}

			days := int(dueDate.Sub(todayDate).Hours() / 24)
			noteColor := n.Color
			if noteColor == "" {
				noteColor = colorMap[n.ID]
			}
			task := DueTask{
				NoteID:     n.ID,
				NoteName:   n.Name,
				NoteColor:  noteColor,
				Block:      b,
				HTML:       template.HTML(app.renderBlockHTML(n.ID, b)),
				DueDate:    dueDate,
				Recurrence: m[2],
				DaysAway:   days,
			}

			if days < 0 {
				overdue = append(overdue, task)
			} else {
				upcoming = append(upcoming, task)
			}
		}
	}

	sort.Slice(overdue, func(i, j int) bool { return overdue[i].DueDate.Before(overdue[j].DueDate) })
	sort.Slice(upcoming, func(i, j int) bool { return upcoming[i].DueDate.Before(upcoming[j].DueDate) })

	return overdue, upcoming
}

// --- Helpers ---

func toTitle(s string) string {
	return strings.ReplaceAll(s, "-", " ")
}

func isHTMX(r *http.Request) bool {
	return r.Header.Get("HX-Request") == "true"
}

// --- HTTP Handlers ---

func (app *App) handleIndex(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}

	notes := app.getNotes()
	sort.Slice(notes, func(i, j int) bool { return notes[i].ModTime.After(notes[j].ModTime) })

	recent := notes
	if len(recent) > 8 {
		recent = recent[:8]
	}

	overdue, upcoming := app.getDueTasks()

	data := map[string]any{
		"Overdue":  overdue,
		"Upcoming": upcoming,
		"Recent":   recent,
	}

	if isHTMX(r) {
		app.templates.ExecuteTemplate(w, "index.html", data)
	} else {
		app.templates.ExecuteTemplate(w, "layout.html", map[string]any{
			"Page":    "index",
			"Content": data,
		})
	}
}

func (app *App) handleNote(w http.ResponseWriter, r *http.Request) {
	id := strings.TrimPrefix(r.URL.Path, "/note/")
	if id == "" {
		http.NotFound(w, r)
		return
	}

	content, err := app.readNote(id)
	if err != nil {
		http.NotFound(w, r)
		return
	}

	fmID, tags, sortOrder, color, body := parseFrontmatter(content)
	if fmID == "" {
		fmID = id
	}
	_ = sortOrder
	if color == "" {
		color = app.buildColorMap()[id]
	}
	blocks := parseBlocks(body)

	// Render each block's HTML
	type RenderedBlock struct {
		Block
		HTML template.HTML
	}
	var rendered []RenderedBlock
	for _, b := range blocks {
		rendered = append(rendered, RenderedBlock{
			Block: b,
			HTML:  template.HTML(app.renderBlockHTML(id, b)),
		})
	}

	data := map[string]any{
		"ID":     id,
		"Name":   toTitle(fmID),
		"Tags":   tags,
		"Color":  color,
		"Blocks": rendered,
	}

	if isHTMX(r) {
		if tmplErr := app.templates.ExecuteTemplate(w, "note.html", data); tmplErr != nil {
			log.Printf("Template error for note %s: %v", id, tmplErr)
		}
	} else {
		if tmplErr := app.templates.ExecuteTemplate(w, "layout.html", map[string]any{
			"Page":    "note",
			"Content": data,
		}); tmplErr != nil {
			log.Printf("Template error for note %s: %v", id, tmplErr)
		}
	}
}

func (app *App) handleNav(w http.ResponseWriter, r *http.Request) {
	query := strings.ToLower(r.URL.Query().Get("q"))
	groups, uncategorized := app.buildNavGroups()

	// Filter if query present
	if query != "" {
		groups = filterNavGroups(groups, query)
		var filteredUncat []Note
		for _, n := range uncategorized {
			if strings.Contains(strings.ToLower(n.Name), query) {
				filteredUncat = append(filteredUncat, n)
			}
		}
		uncategorized = filteredUncat
	}

	data := map[string]any{
		"Groups":        groups,
		"Uncategorized": uncategorized,
		"Query":         r.URL.Query().Get("q"),
	}
	app.templates.ExecuteTemplate(w, "nav.html", data)
}

func filterNavGroups(groups []NavGroup, query string) []NavGroup {
	var result []NavGroup
	for _, g := range groups {
		nameMatch := strings.Contains(strings.ToLower(g.Name), query)
		filteredChildren := filterNavGroups(g.Children, query)
		if nameMatch || len(filteredChildren) > 0 {
			g.Children = filteredChildren
			result = append(result, g)
		}
	}
	return result
}

func (app *App) handleBlockEdit(w http.ResponseWriter, r *http.Request) {
	// GET /note/{id}/block/{n}/edit
	parts := strings.Split(r.URL.Path, "/")
	if len(parts) < 5 {
		http.NotFound(w, r)
		return
	}
	id := parts[2]
	blockIdx := 0
	fmt.Sscanf(parts[4], "%d", &blockIdx)

	content, err := app.readNote(id)
	if err != nil {
		http.NotFound(w, r)
		return
	}
	_, _, _, _, body := parseFrontmatter(content)
	blocks := parseBlocks(body)

	if blockIdx >= len(blocks) {
		http.NotFound(w, r)
		return
	}

	data := map[string]any{
		"NoteID": id,
		"Block":  blocks[blockIdx],
	}
	app.templates.ExecuteTemplate(w, "block-edit.html", data)
}

func (app *App) handleBlockView(w http.ResponseWriter, r *http.Request) {
	// GET /note/{id}/block/{n}
	parts := strings.Split(r.URL.Path, "/")
	if len(parts) < 5 {
		http.NotFound(w, r)
		return
	}
	id := parts[2]
	blockIdx := 0
	fmt.Sscanf(parts[4], "%d", &blockIdx)

	content, err := app.readNote(id)
	if err != nil {
		http.NotFound(w, r)
		return
	}
	_, _, _, _, body := parseFrontmatter(content)
	blocks := parseBlocks(body)

	if blockIdx >= len(blocks) {
		http.NotFound(w, r)
		return
	}

	b := blocks[blockIdx]
	data := map[string]any{
		"NoteID": id,
		"Block":  b,
		"HTML":   template.HTML(app.renderBlockHTML(id, b)),
	}
	app.templates.ExecuteTemplate(w, "block-view.html", data)
}

func (app *App) handleBlockSave(w http.ResponseWriter, r *http.Request) {
	// PUT /note/{id}/block/{n}
	parts := strings.Split(r.URL.Path, "/")
	if len(parts) < 5 {
		http.NotFound(w, r)
		return
	}
	id := parts[2]
	blockIdx := 0
	fmt.Sscanf(parts[4], "%d", &blockIdx)

	r.ParseForm()
	newRaw := r.FormValue("content")

	content, err := app.readNote(id)
	if err != nil {
		http.Error(w, "note not found", 404)
		return
	}
	fmID, tags, fmSort, fmColor, body := parseFrontmatter(content)
	blocks := parseBlocks(body)

	if blockIdx >= len(blocks) {
		http.Error(w, "block not found", 404)
		return
	}

	blocks[blockIdx].Raw = newRaw
	// Re-parse the block type
	if m := taskRegex.FindStringSubmatch(newRaw); m != nil {
		blocks[blockIdx].Type = "task"
		switch m[2] {
		case " ":
			blocks[blockIdx].Checked = 0
		case "x":
			blocks[blockIdx].Checked = 1
		case "-":
			blocks[blockIdx].Checked = 2
		}
	}

	newBody := blocksToMarkdown(blocks)
	if fmID == "" {
		fmID = id
	}
	fullContent := buildFrontmatter(fmID, tags, fmSort, fmColor) + "\n" + newBody
	if err := app.writeNote(id, fullContent); err != nil {
		http.Error(w, "write failed", 500)
		return
	}

	// Return the updated block view
	b := blocks[blockIdx]
	data := map[string]any{
		"NoteID": id,
		"Block":  b,
		"HTML":   template.HTML(app.renderBlockHTML(id, b)),
	}
	app.templates.ExecuteTemplate(w, "block-view.html", data)
}

func (app *App) handleBlockToggle(w http.ResponseWriter, r *http.Request) {
	// PUT /note/{id}/block/{n}/toggle
	parts := strings.Split(r.URL.Path, "/")
	if len(parts) < 6 {
		http.NotFound(w, r)
		return
	}
	id := parts[2]
	blockIdx := 0
	fmt.Sscanf(parts[4], "%d", &blockIdx)

	content, err := app.readNote(id)
	if err != nil {
		http.Error(w, "note not found", 404)
		return
	}
	fmID, tags, fmSort, fmColor, body := parseFrontmatter(content)
	blocks := parseBlocks(body)

	if blockIdx >= len(blocks) {
		http.Error(w, "block not found", 404)
		return
	}

	b := &blocks[blockIdx]
	if b.Type != "task" {
		http.Error(w, "not a task", 400)
		return
	}

	// Cycle: unchecked -> checked -> cancelled -> unchecked
	newState := " "
	switch b.Checked {
	case 0:
		newState = "x"
		b.Checked = 1
	case 1:
		newState = "-"
		b.Checked = 2
	case 2:
		newState = " "
		b.Checked = 0
	}
	b.Raw = taskRegex.ReplaceAllString(b.Raw, "${1}- ["+newState+"] ${3}")

	newBody := blocksToMarkdown(blocks)
	if fmID == "" {
		fmID = id
	}
	fullContent := buildFrontmatter(fmID, tags, fmSort, fmColor) + "\n" + newBody
	if err := app.writeNote(id, fullContent); err != nil {
		http.Error(w, "write failed", 500)
		return
	}

	data := map[string]any{
		"NoteID": id,
		"Block":  *b,
		"HTML":   template.HTML(app.renderBlockHTML(id, *b)),
	}
	app.templates.ExecuteTemplate(w, "block-view.html", data)
}

func (app *App) handleBlockMove(w http.ResponseWriter, r *http.Request) {
	// POST /note/{id}/block/{n}/move?dir=up|down
	parts := strings.Split(r.URL.Path, "/")
	if len(parts) < 6 {
		http.NotFound(w, r)
		return
	}
	id := parts[2]
	blockIdx := 0
	fmt.Sscanf(parts[4], "%d", &blockIdx)
	dir := r.URL.Query().Get("dir")

	content, err := app.readNote(id)
	if err != nil {
		http.Error(w, "note not found", 404)
		return
	}
	fmID, tags, fmSort, fmColor, body := parseFrontmatter(content)
	blocks := parseBlocks(body)

	if blockIdx >= len(blocks) {
		http.Error(w, "block not found", 404)
		return
	}

	// Swap blocks
	swapIdx := blockIdx
	if dir == "up" && blockIdx > 0 {
		swapIdx = blockIdx - 1
	} else if dir == "down" && blockIdx < len(blocks)-1 {
		swapIdx = blockIdx + 1
	}

	if swapIdx != blockIdx {
		blocks[blockIdx], blocks[swapIdx] = blocks[swapIdx], blocks[blockIdx]
		blocks[blockIdx].Index = blockIdx
		blocks[swapIdx].Index = swapIdx
	}

	newBody := blocksToMarkdown(blocks)
	if fmID == "" {
		fmID = id
	}
	fullContent := buildFrontmatter(fmID, tags, fmSort, fmColor) + "\n" + newBody
	if err := app.writeNote(id, fullContent); err != nil {
		http.Error(w, "write failed", 500)
		return
	}

	// Re-render all blocks for this note
	app.handleNote(w, r)
}

func (app *App) handleBlockReorder(w http.ResponseWriter, r *http.Request) {
	// POST /note/{id}/reorder  body: {"order": [3, 0, 1, 2]}
	parts := strings.Split(r.URL.Path, "/")
	if len(parts) < 3 {
		http.NotFound(w, r)
		return
	}
	id := parts[2]

	var payload struct {
		Order []int `json:"order"`
	}
	if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
		http.Error(w, "bad request", 400)
		return
	}

	content, err := app.readNote(id)
	if err != nil {
		http.Error(w, "note not found", 404)
		return
	}
	fmID, tags, fmSort, fmColor, body := parseFrontmatter(content)
	blocks := parseBlocks(body)

	if len(payload.Order) != len(blocks) {
		http.Error(w, "order length mismatch", 400)
		return
	}

	// Validate indices
	seen := make(map[int]bool)
	for _, idx := range payload.Order {
		if idx < 0 || idx >= len(blocks) || seen[idx] {
			http.Error(w, "invalid order", 400)
			return
		}
		seen[idx] = true
	}

	// Reorder blocks
	reordered := make([]Block, len(blocks))
	for newIdx, oldIdx := range payload.Order {
		reordered[newIdx] = blocks[oldIdx]
		reordered[newIdx].Index = newIdx
	}

	newBody := blocksToMarkdown(reordered)
	if fmID == "" {
		fmID = id
	}
	fullContent := buildFrontmatter(fmID, tags, fmSort, fmColor) + "\n" + newBody
	if err := app.writeNote(id, fullContent); err != nil {
		http.Error(w, "write failed", 500)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

func (app *App) handleBlockAdd(w http.ResponseWriter, r *http.Request) {
	// POST /note/{id}/block?type=task|text
	parts := strings.Split(r.URL.Path, "/")
	if len(parts) < 4 {
		http.NotFound(w, r)
		return
	}
	id := parts[2]
	blockType := r.URL.Query().Get("type")

	content, err := app.readNote(id)
	if err != nil {
		http.Error(w, "note not found", 404)
		return
	}
	fmID, tags, fmSort, fmColor, body := parseFrontmatter(content)

	newLine := ""
	switch blockType {
	case "task":
		newLine = "- [ ] "
	case "text":
		newLine = ""
	default:
		newLine = "- [ ] "
	}

	// Append to body
	body = strings.TrimRight(body, "\n") + "\n" + newLine + "\n"

	if fmID == "" {
		fmID = id
	}
	fullContent := buildFrontmatter(fmID, tags, fmSort, fmColor) + "\n" + body
	if err := app.writeNote(id, fullContent); err != nil {
		http.Error(w, "write failed", 500)
		return
	}

	// Re-render the note — the new block will be in edit mode
	blocks := parseBlocks(body)
	lastIdx := len(blocks) - 1
	data := map[string]any{
		"NoteID": id,
		"Block":  blocks[lastIdx],
	}
	app.templates.ExecuteTemplate(w, "block-edit.html", data)
}

func (app *App) handleNewNote(w http.ResponseWriter, r *http.Request) {
	// POST /notes — create a new note
	r.ParseForm()
	name := r.FormValue("name")
	if name == "" {
		http.Error(w, "name required", 400)
		return
	}

	// Kebab-case the name
	id := strings.ToLower(name)
	id = strings.ReplaceAll(id, " ", "-")
	id = regexp.MustCompile(`[^a-z0-9-]`).ReplaceAllString(id, "")

	// Check if exists
	path := filepath.Join(app.notesDir, id+".md")
	if _, err := os.Stat(path); err == nil {
		// Already exists, redirect to it
		w.Header().Set("HX-Redirect", "/note/"+id)
		w.WriteHeader(200)
		return
	}

	content := buildFrontmatter(id, []string{}, 0, "") + "\n# " + name + "\n"
	if err := os.WriteFile(path, []byte(content), 0644); err != nil {
		http.Error(w, "write failed", 500)
		return
	}
	app.refreshNotes()

	w.Header().Set("HX-Redirect", "/note/"+id)
	w.WriteHeader(200)
}

func (app *App) handleQuickTask(w http.ResponseWriter, r *http.Request) {
	// POST /task — add a task to a note from the home page
	r.ParseForm()
	noteName := strings.TrimSpace(r.FormValue("note"))
	taskContent := strings.TrimSpace(r.FormValue("content"))
	dueDate := strings.TrimSpace(r.FormValue("due"))

	if noteName == "" || taskContent == "" {
		http.Error(w, "note and content required", 400)
		return
	}

	// Resolve note name to ID (try as-is first, then kebab-case)
	id := noteName
	content, err := app.readNote(id)
	if err != nil {
		id = strings.ToLower(strings.ReplaceAll(noteName, " ", "-"))
		content, err = app.readNote(id)
		if err != nil {
			http.Error(w, "note not found: "+noteName, 404)
			return
		}
	}

	fmID, tags, fmSort, fmColor, body := parseFrontmatter(content)

	// Build the task line
	taskLine := "- [ ] " + taskContent
	if dueDate != "" {
		taskLine += " [due: " + dueDate + "]"
	}

	body = strings.TrimRight(body, "\n") + "\n" + taskLine + "\n"

	if fmID == "" {
		fmID = id
	}
	fullContent := buildFrontmatter(fmID, tags, fmSort, fmColor) + "\n" + body
	if err := app.writeNote(id, fullContent); err != nil {
		http.Error(w, "write failed", 500)
		return
	}

	// Re-render the index content
	r.URL.Path = "/"
	app.handleIndex(w, r)
}

func (app *App) handleNotesAPI(w http.ResponseWriter, r *http.Request) {
	notes := app.getNotes()
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(notes)
}

func (app *App) handleTagAdd(w http.ResponseWriter, r *http.Request) {
	// POST /note/{id}/tags?add=tagname
	parts := strings.Split(r.URL.Path, "/")
	if len(parts) < 4 {
		http.NotFound(w, r)
		return
	}
	id := parts[2]
	r.ParseForm()
	newTag := strings.TrimSpace(r.FormValue("add"))
	if newTag == "" {
		http.Error(w, "tag required", 400)
		return
	}

	content, err := app.readNote(id)
	if err != nil {
		http.Error(w, "note not found", 404)
		return
	}
	fmID, tags, fmSort, fmColor, body := parseFrontmatter(content)
	if fmID == "" {
		fmID = id
	}

	// Don't add duplicates
	for _, t := range tags {
		if strings.ToLower(t) == strings.ToLower(newTag) {
			// Already exists, just re-render
			app.renderTagEditor(w, id, tags)
			return
		}
	}
	tags = append(tags, newTag)

	fullContent := buildFrontmatter(fmID, tags, fmSort, fmColor) + "\n" + body
	if err := app.writeNote(id, fullContent); err != nil {
		http.Error(w, "write failed", 500)
		return
	}
	app.renderTagEditor(w, id, tags)
}

func (app *App) handleTagRemove(w http.ResponseWriter, r *http.Request) {
	// DELETE /note/{id}/tags?remove=tagname
	parts := strings.Split(r.URL.Path, "/")
	if len(parts) < 4 {
		http.NotFound(w, r)
		return
	}
	id := parts[2]
	removeTag := r.URL.Query().Get("remove")
	if removeTag == "" {
		http.Error(w, "tag required", 400)
		return
	}

	content, err := app.readNote(id)
	if err != nil {
		http.Error(w, "note not found", 404)
		return
	}
	fmID, tags, fmSort, fmColor, body := parseFrontmatter(content)
	if fmID == "" {
		fmID = id
	}

	// Remove the tag
	var newTags []string
	for _, t := range tags {
		if t != removeTag {
			newTags = append(newTags, t)
		}
	}

	fullContent := buildFrontmatter(fmID, newTags, fmSort, fmColor) + "\n" + body
	if err := app.writeNote(id, fullContent); err != nil {
		http.Error(w, "write failed", 500)
		return
	}
	app.renderTagEditor(w, id, newTags)
}

func (app *App) renderTagEditor(w http.ResponseWriter, id string, tags []string) {
	data := map[string]any{
		"ID":   id,
		"Tags": tags,
	}
	app.templates.ExecuteTemplate(w, "tags-edit.html", data)
}

// --- Router ---

func (app *App) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	path := r.URL.Path

	switch {
	case path == "/" && r.Method == "GET":
		app.handleIndex(w, r)
	case path == "/nav" && r.Method == "GET":
		app.handleNav(w, r)
	case path == "/task" && r.Method == "POST":
		app.handleQuickTask(w, r)
	case strings.HasPrefix(path, "/note/") && strings.HasSuffix(path, "/tags"):
		switch r.Method {
		case "POST":
			app.handleTagAdd(w, r)
		case "DELETE":
			app.handleTagRemove(w, r)
		default:
			http.Error(w, "method not allowed", 405)
		}
	case strings.HasPrefix(path, "/note/") && strings.HasSuffix(path, "/edit") && r.Method == "GET":
		app.handleBlockEdit(w, r)
	case strings.HasPrefix(path, "/note/") && strings.HasSuffix(path, "/toggle") && r.Method == "PUT":
		app.handleBlockToggle(w, r)
	case strings.HasPrefix(path, "/note/") && strings.HasSuffix(path, "/reorder") && r.Method == "POST":
		app.handleBlockReorder(w, r)
	case strings.HasPrefix(path, "/note/") && strings.HasSuffix(path, "/move") && r.Method == "POST":
		app.handleBlockMove(w, r)
	case strings.HasPrefix(path, "/note/") && strings.Contains(path, "/block") && !strings.Contains(path, "/edit") && !strings.Contains(path, "/toggle") && !strings.Contains(path, "/move"):
		switch r.Method {
		case "GET":
			app.handleBlockView(w, r)
		case "PUT":
			app.handleBlockSave(w, r)
		case "POST":
			app.handleBlockAdd(w, r)
		default:
			http.Error(w, "method not allowed", 405)
		}
	case strings.HasPrefix(path, "/note/") && r.Method == "GET":
		app.handleNote(w, r)
	case path == "/notes" && r.Method == "POST":
		app.handleNewNote(w, r)
	case path == "/api/notes" && r.Method == "GET":
		app.handleNotesAPI(w, r)
	case strings.HasPrefix(path, "/static/"):
		http.FileServer(http.FS(staticFS)).ServeHTTP(w, r)
	default:
		http.NotFound(w, r)
	}
}

func main() {
	if len(os.Args) < 2 {
		log.Fatal("Usage: notes-app <notes-directory>")
	}
	notesDir := os.Args[1]

	info, err := os.Stat(notesDir)
	if err != nil || !info.IsDir() {
		log.Fatalf("Notes directory does not exist: %s", notesDir)
	}

	addr := "127.0.0.1:3002"
	if envAddr := os.Getenv("LISTEN_ADDR"); envAddr != "" {
		addr = envAddr
	}

	app := NewApp(notesDir)

	// Background refresh: pick up filesystem changes (nvim edits) every 5 seconds
	go func() {
		for {
			time.Sleep(5 * time.Second)
			app.refreshNotes()
		}
	}()

	log.Printf("notes-app serving %s on %s", notesDir, addr)
	log.Fatal(http.ListenAndServe(addr, app))
}
