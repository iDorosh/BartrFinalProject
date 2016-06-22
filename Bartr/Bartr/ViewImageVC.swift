//
//  ViewImage.swift
//  Bartr
//
//  Created by Ian Dorosh on 6/20/16.
//  Copyright © 2016 Vulkan Mobile Development. All rights reserved.
//

import UIKit

class ViewImageVC: UIViewController {
    
    //Holds the selected image
    var showImage : UIImage = UIImage()
    
    //Displays the selected image
    @IBOutlet weak var largerImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        //Set UIImage View to the proper image
        largerImage.image = showImage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
