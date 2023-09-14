//
//  IntExtensions.swift
//  RecipeBook-CoreML
//
//  Created by Łukasz Bielawski on 14/09/2023.
//

import Foundation

extension Int {
    var romanNumeral: String {
        var integerValue = self
        if self >= 4000 {
            return String(self)
        }
        var numeralString = ""
        let mappingList: [(Int, String)] = [(1000, "M"),
                                            (900, "CM"),
                                            (500, "D"),
                                            (400, "CD"),
                                            (100, "C"),
                                            (90, "XC"),
                                            (50, "L"),
                                            (40, "XL"),
                                            (10, "X"),
                                            (9, "IX"),
                                            (5, "V"),
                                            (4, "IV"),
                                            (1, "I")]
        for index in mappingList {
            while integerValue >= index.0 {
                integerValue -= index.0
                numeralString += index.1
            }
        }
        return numeralString
    }
}
