import Foundation
import MCP
import Core

public actor ToolHandler {
    private let service = ContactsService.shared

    public init() {}

    public func callTool(_ params: CallTool.Parameters) async throws -> CallTool.Result {
        switch params.name {
        case "contacts_list":
            return try await handleContactsList(params)
        case "contacts_search":
            return try await handleContactsSearch(params)
        case "contacts_get":
            return try await handleContactsGet(params)
        case "contacts_create":
            return try await handleContactsCreate(params)
        case "contacts_update":
            return try await handleContactsUpdate(params)
        case "contacts_delete":
            return try await handleContactsDelete(params)
        case "groups_list":
            return try await handleGroupsList()
        case "groups_members":
            return try await handleGroupsMembers(params)
        default:
            throw ContactbookMCPError.methodNotFound("Unknown tool: \(params.name)")
        }
    }

    // MARK: - Handlers

    private func handleContactsList(_ params: CallTool.Parameters) async throws -> CallTool.Result {
        var limit: Int? = nil
        if case .int(let l) = params.arguments?["limit"] {
            limit = l
        }

        let contacts = try await service.listContacts(limit: limit)
        return CallTool.Result(content: [.text(toJSON(contacts))])
    }

    private func handleContactsSearch(_ params: CallTool.Parameters) async throws -> CallTool.Result {
        guard case .string(let query) = params.arguments?["query"] else {
            throw ContactbookMCPError.invalidParams("Missing 'query' parameter")
        }

        let contacts = try await service.searchContacts(query: query)
        return CallTool.Result(content: [.text(toJSON(contacts))])
    }

    private func handleContactsGet(_ params: CallTool.Parameters) async throws -> CallTool.Result {
        guard case .string(let id) = params.arguments?["id"] else {
            throw ContactbookMCPError.invalidParams("Missing 'id' parameter")
        }

        guard let contact = try await service.getContact(id: id) else {
            return CallTool.Result(content: [.text("{\"error\": \"Contact not found\"}")])
        }

        return CallTool.Result(content: [.text(toJSON(contact))])
    }

    private func handleContactsCreate(_ params: CallTool.Parameters) async throws -> CallTool.Result {
        var firstName: String? = nil
        if case .string(let f) = params.arguments?["firstName"] { firstName = f }

        var lastName: String? = nil
        if case .string(let l) = params.arguments?["lastName"] { lastName = l }

        var email: String? = nil
        if case .string(let e) = params.arguments?["email"] { email = e }

        var phone: String? = nil
        if case .string(let p) = params.arguments?["phone"] { phone = p }

        var organization: String? = nil
        if case .string(let o) = params.arguments?["organization"] { organization = o }

        var jobTitle: String? = nil
        if case .string(let j) = params.arguments?["jobTitle"] { jobTitle = j }

        var note: String? = nil
        if case .string(let n) = params.arguments?["note"] { note = n }

        guard firstName != nil || lastName != nil || organization != nil else {
            return CallTool.Result(content: [.text("{\"error\": \"At least firstName, lastName, or organization is required\"}")])
        }

        let id = try await service.createContact(
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

    private func handleContactsUpdate(_ params: CallTool.Parameters) async throws -> CallTool.Result {
        guard case .string(let id) = params.arguments?["id"] else {
            throw ContactbookMCPError.invalidParams("Missing 'id' parameter")
        }

        var firstName: String? = nil
        if case .string(let f) = params.arguments?["firstName"] { firstName = f }

        var lastName: String? = nil
        if case .string(let l) = params.arguments?["lastName"] { lastName = l }

        var organization: String? = nil
        if case .string(let o) = params.arguments?["organization"] { organization = o }

        var jobTitle: String? = nil
        if case .string(let j) = params.arguments?["jobTitle"] { jobTitle = j }

        var note: String? = nil
        if case .string(let n) = params.arguments?["note"] { note = n }

        let success = try await service.updateContact(
            id: id,
            firstName: firstName,
            lastName: lastName,
            organization: organization,
            jobTitle: jobTitle,
            note: note
        )

        return CallTool.Result(content: [.text("{\"success\": \(success)}")])
    }

    private func handleContactsDelete(_ params: CallTool.Parameters) async throws -> CallTool.Result {
        guard case .string(let id) = params.arguments?["id"] else {
            throw ContactbookMCPError.invalidParams("Missing 'id' parameter")
        }

        let success = try await service.deleteContact(id: id)
        return CallTool.Result(content: [.text("{\"success\": \(success)}")])
    }

    private func handleGroupsList() async throws -> CallTool.Result {
        let groups = try await service.listGroups()
        return CallTool.Result(content: [.text(toJSON(groups))])
    }

    private func handleGroupsMembers(_ params: CallTool.Parameters) async throws -> CallTool.Result {
        guard case .string(let name) = params.arguments?["name"] else {
            throw ContactbookMCPError.invalidParams("Missing 'name' parameter")
        }

        let contacts = try await service.getGroupMembers(groupName: name)
        return CallTool.Result(content: [.text(toJSON(contacts))])
    }

    // MARK: - Helpers

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

extension ToolHandler {
    public static let allTools: [Tool] = [
        Tool(
            name: "contacts_list",
            description: "List all contacts from Apple Contacts. Optional: limit (int) to cap results.",
            inputSchema: .object([
                "properties": .object([
                    "limit": .object([
                        "type": .string("integer"),
                        "description": .string("Maximum number of contacts to return")
                    ])
                ])
            ])
        ),
        Tool(
            name: "contacts_search",
            description: "Search contacts by name, email, phone, or organization. Required: query (string).",
            inputSchema: .object([
                "properties": .object([
                    "query": .object([
                        "type": .string("string"),
                        "description": .string("Search query")
                    ])
                ]),
                "required": .array([.string("query")])
            ])
        ),
        Tool(
            name: "contacts_get",
            description: "Get a contact by ID with full details. Required: id (string).",
            inputSchema: .object([
                "properties": .object([
                    "id": .object([
                        "type": .string("string"),
                        "description": .string("Contact ID")
                    ])
                ]),
                "required": .array([.string("id")])
            ])
        ),
        Tool(
            name: "contacts_create",
            description: "Create a new contact. At least one of firstName, lastName, or organization required. Optional: email, phone, jobTitle, note.",
            inputSchema: .object([
                "properties": .object([
                    "firstName": .object([
                        "type": .string("string"),
                        "description": .string("First name")
                    ]),
                    "lastName": .object([
                        "type": .string("string"),
                        "description": .string("Last name")
                    ]),
                    "email": .object([
                        "type": .string("string"),
                        "description": .string("Email address")
                    ]),
                    "phone": .object([
                        "type": .string("string"),
                        "description": .string("Phone number")
                    ]),
                    "organization": .object([
                        "type": .string("string"),
                        "description": .string("Organization/company")
                    ]),
                    "jobTitle": .object([
                        "type": .string("string"),
                        "description": .string("Job title")
                    ]),
                    "note": .object([
                        "type": .string("string"),
                        "description": .string("Note")
                    ])
                ])
            ])
        ),
        Tool(
            name: "contacts_update",
            description: "Update an existing contact. Required: id (string). Optional: firstName, lastName, organization, jobTitle, note.",
            inputSchema: .object([
                "properties": .object([
                    "id": .object([
                        "type": .string("string"),
                        "description": .string("Contact ID")
                    ]),
                    "firstName": .object([
                        "type": .string("string"),
                        "description": .string("First name")
                    ]),
                    "lastName": .object([
                        "type": .string("string"),
                        "description": .string("Last name")
                    ]),
                    "organization": .object([
                        "type": .string("string"),
                        "description": .string("Organization/company")
                    ]),
                    "jobTitle": .object([
                        "type": .string("string"),
                        "description": .string("Job title")
                    ]),
                    "note": .object([
                        "type": .string("string"),
                        "description": .string("Note")
                    ])
                ]),
                "required": .array([.string("id")])
            ])
        ),
        Tool(
            name: "contacts_delete",
            description: "Delete a contact. Required: id (string).",
            inputSchema: .object([
                "properties": .object([
                    "id": .object([
                        "type": .string("string"),
                        "description": .string("Contact ID")
                    ])
                ]),
                "required": .array([.string("id")])
            ])
        ),
        Tool(
            name: "groups_list",
            description: "List all contact groups with member counts.",
            inputSchema: .object([:])
        ),
        Tool(
            name: "groups_members",
            description: "Get all contacts in a group. Required: name (string) - the group name.",
            inputSchema: .object([
                "properties": .object([
                    "name": .object([
                        "type": .string("string"),
                        "description": .string("Group name")
                    ])
                ]),
                "required": .array([.string("name")])
            ])
        ),
    ]
}
