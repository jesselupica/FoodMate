//
//  RecipeStreamCollectionViewCell.swift
//  FoodMate
//
//  Created by Jesse Lupica on 4/16/15.
//  Copyright (c) 2015 Jesse Lupica. All rights reserved.
//

import UIKit
import Alamofire

extension Alamofire.Request {
    class func imageResponseSerializer() -> Serializer {
        return { request, response, data in
            if data == nil {
                return (nil, nil)
            }
            
            let image = UIImage(data: data!, scale: UIScreen.mainScreen().scale)
            
            return (image, nil)
        }
    }
    
    func responseImage(completionHandler: (NSURLRequest, NSHTTPURLResponse?, UIImage?, NSError?) -> Void) -> Self {
        return response(serializer: Request.imageResponseSerializer(), completionHandler: { (request, response, image, error) in
            completionHandler(request, response, image as? UIImage, error)
        })
    }
    public typealias Serializer = (NSURLRequest, NSHTTPURLResponse?, NSData?) -> (AnyObject?, NSError?)
}




class RecipeStreamCollectionViewCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    var textLabel: UITextView!
    var ratingLabel: UILabel!
    var request: Alamofire.Request?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        //imageView.autoresizingMask = .FlexibleWidth | .FlexibleHeight;
        imageView.clipsToBounds = true;
        contentView.addSubview(imageView)
        //self.bringSubviewToFront(imageView)
        
        let textFrame = CGRect(x: 0, y: imageView.frame.size.height, width: frame.size.width, height: frame.size.height - imageView.frame.size.height - 20)
        textLabel = UITextView(frame: textFrame)
        textLabel.font = UIFont(name: "Baskerville-Bold", size: 14)
        textLabel.textAlignment = .Center
        textLabel.backgroundColor = UIColor.whiteColor()
        textLabel.scrollEnabled = false
        textLabel.editable = false;
        contentView.addSubview(textLabel)
        
        let ratingTextFrame = CGRect(x: 0, y: self.frame.size.height - 20, width: frame.size.width, height: 20)
        ratingLabel = UILabel(frame: ratingTextFrame)
        ratingLabel.font = UIFont(name: "Baskerville", size: 14)
        ratingLabel.textAlignment = .Center
        contentView.addSubview(ratingLabel)

        //self.layer.borderWidth = 2
        //self.layer.borderColor = UIColor.lightGrayColor().CGColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        //imageView.autoresizingMask = .FlexibleWidth | .FlexibleHeight;
       // imageView.clipsToBounds = true;

        contentView.addSubview(imageView)
        //self.bringSubviewToFront(imageView)
        
        let textFrame = CGRect(x: 0, y: imageView.frame.size.height, width: frame.size.width, height: frame.size.height)
        textLabel = UITextView(frame: textFrame)
        textLabel.font = UIFont(name: "Times New Roman", size: 14)
        textLabel.textAlignment = .Center
        contentView.addSubview(textLabel)
    }
    
    func fadeIn() {
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
    
            self.imageView.alpha = 1.0
    
            }, completion: nil)
    }
    
    func adjustToFittingHeight() {
        // Using simply ContentSize does not work on iOS7. The dimensions are calculated lazily.
        // Enforce the layout of the text container to get correct measurements.
        self.textLabel.layoutManager.ensureLayoutForTextContainer(self.textLabel.textContainer);
    
        // Get container size from the layout manager.
        var containerSize = self.textLabel.layoutManager.usedRectForTextContainer(self.textLabel.textContainer).size;
    
        // Take insets into consideration.
        var height = containerSize.height + self.textLabel.textContainerInset.top + self.textLabel.textContainerInset.bottom
    
        // Adjust frame but only alter height.
        var newFrame = CGRect(x: self.textLabel.frame.origin.x, y: self.textLabel.frame.origin.y, width: self.textLabel.frame.width, height: height);
    
        // Return the height for convenient access.
        self.textLabel.frame = newFrame
    }
    
}
