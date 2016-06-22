//
//  ChatViewController.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/11/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit

class Chat: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //Back to Chat Action
    @IBAction func backToChat(segue: UIStoryboardSegue){}
    
    //Table View
    @IBOutlet weak var tabletView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        UIApplication.sharedApplication().statusBarStyle = .Default
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Set Up Table View
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let post = indexPath.row
        let cell : CustomChatTableCell = tableView.dequeueReusableCellWithIdentifier("chatCell")! as! CustomChatTableCell
        cell.tableConfig(post)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
    }
}
