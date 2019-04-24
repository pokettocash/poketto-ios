//
//  PaySendController.swift
//  Poketto
//
//  Created by André Sousa on 23/04/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit

class PaymentSendController: UIViewController {
    
    var address                         : String!
    @IBOutlet weak var userImageView    : UIImageView!
    @IBOutlet weak var userNameLabel    : UILabel!
    @IBOutlet weak var amountTextField  : UITextField!
    var navBarTitleLabel                : UILabel!
    var navBarSubTitleLabel             : UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        if address != nil {
            userNameLabel.text = address
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNavigationBar()
        if address != nil {
            userNameLabel.text = address
            amountTextField.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeNavBarLabels()
    }
    
    func setNavigationBar() {
        
        if let navigationBar = navigationController?.navigationBar {
            let firstFrame = CGRect(x: navigationBar.frame.width/2 - 47, y: 0, width: 94, height: 18)
            let secondFrame = CGRect(x: 0, y: 20, width: navigationBar.frame.width, height: 12)
            
            navBarTitleLabel = UILabel(frame: firstFrame)
            navBarTitleLabel.text = "Send Money"
            navBarTitleLabel.font = UIFont.boldSystemFont(ofSize: 16)
            navBarTitleLabel.textAlignment = .center
            
            navBarSubTitleLabel = UILabel(frame: secondFrame)
            navBarSubTitleLabel.text = "Balance ... xDai"
            navBarSubTitleLabel.font = UIFont.systemFont(ofSize: 12)
            navBarSubTitleLabel.textColor = UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 0.6)
            navBarSubTitleLabel.textAlignment = .center
            
            navigationBar.addSubview(navBarTitleLabel)
            navigationBar.addSubview(navBarSubTitleLabel)

            let wallet = Wallet.init()
            
            let explorer = Explorer.init()
            explorer.balanceFrom(address: wallet.getEthereumAddress()!.address, completion: { balance in
                print(balance)
                self.navBarSubTitleLabel.text = "Balance \(balance) xDai"
            })
        }
    }
    
    func removeNavBarLabels() {
        
        navBarTitleLabel.removeFromSuperview()
        navBarSubTitleLabel.removeFromSuperview()
        navBarTitleLabel = nil
        navBarSubTitleLabel = nil
    }
    
    @IBAction func send() {
        
        if let amount = amountTextField.text {
            let wallet = Wallet.init()
            wallet.send(toAddress: wallet.getEthereumAddress()!.address, value: amount, success: { result in
                print("show next screen")
                let transaction = ["address": wallet.getEthereumAddress()!.address, "amount": amount]
                self.performSegue(withIdentifier: "success", sender: transaction)
            }) { error in
                DispatchQueue.main.async {
                    let msg = "Invalid code"
                    let alert = UIAlertController(title: "Error",
                                                  message: msg,
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "success" {
            let paymentSuccessVC = segue.destination as! PaymentSuccessController
            paymentSuccessVC.address = (sender as! [String: Any])["address"] as? String
            paymentSuccessVC.amount = (sender as! [String: Any])["amount"] as? String
        }
    }
}
