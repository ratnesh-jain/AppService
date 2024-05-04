//
//  File.swift
//  
//
//  Created by Ratnesh Jain on 21/10/23.
//

import Foundation
import Moya

public struct AVoid: Codable, Hashable {
    public init() {}
}

public enum DownloadStream: Equatable {
    case progressing(Double)
    case completed
}

open class Service<Target: TargetType> {
    
    enum ServiceError: Swift.Error, LocalizedError, Equatable {
        case message(String)
        case tokenExpired
        case canNotRefreshToken
        
        public var errorDescription: String?  {
            switch self {
            case .message(let string):
                return string
            case .tokenExpired:
                return "Token expired"
            case .canNotRefreshToken:
                return "Please login again"
            }
        }
    }
    
    public init() {}
    public var extraPlugins: [PluginType] = []
    
    private lazy var provider: MoyaProvider<Target> = {
        let networkPlugin = NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        let accessTokenPlugin = XAuthTokenPlugin { type in
            return self.accessToken(for: type)
        }
        let queryItemResolver = QueryItemResolver()
        var plugins: [PluginType] = [networkPlugin, accessTokenPlugin, queryItemResolver]
        plugins.append(contentsOf: extraPlugins)
        return .init(plugins: plugins)
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-ddTHH:mm:ss.SSSSSSSSSZ"
        // 2023-10-05T00:44:12.787734825Z
        return formatter
    }()
    
    private lazy var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(self.dateFormatter)
        return decoder
    }()
    
    public func fetch<T: Codable>(_ target: Target) async throws -> T {
        try await withUnsafeThrowingContinuation { continuation in
            self.provider.request(target) { result in
                switch result {
                case .success(let response):
                    do {
                        let response = try response.filterSuccessfulStatusCodes()
                        if type(of: T.self) == type(of: String.self) {
                            let decoded = try response.mapString()
                            continuation.resume(returning: decoded as! T)
                        } else if type(of: T.self) == type(of: AVoid.self) {
                            continuation.resume(returning: AVoid() as! T)
                        } else {
                            let decoded = try response.map(T.self, using: self.jsonDecoder)
                            continuation.resume(returning: decoded)
                        }
                        
                    } catch {
                        if response.statusCode == 404 {
                            continuation.resume(throwing: ServiceError.message("No item found"))
                        } else if response.statusCode == 401 {
                            continuation.resume(throwing: ServiceError.tokenExpired)
                        } else {
                            continuation.resume(throwing: error)
                        }
                        print(error)
                    }
                case .failure(let error):
                    print(error)
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func stream(_ target: Target) -> AsyncThrowingStream<DownloadStream, Error> {
        AsyncThrowingStream { continuation in
            self.provider.request(target, callbackQueue: nil) { progress in
                continuation.yield(.progressing(progress.progress))
            } completion: { result in
                switch result {
                case .success:
                    continuation.yield(.completed)
                    continuation.finish()
                    
                case .failure(let error):
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    open func accessToken(for type: TargetType) -> String {
        return ""
    }
    
}
