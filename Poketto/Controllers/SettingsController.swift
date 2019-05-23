//
//  SettingsController.swift
//  Poketto
//
//  Created by André Sousa on 22/04/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit
import Presentr

class SettingsController: UIViewController, SettingsOptionsDelegate, PresentrDelegate {
    weak var settingsOptionsController : SettingsOptionsController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer.cornerRadius = 25
        view.clipsToBounds = true
    }
        
    @IBAction func dismiss() {
        
        AppDelegate.shared.removeBackgroundBlur()
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
    
    func presentrShouldDismiss(keyboardShowing: Bool) -> Bool {
        AppDelegate.shared.removeBackgroundBlur()
        return true
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
            UIApplication.shared.open(URL(string: "https://github.com/pokettocash/poketto-ios")!, options: [:], completionHandler: nil)
        }
    }
}
