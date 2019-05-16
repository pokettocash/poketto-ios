//
//  PaymentSuccessController.swift
//  Poketto
//
//  Created by André Sousa on 24/04/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit
import web3swift
import Contacts

class PaymentSuccessController: UIViewController {
    
    var fromDetails                         : Bool!
    var transaction                         : TransactionSendingResult!
    var paymentContact                      : PaymentContact!
    @IBOutlet weak var userImageView        : UIImageView!
    @IBOutlet weak var userNameLabel        : UILabel!
    @IBOutlet weak var addressLabel         : UILabel!
    @IBOutlet weak var shortAddressLabel    : UILabel!
    @IBOutlet weak var amountLabel          : UILabel!
    @IBOutlet weak var assignWalletButton   : UIButton!
    var contactStore                        = CNContactStore()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let amountValue = Float(transaction.transaction.value) / 1000000000000000000.0
        let amount = String(format: "%.2f", amountValue)

        addressLabel.text = "\(transaction.transaction.to.address)"
        
        let attributedString = NSMutableAttributedString(string: amount,
                                                         attributes: [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 40),
                                                                       NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1)])
        attributedString.append(NSMutableAttributedString(string: "xDai",
            attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                         NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1)]))
        amountLabel.attributedText = attributedString
        
        if let contactId = paymentContact?.contactId {
            
            assignWalletButton.isHidden = true
            assignWalletButton.isUserInteractionEnabled = false
            addressLabel.isHidden = true
            userNameLabel.isHidden = false
            shortAddressLabel.isHidden = false

            userImageView.layer.cornerRadius = userImageView.frame.size.width/2
            
            shortAddressLabel.text = "\(transaction.transaction.to.address)"

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
            addressLabel.isHidden = false
            userNameLabel.isHidden = true
            shortAddressLabel.isHidden = true
            DispatchQueue.main.async {
                self.userImageView.image = UIImage(named: "unknown-address")
            }
        }

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
        
        if fromDetails {
            navigationController?.setNavigationBarHidden(false, animated: true)
            navigationController?.popToRootViewController(animated: true)
        } else {
            navigationController?.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func assignContact() {
        
        let contactsNavVC = storyboard?.instantiateViewController(withIdentifier: "contactsNavVC") as! UINavigationController
        let contactsVC = contactsNavVC.viewControllers[0] as! ContactsController
        contactsVC.address = "\(transaction.transaction.to.address)"
        navigationController?.present(contactsNavVC, animated: true, completion: nil)
    }
    
    @IBAction func shareTransaction() {
        
        if let hash = transaction.transaction.txhash {
            let urlString = "https://blockscout.com/poa/dai/tx/\(hash)/internal_transactions"
            let url = URL(string: urlString)
            let ac = UIActivityViewController(activityItems: [url!], applicationActivities: nil)
            present(ac, animated: true)
        }
    }
}
