//
//  SettingsController.swift
//  Poketto
//
//  Created by André Sousa on 22/04/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit

class SettingsController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer.cornerRadius = 25
        navigationController?.navigationBar.layer.cornerRadius = 25
        navigationController?.navigationBar.clipsToBounds = true
    }
        
    @IBAction func dismiss() {
        
        dismiss(animated: true, completion: nil)
    }
}

class SettingsOptionsController: UITableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0) {
            if let seed = Wallet.init().exportSeed() {
                let items = [seed]
                let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                present(ac, animated: true)
            }
        }
    }
}
