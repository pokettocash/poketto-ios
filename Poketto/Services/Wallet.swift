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
    
    func importSeed(seed: String) {
        KeychainWrapper.standard.set(seed, forKey: "mnemonic")
    }
    
    func exportSeed() -> String? {
        return KeychainWrapper.standard.string(forKey: "mnemonic")
    }
    
    func getEthereumAddress() -> EthereumAddress? {
        
        let mnemonic = KeychainWrapper.standard.string(forKey: "mnemonic")
        if(mnemonic == nil) {
            return nil
        }
        print("mnemonic \(mnemonic!)")
        
        let keystore = try! BIP32Keystore(mnemonics: mnemonic!)
        let ownWalletAddress = keystore?.addresses?.first!
        
        return ownWalletAddress
    }
    
    func send(toAddress: String, value: String, success: @escaping (TransactionSendingResult) -> Void, failure: @escaping (String) -> Void) {
        
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
        options.gasPrice = .manual(Web3.Utils.parseToBigUInt("3", units: .Gwei)!)
        options.gasLimit = .automatic
        let tx = contract.write(
            "fallback",
            parameters: [AnyObject](),
            extraData: Data(),
            transactionOptions: options)!
        
        do {
            let result = try tx.send()
            print("success executing transaction")
            print(result)
            // Balance
            let balanceResult = try! connection.eth.getBalance(address: ownWalletAddress!)
            let balanceString = Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 6)!
            print("balanceString \(balanceString)")
            success(result)
        } catch {
            print("error executing transaction")
            print(error)
            if let web3Error = error as? Web3Error {
                print("error \(web3Error)")
                // Waiting for PR
//                let desc = web3Error.errorDescription
//                print("desc \(desc)")
//                failure(desc)
                failure("Error executing transaction \(web3Error.localizedDescription)")
            } else {
                failure("Invalid code")
            }
        }
    }
}
