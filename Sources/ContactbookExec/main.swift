import ContactbookCLI

@main
struct ContactbookMain {
    static func main() async throws {
        try await Contactbook.main()
    }
}
