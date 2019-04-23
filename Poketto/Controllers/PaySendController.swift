//
//  PaySendController.swift
//  Poketto
//
//  Created by André Sousa on 23/04/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit

class PaySendController: UIViewController {
    
    var address : String!
    @IBOutlet weak var userImageView    : UIImageView!
    @IBOutlet weak var userNameLabel    : UILabel!
    @IBOutlet weak var amountTextField  : UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        if address != nil {
            userNameLabel.text = address
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if address != nil {
            userNameLabel.text = address
            amountTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func send() {
        
    }
}
