import Foundation

struct GeminiService {
    private let apiKey = Config.geminiAPIKey
    private let model = Config.geminiModel
    
    func send(userText: String, history: [ChatMessage]) async throws -> String {
        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(apiKey)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = buildRequestBody(userText: userText, history: history)
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw GeminiError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        
        guard let firstCandidate = geminiResponse.candidates.first,
              let firstPart = firstCandidate.content.parts.first else {
            throw GeminiError.noContent
        }
        
        return firstPart.text
    }
    
    private func buildRequestBody(userText: String, history: [ChatMessage]) -> GeminiRequest {
        var contents: [GeminiContent] = []
        
        // Add system instruction as the first user message
        contents.append(GeminiContent(
            role: "user",
            parts: [GeminiPart(text: "You are a helpful AI assistant. Continue this conversation naturally.")]
        ))
        contents.append(GeminiContent(
            role: "model",
            parts: [GeminiPart(text: "Understood. I'll be helpful and respond naturally.")]
        ))
        
        // Add conversation history
        for message in history {
            let role = message.role == "user" ? "user" : "model"
            contents.append(GeminiContent(
                role: role,
                parts: [GeminiPart(text: message.text)]
            ))
        }
        
        // Add current user message
        contents.append(GeminiContent(
            role: "user",
            parts: [GeminiPart(text: userText)]
        ))
        
        return GeminiRequest(contents: contents)
    }
}
// MARK: - Request/Response Models

struct GeminiRequest: Codable {
    let contents: [GeminiContent]
}

struct GeminiContent: Codable {
    let role: String
    let parts: [GeminiPart]
}

struct GeminiPart: Codable {
    let text: String
}

struct GeminiResponse: Codable {
    let candidates: [GeminiCandidate]
}

struct GeminiCandidate: Codable {
    let content: GeminiContent
}

// MARK: - Errors

enum GeminiError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int)
    case noContent
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from Gemini API"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .noContent:
            return "No content in Gemini response"
        }
    }
}

