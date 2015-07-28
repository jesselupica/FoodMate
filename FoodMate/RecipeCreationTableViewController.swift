//
//  RecipeCreationTableViewController.swift
//  FoodMate
//
//  Created by Jesse Lupica on 2/19/15.
//  Copyright (c) 2015 Jesse Lupica. All rights reserved.
//

import UIKit
import AVFoundation

class RecipeCreationTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate {
    
    
    
    /* Known Glitches:
    - edit end and begin in view, check to see if view is in sight while loading
    */
    @IBOutlet weak var recipeTableView: UITableView!
    
    let pickerDataValueTranslation: [Double] = [(1/16), (1/8), (1/4), (1/3), (1/2), (2/3), 1, (5/4), (4/3), (3/2), (5/3), (7/4), 2, (9/4), (5/2), (11/4), 3, (13/4), (7/2), (15/4), 4, (9/2), 5, 6, 7, 8, 9, 10, 11, 12 ]
    var pickerViewIndexPath: NSIndexPath!
    var pickerViewIDTag = 5
    var cellInputIDTag = 45
    var titleInputIDTag = 12
    var sliderIDTag = 7
    var textLabelIDTag = 4
    var recipeImageIDTag = 3
    var textViewIDTag = 11
    let breakCode = "BREAK 4321 SWAGGER"
    
    var heightForViewCellRow = 60
    
    var recipe: Recipe!
    var myRecipeManager: RecipeManager!
    
    
    var numRowsInSection: [Int]!
    var sectionTitles: [String]! = ["Title", "Details", "Ingredients", "Recipe"]
    var tableInformation: [String] = []
    var newTableInformation: [[String]] =  [["", ""], [""], ["", "addIngredient" ], ["", "addStep" ]]
    var quantityTableInformation: [[String]] = [["",""]]
    var firstLoad = true
    var addingCell = false
    var isRemovingCell = false
    
