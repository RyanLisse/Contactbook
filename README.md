# Contactbook

![Contactbook Logo](assets/logo.svg)

Contactbook - your contacts, at your command

Contactbook is a macOS command-line interface (CLI) and Model Context Protocol (MCP) server for Apple Contacts. It allows you to manage your contacts directly from the terminal or through AI agents.

## Requirements

- macOS 26+ (Tahoe)
- Swift 6.2+

## Installation

### From Source

Clone the repository and build using Swift Package Manager:

```bash
git clone https://github.com/RyanLisse/Contactbook.git
cd Contactbook
swift build -c release
```

The binary will be available at `.build/release/contactbook`. You can move it to your PATH:

```bash
cp .build/release/contactbook /usr/local/bin/
```

## CLI Usage

### List Contacts

```bash
contactbook contacts list --limit 10
```

### Search Contacts

```bash
contactbook contacts search "John"
```

### Get Contact by ID

```bash
contactbook contacts get "UUID:ABPerson"
```

### Create a Contact

```bash
contactbook contacts create --first "John" --last "Doe" --phone "+1234567890" --email "john@example.com" --org "Acme Inc"
```

### Update a Contact

```bash
contactbook contacts update "UUID:ABPerson" --phone "+0987654321"
```

### Delete a Contact

```bash
contactbook contacts delete "UUID:ABPerson"
```

### List Groups

```bash
contactbook groups list
```

### Get Group Members

```bash
contactbook groups members "Family"
```

## MCP Server Setup

Contactbook can run as an MCP server, enabling AI agents (like Claude Desktop) to interact with your Apple Contacts.

### Configuration for Claude Desktop

Add the following to your `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "contactbook": {
      "command": "contactbook",
      "args": ["mcp", "serve"]
    }
  }
}
```

### Available MCP Tools

The server exposes 8 tools for managing contacts:

1. **contacts_list**: List contacts with optional limit. Optional: `limit` (int, default 50).
2. **contacts_get**: Get a contact by ID. Required: `id` (string).
3. **contacts_search**: Search contacts by name, email, phone, or organization. Required: `query` (string).
4. **contacts_create**: Create a new contact. Optional: `first_name`, `last_name`, `phone`, `email`, `organization` (all strings).
5. **contacts_update**: Update an existing contact. Required: `id` (string). Optional: `first_name`, `last_name`, `phone`, `email`, `organization`.
6. **contacts_delete**: Delete a contact by ID. Required: `id` (string).
7. **groups_list**: List all contact groups with member counts.
8. **groups_members**: Get members of a specific group. Required: `group_name` (string).

## Performance Notes

- Default contact limit is 50 to handle large contact databases efficiently
- Uses AppleScript with optimized JSON output for fast querying
- Contact IDs are in the format `UUID:ABPerson`

## License

This project is licensed under the MIT License.
