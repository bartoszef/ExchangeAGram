//
//  FilterViewController.swift
//  ExchangeAGram
//
//  Created by bartosz on 9/11/2015.
//  Copyright (c) 2015 bartosz. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate { // we need to conform this class to protocols: UICollectionViewDataSource, UICollectionViewDelegate and then implement required functions [collectionView() x2]
    
    var thisFeedItem:FeedItem!
    
    
    // setup a collection view instance inside our filterViewController, so that we can see how to make collection views in code
    var collectionView:UICollectionView!
    
    let kIntensity = 0.7
    
    var context:CIContext = CIContext(options: nil)
    
    var filters:[CIFilter] = []
    
    let placeHolderImage = UIImage(named: "Placeholder")
    
    let tmp = NSTemporaryDirectory() // returns path

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let layout = UICollectionViewFlowLayout()
        
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        layout.itemSize = CGSize(width: 150.0, height: 150.0)
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.backgroundColor = UIColor.whiteColor() // a little formatting
        
        // register FilterCell class with the collection view, so that it knows which cell we will be using:
        collectionView.registerClass(FilterCell.self, forCellWithReuseIdentifier: "Cell")
        
        println("hey1")
        
        self.view.addSubview(collectionView) // and add it
        
        filters = photoFilters()
        

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:FilterCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as FilterCell
        
        //if cell.imageView.image == nil { // hashed out cause it's caching now, can be reloaded as many times it wants, it takes it from the cache
        
            cell.imageView.image = placeHolderImage
            
            let filterQueue:dispatch_queue_t = dispatch_queue_create("filter queue", nil)
            dispatch_async(filterQueue, { () -> Void in
                
                // this is without cache:
                // let filterImage = self.filteredImageFromImage(self.thisFeedItem.thumbNail, filter: self.filters[indexPath.row])
                // this is with cache:
                let filterImage = self.getCachedImage(indexPath.row)
                
                // go back to the main thread
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    cell.imageView.image = filterImage
                })
            })
            
        //}

    
