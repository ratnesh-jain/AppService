//
//  File.swift
//  
//
//  Created by Ratnesh Jain on 21/10/23.
//

import ComposableArchitecture
import Foundation
import Moya

public struct AppTarget {
    public var url: URL
    public var path: String
    public var method: Moya.Method
    public var task: Moya.Task
    public var authType: AuthorizationType?
    public var additionalHeaders: [String: String]?
    
    var queries: [URLQueryItem]
    
    public init(url: URL, path: String, headers: [String: String]? = nil, method: Moya.Method, task: Moya.Task = .requestPlain, queries: [URLQueryItem] = [], authType: AuthorizationType? = .none) {
        self.url = url
        self.path = path
        self.additionalHeaders = headers
        self.method = method
        self.task = task
        self.queries = queries
        self.authType = authType
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
