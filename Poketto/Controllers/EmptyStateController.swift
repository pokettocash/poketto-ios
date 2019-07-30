//
//  EmptyStateController.swift
//  Poketto
//
//  Created by André Sousa on 30/04/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit

class EmptyStateController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func addFunds() {
        
        UIApplication.shared.open(URL(string: "https://medium.com/@jaredstauffer/how-to-get-xdai-how-to-convert-dai-to-xdai-eth-dai-xdai-30a60e4b6641")!, options: [:], completionHandler: nil)
    }
    
    @IBAction func receiveFunds() {
        
        let parent = self.parent as! DashboardController
        parent.request()
    }
    
    @IBAction func learnMore() {
        
        UIApplication.shared.open(URL(string: "https://poa.network/xdai")!, options: [:], completionHandler: nil)
    }
    
}
