import Foundation

extension Dictionary where Key == String, Value == Any {
    func string(for key: String) -> String? {
        return self[key] as? String
    }
    
    func nsNumber(for key: String) -> NSNumber? {
        return self[key] as? NSNumber
    }
    
    func int(for key: String) -> Int? {
        return self[key] as? Int
    }
    
    func double(for key: String) -> Double? {
        return self[key] as? Double
    }
    
    func float(for key: String) -> Float? {
        return self[key] as? Float
    }
    
    func bool(for key: String) -> Bool {
        return self[key] as? Bool ?? false
    }
    
    func date(for key: String) -> Date? {
        return self[key] as? Date
    }
    
    func dictionary(for key: String) -> [String: Any]? {
        return self[key] as? [String: Any]
    }
    
    func dictionaryArray(for key: String) -> [[String: Any]]? {
        return self[key] as? [[String: Any]]
    }
}
