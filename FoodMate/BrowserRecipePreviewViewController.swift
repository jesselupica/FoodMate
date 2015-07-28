//
//  RecipeCreationTableViewController.swift
//  FoodMate
//
//  Created by Jesse Lupica on 2/6/15.
//  Copyright (c) 2015 Jesse Lupica. All rights reserved.
//

import UIKit
import Alamofire

class BrowserRecipePreviewViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    var canEditText: Bool = false
    @IBOutlet weak var recipeTableView: UITableView!
    var recipe: Recipe!
    var recipeName: String! = ""
    
    var sliderCellTextLabelIDTag = 1
    var sliderIDTag = 2
    var previousSliderValue: Int! = 0
    
    var numRowsInSection: [Int]!
    let sectionTitles: [String]! = ["", "Ingredients", "Recipe"]
    var ingredientValues: [Double] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println(recipe)
        self.navigationItem.title = recipe.title

        if(tabBarController?.tabBar.hidden == true) {
            tabBarController?.tabBar.hidden = false
        }
        var activityView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityView.color = UIColor(red: 40/255, green: 201/255, blue: 0, alpha: 1)
        
        activityView.center = self.view.center
        activityView.hidesWhenStopped = true
        
        activityView.startAnimating()
        
        self.view.addSubview(activityView)
        
        var id = recipe.id
        Alamofire.request(.GET, "http://api.yummly.com/v1/api/recipe/\(id)?_app_id=ee996d1f&_app_key=ef47e9b2c78d05957c8ded2f86a6ef1a", parameters: ["": ""]).responseJSON() {
            (_, _, JSON, error) in
            
            if error == nil {
                // 4
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    println(JSON)
                    // 5, 6, 7
                    var ingredientStrings = (JSON!["ingredientLines"] as! NSArray)
                    println(ingredientStrings)
                    var ingredientArray = [] as [Ingredient]
                    
                    for element in ingredientStrings {
                        var stringArray = element.componentsSeparatedByString(" ") as! [String]
                        var quantity = 0 as Double
                        if( stringArray.count > 1 ) {
                            quantity = (stringArray[0] as NSString).doubleValue
                            stringArray.removeAtIndex(0)
                        }
                        var unitValue = ""
                        var found = false
                        for unit in Ingredient.classPickerData.pickerData[1] {
                            if(stringArray[0] == unit || stringArray[0] == "\(unit)s") {
                                found = true
                                unitValue = unit
                                stringArray.removeAtIndex(0)
                            }
                        }
                        if( found == false ){
                            unitValue == "whole"
                        }
                        var foodName = ""
                        for word in stringArray {
                            foodName = "\(foodName) \(word)"
                        }
                        foodName = foodName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                        var newIngredient = Ingredient(food: foodName, quantity: quantity, units: unitValue)
                        ingredientArray.append(newIngredient);
                    }
                    self.recipe.ingredients = ingredientArray
                    self.recipe.rating = (JSON!["rating"] as! NSNumber!).doubleValue
                    self.recipe.servings = (JSON!["numberOfServings"] as! NSNumber).integerValue
                    self.numRowsInSection = [3, self.recipe.ingredients.count, self.recipe.instructions.count]
                    dispatch_async(dispatch_get_main_queue()) {
                        activityView.stopAnimating()
                        self.recipeTableView.reloadData()
                    }
                }
            }
        }
        println("finished view did load \(self.recipe)")
        numRowsInSection = [3, recipe.ingredients.count, recipe.instructions.count]

        for ingredient in recipe.ingredients {
            ingredientValues.append(ingredient.quantity)
        }
    }
    
    

    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return numRowsInSection.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return numRowsInSection[section]
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        if(indexPath.section == 0 ) {
            if (indexPath.row == 0) {
                cell = createImageCell(indexPath)
            }
            else {
                if(indexPath.row == 1) {
                    cell = createNormalCell(indexPath)
                    cell.textLabel!.text = "Rating: \(recipe.rating)"
                }
                if(indexPath.row == 2) {
                    cell = createNormalCell(indexPath)
                    cell.textLabel!.text = "Serves: \(recipe.servings)"
                }
            }
            
        }
        if(indexPath.section == 1) {
            cell = createNormalCell(indexPath)
        
            var ingredient = recipe.ingredients[indexPath.row]
                
            cell.textLabel?.text = "\(ingredient.food)"
        
            cell.detailTextLabel?.text = "\(ingredient.quantity) \(ingredient.units)"
        }
        if(indexPath.section == 3) {
            cell = createNormalCell(indexPath)
            //cell.textLabel?.text = recipe.instructions[indexPath.row]
            
            
        }
        
        return cell
    }
    
    func createNormalCell(indexPath: NSIndexPath) -> UITableViewCell {
        var cell = recipeTableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        cell.detailTextLabel?.text = ""
        return cell
    }
    
    func createImageCell(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = recipeTableView.dequeueReusableCellWithIdentifier("imageCell", forIndexPath: indexPath) as! RecipeImageTableViewCell
        
        cell.backgroundColor = UIColor.redColor()
        
        cell.myImageView.contentMode = UIViewContentMode.ScaleAspectFill
        //imageView.autoresizingMask = .FlexibleWidth | .FlexibleHeight;
        cell.myImageView.clipsToBounds = true;
    
        cell.request = Alamofire.request(.GET, recipe.imageURL).responseImage() {
            (request, _, image, error) in
            if error == nil && image != nil {
                cell.myImageView.image = image
                cell.innerFoodImage.image = image
                
            }
        }
        
        var foodImageSize = CGSize(width: cell.frame.width, height: 147)
        let foodImageFrame = CGRect(origin: CGPoint(x: 0, y: 0), size: foodImageSize)
        
        cell.myImageView.frame = foodImageFrame
        
        var effect = UIBlurEffect(style: .Light)
        var effectView = UIVisualEffectView(effect: effect)
        
        effectView.frame = foodImageFrame
        
        cell.myImageView.addSubview(effectView)
        
        cell.innerFoodImage.frame = CGRect(x: 0, y: 0, width: foodImageFrame.height * 0.8, height: foodImageFrame.height * 0.8)
        
        cell.innerFoodImage.layer.masksToBounds = true
        cell.innerFoodImage.layer.cornerRadius = 0.5 * cell.innerFoodImage.bounds.size.height
        cell.innerFoodImage.center = cell.myImageView.center
        cell.innerFoodImage.layer.borderWidth = 2
        cell.innerFoodImage.layer.borderColor = UIColor.whiteColor().CGColor
        cell.myImageView.bringSubviewToFront(cell.innerFoodImage)
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        recipeTableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        var height = tableView.estimatedSectionHeaderHeight
        if(section == 0) {
            return 0.001
        }
        return height+20
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if(indexPath == NSIndexPath(forRow: 0, inSection: 0)) {

            return 147
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

    @IBAction func saveRecipe(sender: UIBarButtonItem) {
        performSegueWithIdentifier("courseSelectionSegue", sender: self)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "addToShoppingListSegue") {
            var addToShoppingListVC = segue.destinationViewController as! AddToShoppingListViewController
            addToShoppingListVC.myRecipe = self.recipe
        } else if (segue.identifier == " courseSelectionSegue") {
            var courseSelectionVC = segue.destinationViewController as! CourseSelectionViewController
            courseSelectionVC.selectedRecipe = self.recipe
            
        }
        
        
    }
    
    
}
