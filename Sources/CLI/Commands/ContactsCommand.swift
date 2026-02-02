import ArgumentParser
import Foundation
import Core

public struct ContactsCommand: AsyncParsableCommand {
    public init() {}
    public static let configuration = CommandConfiguration(
        commandName: "contacts",
        abstract: "Manage contacts",
        subcommands: [
            ListContacts.self,
            SearchContacts.self,
            GetContact.self,
            CreateContact.self,
            UpdateContact.self,
            DeleteContact.self,
        ],
        defaultSubcommand: ListContacts.self
    )
}

public struct ListContacts: AsyncParsableCommand {
    public init() {}
    public static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List all contacts"
    )

    @Option(name: .shortAndLong, help: "Maximum number of contacts to return")
    var limit: Int?

    @Flag(name: .long, help: "Output as JSON")
    var json: Bool = false

    @Flag(name: .long, help: "Output as plain text (tab-separated)")
    var plain: Bool = false

    @Flag(name: .long, help: "Output count only")
    var quiet: Bool = false

    public func run() async throws {
        let service = ContactsService.shared
        let contacts = try await service.listContacts(limit: limit)

        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(contacts)
            print(String(data: data, encoding: .utf8)!)
        } else if quiet {
            print(contacts.count)
        } else if plain {
            for contact in contacts {
                let phones = contact.phones.joined(separator: ";")
                let emails = contact.emails.joined(separator: ";")
                print("\(contact.id)\t\(contact.fullName)\t\(phones)\t\(emails)")
            }
        } else {
            if contacts.isEmpty {
                print("No contacts found")
            } else {
                print("Found \(contacts.count) contact(s):\n")
                for contact in contacts {
                    printContact(contact)
                }
            }
        }
    }
}

public struct SearchContacts: AsyncParsableCommand {
    public init() {}
    public static let configuration = CommandConfiguration(
        commandName: "search",
        abstract: "Search contacts by name, email, phone, or organization"
    )

    @Argument(help: "Search query")
    var query: String

    @Flag(name: .long, help: "Output as JSON")
    var json: Bool = false

    @Flag(name: .long, help: "Output as plain text (tab-separated)")
    var plain: Bool = false

    @Flag(name: .long, help: "Output count only")
    var quiet: Bool = false

    public func run() async throws {
        let service = ContactsService.shared
        let contacts = try await service.searchContacts(query: query)

        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(contacts)
            print(String(data: data, encoding: .utf8)!)
        } else if quiet {
            print(contacts.count)
        } else if plain {
            for contact in contacts {
                let phones = contact.phones.joined(separator: ";")
                let emails = contact.emails.joined(separator: ";")
                print("\(contact.id)\t\(contact.fullName)\t\(phones)\t\(emails)")
            }
        } else {
            if contacts.isEmpty {
                print("No contacts matching '\(query)'")
            } else {
                print("Found \(contacts.count) contact(s) matching '\(query)':\n")
                for contact in contacts {
                    printContact(contact)
                }
            }
        }
    }
}

public struct GetContact: AsyncParsableCommand {
    public init() {}
    public static let configuration = CommandConfiguration(
        commandName: "get",
        abstract: "Get a contact by ID"
    )

    @Argument(help: "Contact ID")
    var id: String

    @Flag(name: .long, help: "Output as JSON")
    var json: Bool = false

    @Flag(name: .long, help: "Output as plain text (tab-separated)")
    var plain: Bool = false

    @Flag(name: .long, help: "Output ID only")
    var quiet: Bool = false

    public func run() async throws {
        let service = ContactsService.shared
        guard let contact = try await service.getContact(id: id) else {
            throw ContactsError.contactNotFound
        }

        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(contact)
            print(String(data: data, encoding: .utf8)!)
        } else if quiet {
            print(contact.id)
        } else if plain {
            let phones = contact.phones.joined(separator: ";")
            let emails = contact.emails.joined(separator: ";")
            print("\(contact.id)\t\(contact.fullName)\t\(phones)\t\(emails)")
        } else {
            printContact(contact, verbose: true)
        }
    }
}

