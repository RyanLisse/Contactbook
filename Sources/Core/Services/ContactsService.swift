import Foundation

public actor ContactsService {
    public static let shared = ContactsService()

    private init() {}

    // MARK: - AppleScript Execution

    private func runAppleScript(_ script: String, timeout: TimeInterval = 120) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", script]

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        try process.run()

        let deadline = Date().addingTimeInterval(timeout)
        while process.isRunning && Date() < deadline {
            Thread.sleep(forTimeInterval: 0.1)
        }

        if process.isRunning {
            process.terminate()
            return ""
        }

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

        if process.terminationStatus != 0 {
            let errorString = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            throw ContactsError.scriptError(errorString)
        }

        return String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    // MARK: - List Contacts

    public func listContacts(limit: Int? = nil) async throws -> [Contact] {
        let maxCount = limit ?? 50

        let script = """
        tell application "Contacts"
            set output to ""
            set contactCount to 0
            repeat with p in people
                if contactCount >= \(maxCount) then exit repeat
                set contactId to id of p
                set firstName to first name of p
                set lastName to last name of p
                set orgName to organization of p
                set jobTitleVal to job title of p
                set noteVal to note of p
                set birthdayVal to ""
                try
                    set birthdayVal to birth date of p as string
                end try

                set emailList to ""
                repeat with e in emails of p
                    if emailList is not "" then set emailList to emailList & ";;;"
                    set emailList to emailList & (value of e)
                end repeat

                set phoneList to ""
                repeat with ph in phones of p
                    if phoneList is not "" then set phoneList to phoneList & ";;;"
                    set phoneList to phoneList & (value of ph)
                end repeat

                set addrList to ""
                repeat with a in addresses of p
                    if addrList is not "" then set addrList to addrList & ";;;"
                    set addrParts to ""
                    try
                        set addrParts to (street of a) & ", " & (city of a) & ", " & (state of a) & " " & (zip of a) & ", " & (country of a)
                    end try
                    set addrList to addrList & addrParts
                end repeat

                set recordLine to contactId & "\t" & firstName & "\t" & lastName & "\t" & orgName & "\t" & jobTitleVal & "\t" & noteVal & "\t" & birthdayVal & "\t" & emailList & "\t" & phoneList & "\t" & addrList
                if output is not "" then set output to output & linefeed
                set output to output & recordLine
                set contactCount to contactCount + 1
            end repeat
            return output
        end tell
        """

        let result = try runAppleScript(script)
        return parseContacts(result)
    }

    // MARK: - Search Contacts

    public func searchContacts(query: String) async throws -> [Contact] {
        let escapedQuery = query.replacingOccurrences(of: "\"", with: "\\\"")

        let script = """
        tell application "Contacts"
            set output to ""
            set matchedPeople to (every person whose name contains "\(escapedQuery)")
            repeat with p in matchedPeople
                set contactId to id of p
                set firstName to first name of p
                set lastName to last name of p
                set orgName to organization of p
                set jobTitleVal to job title of p
                set noteVal to note of p
                set birthdayVal to ""
                try
                    set birthdayVal to birth date of p as string
                end try

                set emailList to ""
                repeat with e in emails of p
                    if emailList is not "" then set emailList to emailList & ";;;"
                    set emailList to emailList & (value of e)
                end repeat

                set phoneList to ""
                repeat with ph in phones of p
                    if phoneList is not "" then set phoneList to phoneList & ";;;"
                    set phoneList to phoneList & (value of ph)
                end repeat

                set addrList to ""
                repeat with a in addresses of p
                    if addrList is not "" then set addrList to addrList & ";;;"
                    set addrParts to ""
                    try
                        set addrParts to (street of a) & ", " & (city of a) & ", " & (state of a) & " " & (zip of a) & ", " & (country of a)
                    end try
                    set addrList to addrList & addrParts
                end repeat

                set recordLine to contactId & "\t" & firstName & "\t" & lastName & "\t" & orgName & "\t" & jobTitleVal & "\t" & noteVal & "\t" & birthdayVal & "\t" & emailList & "\t" & phoneList & "\t" & addrList
                if output is not "" then set output to output & linefeed
                set output to output & recordLine
            end repeat
            return output
        end tell
        """

        let result = try runAppleScript(script)
        return parseContacts(result)
    }

    // MARK: - Get Contact

    public func getContact(id: String) async throws -> Contact? {
        let escapedId = id.replacingOccurrences(of: "\"", with: "\\\"")

        let script = """
        tell application "Contacts"
            try
                set p to first person whose id is "\(escapedId)"
                set contactId to id of p
                set firstName to first name of p
                set lastName to last name of p
                set orgName to organization of p
                set jobTitleVal to job title of p
                set noteVal to note of p
                set birthdayVal to ""
                try
                    set birthdayVal to birth date of p as string
                end try

                set emailList to ""
                repeat with e in emails of p
                    if emailList is not "" then set emailList to emailList & ";;;"
                    set emailList to emailList & (value of e)
                end repeat

                set phoneList to ""
                repeat with ph in phones of p
                    if phoneList is not "" then set phoneList to phoneList & ";;;"
                    set phoneList to phoneList & (value of ph)
                end repeat

                set addrList to ""
                repeat with a in addresses of p
                    if addrList is not "" then set addrList to addrList & ";;;"
                    set addrParts to ""
                    try
                        set addrParts to (street of a) & ", " & (city of a) & ", " & (state of a) & " " & (zip of a) & ", " & (country of a)
                    end try
                    set addrList to addrList & addrParts
                end repeat

                return contactId & "\t" & firstName & "\t" & lastName & "\t" & orgName & "\t" & jobTitleVal & "\t" & noteVal & "\t" & birthdayVal & "\t" & emailList & "\t" & phoneList & "\t" & addrList
            on error
                return ""
            end try
        end tell
        """

        let result = try runAppleScript(script)
        if result.isEmpty {
            return nil
        }
        let contacts = parseContacts(result)
        return contacts.first
    }

    // MARK: - Create Contact

    public func createContact(
        firstName: String?,
        lastName: String?,
        email: String?,
        phone: String?,
        organization: String?,
        jobTitle: String?,
        note: String?
    ) async throws -> String {
        let fn = (firstName ?? "").replacingOccurrences(of: "\"", with: "\\\"")
        let ln = (lastName ?? "").replacingOccurrences(of: "\"", with: "\\\"")
        let org = (organization ?? "").replacingOccurrences(of: "\"", with: "\\\"")
        let jt = (jobTitle ?? "").replacingOccurrences(of: "\"", with: "\\\"")
        let em = (email ?? "").replacingOccurrences(of: "\"", with: "\\\"")
        let ph = (phone ?? "").replacingOccurrences(of: "\"", with: "\\\"")

        var setProps = "set newPerson to make new person with properties {"
        var props: [String] = []
        if !fn.isEmpty { props.append("first name:\"\(fn)\"") }
        if !ln.isEmpty { props.append("last name:\"\(ln)\"") }
        if !org.isEmpty { props.append("organization:\"\(org)\"") }
        if !jt.isEmpty { props.append("job title:\"\(jt)\"") }
        setProps += props.joined(separator: ", ") + "}"

        var emailScript = ""
        if !em.isEmpty {
            emailScript = "make new email at end of emails of newPerson with properties {label:\"work\", value:\"\(em)\"}"
        }

        var phoneScript = ""
        if !ph.isEmpty {
            phoneScript = "make new phone at end of phones of newPerson with properties {label:\"mobile\", value:\"\(ph)\"}"
        }

        let script = """
        tell application "Contacts"
            \(setProps)
            \(emailScript)
            \(phoneScript)
            save
            return id of newPerson
        end tell
        """

        return try runAppleScript(script)
    }

    // MARK: - Update Contact

    public func updateContact(
        id: String,
        firstName: String?,
        lastName: String?,
        organization: String?,
        jobTitle: String?,
        note: String?
    ) async throws -> Bool {
        let escapedId = id.replacingOccurrences(of: "\"", with: "\\\"")

        var updates: [String] = []
        if let fn = firstName {
            updates.append("set first name of p to \"\(fn.replacingOccurrences(of: "\"", with: "\\\""))\"")
        }
        if let ln = lastName {
            updates.append("set last name of p to \"\(ln.replacingOccurrences(of: "\"", with: "\\\""))\"")
        }
        if let org = organization {
            updates.append("set organization of p to \"\(org.replacingOccurrences(of: "\"", with: "\\\""))\"")
        }
        if let jt = jobTitle {
            updates.append("set job title of p to \"\(jt.replacingOccurrences(of: "\"", with: "\\\""))\"")
        }

        guard !updates.isEmpty else { return false }

        let script = """
        tell application "Contacts"
            try
                set p to first person whose id is "\(escapedId)"
                \(updates.joined(separator: "\n            "))
                save
                return "true"
            on error
                return "false"
            end try
        end tell
        """

        let result = try runAppleScript(script)
        return result == "true"
    }

    // MARK: - Delete Contact

    public func deleteContact(id: String) async throws -> Bool {
        let escapedId = id.replacingOccurrences(of: "\"", with: "\\\"")

        let script = """
        tell application "Contacts"
            try
                set p to first person whose id is "\(escapedId)"
                delete p
                save
                return "true"
            on error
                return "false"
            end try
        end tell
        """

        let result = try runAppleScript(script)
        return result == "true"
    }

    // MARK: - Groups

    public func listGroups() async throws -> [ContactGroup] {
        let script = """
        tell application "Contacts"
            set output to ""
            repeat with g in groups
                set gId to id of g
                set gName to name of g
                set memberCount to count of people of g
                set recordLine to gId & "\t" & gName & "\t" & memberCount
                if output is not "" then set output to output & linefeed
                set output to output & recordLine
            end repeat
            return output
        end tell
        """

        let result = try runAppleScript(script)
        return parseGroups(result)
    }

    public func getGroupMembers(groupName: String) async throws -> [Contact] {
        let escapedName = groupName.replacingOccurrences(of: "\"", with: "\\\"")

        let script = """
        tell application "Contacts"
            set output to ""
            try
                set g to first group whose name is "\(escapedName)"
                repeat with p in people of g
                    set contactId to id of p
                    set firstName to first name of p
                    set lastName to last name of p
                    set orgName to organization of p
                    set jobTitleVal to job title of p
                    set noteVal to note of p
                    set birthdayVal to ""
                    try
                        set birthdayVal to birth date of p as string
                    end try

                    set emailList to ""
                    repeat with e in emails of p
                        if emailList is not "" then set emailList to emailList & ";;;"
                        set emailList to emailList & (value of e)
                    end repeat

                    set phoneList to ""
                    repeat with ph in phones of p
                        if phoneList is not "" then set phoneList to phoneList & ";;;"
                        set phoneList to phoneList & (value of ph)
                    end repeat

                    set addrList to ""
                    repeat with a in addresses of p
                        if addrList is not "" then set addrList to addrList & ";;;"
                        set addrParts to ""
                        try
                            set addrParts to (street of a) & ", " & (city of a) & ", " & (state of a) & " " & (zip of a) & ", " & (country of a)
                        end try
                        set addrList to addrList & addrParts
                    end repeat

                    set line to contactId & "\t" & firstName & "\t" & lastName & "\t" & orgName & "\t" & jobTitleVal & "\t" & noteVal & "\t" & birthdayVal & "\t" & emailList & "\t" & phoneList & "\t" & addrList
                    if output is not "" then set output to output & linefeed
                    set output to output & line
                end repeat
            end try
            return output
        end tell
        """

        let result = try runAppleScript(script)
        return parseContacts(result)
    }

    // MARK: - Phone Lookup

    public func lookupByPhone(phoneNumber: String) async throws -> Contact? {
        let normalizedInput = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        guard !normalizedInput.isEmpty else { return nil }

        let searchSuffix = normalizedInput.count >= 7 ? String(normalizedInput.suffix(7)) : normalizedInput

        let script = """
        with timeout of 30 seconds
            tell application "Contacts"
                repeat with p in people
                    repeat with ph in phones of p
                        if value of ph contains "\(searchSuffix)" then
                            set contactId to id of p
                            set firstName to first name of p
                            set lastName to last name of p
                            set orgName to organization of p
                            set jobTitleVal to job title of p
                            set noteVal to note of p
                            set birthdayVal to ""
                            try
                                set birthdayVal to birth date of p as string
                            end try

                            set emailList to ""
                            repeat with e in emails of p
                                if emailList is not "" then set emailList to emailList & ";;;"
                                set emailList to emailList & (value of e)
                            end repeat

                            set phoneList to ""
                            repeat with ph2 in phones of p
                                if phoneList is not "" then set phoneList to phoneList & ";;;"
                                set phoneList to phoneList & (value of ph2)
                            end repeat

                            set addrList to ""
                            repeat with a in addresses of p
                                if addrList is not "" then set addrList to addrList & ";;;"
                                set addrParts to ""
                                try
                                    set addrParts to (street of a) & ", " & (city of a) & ", " & (state of a) & " " & (zip of a) & ", " & (country of a)
                                end try
                                set addrList to addrList & addrParts
                            end repeat

                            return contactId & "\t" & firstName & "\t" & lastName & "\t" & orgName & "\t" & jobTitleVal & "\t" & noteVal & "\t" & birthdayVal & "\t" & emailList & "\t" & phoneList & "\t" & addrList
                        end if
                    end repeat
                end repeat
                return ""
            end tell
        end timeout
        """

        let result = try runAppleScript(script, timeout: 15)
        if result.isEmpty {
            return nil
        }
        let contacts = parseContacts(result)
        return contacts.first
    }

    // MARK: - Parsing Helpers

    private func parseContacts(_ output: String) -> [Contact] {
        guard !output.isEmpty else { return [] }

        return output.components(separatedBy: "\n").compactMap { line -> Contact? in
            let fields = line.components(separatedBy: "\t")
            guard fields.count >= 9 else { return nil }

            let id = fields[0]
            let firstName = fields[1] == "missing value" ? "" : fields[1]
            let lastName = fields[2] == "missing value" ? "" : fields[2]
            let organization = fields[3] == "missing value" ? nil : (fields[3].isEmpty ? nil : fields[3])
            let jobTitle = fields[4] == "missing value" ? nil : (fields[4].isEmpty ? nil : fields[4])
            let note = fields[5] == "missing value" ? nil : (fields[5].isEmpty ? nil : fields[5])
            let birthday = fields[6] == "missing value" ? nil : (fields[6].isEmpty ? nil : fields[6])
            let emails = fields[7].isEmpty ? [] : fields[7].components(separatedBy: ";;;").filter { !$0.isEmpty && $0 != "missing value" }
            let phones = fields[8].isEmpty ? [] : fields[8].components(separatedBy: ";;;").filter { !$0.isEmpty && $0 != "missing value" }
            let addresses = fields.count > 9 && !fields[9].isEmpty ? fields[9].components(separatedBy: ";;;").filter { !$0.isEmpty && $0 != "missing value" } : []

            let fullName = [firstName, lastName].filter { !$0.isEmpty }.joined(separator: " ")

            return Contact(
                id: id,
                firstName: firstName,
                lastName: lastName,
                fullName: fullName.isEmpty ? (organization ?? "Unknown") : fullName,
                emails: emails,
                phones: phones,
                organization: organization,
                jobTitle: jobTitle,
                note: note,
                birthday: birthday,
                addresses: addresses
            )
        }
    }

    private func parseGroups(_ output: String) -> [ContactGroup] {
        guard !output.isEmpty else { return [] }

        return output.components(separatedBy: "\n").compactMap { line -> ContactGroup? in
            let fields = line.components(separatedBy: "\t")
            guard fields.count >= 3 else { return nil }

            let id = fields[0]
            let name = fields[1]
            let memberCount = Int(fields[2]) ?? 0

            return ContactGroup(id: id, name: name, memberCount: memberCount)
        }
    }
}
