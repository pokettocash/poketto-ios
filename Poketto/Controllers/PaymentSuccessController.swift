//
//  PaymentSuccessController.swift
//  Poketto
//
//  Created by André Sousa on 24/04/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit

class PaymentSuccessController: UIViewController {
    
    var address                     : String!
    var amount                      : String!
    @IBOutlet weak var addressLabel : UILabel!
    @IBOutlet weak var amountLabel  : UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        addressLabel.text = address
        amountLabel.text = amount
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func done() {
        
        navigationController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func assignContact() {
        
        let contactsNavVC = storyboard?.instantiateViewController(withIdentifier: "contactsNavVC") as! UINavigationController
        let contactsVC = contactsNavVC.viewControllers[0] as! ContactsController
        contactsVC.address = address
        navigationController?.present(contactsNavVC, animated: true, completion: nil)
    }
}
