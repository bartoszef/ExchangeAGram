//
//  ProfileViewController.swift
//  ExchangeAGram
//
//  Created by bartosz on 17/11/2015.
//  Copyright (c) 2015 bartosz. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, FBLoginViewDelegate {
   
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fbLoginView: FBLoginView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fbLoginView.delegate = self // when a callback occurs it now knows where to go (?)
        self.fbLoginView.readPermissions = ["public_profile", "publish_actions"]
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loginViewShowingLoggedInUser(loginView: FBLoginView!) {
        profileImageView.hidden = false
        nameLabel.hidden = false
        
    }
    
    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser!) {
        
        // called after successfully lofgged in
        
        println(user)
        
        nameLabel.text = user.name
        
        // fetch profile pic and display:
        let userImageURL = "https://graph.facebook.com/\(user.objectID)/picture?type=small"
        let url = NSURL(string: userImageURL)
        let imageData = NSData(contentsOfURL: url!)
        let image = UIImage(data: imageData!)
        
        profileImageView.image = image
        
        
    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
        profileImageView.hidden = true
        nameLabel.hidden = true
    }
    
    
    func loginView(loginView: FBLoginView!, handleError error: NSError!) {
        
        println("Error: \(error.localizedDescription)")
        
    }
    
}
