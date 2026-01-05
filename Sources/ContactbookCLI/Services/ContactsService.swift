import Foundation

struct Contact: Codable, Sendable {
    let id: String
    let firstName: String
    let lastName: String
    let fullName: String
    let emails: [String]
    let phones: [String]
    let organization: String?
    let jobTitle: String?
    let note: String?
    let birthday: String?
    let addresses: [String]
}

struct ContactGroup: Codable, Sendable {
    let id: String
    let name: String
    let memberCount: Int
}

actor ContactsService {
    static let shared = ContactsService()
    
    private init() {}
    
    func listContacts(limit: Int? = nil) async throws -> [Contact] {
        let maxCount = limit ?? 50
        
        let script = """
        use framework "Foundation"
        use scripting additions
        
        tell application "Contacts"
            set resultList to {}
            set maxItems to \(maxCount)
            set peopleList to people
            set totalCount to count of peopleList
            set loopCount to totalCount
            if loopCount > maxItems then set loopCount to maxItems
            
            repeat with i from 1 to loopCount
                set p to item i of peopleList
                set contactId to id of p
                set fName to first name of p
                set lName to last name of p
                
                if fName is missing value then set fName to ""
                if lName is missing value then set lName to ""
                
                set fullN to name of p
                if fullN is missing value then set fullN to ""
                
                set emailVal to ""
                if (count of emails of p) > 0 then
                    set emailVal to value of item 1 of emails of p
                end if
                
                set phoneVal to ""
                if (count of phones of p) > 0 then
                    set phoneVal to value of item 1 of phones of p
                end if
                
                set org to organization of p
                if org is missing value then set org to ""
                
                set jTitle to job title of p
                if jTitle is missing value then set jTitle to ""
                
                set jsonLine to "{\\"id\\":\\"" & contactId & "\\",\\"fn\\":\\"" & my escapeJSON(fName) & "\\",\\"ln\\":\\"" & my escapeJSON(lName) & "\\",\\"name\\":\\"" & my escapeJSON(fullN) & "\\",\\"email\\":\\"" & my escapeJSON(emailVal) & "\\",\\"phone\\":\\"" & my escapeJSON(phoneVal) & "\\",\\"org\\":\\"" & my escapeJSON(org) & "\\",\\"title\\":\\"" & my escapeJSON(jTitle) & "\\"}"
                set end of resultList to jsonLine
            end repeat
            
            set AppleScript's text item delimiters to ","
            set jsonArray to "[" & (resultList as text) & "]"
            set AppleScript's text item delimiters to ""
            return jsonArray
        end tell
        
        on escapeJSON(theText)
            set theText to my replaceText(theText, "\\\\", "\\\\\\\\")
            set theText to my replaceText(theText, "\\"", "\\\\\\"")
            set theText to my replaceText(theText, return, "\\\\n")
            set theText to my replaceText(theText, linefeed, "\\\\n")
            set theText to my replaceText(theText, tab, "\\\\t")
            return theText
        end escapeJSON
        
        on replaceText(theText, searchStr, replaceStr)
            set AppleScript's text item delimiters to searchStr
            set theItems to text items of theText
            set AppleScript's text item delimiters to replaceStr
            set theText to theItems as text
            set AppleScript's text item delimiters to ""
            return theText
        end replaceText
        """
        
        let output = try await runAppleScript(script)
        return parseJSONContacts(output)
    }
    
    func searchContacts(query: String) async throws -> [Contact] {
        let escapedQuery = query.replacingOccurrences(of: "\"", with: "\\\"")
        
        let script = """
        use framework "Foundation"
        use scripting additions
        
        tell application "Contacts"
            set resultList to {}
            set matchingPeople to (every person whose name contains "\(escapedQuery)")
            
            repeat with p in matchingPeople
                set contactId to id of p
                set fName to first name of p
                set lName to last name of p
                
                if fName is missing value then set fName to ""
                if lName is missing value then set lName to ""
                
                set fullN to name of p
                if fullN is missing value then set fullN to ""
                
                set emailVal to ""
                if (count of emails of p) > 0 then
                    set emailVal to value of item 1 of emails of p
                end if
                
                set phoneVal to ""
                if (count of phones of p) > 0 then
                    set phoneVal to value of item 1 of phones of p
                end if
                
                set org to organization of p
                if org is missing value then set org to ""
                
                set jTitle to job title of p
                if jTitle is missing value then set jTitle to ""
                
                set jsonLine to "{\\"id\\":\\"" & contactId & "\\",\\"fn\\":\\"" & my escapeJSON(fName) & "\\",\\"ln\\":\\"" & my escapeJSON(lName) & "\\",\\"name\\":\\"" & my escapeJSON(fullN) & "\\",\\"email\\":\\"" & my escapeJSON(emailVal) & "\\",\\"phone\\":\\"" & my escapeJSON(phoneVal) & "\\",\\"org\\":\\"" & my escapeJSON(org) & "\\",\\"title\\":\\"" & my escapeJSON(jTitle) & "\\"}"
                set end of resultList to jsonLine
            end repeat
            
            set AppleScript's text item delimiters to ","
            set jsonArray to "[" & (resultList as text) & "]"
            set AppleScript's text item delimiters to ""
            return jsonArray
        end tell
        
        on escapeJSON(theText)
            set theText to my replaceText(theText, "\\\\", "\\\\\\\\")
            set theText to my replaceText(theText, "\\"", "\\\\\\"")
            set theText to my replaceText(theText, return, "\\\\n")
            set theText to my replaceText(theText, linefeed, "\\\\n")
            set theText to my replaceText(theText, tab, "\\\\t")
            return theText
        end escapeJSON
        
        on replaceText(theText, searchStr, replaceStr)
            set AppleScript's text item delimiters to searchStr
            set theItems to text items of theText
            set AppleScript's text item delimiters to replaceStr
            set theText to theItems as text
            set AppleScript's text item delimiters to ""
            return theText
        end replaceText
        """
        
        let output = try await runAppleScript(script)
        return parseJSONContacts(output)
    }
    
    func getContact(id: String) async throws -> Contact? {
        let escapedId = id.replacingOccurrences(of: "\"", with: "\\\"")
        
        let script = """
        use framework "Foundation"
        use scripting additions
        
        tell application "Contacts"
            try
                set p to person id "\(escapedId)"
                
                set contactId to id of p
                set fName to first name of p
                set lName to last name of p
                
                if fName is missing value then set fName to ""
                if lName is missing value then set lName to ""
                
                set fullN to name of p
                if fullN is missing value then set fullN to ""
                
                set emailVal to ""
                if (count of emails of p) > 0 then
                    set emailVal to value of item 1 of emails of p
                end if
                
                set phoneVal to ""
                if (count of phones of p) > 0 then
                    set phoneVal to value of item 1 of phones of p
                end if
                
                set org to organization of p
                if org is missing value then set org to ""
                
                set jTitle to job title of p
                if jTitle is missing value then set jTitle to ""
                
                set contactNote to note of p
                if contactNote is missing value then set contactNote to ""
                
                set jsonLine to "{\\"id\\":\\"" & contactId & "\\",\\"fn\\":\\"" & my escapeJSON(fName) & "\\",\\"ln\\":\\"" & my escapeJSON(lName) & "\\",\\"name\\":\\"" & my escapeJSON(fullN) & "\\",\\"email\\":\\"" & my escapeJSON(emailVal) & "\\",\\"phone\\":\\"" & my escapeJSON(phoneVal) & "\\",\\"org\\":\\"" & my escapeJSON(org) & "\\",\\"title\\":\\"" & my escapeJSON(jTitle) & "\\",\\"note\\":\\"" & my escapeJSON(contactNote) & "\\"}"
                return jsonLine
            on error
                return "{}"
            end try
        end tell
        
        on escapeJSON(theText)
            set theText to my replaceText(theText, "\\\\", "\\\\\\\\")
            set theText to my replaceText(theText, "\\"", "\\\\\\"")
            set theText to my replaceText(theText, return, "\\\\n")
            set theText to my replaceText(theText, linefeed, "\\\\n")
            set theText to my replaceText(theText, tab, "\\\\t")
            return theText
        end escapeJSON
        
        on replaceText(theText, searchStr, replaceStr)
            set AppleScript's text item delimiters to searchStr
            set theItems to text items of theText
            set AppleScript's text item delimiters to replaceStr
            set theText to theItems as text
            set AppleScript's text item delimiters to ""
            return theText
        end replaceText
        """
        
        let output = try await runAppleScript(script)
        let trimmed = output.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != "{}" else { return nil }
        
        return parseJSONContact(trimmed)
    }
    
    func createContact(
        firstName: String?,
        lastName: String?,
        email: String?,
        phone: String?,
        organization: String?,
        jobTitle: String?,
        note: String?
    ) async throws -> String {
        var propertyLines: [String] = []
        
        if let firstName, !firstName.isEmpty {
            propertyLines.append("set first name of newPerson to \"\(firstName.replacingOccurrences(of: "\"", with: "\\\""))\"")
        }
        if let lastName, !lastName.isEmpty {
            propertyLines.append("set last name of newPerson to \"\(lastName.replacingOccurrences(of: "\"", with: "\\\""))\"")
        }
        if let organization, !organization.isEmpty {
            propertyLines.append("set organization of newPerson to \"\(organization.replacingOccurrences(of: "\"", with: "\\\""))\"")
        }
        if let jobTitle, !jobTitle.isEmpty {
            propertyLines.append("set job title of newPerson to \"\(jobTitle.replacingOccurrences(of: "\"", with: "\\\""))\"")
        }
        if let note, !note.isEmpty {
            propertyLines.append("set note of newPerson to \"\(note.replacingOccurrences(of: "\"", with: "\\\""))\"")
        }
        
        var emailLine = ""
        if let email, !email.isEmpty {
            emailLine = "make new email at end of emails of newPerson with properties {label:\"work\", value:\"\(email.replacingOccurrences(of: "\"", with: "\\\""))\"}"
        }
        
        var phoneLine = ""
        if let phone, !phone.isEmpty {
            phoneLine = "make new phone at end of phones of newPerson with properties {label:\"mobile\", value:\"\(phone.replacingOccurrences(of: "\"", with: "\\\""))\"}"
        }
        
        let script = """
        tell application "Contacts"
            set newPerson to make new person
            \(propertyLines.joined(separator: "\n            "))
            \(emailLine)
            \(phoneLine)
            save
            return id of newPerson
        end tell
        """
        
        return try await runAppleScript(script).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func updateContact(
        id: String,
        firstName: String?,
        lastName: String?,
        organization: String?,
        jobTitle: String?,
        note: String?
    ) async throws -> Bool {
        let escapedId = id.replacingOccurrences(of: "\"", with: "\\\"")
        var updates: [String] = []
        
        if let firstName {
            updates.append("set first name of p to \"\(firstName.replacingOccurrences(of: "\"", with: "\\\""))\"")
        }
        if let lastName {
            updates.append("set last name of p to \"\(lastName.replacingOccurrences(of: "\"", with: "\\\""))\"")
        }
        if let organization {
            updates.append("set organization of p to \"\(organization.replacingOccurrences(of: "\"", with: "\\\""))\"")
        }
        if let jobTitle {
            updates.append("set job title of p to \"\(jobTitle.replacingOccurrences(of: "\"", with: "\\\""))\"")
        }
        if let note {
            updates.append("set note of p to \"\(note.replacingOccurrences(of: "\"", with: "\\\""))\"")
        }
        
        guard !updates.isEmpty else { return false }
        
        let script = """
        tell application "Contacts"
            try
                set p to person id "\(escapedId)"
                \(updates.joined(separator: "\n                "))
                save
                return "true"
            on error
                return "false"
            end try
        end tell
        """
        
        let result = try await runAppleScript(script)
        return result.trimmingCharacters(in: .whitespacesAndNewlines) == "true"
    }
    
    func deleteContact(id: String) async throws -> Bool {
        let escapedId = id.replacingOccurrences(of: "\"", with: "\\\"")
        
        let script = """
        tell application "Contacts"
            try
                set p to person id "\(escapedId)"
                delete p
                save
                return "true"
            on error
                return "false"
            end try
        end tell
        """
        
        let result = try await runAppleScript(script)
        return result.trimmingCharacters(in: .whitespacesAndNewlines) == "true"
    }
    
    func listGroups() async throws -> [ContactGroup] {
        let script = """
        use framework "Foundation"
        use scripting additions
        
        tell application "Contacts"
            set resultList to {}
            repeat with g in groups
                set gId to id of g
                set gName to name of g
                set memberCount to count of people of g
                set jsonLine to "{\\"id\\":\\"" & gId & "\\",\\"name\\":\\"" & my escapeJSON(gName) & "\\",\\"count\\":" & memberCount & "}"
                set end of resultList to jsonLine
            end repeat
            
            set AppleScript's text item delimiters to ","
            set jsonArray to "[" & (resultList as text) & "]"
            set AppleScript's text item delimiters to ""
            return jsonArray
        end tell
        
        on escapeJSON(theText)
            set theText to my replaceText(theText, "\\\\", "\\\\\\\\")
            set theText to my replaceText(theText, "\\"", "\\\\\\"")
            set theText to my replaceText(theText, return, "\\\\n")
            set theText to my replaceText(theText, linefeed, "\\\\n")
            return theText
        end escapeJSON
        
        on replaceText(theText, searchStr, replaceStr)
            set AppleScript's text item delimiters to searchStr
            set theItems to text items of theText
            set AppleScript's text item delimiters to replaceStr
            set theText to theItems as text
            set AppleScript's text item delimiters to ""
            return theText
        end replaceText
        """
        
        let output = try await runAppleScript(script)
        return parseJSONGroups(output)
    }
    
    func getGroupMembers(groupName: String) async throws -> [Contact] {
        let escapedName = groupName.replacingOccurrences(of: "\"", with: "\\\"")
        
        let script = """
        use framework "Foundation"
        use scripting additions
        
        tell application "Contacts"
            set resultList to {}
            try
                set g to group "\(escapedName)"
                repeat with p in people of g
                    set contactId to id of p
                    set fName to first name of p
                    set lName to last name of p
                    
                    if fName is missing value then set fName to ""
                    if lName is missing value then set lName to ""
                    
                    set fullN to name of p
                    if fullN is missing value then set fullN to ""
                    
                    set emailVal to ""
                    if (count of emails of p) > 0 then
                        set emailVal to value of item 1 of emails of p
                    end if
                    
                    set phoneVal to ""
                    if (count of phones of p) > 0 then
                        set phoneVal to value of item 1 of phones of p
                    end if
                    
                    set org to organization of p
                    if org is missing value then set org to ""
                    
                    set jTitle to job title of p
                    if jTitle is missing value then set jTitle to ""
                    
                    set jsonLine to "{\\"id\\":\\"" & contactId & "\\",\\"fn\\":\\"" & my escapeJSON(fName) & "\\",\\"ln\\":\\"" & my escapeJSON(lName) & "\\",\\"name\\":\\"" & my escapeJSON(fullN) & "\\",\\"email\\":\\"" & my escapeJSON(emailVal) & "\\",\\"phone\\":\\"" & my escapeJSON(phoneVal) & "\\",\\"org\\":\\"" & my escapeJSON(org) & "\\",\\"title\\":\\"" & my escapeJSON(jTitle) & "\\"}"
                    set end of resultList to jsonLine
                end repeat
            end try
            
            set AppleScript's text item delimiters to ","
            set jsonArray to "[" & (resultList as text) & "]"
            set AppleScript's text item delimiters to ""
            return jsonArray
        end tell
        
        on escapeJSON(theText)
            set theText to my replaceText(theText, "\\\\", "\\\\\\\\")
            set theText to my replaceText(theText, "\\"", "\\\\\\"")
            set theText to my replaceText(theText, return, "\\\\n")
            set theText to my replaceText(theText, linefeed, "\\\\n")
            return theText
        end escapeJSON
        
        on replaceText(theText, searchStr, replaceStr)
            set AppleScript's text item delimiters to searchStr
            set theItems to text items of theText
            set AppleScript's text item delimiters to replaceStr
            set theText to theItems as text
            set AppleScript's text item delimiters to ""
            return theText
        end replaceText
        """
        
        let output = try await runAppleScript(script)
        return parseJSONContacts(output)
    }
    
    private func runAppleScript(_ script: String) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global().async {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
                process.arguments = ["-e", script]
                
                let pipe = Pipe()
                let errorPipe = Pipe()
                process.standardOutput = pipe
                process.standardError = errorPipe
                
                do {
                    try process.run()
                    process.waitUntilExit()
                    
                    let data = pipe.fileHandleForReading.readDataToEndOfFile()
                    let output = String(data: data, encoding: .utf8) ?? ""
                    
                    if process.terminationStatus != 0 {
                        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                        let errorOutput = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                        continuation.resume(throwing: ContactsError.scriptFailed(errorOutput))
                    } else {
                        continuation.resume(returning: output)
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private struct JSONContactSimple: Decodable {
        let id: String
        let fn: String
        let ln: String
        let name: String
        let email: String
        let phone: String
        let org: String
        let title: String
        let note: String?
    }
    
    private struct JSONGroup: Decodable {
        let id: String
        let name: String
        let count: Int
    }
    
    private func parseJSONContacts(_ output: String) -> [Contact] {
        let trimmed = output.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != "[]" else { return [] }
        
        guard let data = trimmed.data(using: .utf8) else { return [] }
        
        do {
            let items = try JSONDecoder().decode([JSONContactSimple].self, from: data)
            return items.map { item in
                Contact(
                    id: item.id,
                    firstName: item.fn,
                    lastName: item.ln,
                    fullName: item.name.isEmpty ? "\(item.fn) \(item.ln)".trimmingCharacters(in: .whitespaces) : item.name,
                    emails: item.email.isEmpty ? [] : [item.email],
                    phones: item.phone.isEmpty ? [] : [item.phone],
                    organization: item.org.isEmpty ? nil : item.org,
                    jobTitle: item.title.isEmpty ? nil : item.title,
                    note: item.note,
                    birthday: nil,
                    addresses: []
                )
            }
        } catch {
            return []
        }
    }
    
    private func parseJSONContact(_ output: String) -> Contact? {
        let trimmed = output.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != "{}" else { return nil }
        
        guard let data = trimmed.data(using: .utf8) else { return nil }
        
        do {
            let item = try JSONDecoder().decode(JSONContactSimple.self, from: data)
            return Contact(
                id: item.id,
                firstName: item.fn,
                lastName: item.ln,
                fullName: item.name.isEmpty ? "\(item.fn) \(item.ln)".trimmingCharacters(in: .whitespaces) : item.name,
                emails: item.email.isEmpty ? [] : [item.email],
                phones: item.phone.isEmpty ? [] : [item.phone],
                organization: item.org.isEmpty ? nil : item.org,
                jobTitle: item.title.isEmpty ? nil : item.title,
                note: item.note,
                birthday: nil,
                addresses: []
            )
        } catch {
            return nil
        }
    }
    
    private func parseJSONGroups(_ output: String) -> [ContactGroup] {
        let trimmed = output.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != "[]" else { return [] }
        
        guard let data = trimmed.data(using: .utf8) else { return [] }
        
        do {
            let items = try JSONDecoder().decode([JSONGroup].self, from: data)
            return items.map { ContactGroup(id: $0.id, name: $0.name, memberCount: $0.count) }
        } catch {
            return []
        }
    }
}

enum ContactsError: Error, LocalizedError {
    case scriptFailed(String)
    case contactNotFound
    case invalidInput(String)
    
    var errorDescription: String? {
        switch self {
        case .scriptFailed(let msg): return "AppleScript error: \(msg)"
        case .contactNotFound: return "Contact not found"
        case .invalidInput(let msg): return "Invalid input: \(msg)"
        }
    }
}
