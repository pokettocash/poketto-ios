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

    var transaction                                 : Transaction!
    var paymentContact                              : PaymentContact!
    @IBOutlet weak var titleLabel                   : UILabel!
    @IBOutlet weak var toLabel                      : UILabel!
    @IBOutlet weak var userImageView                : UIImageView!
    @IBOutlet weak var userNameLabel                : UILabel!
    @IBOutlet weak var addressLabel                 : TapAndCopyLabel!
    @IBOutlet weak var shortAddressLabel            : TapAndCopyLabel!
    @IBOutlet weak var amountLabel                  : UILabel!
    @IBOutlet weak var messageLabel                 : UILabel!
    @IBOutlet weak var dateLabel                    : UILabel!
    @IBOutlet weak var hourLabel                    : UILabel!
    @IBOutlet weak var assignWalletButton           : UIButton!
    var contactStore                                = CNContactStore()
    @IBOutlet weak var firstDividerTopConstraint    : NSLayoutConstraint!
    @IBOutlet weak var secondDividerBottomConstraint: NSLayoutConstraint!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Payment details"
        
        if transaction.transactionType == .Credit {
            toLabel.text = "From:"
            titleLabel.text = "You've received"
        }
        
        let amountValue = Float(transaction.amount)
        let amount = String(format: "%.2f", amountValue)
        
        userImageView.image = transaction.displayImage!
        userImageView.layer.cornerRadius = userImageView.frame.size.width/2
        
        if (transaction.displayName != nil) {
            
            addressLabel.isHidden = true
            userNameLabel.isHidden = false
            shortAddressLabel.isHidden = false
            
            shortAddressLabel.text = transaction.transactionType == .Credit ? transaction.fromAddress ?? "" : transaction.toAddress ?? ""

            userNameLabel.text = transaction.displayName
            userNameLabel.font = UIFont.systemFont(ofSize: 16)
            assignWalletButton.setTitle("  Reassign address to contact", for: .normal)
        } else {
            
            addressLabel.isHidden = false
            userNameLabel.isHidden = true
            shortAddressLabel.isHidden = true

            addressLabel.text = transaction.transactionType == .Credit ? transaction.fromAddress ?? "" : transaction.toAddress ?? ""
            addressLabel.numberOfLines = 2
        }
        
        let attributedString = NSMutableAttributedString(string: amount,
                                                         attributes: [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 40),
                                                                       NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1)])
        attributedString.append(NSMutableAttributedString(string: "xDai",
                                                          attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                                                                       NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1)]))
        amountLabel.attributedText = attributedString
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMMM yyyy"
        dateLabel.text = dateFormatter.string(from: transaction.date)
        
        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "hh:mm"
        hourLabel.text = hourFormatter.string(from: transaction.date)
        
        if transaction.input != "0x" {
            
            let indexStartOfText = transaction.input!.index(transaction.input!.startIndex, offsetBy: 2)
            let hexadecimalSubstring = String.init(transaction.input![indexStartOfText...])
            if let messageData = hexadecimalSubstring.hexadecimal {
                let message = String.init(data: messageData, encoding: .utf8)
                messageLabel.text = "\"\(message!)\""
            } else {
                messageLabel.removeFromSuperview()
            }
        } else {
            messageLabel.removeFromSuperview()
        }
        
        if UIScreen.main.bounds.size.height <= 568 {
            firstDividerTopConstraint.constant = 16
            secondDividerBottomConstraint.constant = 16
            if messageLabel != nil {
                messageLabel.numberOfLines = 3
                messageLabel.lineBreakMode = .byTruncatingTail
            }
        }
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    @IBAction func done() {
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func assignContact() {
        
        let contactsNavVC = storyboard?.instantiateViewController(withIdentifier: "contactsNavVC") as! UINavigationController
        let contactsVC = contactsNavVC.viewControllers[0] as! ContactsController
        if transaction.transactionType == .Credit {
            contactsVC.address = transaction.fromAddress
        } else {
            contactsVC.address = transaction.toAddress
        }
        contactsVC.delegate = self
        navigationController?.present(contactsNavVC, animated: true, completion: nil)
    }
    
    @IBAction func shareTransaction() {
        
        if let hash = transaction.txHash {
            let urlString = "https://blockscout.com/poa/dai/tx/\(hash)/internal_transactions"
            let url = URL(string: urlString)
            let ac = UIActivityViewController(activityItems: [url!], applicationActivities: nil)
            present(ac, animated: true)
        }
    }
    
    @IBAction func sendPayment() {

        var paymentContact : PaymentContact
        if transaction.transactionType == .Credit {
            paymentContact = PaymentContact().addContact(from: transaction.fromAddress)
        } else {
            paymentContact = PaymentContact().addContact(from: transaction.toAddress)
        }
        performSegue(withIdentifier: "sendFromDetails", sender: paymentContact)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sendFromDetails" {
            let paymentContact = sender as! PaymentContact
            let paymentSendVC = segue.destination as! PaymentSendController
            paymentSendVC.address = paymentContact.address
            paymentSendVC.paymentContact = paymentContact
            paymentSendVC.fromDetails = true

            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
        }
    }

}

extension PaymentDetailsController : ContactsDelegate {
    
    func assignedContact(phoneContact: CNContact) {
        userNameLabel.text = "\(phoneContact.givenName) \(phoneContact.familyName)"
        DispatchQueue.main.async {
            if let contactThumbailData = phoneContact.thumbnailImageData {
                self.userImageView.image = UIImage(data: contactThumbailData)
            } else {
                DispatchQueue.main.async {
                    self.userImageView.image = UIImage(named: "contact-placeholder")
                }
            }
        }
    }
}
