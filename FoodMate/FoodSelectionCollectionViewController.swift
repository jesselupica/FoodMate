//
//  FoodSelectionCollectionViewController.swift
//  FoodMate
//
//  Created by Jesse Lupica on 2/5/15.
//  Copyright (c) 2015 Jesse Lupica. All rights reserved.
//

import UIKit

let reuseIdentifier = "Cell"

class FoodSelectionCollectionViewController: UICollectionViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    let foods = ["Appetizers", "Cocktails", "Entrees", "Desserts", "Lunches", "Snacks"]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
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

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 4
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return 3
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! UICollectionViewCell
        
        var lCurrentWidth = self.view.frame.size.width;
        var lCurrentHeight = self.view.frame.size.height;
        cell.layer.borderWidth = 2
        
        println(indexPath.section)
        cell.frame = CGRect(x: 0, y: 0, width: lCurrentWidth * 0.21875, height: lCurrentWidth * 0.21875)
        cell.center = CGPoint(x: lCurrentWidth * 0.195 + lCurrentWidth * 0.305 * CGFloat(indexPath.row) , y: lCurrentHeight * 0.29 + lCurrentHeight * 0.193 * CGFloat(indexPath.section ))
        
        
        cell.layer.cornerRadius = 0.5 * cell.frame.width
        cell.backgroundColor = UIColor.blackColor()
        
    
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
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
        println("action")
        
    }
    
    override func collectionView(collectionView: (UICollectionView!),
        didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println("select")
        performSegueWithIdentifier("foodSelectionSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "foodSelectionSegue" {
            let food = "This is the name of the food"
            let recipeSelection = segue.destinationViewController as! RecipeSelectionViewController
            recipeSelection.food = food
        }
    }

}
