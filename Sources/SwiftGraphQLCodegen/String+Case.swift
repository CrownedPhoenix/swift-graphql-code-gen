import Foundation

extension String {

    /// Returns the string PascalCased.
    public var pascalCase: String {
        var result = ""

        var capitalize = true
        var isAbbreviation = false

        for index in self.indices {
            let char = self[index]

            if char.isNumber {
                result.append(char)
                capitalize = true
                isAbbreviation = false
                continue
            }

            // Skip all special characters.
            guard char.isLetter else {
                capitalize = true
                isAbbreviation = false
                continue
            }

            if char.isLowercase {
                if capitalize {
                    result.append(char.uppercased())
                } else {
                    result.append(char)
                }
                capitalize = false
                isAbbreviation = false
                continue
            }

            // abcABCDe
            // abcAbcDe
            if char.isUppercase {
                if index < self.index(before: self.endIndex) {
                    let isNextCharLowerCase = self[self.index(after: index)].isLowercase

                    // D -> D
                    if isNextCharLowerCase {
                        isAbbreviation = false
                        result.append(char)
                        capitalize = false
                        continue
                    }
                }

                // A -> A
                if !isAbbreviation {
                    isAbbreviation = true
                    result.append(char)
                    capitalize = false
                } else {
                    // B -> b
                    if capitalize {
                        result.append(char)
                        capitalize = false
                    } else {
                        result.append(char.lowercased())
                    }
                }
                continue
            }
        }

        return result
    }

    /// Returns the string – camelCased – while retaining all leading and trailing underscores
    ///
    ///     _foo_             // returns _foo_
    ///     ___foo_bar___     // returns ___fooBar___
    ///
    public var camelCasePreservingSurroundingUnderscores: String {
        let leading = prefix { $0 == "_" }
        let remainder = dropFirst(leading.count)
        let trimmed = remainder.trimmingCharacters(in: CharacterSet(["_"]))
        let trailing = String.SubSequence(repeating: "_", count: remainder.count - trimmed.count)

        let pascal = pascalCase
        return String(leading)
        + pascal[pascal.startIndex].lowercased()
        + pascal.dropFirst()
        + String(trailing)
    }
}
