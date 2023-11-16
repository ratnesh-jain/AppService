//
//  File.swift
//  
//
//  Created by Ratnesh Jain on 21/10/23.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ServiceMacro: ExtensionMacro {
    enum Error: Swift.Error {
        case requiresEnumDecl
    }
    
    public static func expansion<D: DeclGroupSyntax, T: TypeSyntaxProtocol, C: MacroExpansionContext>(of node: AttributeSyntax, attachedTo declaration: D, providingExtensionsOf type: T, conformingTo protocols: [TypeSyntax], in context: C) throws -> [ExtensionDeclSyntax] {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            throw Error.requiresEnumDecl
        }
        
        let nodeTitle = enumDecl.name.text
        
        let enumCasesDecls = (enumDecl.memberBlock.members).compactMap({$0.as(MemberBlockItemSyntax.self)?.decl.as(EnumCaseDeclSyntax.self)})
        
        let enumAttributesDecls = enumCasesDecls.map { $0.attributes.compactMap {$0.as(AttributeSyntax.self)} }
        
        let argumentList = enumAttributesDecls.map { $0.compactMap { $0.asRequest } }.flatMap { $0 }
        
        let caseNames = enumCasesDecls.map { $0.elements.map { $0.name.text }}.flatMap { $0 }
        
        let functions: String = zip(caseNames, argumentList).map { functionName, arguments in
            """
            public static func \(functionName)(queries: @autoclosure () -> [URLQueryItem] = [], request: Encodable? = nil) async throws -> \(arguments.2) {
                
            }
            """
        }.joined(separator: "\n\n")
        
        return [
            try ExtensionDeclSyntax(
            """
            extension \(raw: nodeTitle) {
                \(raw: functions)
            }
            """
            )
        ]
    }
}

extension EnumCaseDeclSyntax {
    var caseNames: [String] {
        self.elements.map { $0.name.text }
    }
}

extension AttributeSyntax {
    var asRequest: ([String], String, String)? {
        guard let identifier = self.attributeName.as(IdentifierTypeSyntax.self)?.name.text,
              identifier == "Request"
        else {
            return nil
        }
        let expressions = self.labeledExprs
        if expressions.count == 1, let response = expressions.first?.responseType {
            return (["get"], "none", response)
        }
        if expressions.count == 2 {
            var method = ""
            var auth = "none"
            if let methodVal = expressions.first?.methods {
                method = methodVal
            } else if let authType = expressions.first?.authType {
                method = "get"
                auth = authType
            }
            if let response = expressions.last?.responseType {
                return ([method], auth, response)
            }
        }
        if expressions.count == 3 {
            var method = "get"
            var authType = "none"
            var response = "AVoid"
            if let methodVal = expressions[0].methods {
                method = methodVal
            }
            if let authValue = expressions[1].methods {
                authType = authValue
            }
            if let responseVal = expressions[2].responseType {
                response = responseVal
            }
            return ([method], authType, response)
        }
        return nil
    }
    
    var labeledExprs: [LabeledExprSyntax] {
        let items = self.arguments?.as(LabeledExprListSyntax.self)?.compactMap({$0.as(LabeledExprSyntax.self)})
        return items ?? []
    }
}

extension LabeledExprSyntax {
    var authType: String? {
        guard label?.text == "authType" else { return nil }
        let value = self.expression.as(MemberAccessExprSyntax.self)?.declName.baseName.text
        return value ?? "none"
    }
    
    var responseType: String? {
        guard label?.text == "response" else { return nil }
        let value = self.expression.as(MemberAccessExprSyntax.self)?.base?.as(DeclReferenceExprSyntax.self)?.baseName.text
        return value
    }
    
    var methods: String? {
        guard label == nil else { return nil }
        let value = self.expression.as(MemberAccessExprSyntax.self)?.declName.baseName.text
        return value ?? "get"
    }
}
