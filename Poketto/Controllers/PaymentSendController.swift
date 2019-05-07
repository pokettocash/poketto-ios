//
//  PaySendController.swift
//  Poketto
//
//  Created by André Sousa on 23/04/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit
import SVProgressHUD
import web3swift
import Contacts

class PaymentSendController: UIViewController {
    
    var address                         : String!
    var paymentContact                  : PaymentContact!
    @IBOutlet weak var userImageView    : UIImageView!
    @IBOutlet weak var userNameLabel    : UILabel!
    @IBOutlet weak var amountTextField  : UITextField!
    var navBarTitleLabel                : UILabel!
    var navBarSubTitleLabel             : UILabel!
    var contactStore                = CNContactStore()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("PaymentSendController address \(address!)")
        
        userImageView.layer.cornerRadius = userImageView.frame.size.width/2
        
        if address != nil {
            userNameLabel.text = address
        }
        if let contactId = paymentContact?.contactId {
            
            userNameLabel.text = paymentContact.name
            userNameLabel.font = UIFont.systemFont(ofSize: 16)
            userNameLabel.textColor = UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1)

            do {
                let phoneContact = try contactStore.unifiedContact(withIdentifier: contactId, keysToFetch: [CNContactThumbnailImageDataKey as CNKeyDescriptor])
                if let avatar = phoneContact.thumbnailImageData {
                    DispatchQueue.main.async {
                        self.userImageView.image = UIImage(data: avatar)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.userImageView.image = UIImage(named: "contact-placeholder")
                    }
                }
            } catch {
                print("Error fetching results for container")
                DispatchQueue.main.async {
                    self.userImageView.image = UIImage(named: "contact-placeholder")
                }
            }
        } else {
            DispatchQueue.main.async {
                self.userImageView.image = UIImage(named: "unknown-address")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNavigationBar()
        if address != nil {
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
            
            SVProgressHUD.show()
            SVProgressHUD.setDefaultMaskType(.black)
            SVProgressHUD.setForegroundColor(UIColor(red: 251/255, green: 198/255, blue: 73/255, alpha: 1))
            UIApplication.shared.isNetworkActivityIndicatorVisible = true

            DispatchQueue.global(qos: .background).async {
                print("This is run on the background queue")

                let wallet = Wallet.init()
                print("send \(self.address!)")

                wallet.send(toAddress: self.address!, value: amount, success: { transaction in
                    print("show next screen \(transaction)")
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        self.performSegue(withIdentifier: "success", sender: transaction)
                    }
                }) { error in
                    DispatchQueue.main.async {

                        SVProgressHUD.dismiss()
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false

                        let msg = error
                        let alert = UIAlertController(title: "Error",
                                                      message: msg,
                                                      preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        } else {
            let msg = "Please insert amount."
            let alert = UIAlertController(title: "Error",
                                          message: msg,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "success" {
            let paymentSuccessVC = segue.destination as! PaymentSuccessController
            if paymentContact != nil {
                paymentSuccessVC.paymentContact = paymentContact
            }
            paymentSuccessVC.transaction = sender as? TransactionSendingResult
        }
    }
}
