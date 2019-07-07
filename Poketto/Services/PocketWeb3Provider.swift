//
//  PocketWeb3Provider.swift
//  Poketto
//
//  Created by Pabel Nunez Landestoy on 6/28/19.
//  Copyright © 2019 Poketto. All rights reserved.
//

import Foundation
import web3swift
import PocketSwift
import PromiseKit

public class PocketWeb3Provider: Web3Provider {
    var pocket: Pocket
    static let networkName = "POA"
    static let netID = "100"
    static let devID = "DEVpvmSbHLWxDwhyXeM8VoY"
    public var url: URL
    public var network: Networks?
    public var attachedKeystoreManager: KeystoreManager? = nil
    public var session: URLSession = {() -> URLSession in
        let config = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: config)
        return urlSession
    }()

    public init?(keystoreManager manager: KeystoreManager? = nil) {
        // The url property is mandatory to conform properly to the Web3Provider protocol
        url = URL.init(string: "https://poketto.cash")!
        attachedKeystoreManager = manager
        
        pocket = Pocket.init(devID: PocketWeb3Provider.devID, network: PocketWeb3Provider.networkName, netID: PocketWeb3Provider.netID, maxNodes: 10, requestTimeOut: 10000)
    }
    
    public func sendAsync(_ request: JSONRPCrequest, queue: DispatchQueue) -> Promise<JSONRPCresponse> {
        // Parse JSONRPCrequest method params
        var parameters = [String]()
        request.params?.params.forEach({ (param) in
            if "\(param)" != "" {
                parameters.append("\""+"\(param)"+"\"")
            }
        })
        // Join parameters using ',' as separator
        let parametersStr = parameters.joined(separator:",")
        // Create JSON RPC string for the pocket network
        let data: String = "{\"jsonrpc\":\"\(request.jsonrpc)\",\"method\":\"\(request.method?.rawValue ?? "")\",\"params\":[\"\(parametersStr)\"],\"id\":\(request.id)}"
        // Create a relay object
        let relay = Relay.init(network: PocketWeb3Provider.networkName, netID: PocketWeb3Provider.netID, data: data, devID: pocket.devID, httpMethod: nil, path: nil, queryParams: nil)
        // Send the relay to the Pocket Network
        return Promise<JSONRPCresponse>() { seal in
            pocket.send(relay: relay, onSuccess: { (result) in
                let jsonRPCResponse = JSONRPCresponse.init(id: Int.random(in: 0 ..< 1000), jsonrpc: request.method!.rawValue, result: result, error: nil)
                
                seal.fulfill(jsonRPCResponse)
            }) { (error) in
                var jsonRPCResponse = JSONRPCresponse.init(id: Int.random(in: 0 ..< 1000), jsonrpc: request.method!.rawValue, result: nil, error: nil)
                jsonRPCResponse.error?.message = "Failed to send request with Error: \(error)"
                seal.fulfill(jsonRPCResponse)
            }
        }
    }
    public func sendAsync(_ requests: JSONRPCrequestBatch, queue: DispatchQueue) -> Promise<JSONRPCresponseBatch> {
        do {
            let jsonEncoder = JSONEncoder()

            let jsonData = try jsonEncoder.encode(requests)
            let jsonString = String(data: jsonData, encoding: .utf8)
            
            // Create a relay object
            let relay = Relay.init(network: PocketWeb3Provider.networkName, netID: PocketWeb3Provider.netID, data: jsonString, devID: PocketWeb3Provider.devID, httpMethod: nil, path: nil, queryParams: nil)
            
            return Promise<JSONRPCresponseBatch>() { seal in
                pocket.send(relay: relay, onSuccess: { (result) in
                    do {
                        let decoder = JSONDecoder.init()
                        let jsonRPCResponseBatch = try decoder.decode(JSONRPCresponseBatch.self, from: result.data(using: .utf8) ?? Data.init())
                        seal.fulfill(jsonRPCResponseBatch)
                    } catch {
                        seal.reject(error)
                    }
                }) { (error) in
                    seal.reject(error)
                }
            }
        } catch {
            return Promise<JSONRPCresponseBatch>() { seal in
                seal.reject(error)
            }
        }
    }

}
