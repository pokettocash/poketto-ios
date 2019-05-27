//
//  PayOptionsController.swift
//  Poketto
//
//  Created by André Sousa on 23/04/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit
import AVFoundation
import QRCodeReader
import SwiftyJSON
import Contacts


class PaymentContactsController: UIViewController, UISearchBarDelegate {

    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
            
            // Configure the view controller (optional)
            $0.showTorchButton        = false
            $0.showSwitchCameraButton = false
            $0.showCancelButton       = true
            $0.showOverlayView        = true
            $0.rectOfInterest         = CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()

    let reuseIdentifier             = "payOptionCellId"
    @IBOutlet weak var tableView    : UITableView!
    var selectedAddress             : String!
    var transactions                : Array<Transaction> = []
    var paymentContacts             : [PaymentContact] = []
    var filteredPaymentContacts     : [PaymentContact] = []
    var wallet                      = Wallet.init()
    var contactStore                = CNContactStore()
    var searchBar                   : UISearchBar!
    var searchBarText               : String!

    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBar()
        setSearchBar()
        setPaymentContacts()
    }

    func setSearchBar() {
        
        searchBar = UISearchBar(frame: CGRect.zero)
        searchBar.delegate = self
        searchBar.placeholder = "Search Contacts"
        navigationItem.titleView = searchBar
        
        for s in searchBar.subviews[0].subviews {
            if s is UITextField {
                s.layer.borderWidth = 2.0
                s.layer.cornerRadius = 10
                s.layer.borderColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1).cgColor
            }
        }
    }
    
    func setNavigationBar() {
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func setPaymentContacts() {
        
        DispatchQueue.global(qos: .background).async {

            var paymentContactsArray : [PaymentContact] = []
            
            var toTransactions : [String] = []
            for transaction in self.transactions {
                toTransactions.append(transaction.toAddress)
            }
            
            var fromTransactions : [String] = []
            for transaction in self.transactions {
                fromTransactions.append(transaction.fromAddress)
            }
            let uniqueToTransactions = Array(Set(toTransactions))
            let uniqueFromTransactions = Array(Set(fromTransactions))
            
            for toTransaction in uniqueToTransactions {
                if paymentContactsArray.count == 0 {
                    let paymentContact = PaymentContact().addContact(from: toTransaction)
                    paymentContactsArray.append(paymentContact)
                } else {
                    var filteredContacts = paymentContactsArray.filter({$0.address.uppercased() == toTransaction.uppercased()})
                    if filteredContacts.count == 0 {
                        if let contact = PKContact.mr_findFirst(byAttribute: "address", withValue: toTransaction.uppercased()) {
                            filteredContacts = paymentContactsArray.filter({$0.address.uppercased() == contact.address!.uppercased()})
                            if filteredContacts.count == 0 {
                                let paymentContact = PaymentContact().addContact(from: toTransaction)
                                paymentContactsArray.append(paymentContact)
                            }
                        } else {
                            let paymentContact = PaymentContact().addContact(from: toTransaction)
                            paymentContactsArray.append(paymentContact)
                        }
                    }
                }
            }
            
            for fromTransaction in uniqueFromTransactions {
                if paymentContactsArray.count == 0 {
                    let paymentContact = PaymentContact().addContact(from: fromTransaction)
                    paymentContactsArray.append(paymentContact)
                } else {
                    var filteredContacts = paymentContactsArray.filter({$0.address.uppercased() == fromTransaction.uppercased()})
                    if filteredContacts.count == 0 {
                        if let contact = PKContact.mr_findFirst(byAttribute: "address", withValue: fromTransaction.uppercased()) {
                            filteredContacts = paymentContactsArray.filter({$0.address.uppercased() == contact.address!.uppercased()})
                            if filteredContacts.count == 0 {
                                let paymentContact = PaymentContact().addContact(from: fromTransaction)
                                paymentContactsArray.append(paymentContact)
                            }
                        } else {
                            let paymentContact = PaymentContact().addContact(from: fromTransaction)
                            paymentContactsArray.append(paymentContact)
                        }
                    }
                }
            }

            DispatchQueue.main.async {
                self.paymentContacts = paymentContactsArray
                self.filteredPaymentContacts = self.paymentContacts
                self.tableView.reloadData()
            }
        }

    }
        
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText:String){

        searchBarText = searchText
        filterContentForSearchText(searchText: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.text = searchBarText
        tableView.reloadData()
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        
        DispatchQueue.main.async {
            self.filteredPaymentContacts.removeAll()
            
            if searchText != "" {
                self.filteredPaymentContacts = self.paymentContacts.filter { paymentContact in
                    return "\(paymentContact.name!)".lowercased().hasPrefix(searchText.lowercased()) || "\(paymentContact.address!)".lowercased().hasPrefix(searchText.lowercased())
                }
            } else {
                self.filteredPaymentContacts = self.paymentContacts
                
            }
            self.tableView.reloadData()
        }
    }
    
    @IBAction func cancel() {
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
        
    func scanAction() {
        
        let customQRCodeController = storyboard?.instantiateViewController(withIdentifier: "customQRCodeVC") as! CustomQRCodeController
        customQRCodeController.delegate = self
        self.present(customQRCodeController, animated: true, completion: nil)        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "send" {
            let sendVC = segue.destination as! PaymentSendController
            sendVC.address = selectedAddress
            if let contact = sender as? PaymentContact {
                sendVC.paymentContact = contact
            }
            sendVC.fromDetails = false
            let backItem = UIBarButtonItem()
            backItem.title = "Pay"
            navigationItem.backBarButtonItem = backItem
        }
    }

}

extension PaymentContactsController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let searchText = searchBarText {
            if searchText != "" {
                return 1
            }
        }
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let searchText = searchBarText {
            if searchText != "" {
                return filteredPaymentContacts.count
            }
        }

        if section == 0 {
            return 2
        } else if section == 1 {
            return 0
        } else {
            return filteredPaymentContacts.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var searchTextIsActive = false
        if let searchText = searchBarText {
            if searchText != "" {
                searchTextIsActive = true
            }
        }

        if (section == 0 && !searchTextIsActive) || filteredPaymentContacts.count == 0 {
            return 0
        }
        return 45
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let searchText = searchBarText {
            if searchText != "" {
                return 56
            }
        }

        if indexPath.section == 0 {
            return 52
        } else if indexPath.section == 1 {
            return 0
        } else {
            return 56
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 58))
        headerView.backgroundColor = UIColor.white
        var searchTextIsActive = false
        if let searchText = searchBarText {
            if searchText != "" {
                searchTextIsActive = true
            }
        }

        if section == 0 && !searchTextIsActive {
            headerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0)
        } else if section == 1 {
//            titleLabel.text = "Popular"
            headerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0)
        } else {
            let titleLabel = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.frame.size.width-30, height: 20))
            headerView.addSubview(titleLabel)
            titleLabel.textColor = UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 0.6)
            titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
            titleLabel.text = "Recent"
            let underline = UIView(frame: CGRect(x: 15, y: 36, width: tableView.frame.size.width-30, height: 2))
            underline.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1)
            headerView.addSubview(underline)
        }
        return headerView

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var searchTextIsActive = false
        if let searchText = searchBarText {
            if searchText != "" {
                searchTextIsActive = true
            }
        }

        if indexPath.section == 0 && !searchTextIsActive {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "pasteCellId", for: indexPath) as! PasteCell
                cell.subtitleLabel.text = "No address on clipboard"
                if let pasteboardString = UIPasteboard.general.string {
                    let first2 = String(pasteboardString.prefix(2))
                    if first2 == "0x" {
                        cell.subtitleLabel.text = UIPasteboard.general.string
                    }
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "scanCellId", for: indexPath)
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "paymentContactCellId", for: indexPath) as! PaymentContactCell
            let paymentContact = filteredPaymentContacts[indexPath.row]
            cell.addressLabel.text = paymentContact.name
                        
            if let contactId = paymentContact.contactId {
                do {
                    let phoneContact = try contactStore.unifiedContact(withIdentifier: contactId, keysToFetch: [CNContactThumbnailImageDataKey as CNKeyDescriptor])
                    if let avatar = phoneContact.thumbnailImageData {
                        DispatchQueue.main.async {
                            cell.contactImageView.image = UIImage(data: avatar)
                        }
                    } else {
                        DispatchQueue.main.async {
                            cell.contactImageView.image = UIImage(named: "contact-placeholder")
                        }
                    }
                } catch {
                    print("Error fetching results for container")
                    DispatchQueue.main.async {
                        cell.contactImageView.image = UIImage(named: "contact-placeholder")
                    }
                }
            } else {
                DispatchQueue.main.async {
                    cell.contactImageView.image = UIImage(named: "unknown-address")
                }
            }

            cell.contactImageView.layer.cornerRadius = 20

            return cell
        }
    }
    
}

