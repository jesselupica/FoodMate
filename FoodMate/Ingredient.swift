//
//  Ingredient.swift
//  FoodMate
//
//  Created by Jesse Lupica on 3/16/15.
//  Copyright (c) 2015 Jesse Lupica. All rights reserved.
//

import Foundation

class Ingredient: NSObject, Printable {
    var food: String!
    var quantity: Double!
    var units: String!
    var notesFromRecipe: String!
    
    struct classPickerData {
        static var pickerData: [[String]] = [["1/16", "1/8", "1/4", "1/3", "1/2", "2/3", "1", "1 1/4", "1 1/3", "1 1/2", "1 2/3", "1 3/4", "2", "2 1/4", "2 1/2", "2 3/4", "3", "3 1/4", "3 1/2", "3 3/4", "4", "4 1/2", "5", "6", "7", "8", "9", "10", "11", "12" ],
            ["teaspoon", "tablespoon", "cup", "whole", "pint", "pinch", "pound", "ounce", "stick"]]
        
        static var pickerDataValueTranslation: [Double] = [(1/16), (1/8), (1/4), (1/3), (1/2), (2/3), 1, (5/4), (4/3), (3/2), (5/3), (7/4), 2, (9/4), (5/2), (11/4), 3, (13/4), (7/2), (15/4), 4, (9/2), 5, 6, 7, 8, 9, 10, 11, 12 ]
    }
        init(food: String, quantity: Double, units: String) {
        super.init()
        self.food = food
        self.quantity = quantity
        self.units = units
    }
    override init() {
        super.init()
    }
    required convenience init(coder decoder: NSCoder) {
        self.init()
        self.food = decoder.decodeObjectForKey("food") as! String?
        self.quantity = decoder.decodeObjectForKey("quantity") as! Double?
        self.units = decoder.decodeObjectForKey("units") as! String?
        self.notesFromRecipe = decoder.decodeObjectForKey("notesFromRecipe") as! String?
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.food, forKey: "food")
        aCoder.encodeObject(self.quantity, forKey: "quantity")
        aCoder.encodeObject(self.units, forKey: "units")
        aCoder.encodeObject(self.notesFromRecipe, forKey: "notesFromRecipe")
    }
    
    override var description : String {
        var output = "\(quantity) \(units) \(food)"
        return output
    }
    
    class func returnPickerData() -> [[String]] {
        return self.classPickerData.pickerData
    }
    
    class func returnPickerDataValueTranslation() -> [Double] {
        return self.classPickerData.pickerDataValueTranslation
    }
    
}