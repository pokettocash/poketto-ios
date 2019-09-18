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
import BigInt

class PaymentSendController: UIViewController {
    
    var fromDetails                                 : Bool!
    var address                                     : String!
    var eip681Code                                  : Web3.EIP681Code?
    var paymentContact                              : PaymentContact!
    @IBOutlet weak var userImageView                : UIImageView!
    @IBOutlet weak var userNameLabel                : UILabel!
    @IBOutlet weak var addressLabel                 : UILabel!
    @IBOutlet weak var amountTextField              : UITextField!
    var navBarTitleLabel                            : UILabel!
    var navBarSubTitleLabel                         : UILabel!
    var contactStore                                = CNContactStore()
    @IBOutlet weak var sendButtonBottomConstraint   : NSLayoutConstraint!
    @IBOutlet weak var maxButton                    : UIButton!
    @IBOutlet weak var additionalViewTopConstraint  : NSLayoutConstraint!
    @IBOutlet weak var currencyTopConstraint        : NSLayoutConstraint!
    @IBOutlet weak var amountTopConstraint          : NSLayoutConstraint!
    @IBOutlet weak var noteTextView                : UITextView!
    var hasCenteredNoteTextViewVertically           = false
    let selection                                   = UISelectionFeedbackGenerator()
    var maxBalanceSelected                          = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userImageView.layer.cornerRadius = userImageView.frame.size.width/2
        
        if eip681Code != nil {
            let targetAddress = eip681Code!.targetAddress
            switch(targetAddress) {
            case .ethereumAddress(let ethereumAddress):
                address = ethereumAddress.address
            case .ensAddress(_): break
            }
        
            if eip681Code!.amount != nil {
                DispatchQueue.main.async {
                    self.amountTextField.text = Web3.Utils.formatToEthereumUnits(BigInt(self.eip681Code!.amount!.magnitude), toUnits: .eth, decimals: 2, decimalSeparator: ",")
                }
            }
        }
        
        if address != nil {
            userNameLabel.text = address
        }
        if let contactId = paymentContact?.contactId {
            
            addressLabel.isHidden = false
            addressLabel.text = address

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
            addressLabel.removeFromSuperview()
            addressLabel = nil

            DispatchQueue.main.async {
                self.userImageView.image = UIImage(named: "unknown-address")
            }
        }
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        if UIScreen.main.bounds.size.height <= 568 {
            maxButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            maxButton.imageEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
            maxButton.imageView?.contentMode = .scaleAspectFit
            additionalViewTopConstraint.constant = 76
            currencyTopConstraint.constant = 26
            amountTopConstraint.constant = 21
            noteTextView.autocorrectionType = .no
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !hasCenteredNoteTextViewVertically {
            noteTextView.centerVertically()
            hasCenteredNoteTextViewVertically = true
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
            let firstFrame = CGRect(x: navigationBar.frame.width/2 - 60, y: 0, width: 120, height: 18)
            let secondFrame = CGRect(x: 0, y: 20, width: navigationBar.frame.width, height: 12)
            
            navBarTitleLabel = UILabel(frame: firstFrame)
            navBarTitleLabel.text = "Send Payment"
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
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            if UIScreen.main.bounds.size.height <= 568 {
                sendButtonBottomConstraint.constant = keyboardHeight + 6
            } else {
                sendButtonBottomConstraint.constant = keyboardHeight + 16
            }
        }
    }
    
    @IBAction func setMaxValue() {
        
        selection.selectionChanged()
        
        var transactionCost = Float(0.000021)
        if self.noteTextView.text?.isEmpty == false && self.noteTextView.text != "Write a public note" {
            transactionCost = Float(0.00008)
        }
        setMaxValueWithTransactionCost(transactionCost: transactionCost)
    }
    
    func setMaxValueWithTransactionCost(transactionCost: Float) {
        
        let wallet = Wallet.init()

        Explorer.init().balanceFrom(address: wallet.getEthereumAddress()!.address, completion: { balance in
            self.amountTextField.text = String(balance - transactionCost)
            self.maxButton.setTitleColor(UIColor(red: 33/255, green: 107/255, blue: 254/255, alpha: 1), for: .normal)
            self.maxButton.setTitleColor(UIColor(red: 33/255, green: 107/255, blue: 254/255, alpha: 0.5), for: .highlighted)
            self.maxButton.tintColor = UIColor(red: 33/255, green: 107/255, blue: 254/255, alpha: 1)
            self.maxBalanceSelected = true
        })
    }
    
    @IBAction func send() {
        
        if let amount = amountTextField.text {
            
            SVProgressHUD.show()
            SVProgressHUD.setDefaultMaskType(.black)
            SVProgressHUD.setForegroundColor(UIColor(red: 251/255, green: 198/255, blue: 73/255, alpha: 1))
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            var message : String? = nil
            if self.noteTextView.text?.isEmpty == false && self.noteTextView.text != "Write a public note" {
                message = self.noteTextView.text!
            }

            DispatchQueue.global(qos: .background).async {
                print("This is run on the background queue")

                let wallet = Wallet.init()
                
                wallet.send(toAddress: self.address!, value: amount, message: message, success: { transaction in
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
            if self.noteTextView.text?.isEmpty == false && self.noteTextView.text != "Write a public note" {
                paymentSuccessVC.message = self.noteTextView.text!
            }
            paymentSuccessVC.fromDetails = fromDetails
            paymentSuccessVC.transaction = sender as? TransactionSendingResult
        }
    }
}

extension PaymentSendController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == amountTextField && textField.text != "" {
            maxButton.setTitleColor(UIColor(red: 115/255, green: 115/255, blue: 115/255, alpha: 1.0), for: .normal)
            maxButton.setTitleColor(UIColor(red: 115/255, green: 115/255, blue: 115/255, alpha: 0.5), for: .highlighted)
            maxButton.tintColor = UIColor(red: 115/255, green: 115/255, blue: 115/255, alpha: 1.0)
            self.maxBalanceSelected = false
        }

        return true
    }
}

extension PaymentSendController : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Write a public note" {
            textView.text = nil
        }
        self.noteTextView.centerVertically()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write a public note"
        }
        if self.maxBalanceSelected {
            setMaxValue()
        }
        self.noteTextView.centerVertically()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        if textView == noteTextView && noteTextView.text!.count+text.count > 55 {
            return false
        }
        if self.maxBalanceSelected {
            self.setMaxValueWithTransactionCost(transactionCost: Float(0.00008))
        }
        self.noteTextView.centerVertically()
        return true
    }
}

extension UITextView {
    
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
}