extension PaymentContactsController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        var searchTextIsActive = false
        if let searchText = searchBarText {
            if searchText != "" {
                searchTextIsActive = true
            }
        }

        if indexPath.section == 0 && !searchTextIsActive {
            if indexPath.row == 0 {
                if let pasteboardString = UIPasteboard.general.string {
                    let first2 = String(pasteboardString.prefix(2))
                    if first2 == "0x" {
                        selectedAddress = UIPasteboard.general.string
                        performSegue(withIdentifier: "send", sender: nil)
                        return
                    }
                }
                let alert = UIAlertController(title: "Error",
                                              message: "No address on clipboard.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else if indexPath.row == 1 {
                scanAction()
            }
        } else if indexPath.section == 1 {
            
        } else {
            let paymentContact = filteredPaymentContacts[indexPath.row]
            selectedAddress = paymentContact.address
            performSegue(withIdentifier: "send", sender: paymentContact)
        }
    }
}

extension PaymentContactsController : CustomQRCodeControllerDelegate {
    
    func scanned(result: QRCodeReaderResult?) {

        if let resultString = result?.value {
            let first2 = String(resultString.prefix(2))
            if first2 == "0x" {
                DispatchQueue.main.async {
                    self.selectedAddress = resultString
                    self.performSegue(withIdentifier: "send", sender: nil)
                }
            } else {
                DispatchQueue.main.async {
                    let msg = "Invalid address"
                    let alert = UIAlertController(title: "Error",
                                                  message: msg,
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
