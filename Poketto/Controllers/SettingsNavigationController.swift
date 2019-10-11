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
    func buyAttemptCompleted()
}

class SettingsNavigationController: UINavigationController {
    weak var settingsDelegate: SettingsDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.navigationBar.shadowImage = UIImage()
    }
    
    func importCompleted() {
        settingsDelegate?.importCompleted()
    }
    
    func buyAttemptCompleted() {
        settingsDelegate?.buyAttemptCompleted()
    }

}
