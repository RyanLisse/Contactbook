import Foundation
import MCP

public actor ContactbookMCPServer {
    private var server: Server?
    
    public init() {}
    
    public func run() async throws {
        let transport = StdioTransport()
        
        let capabilities = Server.Capabilities(
            tools: .init(listChanged: false)
        )
        
        let server = Server(
            name: "contactbook",
            version: "1.0.0",
            capabilities: capabilities
        )
        self.server = server
        
        await server.withMethodHandler(ListTools.self) { _ in
            ListTools.Result(tools: Self.mcpTools)
        }
        
        await server.withMethodHandler(CallTool.self) { [weak self] params in
            guard let self = self else {
                throw ContactbookMCPError.internalError("Server not initialized")
            }
            return try await self.handleToolCall(params)
        }
        
        try await server.start(transport: transport)
    }
    
    private func handleToolCall(_ params: CallTool.Parameters) async throws -> CallTool.Result {
        let toolName = params.name
        let args = params.arguments ?? [:]
        
        switch toolName {
        case "contacts_list":
            return try await handleContactsList(args)
        case "contacts_search":
            return try await handleContactsSearch(args)
        case "contacts_get":
            return try await handleContactsGet(args)
        case "contacts_create":
            return try await handleContactsCreate(args)
        case "contacts_update":
            return try await handleContactsUpdate(args)
        case "contacts_delete":
            return try await handleContactsDelete(args)
        case "groups_list":
            return try await handleGroupsList()
        case "groups_members":
            return try await handleGroupsMembers(args)
        default:
            throw ContactbookMCPError.methodNotFound("Unknown tool: \(toolName)")
        }
    }
    
    private func handleContactsList(_ args: [String: Value]) async throws -> CallTool.Result {
        var limit: Int? = nil
        if case .int(let l) = args["limit"] {
            limit = l
        }
        
        let contacts = try await ContactsService.shared.listContacts(limit: limit)
        return CallTool.Result(content: [.text(toJSON(contacts))])
    }
    
    private func handleContactsSearch(_ args: [String: Value]) async throws -> CallTool.Result {
        guard case .string(let query) = args["query"] else {
            throw ContactbookMCPError.invalidParams("Missing 'query' parameter")
        }
        
        let contacts = try await ContactsService.shared.searchContacts(query: query)
        return CallTool.Result(content: [.text(toJSON(contacts))])
    }
    
    private func handleContactsGet(_ args: [String: Value]) async throws -> CallTool.Result {
        guard case .string(let id) = args["id"] else {
            throw ContactbookMCPError.invalidParams("Missing 'id' parameter")
        }
        
        guard let contact = try await ContactsService.shared.getContact(id: id) else {
            return CallTool.Result(content: [.text("{\"error\": \"Contact not found\"}")])
        }
        
        return CallTool.Result(content: [.text(toJSON(contact))])
    }
    
    private func handleContactsCreate(_ args: [String: Value]) async throws -> CallTool.Result {
        var firstName: String? = nil
        if case .string(let f) = args["firstName"] { firstName = f }
        
        var lastName: String? = nil
        if case .string(let l) = args["lastName"] { lastName = l }
        
        var email: String? = nil
        if case .string(let e) = args["email"] { email = e }
        
        var phone: String? = nil
        if case .string(let p) = args["phone"] { phone = p }
        
        var organization: String? = nil
        if case .string(let o) = args["organization"] { organization = o }
        
        var jobTitle: String? = nil
        if case .string(let j) = args["jobTitle"] { jobTitle = j }
        
        var note: String? = nil
        if case .string(let n) = args["note"] { note = n }
        
        guard firstName != nil || lastName != nil || organization != nil else {
            return CallTool.Result(content: [.text("{\"error\": \"At least firstName, lastName, or organization is required\"}")])
        }
        
        let id = try await ContactsService.shared.createContact(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone,
            organization: organization,
            jobTitle: jobTitle,
            note: note
        )
        
        return CallTool.Result(content: [.text("{\"id\": \"\(id)\", \"success\": true}")])
    }
    
    private func handleContactsUpdate(_ args: [String: Value]) async throws -> CallTool.Result {
        guard case .string(let id) = args["id"] else {
            throw ContactbookMCPError.invalidParams("Missing 'id' parameter")
        }
        
        var firstName: String? = nil
        if case .string(let f) = args["firstName"] { firstName = f }
        
        var lastName: String? = nil
        if case .string(let l) = args["lastName"] { lastName = l }
        
        var organization: String? = nil
        if case .string(let o) = args["organization"] { organization = o }
        
        var jobTitle: String? = nil
        if case .string(let j) = args["jobTitle"] { jobTitle = j }
        
        var note: String? = nil
        if case .string(let n) = args["note"] { note = n }
        
        let success = try await ContactsService.shared.updateContact(
            id: id,
            firstName: firstName,
            lastName: lastName,
            organization: organization,
            jobTitle: jobTitle,
            note: note
        )
        
        return CallTool.Result(content: [.text("{\"success\": \(success)}")])
    }
    
    private func handleContactsDelete(_ args: [String: Value]) async throws -> CallTool.Result {
        guard case .string(let id) = args["id"] else {
            throw ContactbookMCPError.invalidParams("Missing 'id' parameter")
        }
        
        let success = try await ContactsService.shared.deleteContact(id: id)
        return CallTool.Result(content: [.text("{\"success\": \(success)}")])
    }
    
    private func handleGroupsList() async throws -> CallTool.Result {
        let groups = try await ContactsService.shared.listGroups()
        return CallTool.Result(content: [.text(toJSON(groups))])
    }
    
    private func handleGroupsMembers(_ args: [String: Value]) async throws -> CallTool.Result {
        guard case .string(let name) = args["name"] else {
            throw ContactbookMCPError.invalidParams("Missing 'name' parameter")
        }
        
        let contacts = try await ContactsService.shared.getGroupMembers(groupName: name)
        return CallTool.Result(content: [.text(toJSON(contacts))])
    }
    
    private func toJSON<T: Codable>(_ value: T) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        guard let data = try? encoder.encode(value),
              let string = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return string
    }
}

