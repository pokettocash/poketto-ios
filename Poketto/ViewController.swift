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
import EthereumABI
import EthereumAddress
import BigInt

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Generate new wallet, store on keychain and print wallet
        // let newWallet = generateWallet()
        // print(newWallet?.addresses?.first)
        
        // Get wallet balance
        // let explorer = Explorer.init()
        // explorer.balanceFrom(address: "0x569d656393ca2e1b62a362a6a60556b2ad56721d", completion: { balance in
            // print(balance)
        // })
        
        // Execute transaction on xDai chain
        // send(toAddress: "0x394a29F426F6505d40854ABb730D1c8DE29C8C87", value: "0.001")
    }
    
    func generateWallet() -> AbstractKeystore? {
        let mnemonic = try! BIP39.generateMnemonics(bitsOfEntropy: 256)!
        let keystore = try! BIP32Keystore(mnemonics: mnemonic)
        
        // Store mnemonic on keychain
        KeychainWrapper.standard.set(mnemonic, forKey: "mnemonic")
        print(mnemonic)
        
        return keystore
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
        
        // Balance
        // let balanceResult = try! connection.eth.getBalance(address: walletAddress)
        // let balanceString = Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 6)!
        // print(balanceString)
        
        print(result)
    }

}
