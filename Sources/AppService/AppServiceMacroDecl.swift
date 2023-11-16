import AppServiceSupport

/// A macro that produces both a value and a string containing the
/// source code that generated the value. For example,
///
///     #stringify(x + y)
///
/// produces a tuple `(x + y, "x + y")`.
@freestanding(expression)
public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(module: "AppServiceMacros", type: "StringifyMacro")

@attached(peer)
public macro Request<T: Codable>(_ methods: ServiceMethod... = [.get], authType: AuthType = .none, response: T.Type) = #externalMacro(module: "AppServiceMacros", type: "RequestMacro")

@attached(extension, names: overloaded)
public macro Service() = #externalMacro(module: "AppServiceMacros", type: "ServiceMacro")
