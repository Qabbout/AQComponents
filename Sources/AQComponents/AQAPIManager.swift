//
//  AQAPIManager.swift
//
//
//  Created by Abdulrahman Qabbout on 27/06/2023.
//

import Foundation
import Network
import Combine

private enum APIError: Error {
    case invalidURL
    case requestFailed(Error)
    case decodeFailed(Error)
    case invalidStatusCode(Int)
    case noInternetConnection
}

private enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

private enum ContentType: String {
    case json = "application/json"
}

final private class JSONDecoderService {
    func decode<T: Decodable>(_ data: Data, expecting type: T.Type) throws -> T {
        let decoder = JSONDecoder()
        return try decoder.decode(type, from: data)
    }
}

final public class AQAPIManager {

    private init(){}
    
    private static var defaultHeaders: [String: String] {
        return ["Content-Type": "application/json"]
    }

    @available(iOS 13.0.0, *)
    fileprivate static func request<T: Decodable>(_ urlString: String,
                                     method: HTTPMethod,
                                     session: URLSession = URLSession(configuration: URLSessionConfiguration.default),
                                     decoderService: JSONDecoderService = JSONDecoderService(),
                                     headers: [String: String]? = nil,
                                     timeout: TimeInterval = 30.0,
                                     parameters: [String: Any] = [:],
                                     expecting type: T.Type) async -> Result<T, APIError> {

            // Check network connectivity
        if !AQNetworkMonitor.shared.isConnected {
            return .failure(.noInternetConnection)
        }

        session.configuration.timeoutIntervalForRequest = timeout

        guard var urlComponents = URLComponents(string: urlString) else {
            return .failure(.invalidURL)
        }

        guard let url = urlComponents.url else {
            return .failure(.invalidURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        let requestHeaders = headers ?? defaultHeaders
        request.allHTTPHeaderFields = requestHeaders


        switch method {
        case .get:
            urlComponents.queryItems = parameters.map {
                URLQueryItem(name: $0.key, value: "\($0.value)")
            }
        case .post:
            if let body = try? JSONSerialization.data(withJSONObject: parameters, options: []) {
                request.httpBody = body
            }
        }

        do {
            let (data, response) = try await session.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                dump(httpResponse.statusCode, name: "Response Code")
                dump(httpResponse.allHeaderFields, name: "Response Headers")

                if (200..<300).contains(httpResponse.statusCode) == false {
                    return .failure(.invalidStatusCode(httpResponse.statusCode))
                }
            }
            let decodedData = try decoderService.decode(data, expecting: type)
            dump(decodedData,name: "Decoded Data")
            return .success(decodedData)
        } catch {
            dump(error,name:"Error")
            return .failure(.requestFailed(error))
        }
    }
}

@available(iOS 13.0, *)
final public class AQNetworkMonitor {
    static let shared = AQNetworkMonitor()

    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")

    public var isConnected: Bool {
        return monitor.currentPath.status == .satisfied
    }
    public var isConnectedListener: PassthroughSubject<Bool, Never> = PassthroughSubject<Bool, Never>()

    private init() {
        self.monitor = NWPathMonitor()
    }

    func startMonitoring() {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                dump("We're connected!")
                self.isConnectedListener.send(true)
            } else {
                dump("No connection.")
                self.isConnectedListener.send(false)
            }
        }
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}
