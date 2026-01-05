import ArgumentParser

public struct Contactbook: AsyncParsableCommand {
    public init() {}
    
    public static let configuration = CommandConfiguration(
        commandName: "contactbook",
        abstract: "Apple Contacts CLI and MCP server",
        version: "1.0.0",
        subcommands: [
            ContactsCommand.self,
            GroupsCommand.self,
            MCPCommand.self,
        ],
        defaultSubcommand: ContactsCommand.self
    )
}
