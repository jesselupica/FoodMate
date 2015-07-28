//
//  ShoppingListViewController.swift
//  FoodMate
//
//  Created by Jesse Lupica on 3/23/15.
//  Copyright (c) 2015 Jesse Lupica. All rights reserved.
//

import UIKit

class ShoppingListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var shoppingList: [Ingredient] = []
    var checkedList: [Ingredient] = []
    
    var titleIDTag = 1
    var subtitleIDTag = 2
    var detailIDTag = 3
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.selectedItem?.selectedImage = UIImage(named: "Shopping Basket")
        
        self.shoppingList = retrieveData("shoppingList") as! [Ingredient]
        self.checkedList = retrieveData("checkedList") as! [Ingredient]
        tableView.setEditing(true, animated: true)
      
    }
    
    override func viewDidAppear(animated: Bool) {
        println("ViewDidAppear")
        self.shoppingList = retrieveData("shoppingList") as! [Ingredient]
        self.checkedList = retrieveData("checkedList") as! [Ingredient]
        tableView.reloadData()
        println(shoppingList)
    }
    
    override func viewWillDisappear(animated: Bool) {
        println("View will disappear")
        saveData(shoppingList, title: "shoppingList")
        saveData(checkedList, title: "checkedList")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0) {
            return shoppingList.count
        }
        return checkedList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        cell = createShoppingListCell(tableView, indexPath: indexPath)
        
        
        return cell
    }
    
    func createShoppingListCell(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("shoppingListCell", forIndexPath: indexPath) as! UITableViewCell
        var ingredient: Ingredient!
        if(indexPath.section == 0) {
             ingredient = shoppingList[indexPath.row] as Ingredient
        } else if(indexPath.section == 1) {
             ingredient = checkedList[indexPath.row] as Ingredient
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
            var cellBg = UIView()
            cellBg.backgroundColor = UIColor(red: 40/255, green: 201/255, blue: 0, alpha: 0.5)


            cellBg.layer.masksToBounds = true;
            cell.selectedBackgroundView = cellBg;
            cell.addSubview(cellBg)
            
        }
        
        var textLabel = cell.viewWithTag(titleIDTag) as! UILabel
        textLabel.text = ingredient.food
        var subtitleTextLabel = cell.viewWithTag(subtitleIDTag) as! UILabel
        
        if((ingredient.notesFromRecipe) != nil) {
            subtitleTextLabel.text = "From \(ingredient.notesFromRecipe)"
        } else {
            subtitleTextLabel.text = ""
        }
        var detailTextLabel = cell.viewWithTag(detailIDTag) as! UILabel
        if(ingredient.quantity != nil) {
            detailTextLabel.text = "\(ingredient.quantity) \(ingredient.units)"
        } else {
            detailTextLabel.text = ""
        }
        return cell
    }
    
    func createCheckedListCell(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("checkedListCell", forIndexPath: indexPath) as! UITableViewCell
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
            //println(path)
        }
        //println(path)
        var storedObject: AnyObject?
        if let rawData = NSData(contentsOfFile: path) {
            // do we get serialized data back from the attempted path?
            // if so, unarchive it into an AnyObject, and then convert to an array of HighScores, if possible
           storedObject  = NSKeyedUnarchiver.unarchiveObjectWithData(rawData);
        } else {
            saveData([], title: inputString)
            storedObject = []
        }
        return storedObject!
    }
    
    func saveData(listToSave: [Ingredient], title: String) {
        // find the save directory our app has permission to use, and save the serialized version of self.scores - the HighScores array.
        let saveData = NSKeyedArchiver.archivedDataWithRootObject(listToSave);
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray;
        let documentsDirectory = paths.objectAtIndex(0) as! NSString;
        
        let path = documentsDirectory.stringByAppendingPathComponent("\(title).plist");
        
        saveData.writeToFile(path, atomically: true);
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.section == 0) {
            println("checked List: ")
            println(checkedList)
            println("Moving: ")
            println(shoppingList[indexPath.row])
            checkedList.append(shoppingList[indexPath.row])
            shoppingList.removeAtIndex(indexPath.row)
        
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        
            var row = checkedList.count - 1
            if row == -1 {
                row = 0
            }
            let newIndexPath = NSIndexPath(forRow: row, inSection: 1)
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            tableView.endUpdates()
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.section == 1) {
            shoppingList.append(checkedList[indexPath.row])
            checkedList.removeAtIndex(indexPath.row)
        
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        
            let row = shoppingList.count - 1
            let newIndexPath = NSIndexPath(forRow: row, inSection: 0)
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            tableView.endUpdates()
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
       
        var height = tableView.estimatedSectionHeaderHeight
        if(section == 0) {
            return 0.001
        }
        return height
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
        println("item selected: \(item)")
    }
    
    @IBAction func addCell(sender: UIBarButtonItem) {
        
    }
    
    @IBAction func unwindFromViewController(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func unwindFromViewControllerWithoutSaving(segue: UIStoryboardSegue) {
        
    }
    @IBAction func clearCheckedItems(sender: UIBarButtonItem) {
        
        var list = ["All checked items will be removed forever.", "All checked items will be removed forever. Are you willing to take that risk...?"]
        var message: String!
        if ( CGFloat(Float(arc4random()) / Float(UINT32_MAX)) < 0.1) {
            message = list[1]
        } else {
            message = list[0]
        }
        
        var refreshAlert = UIAlertController(title: "Clear all checked items?", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            println("Handle Cancel Logic here")
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            println("Handle Ok logic here")
            if(self.tableView.indexPathsForSelectedRows() != nil) {
                var selectedRowsIndexPaths = self.tableView.indexPathsForSelectedRows() as! [NSIndexPath]
                if(selectedRowsIndexPaths.count != 0) {
                    self.tableView.beginUpdates()
                    self.checkedList = []
                    self.tableView.deleteRowsAtIndexPaths(selectedRowsIndexPaths, withRowAnimation: .Fade)
                    self.tableView.endUpdates()
                }
            }
        }))
        
        
        
        presentViewController(refreshAlert, animated: true, completion: nil)
    }
 
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
