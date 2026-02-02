# Contactbook 📇 — Apple Contacts CLI + MCP server

[![Swift 6.0](https://img.shields.io/badge/Swift-6.0-F05138?logo=swift&logoColor=white&style=flat-square)](https://swift.org/)
[![macOS 13+](https://img.shields.io/badge/macOS-13+-0078d7?logo=apple&logoColor=white&style=flat-square)](https://www.apple.com/macos/)
[![License: MIT](https://img.shields.io/badge/License-MIT-ffd60a?style=flat-square)](https://opensource.org/licenses/MIT)
[![MCP Server](https://img.shields.io/badge/MCP-Server-2ea44f?style=flat-square)](https://modelcontextprotocol.io/)

Contactbook brings Apple Contacts automation to macOS through a Swift CLI and MCP server. List, search, create, update, and delete contacts — from the terminal or any MCP client.

## What you get

| Feature | Description |
|---------|-------------|
| **List Contacts** | Browse all contacts with optional limit |
| **Search Contacts** | Find by name, email, phone, or organization |
| **Get Contact** | Retrieve full contact details by ID |
| **Create Contact** | Add new contacts with all fields |
| **Update Contact** | Modify existing contact properties |
| **Delete Contact** | Remove contacts (with confirmation) |
| **Groups** | List groups and group members |
| **Lookup** | Quick lookup by name or identifier |
| **MCP Server** | All features exposed as MCP tools for AI agents |

## Install

```bash
# Clone and build
git clone https://github.com/RyanLisse/Contactbook.git
cd Contactbook
swift build -c release

# Install to PATH
cp .build/release/contactbook /usr/local/bin/contactbook
```

## Quick start

```bash
# List contacts
contactbook contacts list --limit 10

# Search contacts
contactbook contacts search "John"

# Get contact by ID
contactbook contacts get <contact-id> --json

# Create a contact
contactbook contacts create \
  --firstName "John" \
  --lastName "Doe" \
  --email "john@example.com" \
  --phone "+1234567890"

# Update a contact
contactbook contacts update <contact-id> --jobTitle "Engineer"

# Delete a contact
contactbook contacts delete <contact-id> --force

# List groups
contactbook groups list

# Quick lookup
contactbook lookup "John Doe"
```

## Permissions

```bash
contactbook status               # check permission status
contactbook authorize            # request permissions
```

## Output formats

- `--json` emits JSON arrays/objects
- `--plain` emits tab-separated lines
- `--quiet` emits counts only

| Command | Key flags | What it does |
|---------|-----------|--------------|
| `contacts list` | `--limit`, `--json` | List all contacts |
| `contacts search` | `<query>`, `--json` | Search contacts |
| `contacts get` | `<id>`, `--json` | Get contact by ID |
| `contacts create` | `--firstName`, `--lastName`, etc. | Create new contact |
| `contacts update` | `<id>`, field options | Update contact |
| `contacts delete` | `<id>`, `--force` | Delete contact |
| `groups list` | `--json` | List all groups |
| `groups members` | `<group-id>` | List group members |
| `lookup` | `<query>` | Quick name/ID lookup |
| `mcp serve` | - | Start MCP server |

## MCP Server

Start the MCP server for AI agent integration:

```bash
contactbook mcp serve
```

### MCP Tools

| Tool | Description |
|------|-------------|
| `contacts_list` | List all contacts |
| `contacts_search` | Search contacts by query |
| `contacts_get` | Get contact by ID |
| `contacts_create` | Create new contact |
| `contacts_update` | Update existing contact |
| `contacts_delete` | Delete contact |
| `groups_list` | List all groups |
| `groups_members` | Get group members |

### Claude Desktop Config

```json
{
  "mcpServers": {
    "contactbook": {
      "command": "/usr/local/bin/contactbook",
      "args": ["mcp", "serve"]
    }
  }
}
```

## Architecture

Follows the [Peekaboo](https://github.com/steipete/Peekaboo) architecture standard:

```
Sources/
├── Core/           # ContactbookCore - framework-agnostic library
│   ├── Models/     # Contact, ContactGroup models
│   ├── Services/   # ContactsService (Contacts framework wrapper)
│   └── Errors/     # ContactsError
├── CLI/            # ContactbookCLI - ArgumentParser commands
│   └── Commands/   # Contacts, Groups, Lookup, MCP commands
├── MCP/            # ContactbookMCP - MCP server with handler pattern
│   └── Handlers/   # ToolHandler
└── Executable/     # Main entry point
```

## Requirements

- **macOS 13+** (Ventura or later)
- **Swift 6.0+** toolchain
- **Contacts permissions** (prompted on first run)

## Development

```bash
# Build
swift build

# Run CLI
swift run contactbook --help

# Test
swift test
```

### Swift 6 Settings

All targets use strict concurrency:

```swift
.enableExperimentalFeature("StrictConcurrency")
.enableUpcomingFeature("ExistentialAny")
.enableUpcomingFeature("NonisolatedNonsendingByDefault")
```

## Known Issues

- **Signing required for full performance**: Without a paid Apple Developer account, the Contacts framework falls back to AppleScript which is slow for large contact lists (4500+ contacts = timeout)
- First run triggers macOS Contacts permission prompts

## License

MIT