//        cell.imageView.image = filteredImageFromImage(thisFeedItem.image, filter: filters[indexPath.row])
//        println("hey")
        
        return cell
    }
    
    // UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        createUIAlertController(indexPath)

        
    }
    
    // Helper funcs
    
    func photoFilters() -> [CIFilter] {
        
        let blur = CIFilter(name: "CIGaussianBlur")
        let instant = CIFilter(name: "CIPhotoEffectInstant")
        let noir = CIFilter(name: "CIPhotoEffectNoir")
        let transfer = CIFilter(name: "CIPhotoEffectTransfer")
        let unsharpen = CIFilter(name: "CIUnsharpMask")
        let monochrome = CIFilter(name: "CIColorMonochrome")
        
        let colorControls = CIFilter(name: "CIColorControls")
        colorControls.setValue(0.5, forKey: kCIInputSaturationKey)
        
        let sepia = CIFilter(name: "CISepiaTone")
        sepia.setValue(kIntensity, forKey: kCIInputIntensityKey)
        
        let colorClamp = CIFilter(name: "CIColorClamp")
        colorClamp.setValue(CIVector(x: 0.9, y: 0.9, z: 0.9, w: 0.9), forKey: "inputMaxComponents")
        colorClamp.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0.2), forKey: "inputMinComponents")
        
        let composite = CIFilter(name: "CIHardLightBlendMode")
        composite.setValue(sepia.outputImage, forKey: kCIInputImageKey)
        
        let vignette = CIFilter(name: "CIVignette")
        vignette.setValue(composite.outputImage, forKey: kCIInputImageKey)
        vignette.setValue(kIntensity * 2, forKey: kCIInputIntensityKey)
        vignette.setValue(kIntensity * 30, forKey: kCIInputRadiusKey)
        
        return [blur, instant, noir, transfer, unsharpen, monochrome, colorControls, sepia, colorClamp, composite, vignette]

        
    }
    
    func filteredImageFromImage(imageData: NSData, filter: CIFilter) -> UIImage {
        
        let unfilteredImage = CIImage(data: imageData)
        
        filter.setValue(unfilteredImage, forKey: kCIInputImageKey)
        let filteredImage:CIImage = filter.outputImage

        let extent = filteredImage.extent() // extent() - return a part of an image (?)

        //extent in this case represents our image boundaries if you will. We declare a constant simply so it's easier to pass it to the createCGImage function which needs to know what we want to create an image from, it needs a rectangle information and that is exactly what extent is giving us here.
        
        let cgImage:CGImageRef = context.createCGImage(filteredImage, fromRect: extent)

        let finalImage = UIImage(CGImage: cgImage)

        return finalImage!
        
    }
    
    // UIAlertController helper functions
    
    func createUIAlertController(indexPath:NSIndexPath) {
        
        let alert = UIAlertController(title: "Photo Options", message: "Please choose an option", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Add Caption!"
            textField.secureTextEntry = false
        }
        
//        var text:String
        
        let textField = alert.textFields![0] as UITextField
//        if textField.text != nil {
//            text = textField.text
//        }
        
        let photoAction = UIAlertAction(title: "Post Photo to Facebook with Caption", style: UIAlertActionStyle.Destructive) { (UIAlertAction) -> Void in
            /* code to run when tapped */
        
            self.shareToFacebook(indexPath)
            
            var text = textField.text
            self.saveFilterToCoreData(indexPath, caption: text)
        
        }
        alert.addAction(photoAction)
        
        let saveFilterAction = UIAlertAction(title: "Save Filter without posting to Facebook", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            /* code to run when tapped */
            
            var text = textField.text
            self.saveFilterToCoreData(indexPath, caption: text)

        }
        alert.addAction(saveFilterAction)
        
        let cancelAction = UIAlertAction(title: "Select another Filter", style: UIAlertActionStyle.Cancel) { (UIAlertAction) -> Void in /* code to run when tapped */ }
        alert.addAction(cancelAction)
    
        self.presentViewController(alert, animated: true, completion: nil)
        
        

        
    }
    
    func saveFilterToCoreData(indexPath: NSIndexPath, caption: String) {
        
        let filterImage = self.filteredImageFromImage(self.thisFeedItem.image, filter: self.filters[indexPath.row])

        let imageData = UIImageJPEGRepresentation(filterImage, 1.0)
        self.thisFeedItem.image = imageData

        let thumbNailData = UIImageJPEGRepresentation(filterImage, 0.1)
        self.thisFeedItem.thumbNail = thumbNailData
        
        self.thisFeedItem.caption = caption

        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()

        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    
    func shareToFacebook(indexPath:NSIndexPath) {
        
        let filterImage = self.filteredImageFromImage(self.thisFeedItem.image, filter: self.filters[indexPath.row])
        
        // NSArray instance here, as fb requires - allows to pass multiple photos
        let photos:NSArray = [filterImage]
        var params = FBPhotoParams()
        params.photos = photos
        
        
        // we call presentShareDialogWithPhotoParams(), pass params, waits for callback function [call] and accesses its result and/or error
        FBDialogs.presentShareDialogWithPhotoParams(params, clientState: nil) { (call, result, error) -> Void in
            
            if result? != nil {
                println(result)
            }
            else {
                println(error)
            }
            
        }
        
        
    }
    
    
    // caching funcs
    
    func cacheImage(imageNumber:Int) {
        
        let fileName = "\(imageNumber)"
        let uniquePath = tmp.stringByAppendingPathComponent(fileName)
        
        if !NSFileManager.defaultManager().fileExistsAtPath(fileName) {
            let data = self.thisFeedItem.thumbNail
            let filter = self.filters[imageNumber]
            let image = filteredImageFromImage(data, filter: filter)
            
            UIImageJPEGRepresentation(image, 1.0).writeToFile(uniquePath, atomically: true)
            
        }
        
    }
    
     func getCachedImage(imageNumber: Int) -> UIImage {
        
        let fileName = "\(imageNumber)"
        let uniquePath = tmp.stringByAppendingPathComponent(fileName)
        
        var image:UIImage

        if NSFileManager.defaultManager().fileExistsAtPath(uniquePath) {
            image = UIImage(contentsOfFile: uniquePath)!
        } else {
            self.cacheImage(imageNumber)
            image = UIImage(contentsOfFile: uniquePath)!
        }
        
        return image
    }



    

}
