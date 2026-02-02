import ArgumentParser
import Foundation
import Core

public struct AuthorizeCommand: AsyncParsableCommand {
    public init() {}

    public static let configuration = CommandConfiguration(
        commandName: "authorize",
        abstract: "Request Contacts access"
    )

    @Flag(name: .long, help: "Output as JSON")
    var json: Bool = false

    @Flag(name: .long, help: "Output as plain text")
    var plain: Bool = false

    @Flag(name: .long, help: "Output status only, no guidance")
    var quiet: Bool = false

    public func run() async throws {
        let service = ContactsService.shared
        let current = await service.authorizationStatus()

        let status: ContactsAuthorizationStatus
        if current == .notDetermined {
            status = try await service.requestAuthorization()
        } else {
            status = current
        }

        if json {
            print("{\"status\": \"\(status.rawValue)\", \"authorized\": \(status.isAuthorized)}")
        } else if plain {
            print(status.rawValue)
        } else {
            print("Contacts access: \(status.displayName)")
            if !quiet && !status.isAuthorized {
                print(status.guidance)
            }
        }

        if !status.isAuthorized {
            throw ContactsError.accessDenied
        }
    }
}