public struct CreateContact: AsyncParsableCommand {
    public init() {}
    public static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a new contact"
    )

    @Option(name: .long, help: "First name")
    var firstName: String?

    @Option(name: .long, help: "Last name")
    var lastName: String?

    @Option(name: .long, help: "Email address")
    var email: String?

    @Option(name: .long, help: "Phone number")
    var phone: String?

    @Option(name: .long, help: "Organization/company")
    var organization: String?

    @Option(name: .long, help: "Job title")
    var jobTitle: String?

    @Option(name: .long, help: "Note")
    var note: String?

    @Flag(name: .long, help: "Output as JSON")
    var json: Bool = false

    public func run() async throws {
        guard firstName != nil || lastName != nil || organization != nil else {
            throw ContactsError.invalidInput("At least firstName, lastName, or organization is required")
        }

        let service = ContactsService.shared
        let id = try await service.createContact(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone,
            organization: organization,
            jobTitle: jobTitle,
            note: note
        )

        if json {
            print("{\"id\": \"\(id)\", \"success\": true}")
        } else {
            print("Contact created with ID: \(id)")
        }
    }
}

public struct UpdateContact: AsyncParsableCommand {
    public init() {}
    public static let configuration = CommandConfiguration(
        commandName: "update",
        abstract: "Update an existing contact"
    )

    @Argument(help: "Contact ID")
    var id: String

    @Option(name: .long, help: "First name")
    var firstName: String?

    @Option(name: .long, help: "Last name")
    var lastName: String?

    @Option(name: .long, help: "Organization/company")
    var organization: String?

    @Option(name: .long, help: "Job title")
    var jobTitle: String?

    @Option(name: .long, help: "Note")
    var note: String?

    @Flag(name: .long, help: "Output as JSON")
    var json: Bool = false

    public func run() async throws {
        let service = ContactsService.shared
        let success = try await service.updateContact(
            id: id,
            firstName: firstName,
            lastName: lastName,
            organization: organization,
            jobTitle: jobTitle,
            note: note
        )

        if json {
            print("{\"success\": \(success)}")
        } else {
            if success {
                print("Contact updated successfully")
            } else {
                print("No updates applied (either contact not found or no fields provided)")
            }
        }
    }
}

public struct DeleteContact: AsyncParsableCommand {
    public init() {}
    public static let configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete a contact"
    )

    @Argument(help: "Contact ID")
    var id: String

    @Flag(name: .long, help: "Skip confirmation")
    var force: Bool = false

    @Flag(name: .long, help: "Output as JSON")
    var json: Bool = false

    public func run() async throws {
        if !force && !json {
            print("Are you sure you want to delete contact \(id)? (y/N) ", terminator: "")
            guard let response = readLine()?.lowercased(), response == "y" || response == "yes" else {
                print("Cancelled")
                return
            }
        }

        let service = ContactsService.shared
        let success = try await service.deleteContact(id: id)

        if json {
            print("{\"success\": \(success)}")
        } else {
            if success {
                print("Contact deleted successfully")
            } else {
                print("Failed to delete contact (may not exist)")
            }
        }
    }
}

private func printContact(_ contact: Contact, verbose: Bool = false) {
    print("[\(contact.id)]")
    print("  Name: \(contact.fullName)")

    if let org = contact.organization {
        if let title = contact.jobTitle {
            print("  Work: \(title) at \(org)")
        } else {
            print("  Organization: \(org)")
        }
    } else if let title = contact.jobTitle {
        print("  Title: \(title)")
    }

    if !contact.emails.isEmpty {
        print("  Email: \(contact.emails.joined(separator: ", "))")
    }

    if !contact.phones.isEmpty {
        print("  Phone: \(contact.phones.joined(separator: ", "))")
    }

    if verbose {
        if let birthday = contact.birthday {
            print("  Birthday: \(birthday)")
        }

        if !contact.addresses.isEmpty {
            print("  Addresses:")
            for addr in contact.addresses {
                let formatted = addr.replacingOccurrences(of: "\n", with: ", ")
                print("    - \(formatted)")
            }
        }

        if let note = contact.note {
            print("  Note: \(note)")
        }
    }

    print()
}
