//
//  Page4Controller.swift
//  Poketto
//
//  Created by Andre Sousa on 17/05/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit

class Page4Controller: UIViewController {

    @IBOutlet weak var imageTopConstraint : NSLayoutConstraint!
    @IBOutlet weak var spacingConstraint : NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spacingConstraint.constant = 44 * UIScreen.main.bounds.size.height/812
        imageTopConstraint.constant = -130 * UIScreen.main.bounds.size.height/812
    }
}
