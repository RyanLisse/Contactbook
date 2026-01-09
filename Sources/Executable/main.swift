import CLI

@main
struct ContactbookMain {
    static func main() async throws {
        try await contactbook.main()
    }
}
