//
//  Feedback.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/23/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit
import Firebase

class Feedback: UIViewController {
    
    var postKey : String = String()
    var previousSegue : String = String()
    
    @IBOutlet weak var blurrView: UIView!
    
    @IBOutlet weak var feedback: UIView!
    
    @IBOutlet var stars: [UIImageView]!
    
    @IBAction func backButton(sender: UIButton) {
        if previousSegue == "Profile"{
            performSegueWithIdentifier("BackToProfile", sender: self)
        } else {
            performSegueWithIdentifier("backToEditProfileSegue", sender: self)
        }
    }
    
    @IBAction func sendFeedBack(sender: UIButton) {
        let selectedPostRef = DataService.dataService.POST_REF.childByAppendingPath(postKey)
        selectedPostRef.removeValue()
        performSegueWithIdentifier("BackToProfile", sender: self)
    }
 
    @IBAction func closeFeedBack(sender: UIButton) {
        blurrView.hidden = true
        feedback.hidden = true
        for i in stars {
            stars[stars.indexOf(i)!].image = UIImage(named: "blankStar")
        }
    }
    
    //Back to Chat Action
    @IBAction func backToFeedback(segue: UIStoryboardSegue){}
    
    //Table View
    @IBOutlet weak var tabletView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        UIApplication.sharedApplication().statusBarStyle = .Default
        blurrView.hidden = true
        feedback.hidden = true
        setupStars()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        self.blurrView.addSubview(blurEffectView)
    }
    
    func setupStars(){
        for index in 0 ... stars.count - 1{
            let getstureRecognizer = UITapGestureRecognizer(target: self, action: #selector (starTapped))
            getstureRecognizer.numberOfTapsRequired = 1
            
            stars[index].addGestureRecognizer(getstureRecognizer)
        }
    }
    
    func starTapped(recognizer: UITapGestureRecognizer){
        let tapped = recognizer.view
        let tappedTag = tapped!.tag
        
        for i in stars {
            stars[stars.indexOf(i)!].image = UIImage(named: "blankStar")
        }
        switch tappedTag{
        case 0:
            stars[0].image = UIImage(named: "clickedStar")
        case 1:
            stars[0].image = UIImage(named: "clickedStar")
            stars[1].image = UIImage(named: "clickedStar")
        case 2:
            stars[0].image = UIImage(named: "clickedStar")
            stars[1].image = UIImage(named: "clickedStar")
            stars[2].image = UIImage(named: "clickedStar")
        case 3:
            stars[0].image = UIImage(named: "clickedStar")
            stars[1].image = UIImage(named: "clickedStar")
            stars[2].image = UIImage(named: "clickedStar")
            stars[3].image = UIImage(named: "clickedStar")
        case 4:
            stars[0].image = UIImage(named: "clickedStar")
            stars[1].image = UIImage(named: "clickedStar")
            stars[2].image = UIImage(named: "clickedStar")
            stars[3].image = UIImage(named: "clickedStar")
            stars[4].image = UIImage(named: "clickedStar")
        default:
            break
        }
    }

    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Set Up Table View
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let post = indexPath.row
        let cell : FeedbackTableCell = tableView.dequeueReusableCellWithIdentifier("FeedbackCell")! as! FeedbackTableCell
        
        cell.tableConfig(post)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        blurrView.hidden = false
        feedback.hidden = false
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}
