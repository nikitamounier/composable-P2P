//
//  File.swift
//  
//
//  Created by Nikita Mounier on 21/06/2021.
//

import Foundation

public struct MultipeerSessionConfig {
    public let myPeerInfo: PeerInfo
    public let bonjourService: String
    public let presharedKey: String
    public let identity: String
    public let connectivityCheckInterval: TimeInterval
    public let failedConnectionTimeout: TimeInterval
    
    public init(
        myPeerInfo: PeerInfo,
        bonjourService: String,
        presharedKey: String,
        identity: String,
        connectivityCheckInterval: TimeInterval = 5,
        failedConnectionTimeout: TimeInterval = 10
    ) {
        self.myPeerInfo = myPeerInfo
        self.bonjourService = bonjourService
        self.presharedKey = presharedKey
        self.identity = identity
        self.connectivityCheckInterval = connectivityCheckInterval
        self.failedConnectionTimeout = failedConnectionTimeout
    }
}
