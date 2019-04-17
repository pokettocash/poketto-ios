//
//  Walllet.swift
//  Poketto
//
//  Created by André Sousa on 17/04/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Web3swift
import EthereumABI
import EthereumAddress
import BigInt

class Wallet {

    func generate() {
        let mnemonic = try! BIP39.generateMnemonics(bitsOfEntropy: 256)!
        let keystore = try! BIP32Keystore(mnemonics: mnemonic)
        
        // Store mnemonic on keychain
        KeychainWrapper.standard.set(mnemonic, forKey: "mnemonic")
        print("mnemonic \(mnemonic)")
        
        print("keystore: \(String(describing: keystore))")
    }
}
