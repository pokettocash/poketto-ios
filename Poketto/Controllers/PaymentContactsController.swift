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

class CustomSearchBar: UISearchBar {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setShowsCancelButton(false, animated: false)
    }
}

class CustomSearchController: UISearchController, UISearchBarDelegate {
    
    lazy var _searchBar: CustomSearchBar = {
        [unowned self] in
        let result = CustomSearchBar(frame: CGRect.zero)
        result.delegate = self
        
        return result
        }()
    
    override var searchBar: UISearchBar {
        get {
            return _searchBar
        }
    }
}


class PaymentContactsController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {

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
    var searchController            : CustomSearchController!
    let reuseIdentifier             = "payOptionCellId"
    @IBOutlet weak var tableView    : UITableView!
    var hasAddressOnClipboard       : Bool = false
    var selectedAddress             : String!
    var transactions                : Array<Any> = []
    var paymentContacts             : [PaymentContact] = []
    var wallet                      = Wallet.init()
    var contactStore                = CNContactStore()

    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBar()
        setSearchBar()
        checkPasteBoard()
        setPaymentContacts()
    }

    func setSearchBar() {
        
        searchController = CustomSearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.placeholder = "Search Contacts"
        searchController.searchBar.showsCancelButton = false
        navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        navigationController!.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .always
        self.definesPresentationContext = true

        for s in searchController.searchBar.subviews[0].subviews {
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
                let transactionJSON = transaction as! JSON
                let toAddress = transactionJSON["to"].stringValue
                toTransactions.append(toAddress)
            }
            
            var fromTransactions : [String] = []
            for transaction in self.transactions {
                let transactionJSON = transaction as! JSON
                let fromAddress = transactionJSON["from"].stringValue
                fromTransactions.append(fromAddress)
            }
            let uniqueToTransactions = Array(Set(toTransactions))
            let uniqueFromTransactions = Array(Set(fromTransactions))
            
            for toTransaction in uniqueToTransactions {
                if paymentContactsArray.count == 0 {
                    let paymentContact = self.addContact(from: toTransaction)
                    paymentContactsArray.append(paymentContact)
                } else {
                    var filteredContacts = paymentContactsArray.filter({$0.address.uppercased() == toTransaction.uppercased()})
                    if filteredContacts.count == 0 {
                        if let contact = PKContact.mr_findFirst(byAttribute: "address", withValue: toTransaction.uppercased()) {
                            filteredContacts = paymentContactsArray.filter({$0.address.uppercased() == contact.address!.uppercased()})
                            if filteredContacts.count == 0 {
                                let paymentContact = self.addContact(from: toTransaction)
                                paymentContactsArray.append(paymentContact)
                            }
                        } else {
                            let paymentContact = self.addContact(from: toTransaction)
                            paymentContactsArray.append(paymentContact)
                        }
                    }
                }
            }
            
            for fromTransaction in uniqueFromTransactions {
                if paymentContactsArray.count == 0 {
                    let paymentContact = self.addContact(from: fromTransaction)
                    paymentContactsArray.append(paymentContact)
                } else {
                    var filteredContacts = paymentContactsArray.filter({$0.address.uppercased() == fromTransaction.uppercased()})
                    if filteredContacts.count == 0 {
                        if let contact = PKContact.mr_findFirst(byAttribute: "address", withValue: fromTransaction.uppercased()) {
                            filteredContacts = paymentContactsArray.filter({$0.address.uppercased() == contact.address!.uppercased()})
                            if filteredContacts.count == 0 {
                                let paymentContact = self.addContact(from: fromTransaction)
                                paymentContactsArray.append(paymentContact)
                            }
                        } else {
                            let paymentContact = self.addContact(from: fromTransaction)
                            paymentContactsArray.append(paymentContact)
                        }
                    }
                }
            }

            DispatchQueue.main.async {
                self.paymentContacts = paymentContactsArray
                self.tableView.reloadData()
            }
        }

    }
    
    func addContact(from address: String) -> PaymentContact {
        
        let paymentContact = PaymentContact()

        if let contact = PKContact.mr_findFirst(byAttribute: "address", withValue: address.uppercased()) {
            paymentContact.name = contact.name
            paymentContact.address = contact.address
            paymentContact.avatarURL = contact.avatar_url
            paymentContact.contactId = contact.contact_id
        } else {
            paymentContact.name = address
            paymentContact.address = address
        }

        return paymentContact
    }

    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel() {
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func checkPasteBoard() {
        
        if let pasteboardString = UIPasteboard.general.string {
            let first2 = String(pasteboardString.prefix(2))
            if first2 == "0x" {
                hasAddressOnClipboard = true
            }
            tableView.reloadData()
        }
    }
    
    func scanAction() {
        
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            if let resultString = result?.value {
                let first2 = String(resultString.prefix(2))
                if first2 == "0x" {
                    DispatchQueue.main.async {
                        self.readerVC.dismiss(animated: true, completion: {
                            self.selectedAddress = resultString
                            self.performSegue(withIdentifier: "send", sender: nil)
                        })
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
            } else {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        
        present(readerVC, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "send" {
            let sendVC = segue.destination as! PaymentSendController
            sendVC.address = selectedAddress
            
            let backItem = UIBarButtonItem()
            backItem.title = "Pay"
            navigationItem.backBarButtonItem = backItem
        }
    }

}

extension PaymentContactsController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if hasAddressOnClipboard {
                return 3
            } else {
                return 2
            }
        } else if section == 1 {
            return 0
        } else {
            return paymentContacts.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
        if section == 0 {
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
        
        if indexPath.section == 0 {
            if hasAddressOnClipboard {
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "pasteCellId", for: indexPath) as! PasteCell
                    cell.subtitleLabel.text = UIPasteboard.general.string
                    return cell
                } else if indexPath.row == 1 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "enterAddressCellId", for: indexPath)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "scanCellId", for: indexPath)
                    return cell
                }
            } else {
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "enterAddressCellId", for: indexPath)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "scanCellId", for: indexPath)
                    return cell
                }
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "paymentContactCellId", for: indexPath) as! PaymentContactCell
            let paymentContact = paymentContacts[indexPath.row]
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
        
        if indexPath.section == 0 {
            if hasAddressOnClipboard {
                if indexPath.row == 0 {
                    selectedAddress = UIPasteboard.general.string
                    performSegue(withIdentifier: "send", sender: nil)
                } else if indexPath.row == 1 {

                } else {
                    scanAction()
                }
            } else {
                if indexPath.row == 0 {

                } else {
                    scanAction()
                }
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
