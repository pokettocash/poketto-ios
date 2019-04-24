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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
