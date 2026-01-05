import ArgumentParser
import Foundation

struct GroupsCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "groups",
        abstract: "Manage contact groups",
        subcommands: [
            ListGroups.self,
            GetGroupMembers.self,
        ],
        defaultSubcommand: ListGroups.self
    )
}

struct ListGroups: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List all groups"
    )
    
    @Flag(name: .long, help: "Output as JSON")
    var json: Bool = false
    
    func run() async throws {
        let groups = try await ContactsService.shared.listGroups()
        
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

struct GetGroupMembers: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "members",
        abstract: "Get members of a group"
    )
    
    @Argument(help: "Group name")
    var name: String
    
    @Flag(name: .long, help: "Output as JSON")
    var json: Bool = false
    
    func run() async throws {
        let contacts = try await ContactsService.shared.getGroupMembers(groupName: name)
        
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
