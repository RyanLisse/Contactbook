import Foundation
import MCP
import Core

public actor ContactbookMCPServer {
    private let toolHandler: ToolHandler

    public init() {
        self.toolHandler = ToolHandler()
    }

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

        await server.withMethodHandler(ListTools.self) { _ in
            ListTools.Result(tools: ToolHandler.allTools)
        }

        await server.withMethodHandler(CallTool.self) { params in
            try await self.toolHandler.callTool(params)
        }

        try await server.start(transport: transport)
    }
}
