//
//  PaymentDetailsController.swift
//  Poketto
//
//  Created by André Sousa on 08/05/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit
import Contacts

class PaymentDetailsController: UIViewController {

    var transaction                         : Transaction!
    var paymentContact                      : PaymentContact!
    @IBOutlet weak var userImageView        : UIImageView!
    @IBOutlet weak var userNameLabel        : UILabel!
    @IBOutlet weak var amountLabel          : UILabel!
    @IBOutlet weak var assignWalletButton   : UIButton!
    var contactStore                        = CNContactStore()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Payment details"

        let amountValue = Float(transaction.amount) / 1000000000000000000.0
        let amount = String(format: "%.2f", amountValue)
        
        userNameLabel.text = transaction.toAddress
        
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
            
            userImageView.layer.cornerRadius = userImageView.frame.size.width/2
            
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
    
    @IBAction func done() {
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func assignContact() {
        
        let contactsNavVC = storyboard?.instantiateViewController(withIdentifier: "contactsNavVC") as! UINavigationController
        let contactsVC = contactsNavVC.viewControllers[0] as! ContactsController
        contactsVC.address = transaction.toAddress
        navigationController?.present(contactsNavVC, animated: true, completion: nil)
    }
    
    @IBAction func shareTransaction() {
        
//        if let hash = transaction.transaction.txhash {
//            let urlString = "https://blockscout.com/poa/dai/tx/\(hash)/internal_transactions"
//            let url = URL(string: urlString)
//            let ac = UIActivityViewController(activityItems: [url!], applicationActivities: nil)
//            present(ac, animated: true)
//        }
    }

}
