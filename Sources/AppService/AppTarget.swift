//
//  File.swift
//  
//
//  Created by Ratnesh Jain on 21/10/23.
//

import Foundation
@preconcurrency import Moya

public struct AppTarget: Sendable {
    public var url: URL
    public var path: String
    public var method: Moya.Method
    public var task: Moya.Task
    public var authType: AuthorizationType?
    public var additionalHeaders: [String: String]?
    
    var queries: [URLQueryItem]
    
    public init(
        url: URL,
        path: String,
        headers: [String: String]? = nil,
        method: Moya.Method,
        task: Moya.Task = .requestPlain,
        queries: [URLQueryItem] = [],
        authType: AuthorizationType? = .none,
        additionalHeaders: [String: String]? = nil
    ) {
        self.url = url
        self.path = path
        self.additionalHeaders = headers
        self.method = method
        self.task = task
        self.queries = queries
        self.authType = authType
        self.additionalHeaders = additionalHeaders
    }
}

extension AppTarget: QueryItemProvider {
    public var queryItems: [URLQueryItem] {
        queries
    }
}

extension AppTarget: TargetType, AccessTokenAuthorizable, XAuthorizable {
    public var authorizationType: Moya.AuthorizationType? {
        self.authType
    }
    
    public var baseURL: URL {
        url
    }
    
    public var headers: [String : String]? {
        additionalHeaders
    }
}
