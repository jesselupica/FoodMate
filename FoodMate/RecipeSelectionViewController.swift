//
//  ViewController.swift
//  FoodMate
//
//  Created by Jesse Lupica on 2/4/15.
//  Copyright (c) 2015 Jesse Lupica. All rights reserved.
//

import UIKit

class RecipeSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var addMealButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var innerFoodImage: UIImageView!
    
    var food: String!
    
    var items: [String]! = []
    var selectedRecipe: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(tabBarController?.tabBar.hidden == true) {
            tabBarController?.tabBar.hidden = false
        }
        
        navBar = self.navigationController?.navigationBar
        self.navigationItem.title = food
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0] as! String
        let path = documentsDirectory.stringByAppendingPathComponent("\(food).plist")
        let fileManager = NSFileManager.defaultManager()
        // check if file exists
        if !fileManager.fileExistsAtPath(path) {
            // create an empty file if it doesn't exist
            if let bundle = NSBundle.mainBundle().pathForResource("DefaultFile", ofType: "plist") {
                fileManager.copyItemAtPath(bundle, toPath: path, error:nil)
            }
        }
        
        if let rawData = NSData(contentsOfFile: path) {
            // do we get serialized data back from the attempted path?
            // if so, unarchive it into an AnyObject, and then convert to an array of HighScores, if possible
            var storedRecipe: AnyObject? = NSKeyedUnarchiver.unarchiveObjectWithData(rawData);
            self.items = storedRecipe as? [String]
        }

        // Do any additional setup after loading the view, typically from a nib.
        addMealButton.backgroundColor = UIColor(red: 40/255, green: 201/255, blue: 0, alpha: 1)

        addMealButton.layer.cornerRadius = 0.5 * addMealButton.bounds.size.height;
        
        addMealButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        foodImage.image = UIImage(named: "exampleImage")
        var foodImageSize = CGSize(width: self.view.frame.width, height: self.view.frame.height * 0.25)
        let foodImageFrame = CGRect(origin: CGPoint(x: 0, y: navBar.frame.minY), size: foodImageSize)
        
        
        var effect = UIBlurEffect(style: .Light)
        var effectView = UIVisualEffectView(effect: effect)
        
        effectView.frame = foodImage.bounds
        //effectView.center = foodImage.center
        
        foodImage.addSubview(effectView)
            
        
        innerFoodImage.image = UIImage(named: "exampleImage")
        innerFoodImage.layer.masksToBounds = true
        innerFoodImage.layer.cornerRadius = 0.5 * innerFoodImage.bounds.size.height
        innerFoodImage.center = foodImage.center
        innerFoodImage.layer.borderWidth = 2
        innerFoodImage.layer.borderColor = UIColor.whiteColor().CGColor
        self.view.bringSubviewToFront(innerFoodImage)
        println(items)
        println(food)
        
    }
    
    @IBAction func editButtonPressed(sender: UIBarButtonItem) {
        if(tableView.editing == false) {
            
            sender.title = "Done"
            sender.style = .Done
            self.tableView.setEditing(true, animated: true)
        } else {
            
            sender.title = "Edit"
            sender.style = .Bordered
            self.tableView.setEditing(false, animated: true)
            
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        tableView.beginUpdates()

        items.removeAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        saveViewData()
    
        tableView.endUpdates()
    }
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        cell.textLabel?.text = items[indexPath.row]
        cell.backgroundColor = UIColor.clearColor()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRecipe = tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("RecipeInformationSegue", sender: self)
        
    }
    
    @IBAction func addMealButtonPressed(sender: UIButton) {
        performSegueWithIdentifier("RecipeCreationSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "RecipeInformationSegue" {
            println("did call RecipeInformationSegue: calling recipe \(selectedRecipe)")
            let informationVC = segue.destinationViewController as! RecipeInformationViewController
            informationVC.recipeName = selectedRecipe
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindFromView(segue: UIStoryboardSegue) {
        println("unwindFromView")
        if let creationVC = segue.sourceViewController as? RecipeCreationTableViewController {
            items.append(creationVC.recipe.title)
            tableView.reloadData()
            
            saveViewData()
        }
        
    }
    @IBAction func unwindFromViewWithoutSaving(segue: UIStoryboardSegue) {
        
    }
    
    func saveViewData() {
        let saveData = NSKeyedArchiver.archivedDataWithRootObject(items);
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray;
        let documentsDirectory = paths.objectAtIndex(0) as! NSString;
        let path = documentsDirectory.stringByAppendingPathComponent("\(food).plist");
        
        saveData.writeToFile(path, atomically: true);
    }

    


}

