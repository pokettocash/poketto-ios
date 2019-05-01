//
//  SettingsNavigationController.swift
//  Poketto
//
//  Created by Tiago Alves on 01/05/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit

protocol SettingsDelegate: class {
    func importCompleted()
}

class SettingsNavigationController: UINavigationController {
    weak var settingsDelegate: SettingsDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.cornerRadius = 25
        view.clipsToBounds = true
        
        self.navigationBar.shadowImage = UIImage()
    }
    
    func importCompleted() {
        settingsDelegate?.importCompleted()
    }

}
