//
//  ViewController.swift
//  Poketto
//
//  Created by Tiago Alves on 03/04/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Web3swift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Generate new wallet, store on keychain and print wallet
        let newWallet = generateWallet()
        print(newWallet?.addresses?.first)
    }
    
    func generateWallet() -> AbstractKeystore? {
        let mnemonic = try! BIP39.generateMnemonics(bitsOfEntropy: 256)!
        let keystore = try! BIP32Keystore(mnemonics: mnemonic)
        
        // Store mnemonic on keychain
        KeychainWrapper.standard.set(mnemonic, forKey: "mnemonic")
        
        return keystore
    }

}
