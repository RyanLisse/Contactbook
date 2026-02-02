import ArgumentParser
import Foundation
import Core

public struct StatusCommand: AsyncParsableCommand {
    public init() {}

    public static let configuration = CommandConfiguration(
        commandName: "status",
        abstract: "Show Contacts authorization status"
    )

    @Flag(name: .long, help: "Output as JSON")
    var json: Bool = false

    @Flag(name: .long, help: "Output as plain text (tab-separated)")
    var plain: Bool = false

    @Flag(name: .long, help: "Output status only, no guidance")
    var quiet: Bool = false

    public func run() async throws {
        let service = ContactsService.shared
        let status = await service.authorizationStatus()

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
    }
}
