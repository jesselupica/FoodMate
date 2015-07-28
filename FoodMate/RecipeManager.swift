//
//  RecipeManager.swift
//  FoodMate
//
//  Created by Jesse Lupica on 2/19/15.
//  Copyright (c) 2015 Jesse Lupica. All rights reserved.
//

import UIKit

class RecipeManager: NSObject {
    var recipe: Recipe!
    
     required init(recipeName: String) {
        super.init()
                // load existing high scores or set up an empty array
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0] as! String
        let path = documentsDirectory.stringByAppendingPathComponent("\(recipeName).plist")
        let fileManager = NSFileManager.defaultManager()
        println("help!")
        // check if file exists
        if !fileManager.fileExistsAtPath(path) {
            // create an empty file if it doesn't exist
            if let bundle = NSBundle.mainBundle().pathForResource("DefaultFile", ofType: "plist") {
                fileManager.copyItemAtPath(bundle, toPath: path, error:nil)
            }
            println("help!")
        }
        
        if let rawData = NSData(contentsOfFile: path) {
            // do we get serialized data back from the attempted path?
            // if so, unarchive it into an AnyObject, and then convert to an array of HighScores, if possible
            var storedRecipe: AnyObject? = NSKeyedUnarchiver.unarchiveObjectWithData(rawData);
            self.recipe = storedRecipe as? Recipe
        }
    }
    
    func returnRecipe() -> Recipe! {
        return recipe 
    }
    
    func save(recipeToSave: Recipe) {
        // find the save directory our app has permission to use, and save the serialized version of self.scores - the HighScores array.
        let saveData = NSKeyedArchiver.archivedDataWithRootObject(recipeToSave);
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray;
        let documentsDirectory = paths.objectAtIndex(0) as! NSString;
        let path = documentsDirectory.stringByAppendingPathComponent("\(recipeToSave.title).plist");
        
        saveData.writeToFile(path, atomically: true);
    }
  
    // a simple function to add a new high score, to be called from your game logic
    // note that this doesn't sort or filter the scores in any way
    func editRecipe(newRecipe: Recipe) {
        recipe = newRecipe
        self.save(newRecipe);
    }
}