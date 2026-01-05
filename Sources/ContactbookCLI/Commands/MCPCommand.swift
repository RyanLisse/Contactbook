import ArgumentParser
import Foundation

struct MCPCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "mcp",
        abstract: "MCP server operations",
        subcommands: [
            ServeMCP.self,
            ListMCPTools.self,
        ],
        defaultSubcommand: ServeMCP.self
    )
}

struct ServeMCP: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "serve",
        abstract: "Start the MCP server"
    )
    
    func run() async throws {
        let server = ContactbookMCPServer()
        try await server.run()
    }
}

struct ListMCPTools: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "tools",
        abstract: "List available MCP tools"
    )
    
    func run() async throws {
        let tools = [
            ("contacts_list", "List all contacts with optional limit"),
            ("contacts_search", "Search contacts by name, email, phone, or organization"),
            ("contacts_get", "Get a specific contact by ID"),
            ("contacts_create", "Create a new contact"),
            ("contacts_update", "Update an existing contact"),
            ("contacts_delete", "Delete a contact"),
            ("groups_list", "List all contact groups"),
            ("groups_members", "Get members of a specific group"),
        ]
        
        print("Available MCP Tools:\n")
        for (name, description) in tools {
            print("  \(name)")
            print("    \(description)\n")
        }
    }
}
