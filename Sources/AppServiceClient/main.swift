import AppService
import Foundation

let a = 17
let b = 25

let (result, code) = #stringify(a + b)

print("The value \(result) was produced by the code \"\(code)\"")

struct AppResource: Codable {}

@Service
enum Endpoints {
    @Request(.post, response: String.self)
    case login
    
    @Request(.get, .post, authType: .bearer, response: Int.self)
    case users
    
    @Request(response: AppResource.self)
    case resource
}
