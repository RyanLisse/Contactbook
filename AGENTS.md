# Repository Guidelines

## Start Here
- Read `~/Developer/agent-scripts/{AGENTS.MD,tools.md}` before making changes (skip if missing).
- This repo follows the Peekaboo architecture pattern.

## Project Structure & Modules
- `Sources/Core/` contains the framework-agnostic `ContactbookCore` library (Contacts framework integration, models, services).
- `Sources/CLI/` contains the Swift CLI using ArgumentParser.
- `Sources/MCP/` contains the MCP server with handler pattern.
- `Sources/Executable/` is the main entry point.

## Build, Test, and Development Commands
- Build: `swift build` (debug) or `swift build -c release` (release)
- Run CLI: `swift run contactbook --help`
- Test: `swift test`
- MCP server: `swift run contactbook mcp serve`

## Coding Style & Naming Conventions
- Swift 6.0, 4-space indent, 120-column wrap
- Strict concurrency enabled across all targets
- Prefer small scoped extensions over large files
- Actor-based services where needed

## Swift 6 Settings
All targets use:
```swift
.enableExperimentalFeature("StrictConcurrency")
.enableUpcomingFeature("ExistentialAny")
.enableUpcomingFeature("NonisolatedNonsendingByDefault")
```

## Architecture Patterns
- **Core library**: Framework-agnostic, no CLI dependencies
- **Handler pattern**: Separate handlers for MCP tools
- **Service pattern**: ContactsService wraps Contacts framework
- **Error handling**: Custom ContactsError enum

## Reference Patterns
- Peekaboo: `/Volumes/Main SSD/Developer/Peekaboo/`
- Quorum: `/Users/shelton/Developer/Quorum/`
- Caly: `/Volumes/Main SSD/Developer/Caly/`
- Handler pattern skill: `/Users/shelton/clawd/skills/handler-pattern/SKILL.md`

## Testing Guidelines
- Add tests in `Tests/` directory
- Use XCTest with async/await
- Mock Contacts framework where possible

## Commit & Pull Request Guidelines
- Conventional Commits (`feat|fix|chore|docs|test|refactor`)
- Scope optional: `feat(cli): add bulk delete`
- PRs should summarize intent and list test commands

## Security & Configuration
- Never commit credentials
- Contacts permissions managed by macOS
- Respect user contact privacy

## Known Issues
- Without paid Apple Developer account, falls back to AppleScript (slow for large contact lists)
