import MacroTesting
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(AppServiceMacros)
import AppServiceMacros

let testMacros: [String: Macro.Type] = [
    "stringify": StringifyMacro.self,
]
#endif

final class AppServiceTests: XCTestCase {
    
    override func invokeTest() {
        withMacroTesting(macros: [
            StringifyMacro.self,
            ServiceMacro.self,
            RequestMacro.self
        ]) {
            super.invokeTest()
        }
    }
    
    func testStringifyMacro() throws {
        #if canImport(AppServiceMacros)
        assertMacro {
            """
            #stringify(a + b)
            """
        } expansion: {
            """
            (a + b, "a + b")
            """
        }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroWithStringLiteral() throws {
        #if canImport(AppServiceMacros)
        assertMacro {
            """
            #stringify("Hello, \(name)")
            """
        } expansion: {
            """
            ("Hello, -[AppServiceTests testMacroWithStringLiteral]", #""Hello, -[AppServiceTests testMacroWithStringLiteral]""#)
            """
        }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testRequestMacro() throws {
        #if canImport(AppServiceMacros)
        assertMacro {
            """
            @Service
            enum Target {
                @Request(response: String.self)
                case login
            
                @Request(.post, authType: .bearer, response: Int.self)
                case resource
            }
            """
        } expansion: {
            """
            enum Target {
                case login
            
                case resource
            }

            extension Target {
                public static func login(queries: @autoclosure () -> [URLQueryItem] = [], request: Encodable? = nil) async throws -> String {

                }

                public static func resource(queries: @autoclosure () -> [URLQueryItem] = [], request: Encodable? = nil) async throws -> Int {

                }
            }
            """
        }
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
