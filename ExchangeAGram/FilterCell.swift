//
//  FilterCell.swift
//  ExchangeAGram
//
//  Created by bartosz on 9/11/2015.
//  Copyright (c) 2015 bartosz. All rights reserved.
//

import UIKit

class FilterCell: UICollectionViewCell {
    
    var imageView:UIImageView!
    
    // to get our image to appear over the entire view, we add the variable, custom initializer, imageView, and required init below:
    
    
    override init(frame: CGRect) { // a custom initializer here
        
        super.init(frame: frame)

        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        contentView.addSubview(imageView)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
