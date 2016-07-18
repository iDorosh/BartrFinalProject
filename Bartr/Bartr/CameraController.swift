//
//  CameraController.swift
//  Bartr
//
//  Created by Ian Dorosh on 7/12/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit

class CameraController: UIViewController {

    @IBOutlet weak var bgImage: UIImageView!
    @IBAction func backtoMain(sender: UIButton) {
        performSegueWithIdentifier("BacktoMain", sender: self)
    }
    @IBAction func startNewListing(sender: UIButton) {
        performSegueWithIdentifier("showNewListing", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = true
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        self.bgImage.addSubview(blurEffectView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
