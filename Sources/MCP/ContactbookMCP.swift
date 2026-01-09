import Foundation
import MCP
import Core

public enum ContactbookMCPError: Error, LocalizedError {
    case internalError(String)
    case methodNotFound(String)
    case invalidParams(String)

    public var errorDescription: String? {
        switch self {
        case .internalError(let msg): return "Internal error: \(msg)"
        case .methodNotFound(let msg): return "Method not found: \(msg)"
        case .invalidParams(let msg): return "Invalid parameters: \(msg)"
        }
    }
}
