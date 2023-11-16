//
//  File.swift
//  
//
//  Created by Ratnesh Jain on 10/23/23.
//

import Foundation
import Moya

public protocol XAuthorizable {
    var authorizationType: AuthorizationType? { get }
}

public struct XAuthTokenPlugin: PluginType {
    public typealias TokenClosure = (TargetType) -> String
    
    public let tokenClosure: TokenClosure
    
    public init(tokenClosure: @escaping TokenClosure) {
        self.tokenClosure = tokenClosure
    }
    
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard let authorizable = target as? XAuthorizable,
              let authorizationType = authorizable.authorizationType else {
            return request
        }
        
        var request = request
        let realTarget = (target as? MultiTarget)?.target ?? target
        let type = authorizationType.value
        if type == "X-Auth" {
            let authValue = tokenClosure(realTarget)
            request.addValue(authValue, forHTTPHeaderField: "X-Auth")
            return request
        } else {
            return AccessTokenPlugin(tokenClosure: self.tokenClosure).prepare(request, target: target)
        }
        
    }
}