extension ContactbookMCPServer {
    static var mcpTools: [Tool] {
        [
            Tool(
                name: "contacts_list",
                description: "List all contacts from Apple Contacts. Optional: limit (int) to cap results.",
                inputSchema: .object([:])
            ),
            Tool(
                name: "contacts_search",
                description: "Search contacts by name, email, phone, or organization. Required: query (string).",
                inputSchema: .object([:])
            ),
            Tool(
                name: "contacts_get",
                description: "Get a contact by ID with full details. Required: id (string).",
                inputSchema: .object([:])
            ),
            Tool(
                name: "contacts_create",
                description: "Create a new contact. At least one of firstName, lastName, or organization required. Optional: email, phone, jobTitle, note.",
                inputSchema: .object([:])
            ),
            Tool(
                name: "contacts_update",
                description: "Update an existing contact. Required: id (string). Optional: firstName, lastName, organization, jobTitle, note.",
                inputSchema: .object([:])
            ),
            Tool(
                name: "contacts_delete",
                description: "Delete a contact. Required: id (string).",
                inputSchema: .object([:])
            ),
            Tool(
                name: "groups_list",
                description: "List all contact groups with member counts.",
                inputSchema: .object([:])
            ),
            Tool(
                name: "groups_members",
                description: "Get all contacts in a group. Required: name (string) - the group name.",
                inputSchema: .object([:])
            ),
        ]
    }
}

enum ContactbookMCPError: Error, LocalizedError {
    case internalError(String)
    case methodNotFound(String)
    case invalidParams(String)
    
    var errorDescription: String? {
        switch self {
        case .internalError(let msg): return "Internal error: \(msg)"
        case .methodNotFound(let msg): return "Method not found: \(msg)"
        case .invalidParams(let msg): return "Invalid parameters: \(msg)"
        }
    }
}
