//
//  File.swift
//  
//
//  Created by Ratnesh Jain on 11/16/23.
//

import Moya
import Foundation

public protocol QueryItemProvider {
    var queryItems: [URLQueryItem] { get }
}

public extension QueryItemProvider {
    var queryItems: [URLQueryItem] { [] }
}

struct QueryItemResolver: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        if let queryItems = (target as? QueryItemProvider)?.queryItems, !queryItems.isEmpty {
            if #available(iOS 16.0, tvOS 16.0, *) {
                request.url = request.url?.appending(queryItems: queryItems)
            } else {
                request.update(queryItems: queryItems)
            }
        }
        return request
    }
}

extension URLRequest {
    mutating func update(queryItems: [URLQueryItem]) {
        guard let url else { return }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        if let oldQueryItems = components?.queryItems {
            components?.queryItems = oldQueryItems + queryItems
        } else {
            components?.queryItems = queryItems
        }
        self.url = components?.url
    }
}
