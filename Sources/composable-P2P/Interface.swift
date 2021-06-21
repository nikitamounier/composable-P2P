//
//  File.swift
//
//
//  Created by Nikita Mounier on 21/06/2021.
//

import ComposableArchitecture
import Foundation
import Network

public struct Listener {
    public enum Action: Equatable {
        case stateUpdated(NWListener.State)
        case foundNewConnection(NWConnection)
        
        public static func == (lhs: Listener.Action, rhs: Listener.Action) -> Bool {
            switch (lhs, rhs) {
            case let (.stateUpdated(lhsNewState), .stateUpdated(rhsNewState)):
                return lhsNewState == rhsNewState
            case let (.foundNewConnection(lhsNewConnection), .foundNewConnection(rhsNewConnection)):
                return lhsNewConnection.debugDescription == rhsNewConnection.debugDescription
            default:
                return false
            }
        }
    }
    
    public var create: (_ id: AnyHashable,
                        _ bonjourService: String,
                        _ presharedKey: String,
                        _ identity: String,
                        _ myPeerID: String) -> Effect<Action, Never>
    
    public var startListening: (_ id: AnyHashable) -> Effect<Never, Never>
    
    public var stopListening: (_ id: AnyHashable) -> Effect<Never, Never>
    
    
    public init(
        create: @escaping (_ id: AnyHashable, _ bonjourService: String, _ presharedKey: String, _ identity: String, _ myPeerID: String) -> Effect<Action, Never>,
        startListening: @escaping (_ id: AnyHashable) -> Effect<Never, Never>,
        stopListening: @escaping (_ id: AnyHashable) -> Effect<Never, Never>
    ) {
        self.create = create
        self.startListening = startListening
        self.stopListening = stopListening
    }
}

public struct Browser {
    public enum Action: Equatable {
        case stateUpdated(NWBrowser.State)
        case browseResultsChanged(results: Set<NWBrowser.Result>, change: Set<NWBrowser.Result.Change>)
    }
    
    public var create: (_ id: AnyHashable, _ bonjourService: String) -> Effect<Action, Never>
    
    public var startBrowsing: (_ id: AnyHashable) -> Effect<Never, Never>
    
    public var stopBrowsing: (_ id: AnyHashable) -> Effect<Never, Never>
    
    
    public init(
        create: @escaping (_ id: AnyHashable, _ bonjourService: String) -> Effect<Action, Never>,
        startBrowsing: @escaping (_ id: AnyHashable) -> Effect<Never, Never>,
        stopBrowsing: @escaping (_ id: AnyHashable) -> Effect<Never, Never>
    ) {
        self.create = create
        self.startBrowsing = startBrowsing
        self.stopBrowsing = stopBrowsing
    }
}

public struct Connection {
    public enum Action: Equatable {
        case stateUpdated(NWConnection.State)
        case receivedMessage(type: UInt32, data: Data)
    }
    
    public var create: (_ id: AnyHashable, _ connection: NWConnection) -> Effect<Action, Never>
    
    public var startConnection: (_ id: AnyHashable) -> Effect<Never, Never>
    
    public var stopConnection: (_ id: AnyHashable) -> Effect<Never, Never>
    
    public var sendMessage: (_ id: AnyHashable, _ type: UInt32, _ content: Data) -> Effect<Never, Never>
    
    public var receiveNextMessage: (_ id: AnyHashable) -> Effect<Never, Never>
    
    public init(
        create: @escaping (_ id: AnyHashable, _ connection: NWConnection) -> Effect<Action, Never>,
        startConnection: @escaping (_ id: AnyHashable) -> Effect<Never, Never>,
        stopConnection: @escaping (_ id: AnyHashable) -> Effect<Never, Never>,
        sendMessage: @escaping (_ id: AnyHashable, _ type: UInt32, _ content: Data) -> Effect<Never, Never>,
        receiveNextMessage: @escaping (_ id: AnyHashable) -> Effect<Never, Never>
    ) {
        self.create = create
        self.startConnection = startConnection
        self.stopConnection = stopConnection
        self.sendMessage = sendMessage
        self.receiveNextMessage = receiveNextMessage
    }
}
