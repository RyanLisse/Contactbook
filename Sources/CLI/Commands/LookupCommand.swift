import ArgumentParser
import Foundation
import Core

public struct LookupCommand: AsyncParsableCommand {
    public init() {}
    public static let configuration = CommandConfiguration(
        commandName: "lookup",
        abstract: "Lookup a contact by phone number"
    )

    @Argument(help: "Phone number to lookup (e.g., +31648502148)")
    var phoneNumber: String

    @Flag(name: .long, help: "Output as JSON")
    var json: Bool = false

    public func run() async throws {
        let service = ContactsService.shared
        let contact = try await service.lookupByPhone(phoneNumber: phoneNumber)

        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            if let contact = contact {
                let data = try encoder.encode(contact)
                print(String(data: data, encoding: .utf8)!)
            } else {
                print("{\"found\": false}")
            }
        } else {
            if let contact = contact {
                print(contact.fullName)
            } else {
                print("Unknown")
            }
        }
    }
}
