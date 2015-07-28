//
//  Recipe.swift
//  FoodMate
//
//  Created by Jesse Lupica on 2/19/15.
//  Copyright (c) 2015 Jesse Lupica. All rights reserved.
//

import UIKit
import Alamofire

class Recipe:NSObject, NSCoding, Printable {
    var title: String!
    var rating: Double!
    var servings: Int!
    var course: String!
    var ingredients: [Ingredient] = []
    var instructions: [String] = []
    var imageURL: String!
    var image: UIImage!
    var id: String!
    
    required convenience init(coder decoder: NSCoder) {
        self.init()
        self.title = decoder.decodeObjectForKey("title") as! String?
        self.rating = decoder.decodeObjectForKey("rating") as! Double?
        self.servings = decoder.decodeObjectForKey("servings") as! Int?
        self.course = decoder.decodeObjectForKey("course") as! String?
        self.ingredients = decoder.decodeObjectForKey("ingredients") as! [Ingredient]!
        self.instructions = decoder.decodeObjectForKey("instructions") as! [String]!
        self.imageURL = decoder.decodeObjectForKey("imageURL") as! String?
        self.id = decoder.decodeObjectForKey("id") as! String?
    }
    
    convenience init(title: String, rating: Double, servings: Int, ingredients: [Ingredient], instructions: [String]) {
        self.init()
        self.title = title
        self.rating = rating
        self.servings = servings
        self.ingredients = ingredients
        self.instructions = instructions
    }
    
    convenience init(title: String, rating: Double, id: String, url: String) {
        self.init()
        self.title = title
        self.rating = rating
        self.id = id
        self.imageURL = url
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.title, forKey: "title")
        aCoder.encodeObject(self.rating, forKey: "rating")
        aCoder.encodeObject(self.servings, forKey: "servings")
        aCoder.encodeObject(self.course, forKey: "course")
        aCoder.encodeObject(self.ingredients, forKey: "ingredients")
        aCoder.encodeObject(self.instructions, forKey: "instructions")
        aCoder.encodeObject(self.imageURL, forKey: "imageURL")
        aCoder.encodeObject(self.id, forKey: "id")
        
    }
    
    func changeImageSize(newSize: String) {
        self.imageURL = self.imageURL.stringByReplacingOccurrencesOfString("s90-c", withString: newSize)
    }
    
    override var description : String {
        var output = "Recipe Title: \(title) \nRating: \(rating)\nCourse: \(self.course)\nServings: \(servings)\nIngredients: \(ingredients) \nInstructions: \(instructions)\nURL: \(imageURL)"
        return output
    }
    
}

