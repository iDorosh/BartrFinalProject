//
//  ViewImage.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/20/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit

class ViewImageVC: UIViewController {
    
    //Variables
    var showImage : UIImage = UIImage()
    
    //Outlets
    @IBOutlet weak var largerImage: UIImageView!
    
    //Actions
    @IBAction func saveImage(sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        loadUI()
    }
    
    override func didReceiveMemoryWarning() {super.didReceiveMemoryWarning()}
    
    func loadUI(){
        //Set UIImage View to the proper image
        largerImage.image = showImage
        self.tabBarController?.tabBar.hidden = true
    }
}