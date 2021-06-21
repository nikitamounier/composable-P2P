//
//  File.swift
//
//
//  Created by Nikita Mounier on 21/06/2021.
//

import Foundation

public struct PeerInfo: Codable, Equatable {
    public let peerID: String
    public let info: [String: String]
    
    
    public init(peerID: String = UUID().uuidString, info: [String: String]) {
        self.peerID = peerID
        self.info = info
    }
}
