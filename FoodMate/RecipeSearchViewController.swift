//
//  RecipeSearchViewController.swift
//  FoodMate
//
//  Created by Jesse Lupica on 4/14/15.
//  Copyright (c) 2015 Jesse Lupica. All rights reserved.
//

import UIKit
import Alamofire


class RecipeSearchViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, CHTCollectionViewDelegateWaterfallLayout, UIScrollViewDelegate, UISearchBarDelegate, UISearchControllerDelegate {

    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var collectionViewContentStream: UICollectionView!
    
    var recipes: [Recipe] = []
    var imageSize = "s400-c"
    var cellSizes: [CGSize] = []
    var pickedRecipe: Recipe!
    var searchIsOn = false
    var searchDarkenEffect: UIVisualEffectView!
    var searchBar: UISearchBar!
    var searchController: UISearchController!
    var criteriaSegmentedControl: UISegmentedControl!
    var includedExcludedSegmentedControl: UISegmentedControl!
    
    var additionalSearchCriteria: String!
    
        
    var layout = CHTCollectionViewWaterfallLayout()
    
    //let refreshControl = UIRefreshControl()
    
    
    var populatingPhotos = false
    var currentPage = 1
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.translucent = true

        self.navigationController?.navigationBar.tintColor = UIColor(red: 40/255, green: 201/255, blue: 0, alpha: 1)
   
        self.layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        self.layout.minimumColumnSpacing = 10; // space between columns
        self.layout.minimumInteritemSpacing = 10; // space between rows
        
        self.collectionViewContentStream.collectionViewLayout = self.layout;
        self.collectionViewContentStream.autoresizingMask = .FlexibleHeight | .FlexibleWidth;
        self.collectionViewContentStream.dataSource = self;
        self.collectionViewContentStream.delegate = self;
        
        
        Alamofire.request(.GET, "http://api.yummly.com/v1/api/recipes?_app_id=ee996d1f&_app_key=ef47e9b2c78d05957c8ded2f86a6ef1a&requirePictures=true", parameters: ["": ""]).responseJSON() {
            (_, _, JSON, _) in
                let recipeInfos = (JSON!["matches"] as! NSArray)
            for element in recipeInfos {
                var newRecipe = Recipe(title: element["recipeName"] as! String, rating: element["rating"] as! Double, id: element["id"] as! String, url: ((element["imageUrlsBySize"] as! NSDictionary)["90"] as? String!)!)
                newRecipe.changeImageSize(self.imageSize)
                self.recipes.append(newRecipe)
                
               
            }
            self.calculateCellSizes()
            //self.photos.addObjectsFromArray(recipeInfos)
            
            self.collectionViewContentStream!.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func calculateCellSizes() {
        
        for (var i = 0; i < recipes.count; i++) {
            var size = CGSize(width: CGFloat(arc4random() % 50 + 50), height: CGFloat(arc4random() % 25 + 100))
            if(i <= cellSizes.count) {
                cellSizes.append(size)
            }
        }
    }
  
    // 1
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y + view.frame.size.height > scrollView.contentSize.height * 0.8 {
            populatePhotos()
        }
    }
    
    func populatePhotos() {
        // 2
        if populatingPhotos {
            return
        }
        
        populatingPhotos = true
        var request: String!
        var lastItemText = "\(self.recipes.count)"
        println(searchIsOn)
        if(searchIsOn == false) {
            
            request = "http://api.yummly.com/v1/api/recipes?_app_id=ee996d1f&_app_key=ef47e9b2c78d05957c8ded2f86a6ef1a&requirePictures=true&maxResult=10&start=\(lastItemText)"
        } else {
            request = "http://api.yummly.com/v1/api/recipes?_app_id=ee996d1f&_app_key=ef47e9b2c78d05957c8ded2f86a6ef1a&requirePictures=true\(additionalSearchCriteria)&maxResult=10&start=\(lastItemText)"
        }
        // 3
        println(request)
        Alamofire.request(.GET, request, parameters: ["": ""]).responseJSON() {
            (_, _, JSON, error) in
            
            if error == nil {
                // 4
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    // 5, 6, 7
                    println(JSON)
                    var prevNumItems = self.recipes.count
                    var newRecipes: [Recipe] = []
                    let recipeInfos = (JSON!["matches"] as! NSArray)
                    for element in recipeInfos {
                        var newRecipe = Recipe(title: element["recipeName"] as! String, rating: element["rating"] as! Double, id: element["id"] as! String, url: ((element["imageUrlsBySize"] as! NSDictionary)["90"] as? String!)!)
                        newRecipe.changeImageSize(self.imageSize)
                        self.recipes.append(newRecipe)
                        newRecipes.append(newRecipe)}
                    
                    // 8
                    var lastItem = prevNumItems
                    self.calculateCellSizes()

                    // 10
                    let indexPaths = (prevNumItems..<self.recipes.count).map { NSIndexPath(forItem: $0, inSection: 0) }
                    
                    // 11
                    dispatch_async(dispatch_get_main_queue()) {
                        self.collectionViewContentStream.performBatchUpdates({
                            self.collectionViewContentStream!.insertItemsAtIndexPaths(indexPaths)
                            }, completion: nil)
                        
                    }
                    
                    self.currentPage++
                }
            }
            self.populatingPhotos = false
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipes.count
    }

    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! RecipeStreamCollectionViewCell
        
