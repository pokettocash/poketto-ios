//
//  SettingsController.swift
//  Poketto
//
//  Created by André Sousa on 22/04/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit
import BiometricAuthentication

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
        
        if let cell = settingsOptionsController!.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? SettingsCell {
            cell.bioAccessSwitch.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
            
            if let bioAccess = UserDefaults.standard.object(forKey: "bioAccess") as? Bool {
                if bioAccess == true {
                    cell.bioAccessSwitch.setOn(true, animated: true)
                }
            }
        }
    }
    
    @IBAction func bioAccessSwitch(_ sender: Any) {
        let cell = settingsOptionsController!.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! SettingsCell
        if cell.bioAccessSwitch.isOn {
            cell.bioAccessSwitch.setOn(true, animated: true)
        } else {
            cell.bioAccessSwitch.setOn(false, animated:true)
        }
    }
    
    @objc func stateChanged(switchState: UISwitch) {
        selection.selectionChanged()
        let cell = settingsOptionsController!.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! SettingsCell
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
            let cell = self.settingsOptionsController!.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! SettingsCell
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
        } else if (indexPath.row == 3) {
            let alert = UIAlertController(title: "Select a network",
                                          message: "",
                                          preferredStyle: .alert)
            let action1 = UIAlertAction(title: "Default Network", style: .default, handler: { (action) -> Void in
                UserDefaults.standard.set("default", forKey: "currentNetwork")
                print("Default network selected!")
            })
            
            let action2 = UIAlertAction(title: "Pocket Network", style: .default, handler: { (action) -> Void in
                UserDefaults.standard.set("pocket", forKey: "currentNetwork")
                print("Pocket Network selected!")
            })
            
            // Cancel button
            let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
            // Check which network option is selected and change UI style
            if Web3ProviderUtil.getCurrentNetwork() == "pocket" {
                action2.setValue(UIColor.blue, forKey: "titleTextColor")
                action1.setValue(UIColor.gray, forKey: "titleTextColor")
            }else {
                action2.setValue(UIColor.gray, forKey: "titleTextColor")
                action1.setValue(UIColor.blue, forKey: "titleTextColor")
            }
            // Restyle the view of the Alert
            alert.view.layer.cornerRadius = 25
            // Add action buttons and present the Alert
            alert.addAction(action1)
            alert.addAction(action2)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
        } else if (indexPath.row == 4) {
            UIApplication.shared.open(URL(string: "https://github.com/pokettocash/poketto-ios/blob/master/LICENSE")!, options: [:], completionHandler: nil)
        }
    }
}
