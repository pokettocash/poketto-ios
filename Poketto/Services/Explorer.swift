//
//  Explorer.swift
//  Poketto
//
//  Created by Tiago Alves on 09/04/2019.
//  Copyright © 2019 Poketto. All rights reserved.
//

import Foundation
import Alamofire
import Chester
import SwiftyJSON
import PocketSwift
import BigInt

let graphqlEndpoint = "https://blockscout.com/poa/dai/graphiql"
let txListEndpoint = "https://blockscout.com/poa/dai/api?module=account&action=txlist&address="

class Explorer {
    
    func balanceFrom(address: String, completion: @escaping (_ balance: Float) -> ()) {
        do {
            if Web3ProviderUtil.getCurrentNetwork() == "pocket" {
                let pocket = Pocket.init(devID: PocketWeb3Provider.devID, network: PocketWeb3Provider.networkName, netID: PocketWeb3Provider.netID, maxNodes: 5, requestTimeOut: 10000)
                let data = "{\"jsonrpc\":\"2.0\",\"method\":\"eth_getBalance\",\"params\":[\"\(address)\",\"latest\"],\"id\":\(Int.random(in: 0 ..< 1000))}"
                
                let relay = Relay.init(network: PocketWeb3Provider.networkName, netID: PocketWeb3Provider.netID, data: data, devID: PocketWeb3Provider.devID, httpMethod: nil, path: nil, queryParams: nil)
                pocket.send(relay: relay, onSuccess: { (result) in
                    guard let resultObject = self.convertToDictionary(text: result) else {
                        return
                    }
                    if let resultStr = resultObject["result"] as? String {
                        if resultStr.hasPrefix("0x") {
                            let wei = BigInt(resultStr.dropFirst(2), radix: 16)
                            let balance = Float(wei ?? BigInt(0)) / 1000000000000000000.0
                            completion(balance)
                        }else{
                            completion(0)
                        }
                    } else {
                        completion(0)
                    }
                    
                }) { (error) in
                    print("\(error)")
                    completion(0)
                }
            }else{
                let query = try QueryBuilder()
                    .from("address")
                    .with(arguments: Argument(key: "hash", value: address))
                    .with(fields: "fetchedCoinBalance")
                    .build()
                
                let params = [
                    "query": query
                ]
                
                Alamofire.request(graphqlEndpoint, parameters: params).responseJSON { response in
                    let json = JSON(response.result.value!)
                    let result = json["data"]["address"]["fetchedCoinBalance"]
                    if let balance = result.string {
                        let wei = Float(balance)!
                        let dai : Float = wei / 1000000000000000000.0
                        completion(dai)
                    } else {
                        completion(0)
                    }
                }
            }
            
        } catch {
            completion(0)
        }
    }
    
    func transactionsFrom(address: String, completion: @escaping (_ transactions: Array<Any>) -> ()) {
        let url = txListEndpoint + address
        Alamofire.request(url).responseJSON { response in
            let json = JSON(response.result.value!)
            let result = json["result"]
            if let transactions = result.array {
                completion(transactions)
            } else {
                completion([])
            }
        }
    }
    
    // MARK:Tools
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