        let imageURL = (recipes[indexPath.row] as Recipe).imageURL
        
        cell.imageView.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height - 60)
        cell.textLabel.text = self.recipes[indexPath.row].title
       
        cell.textLabel.frame.origin.y = cell.frame.height - 60
        
        cell.textLabel.frame.size = CGSize(width: cell.frame.width, height: 40)
        
        cell.ratingLabel.frame = CGRect(x: 0, y: cell.frame.size.height - 23, width: cell.frame.size.width, height: 20)
        cell.ratingLabel.text = "Rating: \(self.recipes[indexPath.row].rating)"

        
        cell.imageView.image = nil
        cell.request?.cancel()
        
        cell.request = Alamofire.request(.GET, imageURL).responseImage() {
            (request, _, image, error) in
            if error == nil && image != nil {
                cell.imageView.alpha = 0.0
                cell.imageView.image = image
                cell.fadeIn()
            }
        }
        
        return cell
    }

    func collectionView (collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            return cellSizes[indexPath.row]
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println("indexpath.item : \(indexPath.item)")
        println(recipes[indexPath.item])
        self.pickedRecipe = recipes[indexPath.item]
        performSegueWithIdentifier("pickedRecipeSegue", sender: nil)

        
    }
    
    @IBAction func searchButtonPressed(sender: UIBarButtonItem) {
        var animationTime = 0.25
        
        if(searchBar != nil) {
            searchBar.removeFromSuperview()
        }
        if( searchIsOn == false) {
            searchIsOn = true
            
            sender.title = "Cancel"
            
            var effect = UIBlurEffect(style: .Dark)
            var effectView = UIVisualEffectView(effect: effect)
        
            effectView.frame = self.view.frame
            effectView.alpha = 0.0
            self.searchDarkenEffect = effectView
        
            self.view.addSubview(effectView)
            self.view.bringSubviewToFront(effectView)
            
            UIView.animateWithDuration(animationTime, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                
                effectView.alpha = 1.0
                
                }, completion: nil)
     
            searchBar = UISearchBar(frame: CGRect(x: 0, y: self.navigationController!.navigationBar.frame.maxY, width: self.view.frame.width, height: 44))
            searchController = UISearchController(searchResultsController: UITableViewController())
            searchBar.delegate = self
            searchBar.searchBarStyle = UISearchBarStyle.Minimal
            
            
            searchController.delegate = self
            //searchDisplayController.searchResultsDataSource = self
            self.view.addSubview(searchBar)
            
            
            var margin = 20
            
            var indent = 20
        
            let criteria = ["Recipe Name", "Ingredient"]
            
            criteriaSegmentedControl = UISegmentedControl(items: criteria)
            criteriaSegmentedControl.selectedSegmentIndex = 0
            criteriaSegmentedControl.frame = CGRect(x: 10, y: searchBar.frame.maxY + CGFloat(margin), width: self.view.frame.width - 20, height: 30)
            //criteriaSegmentedControl.layer.cornerRadius = 5.0
            criteriaSegmentedControl.backgroundColor = UIColor.darkGrayColor()
            criteriaSegmentedControl.tintColor = UIColor.whiteColor()
            criteriaSegmentedControl.alpha = 0.4
            criteriaSegmentedControl.addTarget(nil, action: "checkIfCanExclude", forControlEvents: .ValueChanged)
            effectView.addSubview(criteriaSegmentedControl)
            
            let options = ["Include", "Exclude"]
            includedExcludedSegmentedControl = UISegmentedControl(items: options)
            includedExcludedSegmentedControl.selectedSegmentIndex = 0
            includedExcludedSegmentedControl.frame = CGRect(x: 10, y: criteriaSegmentedControl.frame.maxY + CGFloat(margin), width: self.view.frame.width - 20, height: 30)
            //criteriaSegmentedControl.layer.cornerRadius = 5.0
            includedExcludedSegmentedControl.backgroundColor = UIColor.darkGrayColor()
            includedExcludedSegmentedControl.tintColor = UIColor.whiteColor()
            includedExcludedSegmentedControl.alpha = 0.1
            includedExcludedSegmentedControl.userInteractionEnabled = false

            effectView.addSubview(includedExcludedSegmentedControl)
            
            
            var searchButton = UIButton(frame: CGRect(x: CGFloat(indent), y: includedExcludedSegmentedControl.frame.maxY + CGFloat(margin), width: self.view.frame.width - CGFloat(2*indent), height: 40))
            searchButton.layer.cornerRadius = searchButton.frame.height * 0.5
            searchButton.layer.masksToBounds = true
            searchButton.setTitle("Search", forState: .Normal)
            searchButton.alpha = 0.4
            searchButton.layer.borderWidth = 2
            
            searchButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            searchButton.backgroundColor = UIColor.darkGrayColor()
            searchButton.layer.borderColor = UIColor.whiteColor().CGColor
            
            
            searchButton.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
            searchButton.addTarget(self, action: "changeButtonColor:", forControlEvents: UIControlEvents.TouchDown)
            searchButton.addTarget(self, action: "pullOffButton:", forControlEvents: UIControlEvents.TouchUpOutside)

            effectView.addSubview(searchButton)
            effectView.bringSubviewToFront(searchButton)

            var addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: searchBar, action: "addSearchTerm")
            
            self.navigationController?.navigationItem.setLeftBarButtonItem( addButton, animated: true)
            
        } else {
            UIView.animateWithDuration(animationTime, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                
                self.searchDarkenEffect.alpha = 0.0
                
                
            }, completion: {
                    self.searchDarkenEffect.removeFromSuperview()
                    return nil}())
            
            searchIsOn = false
        }
        
        
    }
    
    func checkIfCanExclude() {
        if criteriaSegmentedControl.selectedSegmentIndex == 0 {
            includedExcludedSegmentedControl.userInteractionEnabled = false
            includedExcludedSegmentedControl.alpha = 0.1

        } else {
            includedExcludedSegmentedControl.userInteractionEnabled = true
            includedExcludedSegmentedControl.alpha = 0.4


        }
    }
    
    func buttonAction(sender: UIButton) {
        println("buttonAction")
        searchIsOn = true
        
        sender.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        sender.backgroundColor = UIColor.darkGrayColor()
        sender.layer.borderColor = UIColor.whiteColor().CGColor
        
        var searchBarText = self.searchBar.text
        searchBarText = searchBarText.lowercaseString
        searchBarText = searchBarText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        searchBarText = searchBarText.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)

        if(criteriaSegmentedControl.selectedSegmentIndex == 0) {
            additionalSearchCriteria = "&q=\(searchBarText)"
        } else {
            if(includedExcludedSegmentedControl.selectedSegmentIndex == 0) {
                additionalSearchCriteria = "&allowedIngredient[]=\(searchBarText)"
            } else {
                additionalSearchCriteria = "&excludedIngredient[]=\(searchBarText)"
            }
        }
        self.recipes.removeAll(keepCapacity: false)
        self.collectionViewContentStream.reloadData()
        populatePhotos()
        self.searchDarkenEffect.removeFromSuperview()

    }
    
    func changeButtonColor(sender: UIButton) {
        sender.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        sender.backgroundColor = UIColor.foodMateGreen(UIColor.greenColor())()
        sender.layer.borderColor = UIColor.darkGrayColor().CGColor
    }
    
    func pullOffButton(sender: UIButton) {
        sender.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        sender.backgroundColor = UIColor.darkGrayColor()
        sender.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    
    
    /*func colletionView (collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        heightForHeaderInSection section: NSInteger) -> CGFloat {
            
    }
    
    func colletionView (collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        heightForFooterInSection section: NSInteger) -> CGFloat {
            
    }
    
    func colletionView (collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: NSInteger) -> UIEdgeInsets {
            
    }
    
    func colletionView (collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAtIndex section: NSInteger) -> CGFloat {
            
    }*/
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        println("Prepare for segue recipe: \(pickedRecipe)")
        var destinationVC = segue.destinationViewController as! BrowserRecipePreviewViewController
        destinationVC.recipe = self.pickedRecipe
    }
    

}
