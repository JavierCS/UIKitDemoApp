import Foundation

extension Bundle {
    static func getDictionaryFromPlistFile(_ fileName: String, in bundle: Bundle = .main) -> [String: Any]? {
        guard let plistUrl = bundle.url(forResource: fileName, withExtension: "plist"),
              let plistData = try? Data(contentsOf: plistUrl),
              let plistDictionary = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any] else { return nil }
        return plistDictionary
    }
    
    static func getDictionaryArrayFromPlistFile(_ fileName: String, in bundle: Bundle = .main) -> [[String: Any]]? {
        guard let plistUrl = bundle.url(forResource: fileName, withExtension: "plist"),
              let plistData = try? Data(contentsOf: plistUrl),
              let plistDictionaryArray = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [[String: Any]] else { return nil }
        return plistDictionaryArray
    }
}
