//
//  FeedItem.swift
//  ExchangeAGram
//
//  Created by bartosz on 15/11/2015.
//  Copyright (c) 2015 bartosz. All rights reserved.
//

import Foundation
import CoreData

@objc(FeedItem)

class FeedItem: NSManagedObject {

    @NSManaged var caption: String
    @NSManaged var image: NSData
    @NSManaged var thumbNail: NSData

}
