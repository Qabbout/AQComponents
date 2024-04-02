//
//  String+Extensions.swift
//
//
//  Created by Abdulrahman Qabbout on 02/04/2024.
//

import UIKit

public extension String {
    
    func toDate(format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: self)
    }
    
    func hexToInt() -> Int? {
        Int(self, radix: 16)
    }
    
    func replace(target: String, withString: String) -> String {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func getCurrentDateWith(format: String) -> String {
        let todaysDate = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: todaysDate as Date)
    }
    
    var isArabic: Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", "(?s).*\\p{Arabic}.*")
        return predicate.evaluate(with: self)
    }
    
    
    
    var toDictionary: [String: AnyHashable]? {
        guard let data = data(using: .utf8) else { return nil }
        if let dic = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: AnyHashable] {
            return dic
        }
        return nil
    }
    
    func isEmptyOrWhitespace() -> Bool {
        // Check empty string
        if isEmpty {
            return true
        }
        // Trim and check empty string
        return trimmingCharacters(in: .whitespaces) == ""
    }
    
    func maxLength(length: Int) -> String {
        var str = self
        let nsString = str as NSString
        if nsString.length > length {
            str = nsString.substring(with:
                                        NSRange(
                                            location: 0,
                                            length: nsString.length > length ? length : nsString.length
                                        )
            )
            str = str.appending("...")
        }
        return str
    }
    
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        // swiftformat:disable:next redundantSelf
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func ranges(of substring: String, options: CompareOptions = [], locale: Locale? = nil) -> [Range<Index>] {
        var ranges: [Range<Index>] = []
        while let range = range(of: substring, options: options, range: (ranges.last?.upperBound ?? startIndex) ..< endIndex, locale: locale) {
            ranges.append(range)
        }
        return ranges
    }
    
    func cleanupString() -> String {
        let theStringTrimmed = self.trimmingCharacters(in: CharacterSet.whitespaces)
        let wordsInStringArray: [Any] = theStringTrimmed.components(separatedBy: "\n")
        var returnString = String()
        for h in 0..<wordsInStringArray.count {
            let thisElement: String = wordsInStringArray[h] as? String ?? ""
            returnString = returnString + ("\(thisElement)")
        }
        return returnString
    }
    
    func isValidHtmlString() -> Bool {
        if self.isEmpty {
            return false
        }
        return (self.range(of: "<(\"[^\"]*\"|'[^']*'|[^'\">])*>", options: .regularExpression) != nil)
    }
    
    func removeHtmlTags() -> String {
        let regex = try? NSRegularExpression(pattern: ">([^<]+)<")
        let values = regex?.matches(in: self, range: NSRange(self.startIndex..., in: self))
            .map{ String(self[Range($0.range(at:1), in: self)!]) }
        if values?.isEmpty ?? false {
            return ""
        } else {
            return values?.joined(separator: " ") ?? ""
        }
    }
    
    var isPhoneNumber: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, self.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    var initials: String {
        var finalString = String()
        var words = components(separatedBy: .whitespacesAndNewlines)
        
        if let firstCharacter = words.first?.first {
            finalString.append(String(firstCharacter))
            words.removeFirst()
        }
        
        if let lastCharacter = words.last?.first {
            finalString.append(String(lastCharacter))
        }
        
        return finalString.uppercased()
    }
    
    func isValidEmail() -> Bool {
        if self.isEmptyOrWhitespace() {
            return false
        }
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func getTimeInMinutesAndSeconds(totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    func containString(key:String)-> Bool {
        if lowercased().range(of:key) != nil {
            return true
        }
        return false
    }
    
    func containStrings(values:[String])-> Bool {
        for value in values {
            if(containString(key: value)){
                return true
            }
        }
        return false
    }
    
    func getStringValueAfterCharacter(fullString:String, character:String) -> String {
        
        let str = fullString
        guard let index = str.firstIndex(of: Character(character)) else {
            return str
        }
        let indexx = str.index(after: index)
        let after = str.suffix(from: indexx)
        return String(after)
    }
    
    func getStringValueBeforeCharacter(fullString:String, character:String) -> String {
        
        let str = fullString
        guard let index = str.firstIndex(of: Character(character)) else {
            return str
        }
        let before = str.prefix(upTo: index)
        return String(before)
    }
    
    func replacingLastOccurrenceOfString(_ searchString: String,
                                         with replacementString: String,
                                         caseInsensitive: Bool = false) -> String{
        let options: String.CompareOptions
        if caseInsensitive {
            options = [.backwards, .caseInsensitive]
        } else {
            options = [.backwards]
        }
        
        if let range = self.range(of: searchString,
                                  options: options,
                                  range: nil,
                                  locale: nil) {
            
            return self.replacingCharacters(in: range, with: replacementString)
        }
        return self
    }
    
    func camelCaseToSnakeCase() -> String {
        return unicodeScalars.reduce("") {
            if CharacterSet.uppercaseLetters.contains($1) {
                return $0 + "_" + String($1).lowercased()
            } else {
                return $0 + String($1).lowercased()
            }
        }
    }
    
    func camelCaseToDotsCase() -> String {
        return unicodeScalars.reduce("") {
            if CharacterSet.uppercaseLetters.contains($1) {
                return $0 + "." + String($1).lowercased()
            } else {
                return $0 + String($1).lowercased()
            }
        }
    }
    
    func camelCaseToProperCase() -> String {
        return camelCaseToWords()
            .split(separator: " ")
            .map { String($0).capitalized }
            .joined(separator: " ")
    }
    
    func camelCaseToWords() -> String {
        return unicodeScalars.reduce("") {
            if CharacterSet.uppercaseLetters.contains($1) {
                return $0 + " " + String($1)
            } else {
                return $0 + String($1)
            }
        }
    }
    
    
}
