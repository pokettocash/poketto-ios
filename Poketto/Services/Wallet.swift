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
    
    func getEthereumAddress() -> EthereumAddress? {
        
        let mnemonic = KeychainWrapper.standard.string(forKey: "mnemonic")
        if(mnemonic == nil) {
            return nil
        }
        
        let keystore = try! BIP32Keystore(mnemonics: mnemonic!)
        let ownWalletAddress = keystore?.addresses?.first!
        
        return ownWalletAddress
    }
    
    func send(toAddress: String, value: String) {
        
        let toAddress = EthereumAddress(toAddress)!
        
        let endpoint = "https://dai.poa.network"
        let connection = web3(provider: Web3HttpProvider(URL(string: endpoint)!)!)
        
        let mnemonic = KeychainWrapper.standard.string(forKey: "mnemonic")
        let keystore = try! BIP32Keystore(mnemonics: mnemonic!)
        let ownWalletAddress = keystore?.addresses?.first!

        let keystoreManager = KeystoreManager.init([keystore!])
        connection.addKeystoreManager(keystoreManager)
        
        let contract = connection.contract(Web3.Utils.coldWalletABI, at: toAddress, abiVersion: 2)!
        let amount = Web3.Utils.parseToBigUInt(value, units: .eth)
        var options = TransactionOptions.defaultOptions
        options.value = amount
        options.from = ownWalletAddress
        options.gasPrice = .automatic
        options.gasLimit = .automatic
        let tx = contract.write(
            "fallback",
            parameters: [AnyObject](),
            extraData: Data(),
            transactionOptions: options)!
        
        let result = try! tx.send()
        
        print(result)

//         Balance
         let balanceResult = try! connection.eth.getBalance(address: ownWalletAddress!)
         let balanceString = Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 6)!
         print("balanceString \(balanceString)")
    }
}
