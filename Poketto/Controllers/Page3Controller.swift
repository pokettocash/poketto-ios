//
//  Page3Controller.swift
//  Poketto
//
//  Created by André Sousa on 17/04/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit

class Page3Controller: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func goToDashboard() {
        
        let wallet = Wallet.init()
        wallet.generate()
        AppDelegate.shared.rootViewController.switchToDashboard()
    }
}