    var selectedTextView: UITextView!
    var selectedTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        recipe = Recipe()
        numRowsInSection = [2, 1, 2, 2]
        tabBarController?.tabBar.hidden = true
        
    }
    
    override func viewDidAppear(animated: Bool) {
        recipeTableView.setEditing(true, animated: true)
        firstLoad = false
        newTableInformation[1][0] = "4"
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return numRowsInSection.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows = numRowsInSection[section]
        if( self.pickerViewIsShown() == true && section == self.pickerViewIndexPath.section) {
            numberOfRows++
        }
        
        return numberOfRows
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        println("cell for row at IndexPath: (\(indexPath.section), \(indexPath.row))")
    if(self.pickerViewIsShown() && self.pickerViewIndexPath.compare(indexPath) == NSComparisonResult.OrderedSame) {
        cell = createPickerCell(indexPath)
    }
    else if (indexPath.section == 1 && indexPath.row == 0) {
        cell = createSliderCell(indexPath)
    }
    else if (indexPath.section == 0 ) {
        if(indexPath.row == 0) {
            cell = createImageCell(indexPath)
        } else {
            cell = createTitleCell(indexPath)
        }
    }
    else if(indexPath.section == 3 && indexPath.row != recipeTableView.numberOfRowsInSection(indexPath.section) - 1) {
        cell = createTextViewCell(indexPath)
    } else {
        cell = createNormalCell(indexPath)
        }

    return cell
    }
    
    func createTitleCell(indexPath: NSIndexPath) ->UITableViewCell {
        let cell = recipeTableView.dequeueReusableCellWithIdentifier("titleCell", forIndexPath: indexPath) as! UITableViewCell
        cell.selectionStyle = .Default
        var width = Double(self.view.bounds.width)
        
        let myTitleInput = cell.viewWithTag(titleInputIDTag)
        
        if(myTitleInput == nil ) {
            println("cell input: \(myTitleInput)")
            var height = Double(recipeTableView.rectForRowAtIndexPath(indexPath).height)
            var size = CGSize(width: width, height: height)
            var xCoord = cell.textLabel?.frame.origin.x
            var point = CGPoint(x: (indexPath.section < 2 ? xCoord! : 52), y: 0)
            cell.textLabel?.text = ""
            cell.detailTextLabel?.text = ""
            
            
            var cellInput = UITextField(frame: CGRect(origin: point, size: size))
            cellInput.adjustsFontSizeToFitWidth = true
            cellInput.keyboardType = UIKeyboardType.Default
            cellInput.textAlignment = .Left
            cellInput.returnKeyType = .Done
            cellInput.autocapitalizationType = .Words
            cellInput.tag = cellInputIDTag
            cellInput.delegate = self
            cellInput.text = ""
            
            var tableInformation = newTableInformation[indexPath.section][indexPath.row]
            
            if(tableInformation == "") {
                cellInput.placeholder = "Add Title"
                println(cell)
            } else {
                cellInput.text = tableInformation
            }
            cell.addSubview(cellInput)
        }
        return cell
    }
    
    func createNormalCell(indexPath: NSIndexPath) -> UITableViewCell {
        var cell = recipeTableView.dequeueReusableCellWithIdentifier("ingredientCell", forIndexPath: indexPath) as? UITableViewCell
        if cell == nil {
            cell = UITableViewCell(style: .Value1 , reuseIdentifier: "ingredientCell")
        }
        var width = Double(self.view.bounds.width)
        if(indexPath.section == 2) {
            width = width/2
        }
        
        if(addingCell) {
            
            newTableInformation[indexPath.section].insert("", atIndex: indexPath.row)
            var newQuantity = ["", ""]
            quantityTableInformation.insert(newQuantity, atIndex: indexPath.row)
            addingCell = false
        }

        let myCellInput = cell?.viewWithTag(cellInputIDTag)
        println("Cell input is nil: \(myCellInput == nil)")
        
        if(myCellInput == nil ) {
            println("cell input: \(myCellInput)")
            var height = Double(recipeTableView.rectForRowAtIndexPath(indexPath).height)
            var size = CGSize(width: width, height: height)
            var xCoord = cell?.textLabel?.frame.origin.x
            var point = CGPoint(x: (indexPath.section < 2 ? xCoord! : 52), y: 0)
            cell?.textLabel?.text = ""
            cell?.detailTextLabel?.text = ""
        
        
            var cellInput = UITextField(frame: CGRect(origin: point, size: size))
            cellInput.adjustsFontSizeToFitWidth = true
            cellInput.keyboardType = UIKeyboardType.Default
            cellInput.textAlignment = .Left
            cellInput.returnKeyType = .Done
            cellInput.autocapitalizationType = .Words
            cellInput.tag = cellInputIDTag
            cellInput.delegate = self
            cellInput.text = ""
            
            var tableInformation: String!
            if(pickerViewIsShown() && pickerViewIndexPath.section == indexPath.section && pickerViewIndexPath.row < indexPath.row) {
                tableInformation = newTableInformation[indexPath.section][indexPath.row - 1]
            }
            else {
                tableInformation = newTableInformation[indexPath.section][indexPath.row]
            }
        
            if(tableInformation == "") {
                if(indexPath.section == 2) {
                    cellInput.placeholder = "Add Ingredient"
                    cell?.detailTextLabel?.text = "Add Quantity"
                    cell?.detailTextLabel?.backgroundColor = UIColor.clearColor()
                } else if(indexPath.section == 3) {
                    cellInput.placeholder = "Add Step"
                }
            } else if (tableInformation == "addIngredient") {
                cell?.textLabel?.text = "Add New Ingredient"
                cell?.detailTextLabel?.text = ""
            } else if (tableInformation == "addStep"){
                cell?.textLabel?.text = "Add New Instruction"
            } else {
                cellInput.text = tableInformation
            }
        
            if(tableInformation != "addStep" && tableInformation != "addIngredient") {
                cell?.addSubview(cellInput)
            }
        }
        return cell!
    }
    
    func createPickerCell(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = recipeTableView.dequeueReusableCellWithIdentifier("pickerCell", forIndexPath: indexPath) as? UITableViewCell
        var targetedPickerView = cell?.viewWithTag(pickerViewIDTag) as! UIPickerView
        var parentCellIndexPath = NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section)
        var parentCell = recipeTableView.cellForRowAtIndexPath( parentCellIndexPath ) as UITableViewCell!
        if(parentCell?.detailTextLabel?.text == "Add Quantity") {
            var componentZeroDefault = 6
            var componentOneDefault = 2
            targetedPickerView.selectRow(componentZeroDefault, inComponent: 0, animated: false)
            targetedPickerView.selectRow(componentOneDefault, inComponent: 1, animated: false)
            var newText: String! = "\(Ingredient.returnPickerData()[0][componentZeroDefault]) \(Ingredient.returnPickerData()[1][componentOneDefault])"
            parentCell?.detailTextLabel?.text = newText
            var textField = parentCell.viewWithTag(cellInputIDTag) as! UITextField
            
            newTableInformation[parentCellIndexPath.section][parentCellIndexPath.row] = textField.text
        
            quantityTableInformation[parentCellIndexPath.row] = ["\(Ingredient.returnPickerData()[0][componentZeroDefault])", "\(Ingredient.returnPickerData()[1][componentOneDefault])"]
        } else {
            var quantity = parentCell.detailTextLabel?.text
            let quantityArr = quantity!.componentsSeparatedByString(" ")
            
            var value = (quantityArr.count == 3 ? "\(quantityArr[0]) \(quantityArr[1])" : quantityArr[0])
            var units = quantityArr[quantityArr.count - 1]
            var componentZeroValue = findPickerDataIndex(value, component: 0)
            var componentOneValue = findPickerDataIndex(units, component: 1)
            targetedPickerView.selectRow(componentZeroValue, inComponent: 0, animated: false)
            targetedPickerView.selectRow(componentOneValue, inComponent: 1, animated: false)
            println(componentOneValue)
            println(units)
        }
        
        return cell!
    }
    
    func createImageCell(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = recipeTableView.dequeueReusableCellWithIdentifier("imageCell", forIndexPath: indexPath) as! UITableViewCell
        //var myImage = UIImage(named: "EmptyRecipeImage")
        //var myRecipeImage = cell.viewWithTag(recipeImageIDTag) as UIImageView
        //UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.width))
        //myRecipeImage.image = myImage
        //cell.addSubview(myRecipeImage)
        return cell
    }
    
    func createSliderCell(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = recipeTableView.dequeueReusableCellWithIdentifier("sliderCell", forIndexPath: indexPath) as! UITableViewCell
        //cell.backgroundColor = UIColor.clearColor()
        
        return cell
        
    }
    
    func createTextViewCell(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = recipeTableView.dequeueReusableCellWithIdentifier("textViewCell", forIndexPath: indexPath) as! UITableViewCell
        if(addingCell) {
            newTableInformation[indexPath.section].insert("" , atIndex: indexPath.row)
            addingCell = false
        }
        let oldTextView = cell.viewWithTag(textViewIDTag)
        if(oldTextView == nil) {
            var width = Double(self.view.bounds.width)
            var height = Double(heightForViewCellRow - 16)
            var size = CGSize(width: width - 60, height: height - 8)
            var xCoord = cell.textLabel?.frame.origin.x
            var point = CGPoint(x: 52, y: 8)
            cell.textLabel?.text = ""
            cell.detailTextLabel?.text = ""
        
        
            var textView = UITextView(frame: CGRect(origin: point, size: size))
            textView.keyboardType = UIKeyboardType.Default
            textView.textAlignment = .Left
            textView.returnKeyType = .Done
            textView.autocapitalizationType = .Words
            textView.tag = textViewIDTag
            textView.delegate = self
        
            textView.text = "Add Recipe Step"
            var myFont = UIFont(name: "Helvetica", size: 17)
            textView.font = myFont
            textView.textColor = UIColor.lightGrayColor()
            textView.backgroundColor = UIColor.clearColor()
        
            cell.addSubview(textView)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if(pickerViewIsShown() && indexPath.compare(pickerViewIndexPath) == NSComparisonResult.OrderedSame) {
            return .None
        }
        
        if(indexPath.section > 1) {
            if((indexPath.row == tableView.numberOfRowsInSection(indexPath.section) - 1) ||
                (pickerViewIsShown() && pickerViewIndexPath.section == indexPath.section
                && pickerViewIndexPath.row == tableView.numberOfRowsInSection(indexPath.section) - 1
                && indexPath.row == tableView.numberOfRowsInSection(indexPath.section) - 2)) {
                
                return .Insert
            }
            else {
                return .Delete
            }
        }
        else {
            return .None
        }
    }
    
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section > 1
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func saveMeal() {
        println("calling saveMeal")
        
        if(selectedTextField != nil) {
            saveTextFieldData(selectedTextField)
        }
        if(selectedTextView != nil) {
            saveTextViewData(selectedTextView, text: selectedTextView.text)
        }
        
        for(var i = 0; i < newTableInformation.count; i++) {
            if ( i == 0) {
                recipe.title = newTableInformation[0][1]
            } else if (i == 1) {
                recipe.servings = NSString(string: newTableInformation[i][0]).integerValue
            } else if (i == 2) {
                for(var j = 0; j < newTableInformation[i].count; j++) {
                    if(newTableInformation[i][j] != "addIngredient" ) {
                        var index = findPickerDataIndex(quantityTableInformation[j][0], component: 0)
                        if(index != -1) {
                        var ingredient = Ingredient(food: newTableInformation[i][j], quantity: pickerDataValueTranslation[index], units: quantityTableInformation[j][1])
                        recipe.ingredients.append(ingredient)
                        }
                    }
                }
            } else {
                for(var j = 0; j < newTableInformation[i].count; j++) {
                    if(newTableInformation[i][j] != "addStep" ) {
                        recipe.instructions.append(newTableInformation[i][j])
                    }
                }

            }
        }
        myRecipeManager = RecipeManager(recipeName: recipe.title)
        myRecipeManager.save(recipe)
        println("\(recipe) after saving")
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        recipeTableView.beginUpdates()
        var pickerViewWasActive = false
        if(pickerViewIsShown()) {
            hideExistingPicker()

            pickerViewWasActive = true
            
        }
        
        if editingStyle == .Delete {
                isRemovingCell = true
                numRowsInSection[indexPath.section]--
                newTableInformation[indexPath.section].removeAtIndex(indexPath.row)
                var cell = recipeTableView.cellForRowAtIndexPath(indexPath) as UITableViewCell!
            if(cell.reuseIdentifier == "ingredientCell") {
                var cellInput = cell.viewWithTag(cellInputIDTag)
                cellInput?.removeFromSuperview()
            } else {
                var textView = cell.viewWithTag(textViewIDTag)
                textView?.removeFromSuperview()
            }
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                
        } else if editingStyle == .Insert {
                addNewCellToTableView(indexPath, pickerViewWasActive: pickerViewWasActive)
        }
        recipeTableView.endUpdates()
        isRemovingCell = false
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        println("Showing: \(indexPath.section), \(indexPath.row)")
        if(indexPath.section == 0 && indexPath.row == 1) {
            //cell.textLabel?.text = "(0, 1)"
        }
    }
    
    func addNewCellToTableView(indexPath: NSIndexPath, pickerViewWasActive: Bool) {
        var addButtonIsOnlyCell = true
        var cellInput: String!
        var cellQuantity: String!
        var previousCell: UITableViewCell!
        if(recipeTableView.numberOfRowsInSection(indexPath.section) != 1) {
            addButtonIsOnlyCell = false
            previousCell = recipeTableView.cellForRowAtIndexPath(NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section)) as UITableViewCell!
            if(previousCell.reuseIdentifier == "pickerCell") {
                previousCell = recipeTableView.cellForRowAtIndexPath(NSIndexPath(forRow: indexPath.row - 2, inSection: indexPath.section)) as UITableViewCell!
                
            }
            if(indexPath.section == 2) {
                var input = previousCell?.viewWithTag(cellInputIDTag) as! UITextField
                cellInput = input.text
                cellQuantity = previousCell?.detailTextLabel?.text
            } else {
                var input = previousCell?.viewWithTag(textViewIDTag) as! UITextView
                cellInput = input.text
            }
            
        }
        
        println("addButton is only Cell \(addButtonIsOnlyCell)")
        println("previous cell reuse identifier \(previousCell.reuseIdentifier)")
        println("cell input \(cellInput)")
        println("cell quantity \(cellQuantity)")
        if (addButtonIsOnlyCell == false && (previousCell.reuseIdentifier == "ingredientCell" || previousCell.reuseIdentifier == "textViewCell")  && ((cellInput == "" || cellInput == "Add Recipe Step") || (cellQuantity != nil && cellQuantity == "Add Quantity"))) {
            let previousColor = previousCell.backgroundColor
            
            
            UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
                var newCellView = previousCell as UITableViewCell
                newCellView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.34)
                previousCell = newCellView
                }, completion: { (value: Bool) in
                    UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: {
                        var newCellView = previousCell as UITableViewCell
                        newCellView.backgroundColor = previousColor
                        previousCell = newCellView
                        },
                        completion: nil)
                }
            )
        }
        else {
            
            addingCell = true
            numRowsInSection[indexPath.section]++
            var inputIndexPath = indexPath
            if(pickerViewWasActive &&  indexPath.section == 2) {
                inputIndexPath = NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section)
            }
            recipeTableView.insertRowsAtIndexPaths([inputIndexPath], withRowAnimation: .Fade)
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.recipeTableView.beginUpdates()
        
        var pickerViewWasActive = false
        if(pickerViewIsShown()) {
            hideExistingPicker()
            pickerViewWasActive = true
        } else if( indexPath.section == 2 && indexPath.row != tableView.numberOfRowsInSection(indexPath.section) - 1) {
            
            var newPickerIndexPath = self.calculateIndexPathForNewPicker(indexPath)
            
            if (self.pickerViewIsShown()){
                self.hideExistingPicker()
            }
            
            self.showNewPickerAtIndex(newPickerIndexPath)
            
            self.pickerViewIndexPath = NSIndexPath(forRow: newPickerIndexPath.row + 1, inSection: newPickerIndexPath.section)
        }
       var cell = recipeTableView.cellForRowAtIndexPath(indexPath) as UITableViewCell!
        if(cell.textLabel?.text == "Add New Ingredient" || cell.textLabel?.text == "Add New Instruction") {
            
            addNewCellToTableView(indexPath, pickerViewWasActive: pickerViewWasActive)
        }
        self.recipeTableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        self.recipeTableView.endUpdates()
    }
    
    func hideExistingPicker() {
        
        self.recipeTableView.deleteRowsAtIndexPaths([self.pickerViewIndexPath], withRowAnimation: .Fade)
    
        self.pickerViewIndexPath = nil;
    }
    
    func calculateIndexPathForNewPicker(selectedIndexPath: NSIndexPath) -> NSIndexPath {
    
        var newIndexPath: NSIndexPath!
    
        if (( self.pickerViewIsShown()) && (self.pickerViewIndexPath.compare(selectedIndexPath) == NSComparisonResult.OrderedAscending)){
    
            newIndexPath = NSIndexPath(forRow: selectedIndexPath.row - 1, inSection: selectedIndexPath.section)
    
        }else {
            
            newIndexPath = recipeTableView.indexPathForSelectedRow()

        }
        return newIndexPath;
    }
    
    func showNewPickerAtIndex(indexPath: NSIndexPath) {
        var newIndexPath = NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)
        
    recipeTableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
       
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        var rowHeight = self.recipeTableView.rowHeight;
        
        if (self.pickerViewIsShown() && (self.pickerViewIndexPath.compare(indexPath) == NSComparisonResult.OrderedSame)){
            //rowHeight = pickerCellRowHeight!
            rowHeight = 170
        }
        if( indexPath == NSIndexPath(forRow: 0, inSection: 1)) {
            rowHeight = 70
        }
        if( indexPath == NSIndexPath(forRow: 0, inSection: 0)) {
            rowHeight = 170
        }
        var last = newTableInformation[indexPath.section].count - 1
        if (indexPath.section == 3 && indexPath.row != last) {
            rowHeight = 60
        }
    
        return rowHeight;
    }
    
    //MARK: - Picker Delegates and data sources
    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return Ingredient.returnPickerData().count
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Ingredient.returnPickerData()[component].count
    }
    
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return Ingredient.returnPickerData()[component][row]
    }
    
    func pickerViewIsShown() -> Bool {
        return self.pickerViewIndexPath != nil
    }
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        println("did select row")
        var cellIndexPath = NSIndexPath(forRow: pickerViewIndexPath.row - 1, inSection: pickerViewIndexPath.section)
        
        self.recipeTableView.beginUpdates()
        var cell = self.recipeTableView.cellForRowAtIndexPath(cellIndexPath)
        cell?.detailTextLabel?.text = "\(Ingredient.returnPickerData()[0][pickerView.selectedRowInComponent(0)]) \(Ingredient.returnPickerData()[1][pickerView.selectedRowInComponent(1)])"
        self.recipeTableView.endUpdates()
        
        var quantity = cell!.detailTextLabel!.text!
        var textField = cell?.viewWithTag(cellInputIDTag) as! UITextField
        newTableInformation[cellIndexPath.section][cellIndexPath.row] = textField.text
     
        quantityTableInformation[cellIndexPath.row][0] = Ingredient.returnPickerData()[0][pickerView.selectedRowInComponent(0)]
        quantityTableInformation[cellIndexPath.row][1] = Ingredient.returnPickerData()[1][pickerView.selectedRowInComponent(1)]
        println("table information count: \(newTableInformation)")
        println("quantity values: \(quantityTableInformation)")
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
       saveTextFieldData(textField)
        selectedTextField = nil
    }
   
    func textFieldDidBeginEditing(textField: UITextField) {
        selectedTextField = textField
    }
    
    func saveTextFieldData(textField: UITextField) {
        println("textFieldDidEndEditing is called")
        if(!isRemovingCell) {
            
            var cell = textField.superview as? UITableViewCell
            var indexPath = recipeTableView.indexPathForCell(cell!) as NSIndexPath!
            println("Is picker view shown: \(pickerViewIsShown())")
            var myIndexPath: NSIndexPath!
            if(pickerViewIsShown() && pickerViewIndexPath.section == indexPath.section && pickerViewIndexPath.row < indexPath.row) {
                myIndexPath = NSIndexPath(forItem: indexPath.row - 1, inSection: indexPath.section)
            }
            else {
                myIndexPath = NSIndexPath(forItem: indexPath.row, inSection: indexPath.section)
            }
            newTableInformation[myIndexPath.section][myIndexPath.row] = textField.text
            
            if (indexPath?.section == 2)  {
                
                let quantity = cell!.detailTextLabel!.text!
                if(quantity != "Add Quantity") {
                    
                    let quantityArr = quantity.componentsSeparatedByString(" ")
                    
                    var value = (quantityArr.count == 3 ? "\(quantityArr[0]) \(quantityArr[1])" : quantityArr[0])
                    var units = quantityArr[quantityArr.count - 1]
                    quantityTableInformation[myIndexPath.row][0] = value
                    quantityTableInformation[myIndexPath.row][1] = units
                }
            }
        }
        println("table information count: \(newTableInformation)")
        println("quantity values: \(quantityTableInformation)")
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        let cell = recipeTableView.viewWithTag(sliderIDTag)?.superview as! UITableViewCell!
        let indexPath = recipeTableView.indexPathForCell(cell) as NSIndexPath!
        var textField = cell.viewWithTag(textLabelIDTag) as! UILabel
        
        var value: Int! = Int(sender.value)
        if(value == 1) {
            textField.text = "Feeds \(value) Person"
        }
        else {
            textField.text = "Feeds \(value) People"
        }
        
        newTableInformation[indexPath.section][indexPath.row] = "\(value)"
        println("table information count: \(newTableInformation)")
        println("quantity values: \(quantityTableInformation)")
    }
    
    @IBAction func segmentedControlValueChanged(sender: UISegmentedControl) {
        println("segmentedControlValueChanged called")
        if(sender.selectedSegmentIndex == 0) {
            let captureSession = AVCaptureSession()
            captureSession.sessionPreset = AVCaptureSessionPresetLow
            var captureDevice: AVCaptureDevice!
            let devices = AVCaptureDevice.devices()
            println(devices)
            
            for device in devices {
                // Make sure this particular device supports video
                if (device.hasMediaType(AVMediaTypeVideo)) {
                    // Finally check the position and confirm we've got the back camera
                    if(device.position == AVCaptureDevicePosition.Back) {
                        captureDevice = device as? AVCaptureDevice
                    }
                }
            }
            
            if (captureDevice != nil) {
                var err : NSError? = nil
                captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))
                
                if err != nil {
                    println("error: \(err?.localizedDescription)")
                }
                
                var previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                self.view.layer.addSublayer(previewLayer)
                previewLayer?.frame = self.view.layer.frame
                captureSession.startRunning()
            }
        } else {
            
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        selectedTextView = textView
        if(textView.text == "Add Recipe Step") {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
       saveTextViewData(textView, text: textView.text)
        selectedTextView = nil
    }
    
    func saveTextViewData(textView: UITextView, text: String) {
        if(!isRemovingCell) {
            
                var cell = textView.superview as? UITableViewCell
            
                var indexPath = recipeTableView.indexPathForCell(cell!) as NSIndexPath!
                if(indexPath != nil) {
                newTableInformation[indexPath.section][indexPath.row] = textView.text
            }
            
        }
        println("table information count: \(newTableInformation)")
        println("quantity values: \(quantityTableInformation)")
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if(scrollView.isKindOfClass(UITableView)) {
         
            if(selectedTextField != nil) {
                saveTextFieldData(selectedTextField)
            }
            if(selectedTextView != nil) {
                saveTextViewData(selectedTextView, text: selectedTextView.text)
            }
        }
    }
    
    func isAddButtonCell(indexPath: NSIndexPath) -> Bool {
        return indexPath.section == 2 && indexPath.row == recipeTableView.numberOfRowsInSection(indexPath.section) - 1
    }
    
    func findPickerDataIndex(input: String, component: Int) -> Int {
        println("at findPickerDataIndex")
        println("----------------------")
        var pickerIndex = 0
        for value in Ingredient.returnPickerData()[component] {
            println("value: \(value)\nInput: \(input)")
            println("----------------------")
            if(input == value) {
                return pickerIndex
            }
            pickerIndex++
        }
        return -1
    }
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        println("I am preparing for segue")
        if(pickerViewIsShown()) {
            recipeTableView.beginUpdates()
            hideExistingPicker()
            recipeTableView.endUpdates()
        }
        self.saveMeal()
    }

    
}
