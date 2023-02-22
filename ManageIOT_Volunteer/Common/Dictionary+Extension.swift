import Foundation

extension Dictionary {

    func percentEncoded() -> Data? {
        return map { key, val in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedVal = "\(val)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedVal
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }

}
