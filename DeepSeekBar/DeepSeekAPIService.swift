import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case noAPIKey
    case requestFailed(Error)
    case invalidResponse
    case httpError(statusCode: Int, message: String)
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的 URL"
        case .noAPIKey:
            return "未设置 API Key"
        case .requestFailed(let error):
            return "请求失败: \(error.localizedDescription)"
        case .invalidResponse:
            return "无效的服务器响应"
        case .httpError(let statusCode, let message):
            if statusCode == 401 {
                return "API Key 无效，请在设置中检查"
            }
            return "HTTP \(statusCode): \(message)"
        case .decodingFailed(let error):
            return "数据解析失败: \(error.localizedDescription)"
        }
    }
}

class DeepSeekAPIService {
    static let shared = DeepSeekAPIService()

    private let baseURL = "https://api.deepseek.com"
    private var apiKey: String?

    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        config.urlCache = nil
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        return URLSession(configuration: config)
    }()

    private init() {}

    func setAPIKey(_ key: String?) {
        apiKey = key
    }

    // MARK: - Fetch Balance

    func fetchBalance() async throws -> BalanceResponse {
        guard let apiKey else {
            throw APIError.noAPIKey
        }

        guard let url = URL(string: "\(baseURL)/user/balance") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.requestFailed(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? "unknown"
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: body)
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(BalanceResponse.self, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }
}
