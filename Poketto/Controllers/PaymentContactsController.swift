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

    override func viewDidLoad() {
        super.viewDidLoad()

        setNavigationBar()
        setSearchBar()
        checkPasteBoard()
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
            return 0
        }
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "pasteCellId", for: indexPath) as! PasteCell
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
