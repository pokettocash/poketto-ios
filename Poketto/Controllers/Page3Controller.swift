//
//  Page3Controller.swift
//  Poketto
//
//  Created by André Sousa on 17/04/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit

class Page3Controller: UIViewController {

    @IBOutlet weak var spacingConstraint : NSLayoutConstraint!
    @IBOutlet weak var learnMoreButtonBottomConstraint : NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        spacingConstraint.constant = 56 * UIScreen.main.bounds.size.height/812
        
        let window = UIApplication.shared.keyWindow
        var padding : CGFloat = 0
        if window?.safeAreaInsets.bottom == 0 {
            padding = 10
        }

        learnMoreButtonBottomConstraint.constant = (10+padding) * UIScreen.main.bounds.size.height/812 + padding
    }
    
    @IBAction func learnMore() {
        UIApplication.shared.open(URL(string: "https://poa.network/xdai")!, options: [:], completionHandler: nil)
    }
}
