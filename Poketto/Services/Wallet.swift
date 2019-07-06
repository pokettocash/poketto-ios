//
//  Walllet.swift
//  Poketto
//
//  Created by André Sousa on 17/04/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import web3swift
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
    
    func importSeed(seed: String) -> Bool {
        let mnemonicSeed = seed.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            let _ = try BIP32Keystore(mnemonics: mnemonicSeed)
            KeychainWrapper.standard.set(mnemonicSeed, forKey: "mnemonic")
            return true
        } catch {
            return false
        }
    }
    
    func exportSeed() -> String? {
        return KeychainWrapper.standard.string(forKey: "mnemonic")
    }
    
    func getEthereumAddress() -> EthereumAddress? {
        
        let mnemonic = KeychainWrapper.standard.string(forKey: "mnemonic")
        if(mnemonic == nil) {
            return nil
        }
        
        let keystore = try! BIP32Keystore(mnemonics: mnemonic!.trimmingCharacters(in: .whitespacesAndNewlines))
        let ownWalletAddress = keystore?.addresses?.first!
        
        return ownWalletAddress
    }
    
    func send(toAddress: String, value: String, message: String?, success: @escaping (TransactionSendingResult) -> Void, failure: @escaping (String) -> Void) {
        
        let toAddress = EthereumAddress(toAddress.lowercased())!
        
        let currentNetwork = Web3ProviderUtil.getCurrentProvider()
        let connection = web3(provider: currentNetwork)
        
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
        
        // According to https://poa.network/xdai there's a fixed gas price of 1 Gwei
        options.gasPrice = .manual(Web3.Utils.parseToBigUInt("1", units: .Gwei)!)
        
        var messageData = Data()
        if(message == nil) {
            // Set limit to 21000 which is the consumed gas amount for a regular transaction
            options.gasLimit = .manual(21000)
        } else {
            // Set limit to 80000. It should be under 60000 for a 140 char string with 4bytes characters (ex: "𐀀")
            options.gasLimit = .manual(80000)
            messageData = message!.data(using: .utf8)!
        }
        
        let tx = contract.write(
            "fallback",
            parameters: [AnyObject](),
            extraData: messageData,
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
                let desc = web3Error.errorDescription
                print("desc \(desc)")
                failure(desc)
            } else {
                failure("Invalid code")
            }
        }
    }
}
