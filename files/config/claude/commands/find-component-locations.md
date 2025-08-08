# Find Component Locations

This custom command analyzes modified React components in your git branch and traces their exact locations in the component tree, including routes and render conditions.

## Usage

```bash
# Run this command from your project root
claude-code --file find-component-locations.md
```

## What This Command Does

1. **Identifies Modified Components**: Analyzes git diff to find all changed React components (.tsx, .jsx files)
2. **Traces Component Usage**: Crawls the codebase to find where each modified component is imported and used
3. **Maps Render Paths**: Follows the component tree from entry points (routes) to the modified components
4. **Detects Conditions**: Identifies feature toggles, conditional rendering, and special requirements
5. **Provides Navigation Instructions**: Gives specific steps to locate and view each component

## Implementation Steps

### Step 1: Analyze Git Changes
```bash
# Get modified React component files
git diff --name-only HEAD~1 --diff-filter=M | grep -E '\.(tsx|jsx)$'
```

### Step 2: Find Component Imports
For each modified component file:
1. Extract the component name(s) from the file
2. Search codebase for import statements referencing these components
3. Build dependency graph of where components are used

### Step 3: Trace to Entry Points
1. Start from route definitions (usually in routing files)
2. Follow component hierarchy upward from modified components
3. Map the complete path from route → ... → modified component

### Step 4: Analyze Render Conditions
1. Check for feature flags/toggles around component usage
2. Identify conditional rendering (if statements, ternary operators)
3. Note any props or state requirements
4. Document authentication or permission requirements

### Step 5: Generate Location Report
Create a structured report for each modified component:

```
Component: ComponentName
File: path/to/component.tsx
Route: /specific/route/path
Component Path: RouteComponent > LayoutComponent > ContainerComponent > ComponentName
Conditions:
  - Feature Flag: FEATURE_XYZ must be enabled
  - User Role: Admin access required
  - State: Must have data.isLoaded === true
Navigation Steps:
  1. Navigate to /specific/route/path
  2. Ensure FEATURE_XYZ flag is enabled
  3. Login as admin user
  4. Component will render in the main content area
```

## Command Implementation

This command should:

1. **Parse Git Changes**
   - Use `git diff` to identify modified files
   - Filter for React component files
   - Extract component names from exports

2. **Build Import Graph**
   - Search for import statements using grep/ripgrep
   - Follow import chains recursively
   - Identify dead code (imported but never rendered)

3. **Trace Routes**
   - Find routing configuration files
   - Map routes to root components
   - Follow component tree downward

4. **Analyze Conditionals**
   - Search for feature flag usage around components
   - Identify conditional rendering patterns
   - Note authentication/authorization checks

5. **Generate Report**
   - Provide clear navigation instructions
   - Include all necessary conditions
   - Highlight any blockers or special requirements

## Example Output

```
Modified Components Analysis
===========================

1. UserProfileCard
   File: src/components/UserProfileCard.tsx
   Route: /users/{userId}
   Component Path: UserDetailPage > UserProfileSection > UserProfileCard
   Conditions:
     - User must be authenticated
     - Profile must be public OR viewer must be friend/admin
   Navigation:
     1. Login to application
     2. Navigate to /users/123 (any valid user ID)
     3. Component renders in the profile section

2. SettingsToggle
   File: src/components/SettingsToggle.tsx
   Route: /settings/preferences
   Component Path: SettingsPage > PreferencesTab > SettingsToggle
   Conditions:
     - Feature flag: ADVANCED_SETTINGS must be enabled
     - User role: Premium subscriber or admin
   Navigation:
     1. Login as premium user
     2. Enable ADVANCED_SETTINGS feature flag
     3. Navigate to /settings/preferences
     4. Component renders in preferences tab

3. DeadComponent
   File: src/components/DeadComponent.tsx
   Status: DEAD CODE - Imported but never rendered
   Found in: src/unused/OldContainer.tsx (not in component tree)
```

## Technical Notes

- Uses TypeScript/JavaScript AST parsing when possible for accuracy
- Handles dynamic imports and lazy loading
- Accounts for higher-order components and render props
- Identifies components wrapped in feature flag providers
- Detects route-level guards and authentication requirements

## Limitations

- May not detect runtime-only conditional rendering
- Complex state-dependent conditions might require manual verification
- Dynamic route parameters need manual substitution
- Some micro-frontend architectures may require additional analysis