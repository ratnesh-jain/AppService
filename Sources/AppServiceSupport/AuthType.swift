//
//  File.swift
//  
//
//  Created by Ratnesh Jain on 21/10/23.
//

import Foundation
import Moya

public enum AuthType {
    case basic
    case bearer
    case custom(String)
    case none
}
