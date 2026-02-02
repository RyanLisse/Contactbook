import Foundation

public enum ContactsAuthorizationStatus: String, Codable, Sendable, Equatable {
    case notDetermined = "not-determined"
    case restricted = "restricted"
    case denied = "denied"
    case authorized = "authorized"

    public var isAuthorized: Bool {
        self == .authorized
    }

    public var displayName: String {
        switch self {
        case .notDetermined: return "Not determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorized: return "Authorized"
        }
    }

    public var guidance: String {
        switch self {
        case .notDetermined:
            return "Run 'contactbook authorize' to request access."
        case .denied:
            return "Access denied. Enable in System Settings -> Privacy & Security -> Contacts."
        case .restricted:
            return "Access restricted by system policy (parental controls, MDM, etc.)."
        case .authorized:
            return "Full access granted."
        }
    }
}
