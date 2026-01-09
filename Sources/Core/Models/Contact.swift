import Foundation

public struct Contact: Codable, Sendable {
    public let id: String
    public let firstName: String
    public let lastName: String
    public let fullName: String
    public let emails: [String]
    public let phones: [String]
    public let organization: String?
    public let jobTitle: String?
    public let note: String?
    public let birthday: String?
    public let addresses: [String]

    public init(
        id: String,
        firstName: String,
        lastName: String,
        fullName: String,
        emails: [String],
        phones: [String],
        organization: String?,
        jobTitle: String?,
        note: String?,
        birthday: String?,
        addresses: [String]
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.fullName = fullName
        self.emails = emails
        self.phones = phones
        self.organization = organization
        self.jobTitle = jobTitle
        self.note = note
        self.birthday = birthday
        self.addresses = addresses
    }
}

public struct ContactGroup: Codable, Sendable {
    public let id: String
    public let name: String
    public let memberCount: Int

    public init(id: String, name: String, memberCount: Int) {
        self.id = id
        self.name = name
        self.memberCount = memberCount
    }
}

public enum ContactsError: Error, LocalizedError, Sendable {
    case accessDenied
    case contactNotFound
    case invalidInput(String)
    case operationFailed(String)
    case scriptError(String)

    public var errorDescription: String? {
        switch self {
        case .accessDenied: return "Access to contacts was denied"
        case .contactNotFound: return "Contact not found"
        case .invalidInput(let msg): return "Invalid input: \(msg)"
        case .operationFailed(let msg): return "Operation failed: \(msg)"
        case .scriptError(let msg): return "AppleScript error: \(msg)"
        }
    }
}
