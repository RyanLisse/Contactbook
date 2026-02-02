import ArgumentParser
import Core

public struct contactbook: AsyncParsableCommand {
    public init() {}

    public static let configuration = CommandConfiguration(
        commandName: "contactbook",
        abstract: "Apple Contacts CLI and MCP server",
        version: "1.0.0",
        subcommands: [
            StatusCommand.self,
            AuthorizeCommand.self,
            ContactsCommand.self,
            GroupsCommand.self,
            MCPCommand.self,
            LookupCommand.self,
        ],
        defaultSubcommand: ContactsCommand.self
    )
}
