//
//  AddToShoppingListViewController.swift
//  FoodMate
//
//  Created by Jesse Lupica on 3/15/15.
//  Copyright (c) 2015 Jesse Lupica. All rights reserved.
//

import UIKit

class AddToShoppingListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var myRecipe: Recipe!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.backgroundColor = UIColor.whiteColor()
        println(myRecipe)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        var shoppingList = retrieveData("shoppingList") as! [Ingredient]
        
        var ingredientsToBeAdded: [Ingredient] = []
        var indexPaths: [NSIndexPath]
        indexPaths = self.tableView.indexPathsForSelectedRows() as! [NSIndexPath]
        for indexPath in indexPaths {
            myRecipe.ingredients[indexPath.row].notesFromRecipe = myRecipe.title
            ingredientsToBeAdded.append(myRecipe.ingredients[indexPath.row])
        }
        
        for ingredient in ingredientsToBeAdded {
            
            var ingredientInShoppingList: Ingredient = Ingredient()
            var match = false
            for(var i = 0; i < shoppingList.count; i++) {
                if(shoppingList[i].food == ingredient.food) {
                    ingredientInShoppingList = shoppingList[i]
                    match = true
                    break;
                }
            }
            
            if(match == true) {
                
                if(ingredientInShoppingList.notesFromRecipe != nil) {
                    ingredientInShoppingList.notesFromRecipe.stringByAppendingString(", \(myRecipe.title)")
                } else {
                    ingredientInShoppingList.notesFromRecipe = myRecipe.title
                }
                
            }
            else {
                shoppingList.append(ingredient)
            }
        }
        
        
        saveData(shoppingList, title: "shoppingList")
        performSegueWithIdentifier("unwindFromView", sender: self)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        tableView.editing = true
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myRecipe.ingredients.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = "\(myRecipe.ingredients[indexPath.row].food)"
        cell.detailTextLabel?.text = "\(myRecipe.ingredients[indexPath.row].quantity) \(myRecipe.ingredients[indexPath.row].units)"
        println(myRecipe.ingredients[indexPath.row].food)
        println("\(myRecipe.ingredients[indexPath.row].quantity) \(myRecipe.ingredients[indexPath.row].units)")
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
        return cell
    }
    
    func retrieveData(inputString: String) -> AnyObject {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0] as! String
        let path = documentsDirectory.stringByAppendingPathComponent("\(inputString).plist")
        let fileManager = NSFileManager.defaultManager()
        println(path)
        // check if file exists
        if !fileManager.fileExistsAtPath(path) {
            // create an empty file if it doesn't exist
            if let bundle = NSBundle.mainBundle().pathForResource("DefaultFile", ofType: "plist") {
                fileManager.copyItemAtPath(bundle, toPath: path, error:nil)
            }
            println("help!")
        }
        var storedObject: AnyObject?
        if let rawData = NSData(contentsOfFile: path) {
            // do we get serialized data back from the attempted path?
            // if so, unarchive it into an AnyObject, and then convert to an array of HighScores, if possible
            storedObject  = NSKeyedUnarchiver.unarchiveObjectWithData(rawData);
        }
        return storedObject!
    }

    
    func saveData(listToSave: [Ingredient], title: String) {
        // find the save directory our app has permission to use, and save the serialized version of self.scores - the HighScores array.
        let saveData = NSKeyedArchiver.archivedDataWithRootObject(listToSave);
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray;
        let documentsDirectory = paths.objectAtIndex(0) as! NSString;
        
        let path = documentsDirectory.stringByAppendingPathComponent("\(title).plist");
        println(path)
        
        saveData.writeToFile(path, atomically: true);
    }
}
