//
//  AddIngredientViewController.swift
//  FoodMate
//
//  Created by Jesse Lupica on 3/30/15.
//  Copyright (c) 2015 Jesse Lupica. All rights reserved.
//

import UIKit

class AddIngredientViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIScrollViewDelegate {

    
    
    @IBOutlet weak var tableView: UITableView!
    
    var pickerViewIDTag = 2
    var cellInputIDTag = 3
    
    var ingredient: Ingredient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.scrollEnabled = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        //tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        
        if(indexPath.row == 0) {
            cell = createNormalCell(indexPath)
        }
        if(indexPath.row == 1) {
            cell = createPickerCell(indexPath)
        }
        return cell
    }
    
    func createPickerCell(indexPath: NSIndexPath) -> UITableViewCell {
        println("createPickerCell")
        let cell = tableView.dequeueReusableCellWithIdentifier("pickerViewCell", forIndexPath: indexPath) as? UITableViewCell
        var targetedPickerView = cell?.viewWithTag(pickerViewIDTag) as! UIPickerView
        var parentCellIndexPath = NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section)
        var parentCell = tableView.cellForRowAtIndexPath( parentCellIndexPath ) as UITableViewCell!
        if(parentCell?.detailTextLabel?.text == "Add Quantity" || parentCell == nil) {
            var componentZeroDefault = 6
            var componentOneDefault = 2
            println("\(Ingredient.returnPickerData()[0])")
            targetedPickerView.selectRow(componentZeroDefault, inComponent: 0, animated: false)
            targetedPickerView.selectRow(componentOneDefault, inComponent: 1, animated: false)
            var newText: String! = "\(Ingredient.returnPickerData()[0][componentZeroDefault]) \(Ingredient.returnPickerData()[1][componentOneDefault])"
            parentCell?.detailTextLabel?.text = newText
            
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
    
    
    //Finish implimenting this method
    func createNormalCell(indexPath: NSIndexPath) -> UITableViewCell {
        println("createNormalCell")
        var cell = tableView.dequeueReusableCellWithIdentifier("ingredientCell", forIndexPath: indexPath) as? UITableViewCell
        if cell == nil {
            cell = UITableViewCell(style: .Value1 , reuseIdentifier: "ingredientCell")
        }
        var width = Double(self.view.bounds.width)/2
        
        cell?.detailTextLabel?.text = "Add Quantity"
        
        let myCellInput = cell?.viewWithTag(cellInputIDTag)
        println("Cell input is nil: \(myCellInput == nil)")
        
        if(myCellInput == nil ) {
            println("cell input: \(myCellInput)")
            var height = Double(tableView.rectForRowAtIndexPath(indexPath).height)
            var size = CGSize(width: width, height: height)
            var xCoord = cell?.textLabel?.frame.origin.x
            var point = CGPoint(x: (indexPath.section < 2 ? xCoord! : 52), y: 0)
            cell?.textLabel?.text = ""
            
            
            var cellInput = UITextField(frame: CGRect(origin: point, size: size))
            cellInput.adjustsFontSizeToFitWidth = true
            cellInput.keyboardType = UIKeyboardType.Default
            cellInput.textAlignment = .Left
            cellInput.returnKeyType = .Done
            cellInput.autocapitalizationType = .Words
            cellInput.tag = cellInputIDTag
            cellInput.delegate = self
            cellInput.text = ""
            cellInput.placeholder = "Add Ingredient"
            cell?.addSubview(cellInput)
            
        }
        return cell!
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        println("did select row")
        var cellIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        
        self.tableView.beginUpdates()
        var contentCell = self.tableView.cellForRowAtIndexPath(cellIndexPath)
        contentCell?.detailTextLabel?.text = "\(Ingredient.returnPickerData()[0][pickerView.selectedRowInComponent(0)]) \(Ingredient.returnPickerData()[1][pickerView.selectedRowInComponent(1)])"
        self.tableView.endUpdates()
        
        var quantity = contentCell!.detailTextLabel!.text!
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return Ingredient.returnPickerData()[component][row]
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        println("\(Ingredient.returnPickerData()[component].count)")
        return Ingredient.returnPickerData()[component].count
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.row == 1) {
            return 162
        }
        return 44
    }

    func saveData() {
        var cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as UITableViewCell!
        var pickerViewCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as UITableViewCell!
        var cellInput = cell.viewWithTag(cellInputIDTag) as! UITextField
        var pickerView = pickerViewCell.viewWithTag(pickerViewIDTag) as! UIPickerView
        var quantity = Ingredient.returnPickerDataValueTranslation()[pickerView.selectedRowInComponent(0)]
        var units = Ingredient.returnPickerData()[1][pickerView.selectedRowInComponent(1)]

       
        ingredient = Ingredient(food: cellInput.text, quantity: quantity, units: units)
        println(ingredient)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "save") {
            saveData()
            var shoppingListVC = segue.destinationViewController as! ShoppingListViewController
            var shoppingList = shoppingListVC.shoppingList
            shoppingList.append(ingredient)
            shoppingListVC.saveData(shoppingList, title: "shoppingList")
        }
    }
    

}
