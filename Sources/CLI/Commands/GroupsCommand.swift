import ArgumentParser
import Foundation
import Core

public struct GroupsCommand: AsyncParsableCommand {
    public init() {}
    public static let configuration = CommandConfiguration(
        commandName: "groups",
        abstract: "Manage contact groups",
        subcommands: [
            ListGroups.self,
            GetGroupMembers.self,
        ],
        defaultSubcommand: ListGroups.self
    )
}

public struct ListGroups: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List all groups"
    )

    @Flag(name: .long, help: "Output as JSON")
    var json: Bool = false

    public init() {}

    public func run() async throws {
        let service = ContactsService.shared
        let groups = try await service.listGroups()

        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(groups)
            print(String(data: data, encoding: .utf8)!)
        } else {
            if groups.isEmpty {
                print("No groups found")
            } else {
                print("Found \(groups.count) group(s):\n")
                for group in groups {
                    print("[\(group.id)]")
                    print("  Name: \(group.name)")
                    print("  Members: \(group.memberCount)")
                    print()
                }
            }
        }
    }
}

public struct GetGroupMembers: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "members",
        abstract: "Get members of a group"
    )

    @Argument(help: "Group name")
    var name: String

    @Flag(name: .long, help: "Output as JSON")
    var json: Bool = false

    public init() {}

    public func run() async throws {
        let service = ContactsService.shared
        let contacts = try await service.getGroupMembers(groupName: name)

        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(contacts)
            print(String(data: data, encoding: .utf8)!)
        } else {
            if contacts.isEmpty {
                print("No contacts in group '\(name)' (or group not found)")
            } else {
                print("Found \(contacts.count) member(s) in '\(name)':\n")
                for contact in contacts {
                    print("  - \(contact.fullName)")
                    if !contact.emails.isEmpty {
                        print("    Email: \(contact.emails.first!)")
                    }
                    if !contact.phones.isEmpty {
                        print("    Phone: \(contact.phones.first!)")
                    }
                }
            }
        }
    }
}
