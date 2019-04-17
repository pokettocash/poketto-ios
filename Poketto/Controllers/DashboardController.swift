//
//  DashboardController.swift
//  Poketto
//
//  Created by André Sousa on 17/04/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit

class DashboardController: UIViewController {
    
    @IBOutlet var balanceLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let wallet = Wallet.init()

        let explorer = Explorer.init()
        explorer.balanceFrom(address: wallet.getEthereumAddress()!.address, completion: { balance in
            print(balance)
            self.balanceLabel.text = "\(balance) xDai"
        })
    }
}
