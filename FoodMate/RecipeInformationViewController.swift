//
//  RecipeCreationTableViewController.swift
//  FoodMate
//
//  Created by Jesse Lupica on 2/6/15.
//  Copyright (c) 2015 Jesse Lupica. All rights reserved.
//

import UIKit

class RecipeInformationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    var canEditText: Bool = false
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var recipeTableView: UITableView!
    var recipe: Recipe!
    var recipeName: String! = ""
    
    var sliderCellTextLabelIDTag = 1
    var sliderIDTag = 2
    var previousSliderValue: Int! = 0
    
    var numRowsInSection: [Int]!
    let sectionTitles: [String]! = ["Title", "Details", "Ingredients", "Recipe"]
    var ingredientValues: [Double] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(tabBarController?.tabBar.hidden == true) {
            tabBarController?.tabBar.hidden = false
        }
        
        
        var myRecipeManager = RecipeManager(recipeName: recipeName)
        recipe = myRecipeManager.returnRecipe()
        if recipe.servings == 0 {
            recipe.servings = 4
        }
        
        numRowsInSection = [1, 2, recipe.ingredients.count, recipe.instructions.count]
        for ingredient in recipe.ingredients {
            ingredientValues.append(ingredient.quantity)
        }
    }

    @IBAction func editButtonPressed(sender: AnyObject) {
        performSegueWithIdentifier("addToShoppingListSegue", sender: self)
    }
   
    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 4
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return numRowsInSection[section]
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        if(indexPath.section == 0) {
            cell = createNormalCell(indexPath)
            cell.textLabel?.text = recipe.title
          
            
        }
        if(indexPath.section == 1) {
            if(indexPath.row == 0) {
                cell = createNormalCell(indexPath)
            cell.textLabel?.text = "Rating: \(recipe.rating)"
     
            }
            
            else {
                cell = tableView.dequeueReusableCellWithIdentifier("sliderCell", forIndexPath: indexPath) as! UITableViewCell
                var label = cell.viewWithTag(sliderCellTextLabelIDTag) as! UILabel
                if (recipe.servings > 1){
                    label.text = "Feeds \(recipe.servings) People"
                }
                else {
                    label.text = "Feeds \(recipe.servings) Person"
                }
                var slider = cell.viewWithTag(sliderIDTag) as! UISlider
                slider.setValue(Float(recipe.servings), animated: true)
            }
        }
        if(indexPath.section == 2) {
            cell = createNormalCell(indexPath)
            var ingredient = recipe.ingredients[indexPath.row]
            cell.textLabel?.text = "\(ingredient.food)"
            cell.detailTextLabel?.text = "\(ingredientValues[indexPath.row]) \(ingredient.units)"
        }
        if(indexPath.section == 3) {
            cell = createNormalCell(indexPath)
            cell.textLabel?.text = recipe.instructions[indexPath.row]
           

        }

        return cell
    }
    
    func createNormalCell(indexPath: NSIndexPath) -> UITableViewCell {
        var cell = recipeTableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        cell.detailTextLabel?.text = ""
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        recipeTableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath == NSIndexPath(forRow: 1, inSection: 1)) {
            return 70
        }
        var rowHeight = self.recipeTableView.rowHeight;
        return rowHeight
    }

    func rescaleIngredientValues(ratio: Double) {
        var indexPaths: [NSIndexPath] = []
        recipeTableView.beginUpdates()
        for (var i = 0; i < recipe.ingredients.count; i++) {
            ingredientValues[i] = recipe.ingredients[i].quantity * ratio
            var indexPath = NSIndexPath(forRow: i, inSection: 2)
            indexPaths.append(indexPath)
        }
        recipeTableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
        recipeTableView.endUpdates()
        
    }
    
    func formatUnitsForDisplay(value: Double, units: String) -> String {
        var normalizedValue: Double!
        var formattedString = ""
        var inOunces = false
        if(units == "whole") {
            return "\(value) \(units)"
        }
        if(units == "ounce" || units == "pound") {
            inOunces = true
            if(units == "pound") {
                normalizedValue = value * 16
            } else {
                normalizedValue = value
            }
        } else {
            if(units == "tablespoon") {
                normalizedValue = value * 3
            } else if(units == "cup") {
                normalizedValue = value * 48
            } else if(units == "pint") {
                normalizedValue = value * 96
            } else if (units == "teaspoon") {
                normalizedValue = value
            }
        }
        if(!inOunces) {
            if( (normalizedValue/96) >= 1 && units == "pint") {
                var numPints = Int(normalizedValue/96)
                formattedString.stringByAppendingString("\(numPints) pints, ")
                normalizedValue = normalizedValue - Double(numPints * 96)
            }
            if(normalizedValue/48 >= 0.25) {
                var numCups = normalizedValue/48
                numCups = numCups - (numCups % 0.25)
                formattedString.stringByAppendingString("\(numCups) cups, ")
                normalizedValue = normalizedValue - numCups * 48
            }
            if(normalizedValue/3 >= 0.5) {
                var numTbs = normalizedValue/3
                numTbs = numTbs - (numTbs % 0.25)
                formattedString.stringByAppendingString("\(numTbs) tablespoons, ")
                normalizedValue = normalizedValue - numTbs * 3
            }
            if(normalizedValue >= 0.0625) {
                var numTsp = normalizedValue - (normalizedValue % 0.0625)
                formattedString.stringByAppendingString("\(numTsp) tablespoons")
            }
            
        }
        
        return ""
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        let cell = recipeTableView.viewWithTag(sliderIDTag)?.superview?.superview as! UITableViewCell!
        let indexPath = recipeTableView.indexPathForCell(cell) as NSIndexPath!
        var textLabel = cell.viewWithTag(sliderCellTextLabelIDTag) as! UILabel
        
        var value: Int! = Int(sender.value)
        
        if(value == 1) {
            textLabel.text = "Feeds \(value) Person"
        }
        else {
            textLabel.text = "Feeds \(value) People"
        }
        
        if(value != previousSliderValue) {
            var doubleValue = Double(value)
            var doubleServings = Double(recipe.servings)
            var ratio = Double(doubleValue/doubleServings)
            println(value)
            println(ratio)
            rescaleIngredientValues(ratio)
        }
        previousSliderValue = value
    }

    
    // MARK: - Navigation
    
    @IBAction func unwindFromViewCancelButton(segue: UIStoryboardSegue) {
        
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "addToShoppingListSegue") {
            var addToShoppingListVC = segue.destinationViewController as! AddToShoppingListViewController
            addToShoppingListVC.myRecipe = self.recipe
        }
        
        
    }


}
