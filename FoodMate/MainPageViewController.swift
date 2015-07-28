//
//  MainPageViewController.swift
//  FoodMate
//
//  Created by Jesse Lupica on 3/13/15.
//  Copyright (c) 2015 Jesse Lupica. All rights reserved.
//

import UIKit

extension UIColor {
    
    func foodMateGreen() -> UIColor { return UIColor(red: 40/255, green: 201/255, blue: 0, alpha: 1) }

}

class MainPageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let foods = [["Appetizers", "Cocktails", "Entrees"], ["Desserts", "Lunches", "Snacks"]]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        //self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Helvetica-Light", size: 20)!]
        self.navigationController?.navigationBar.tintColor = UIColor(red: 40/255, green: 201/255, blue: 0, alpha: 1)
        self.tabBarController?.tabBar.selectedItem?.selectedImage = UIImage(named: "cutlery23")
        self.tabBarController?.tabBar.tintColor = UIColor(red: 40/255, green: 201/255, blue: 0, alpha: 1)
        self.tabBarController?.tabBarItem.image = UIImage(named: "cutlery23")
        
        if(tabBarController?.tabBar.hidden == true) {
            tabBarController?.tabBar.hidden = false
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if(tabBarController?.tabBar.hidden == true) {
            tabBarController?.tabBar.hidden = false
        }
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 2
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! UICollectionViewCell
        
        var lCurrentWidth = self.view.frame.size.width;
        var lCurrentHeight = self.view.frame.size.height;
        
        var cellImage = UIView()
        cell.layer.borderWidth = 2
        
        println(indexPath.section)
        cell.frame = CGRect(x: 0, y: 0, width: lCurrentWidth * 0.21875, height: lCurrentWidth * 0.21875)
        cell.center = CGPoint(x: lCurrentWidth * 0.195 + lCurrentWidth * 0.305 * CGFloat(indexPath.row) , y: lCurrentHeight * 0.05 + lCurrentHeight * 0.193 * CGFloat(indexPath.section ))
        
        
        cell.layer.cornerRadius = 0.5 * cell.frame.width
        
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor(red: 40/255, green: 201/255, blue: 0, alpha: 1).CGColor
        
        cell.layer.backgroundColor = UIColor(white: 0.8, alpha: 1).CGColor
        
        var fullWord = foods[indexPath.section][indexPath.row]
        var firstLetter  = "\(fullWord[fullWord.startIndex])" as String
        var letterLogo = UILabel(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height))
        letterLogo.text = firstLetter
        letterLogo.textRectForBounds(CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height), limitedToNumberOfLines: 1)
        letterLogo.adjustsFontSizeToFitWidth = true
        letterLogo.font = UIFont(name: "Helvetica Light", size: 50)
        letterLogo.textAlignment = .Center
        letterLogo.textColor = UIColor.whiteColor()
        
        
        //var courseTitle = UILabel(frame: CGRect()
        //coursetitle.textLabel
        
        cell.addSubview(letterLogo)
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
    
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }
    
    func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
        println("action")
        
    }
    
    func collectionView(collectionView: (UICollectionView!),
        didSelectItemAtIndexPath indexPath: NSIndexPath) {
            println("select")
            performSegueWithIdentifier("foodSelectionSegue", sender: indexPath)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "foodSelectionSegue" {
            let indexPath = sender as! NSIndexPath
            let food = foods[indexPath.section][indexPath.row]
            let recipeSelection = segue.destinationViewController as! RecipeSelectionViewController
            recipeSelection.food = food
            println(food)
        }
    }



}
