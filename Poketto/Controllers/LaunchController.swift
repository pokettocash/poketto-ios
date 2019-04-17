//
//  LaunchController.swift
//  Poketto
//
//  Created by André Sousa on 17/04/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit

class LaunchController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let wallet = Wallet.init()
        if(wallet.getEthereumAddress() == nil) {
            AppDelegate.shared.rootViewController.switchToOnboarding()
        } else {
            AppDelegate.shared.rootViewController.switchToDashboard()
        }
    }
    
}
