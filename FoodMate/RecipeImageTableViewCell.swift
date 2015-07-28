//
//  RecipeImageTableViewCell.swift
//  FoodMate
//
//  Created by Jesse Lupica on 5/1/15.
//  Copyright (c) 2015 Jesse Lupica. All rights reserved.
//

import UIKit
import Alamofire


class RecipeImageTableViewCell: UITableViewCell {
    
    var myImageView: UIImageView!
    var innerFoodImage: UIImageView!
    var request: Alamofire.Request?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        myImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        myImageView.contentMode = UIViewContentMode.ScaleAspectFill
        contentView.addSubview(myImageView)
        innerFoodImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        myImageView.addSubview(innerFoodImage)
     
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
