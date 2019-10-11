//
//  SettingsController.swift
//  Poketto
//
//  Created by André Sousa on 22/04/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit
import BiometricAuthentication
import SafariServices

class SettingsController: UIViewController, SettingsOptionsDelegate {
    
    weak var settingsOptionsController      : SettingsOptionsController?
    @IBOutlet weak var versionLabel         : UILabel!
    @IBOutlet weak var settingsContainer    : UIView!
    @IBOutlet weak var versionTopConstraint : NSLayoutConstraint!
    @IBOutlet weak var scrollView           : UIScrollView!
    let selection                           = UISelectionFeedbackGenerator()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let versionString = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let buildString = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        versionLabel.text = "\(versionString)(\(buildString))"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let verticalSpace = scrollView.frame.size.height - (settingsContainer.frame.origin.y + settingsContainer.frame.size.height)
        if verticalSpace < versionTopConstraint.constant {
            versionTopConstraint.constant = verticalSpace
        }
        
        if let cell = settingsOptionsController!.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? SettingsCell {
            cell.bioAccessSwitch.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
            cell.nameLabel.text = "Touch / Face ID"
            
            if let bioAccess = UserDefaults.standard.object(forKey: "bioAccess") as? Bool {
                if bioAccess == true {
                    cell.bioAccessSwitch.setOn(true, animated: true)
                }
            }
        }
        
        if let cell = settingsOptionsController!.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? SettingsCell {
            
            let text = NSMutableAttributedString(string: "*Carbon is responsible for handling purchases")
            text.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 8), range: NSMakeRange(0, text.length))
            text.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 0.6), range: NSMakeRange(0, text.length))

            let selectablePart = NSMakeRange(1, 7)
            text.addAttribute(NSAttributedString.Key.link, value: "carbonWebsite", range: selectablePart)
            text.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: selectablePart)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.left
            paragraphStyle.lineHeightMultiple = 0.3
            text.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, text.length))

            cell.disclaimerTextView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 0.6), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 8)]
            cell.disclaimerTextView.attributedText = text
            cell.disclaimerTextView.isEditable = false
            cell.disclaimerTextView.isSelectable = true
        }

    }
    
    @IBAction func bioAccessSwitch(_ sender: Any) {
        let cell = settingsOptionsController!.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! SettingsCell
        if cell.bioAccessSwitch.isOn {
            cell.bioAccessSwitch.setOn(true, animated: true)
        } else {
            cell.bioAccessSwitch.setOn(false, animated:true)
        }
    }
    
    @objc func stateChanged(switchState: UISwitch) {
        selection.selectionChanged()
        let cell = settingsOptionsController!.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! SettingsCell
        if cell.bioAccessSwitch.isOn {
            askBioAccess()
        } else {
            UserDefaults.standard.set(false, forKey: "bioAccess")
            UserDefaults.standard.synchronize()
        }
    }
    
    func askBioAccess() {
        
        let alert = UIAlertController(title: "Biometric access", message: "Enable authentication.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:  NSLocalizedString("Yes, please!", comment: ""), style: .cancel, handler: { _ in
            
            BioMetricAuthenticator.authenticateWithBioMetrics(reason: "") { (result) in
                switch result {
                case .success( _):
                    UserDefaults.standard.set(true, forKey: "bioAccess")
                    UserDefaults.standard.synchronize()
                    
                case .failure(let error):
                    switch error {
                    // device does not support biometric (face id or touch id) authentication
                    case .biometryNotAvailable:
                        self.showErrorAlert(message: error.message())
                        
                    // No biometry enrolled in this device, ask user to register fingerprint or face
                    case .biometryNotEnrolled:
                        self.showGotoSettingsAlert(message: error.message())
                        
                    // do nothing on canceled by system or user
                    case .fallback, .biometryLockedout, .canceledBySystem, .canceledByUser:
                        self.showPasscodeAuthentication(message: error.message())
                        
                    // show error for any other reason
                    default:
                        self.showErrorAlert(message: error.message())
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title:  NSLocalizedString("No, thank you!", comment: ""), style: .default, handler: { _ in
            let cell = self.settingsOptionsController!.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! SettingsCell
            cell.bioAccessSwitch.setOn(false, animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
        
    @IBAction func dismiss() {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func twitter() {
    
        UIApplication.shared.open(URL(string: "https://twitter.com/pokettocash")!, options: [:], completionHandler: nil)
    }
    
    @IBAction func discord() {
        
        UIApplication.shared.open(URL(string: "https://discord.gg/kMTUpME")!, options: [:], completionHandler: nil)
    }
    
    @IBAction func github() {
        
        UIApplication.shared.open(URL(string: "https://github.com/pokettocash")!, options: [:], completionHandler: nil)
    }
    
    func importScreenView() {
        performSegue(withIdentifier: "importSeed", sender: nil)
    }
    
    // Consider moving the SettingsOptionsController to a table view inside the
    // SettingsController to avoid setting the embed view controller via segue.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueName = segue.identifier {
            if segueName == "settingsOptions" {
                settingsOptionsController = segue.destination as? SettingsOptionsController
                settingsOptionsController?.delegate = self
            }
        }
    }
    
}

protocol SettingsOptionsDelegate: class {
    func importScreenView()
}

class SettingsOptionsController: UITableViewController {
    weak var delegate: SettingsOptionsDelegate?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0) {
            if let seed = Wallet.init().exportSeed() {
                let items = [seed]
                let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                present(ac, animated: true)
            }
        } else if (indexPath.row == 1) {
            delegate?.importScreenView()
        } else if (indexPath.row == 2) {
            let wallet = Wallet.init()
            let walletAddress = wallet.getEthereumAddress()!.address
            let url = URL(string: "https://buy.carbon.money/?apiKey=9899fb8c-837b-41a5-a8bd-3094b7def049&tokens=xDai&homeScreenMessage=Poketto&receiveAddress=\(walletAddress)")
            let vc = SFSafariViewController(url: url!)
            vc.delegate = self
            present(vc, animated: true, completion: nil)

        } else if (indexPath.row == 4) {
            UIApplication.shared.open(URL(string: "https://github.com/pokettocash/poketto-ios/blob/master/LICENSE")!, options: [:], completionHandler: nil)
        }
    }
}

extension SettingsOptionsController : UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        UIApplication.shared.open(Foundation.URL(string: "https://www.carbon.money")!, options: [:], completionHandler: nil)
        return false
    }
}


extension SettingsOptionsController : SFSafariViewControllerDelegate {
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        
        let settingsNavigationController = self.navigationController as! SettingsNavigationController
        settingsNavigationController.buyAttemptCompleted()
    }
}

