import Combine
import ComposableArchitecture
import Network

public extension P2PClient {
    static let live = Self(
        browser: .live,
        listener: .live,
        connection: .live
    )
}

public extension BrowserClient {
    static var live = Self(
        create: { id, bonjourService in
            .run { subscriber in
                let params = NWParameters(includePeerToPeer: true, interfaceType: .wifi)
                let browser = NWBrowser(for: .bonjour(type: bonjourService, domain: nil), using: params)
                browser.stateUpdateHandler = { subscriber.send(.stateUpdated($0)) }
                browser.browseResultsChangedHandler = { subscriber.send(.browseResultsChanged($1)) }
                
                browserDependencies[id] = browser
                
                return AnyCancellable {
                    browserDependencies[id]?.cancel()
                    browserDependencies[id] = nil
                }
            }
        },
        startBrowsing: { id, queue in
            .fireAndForget {
                browserDependencies[id]?.start(queue: queue)
            }
        },
        stopBrowsing: { id in
            .fireAndForget {
                browserDependencies[id]?.cancel()
                browserDependencies[id] = nil
            }
        }
    )
}

public extension ListenerClient {
    static var live = Self(
        create: { id, bonjourService, presharedKey, identity, myPeerID in
            .run { subscriber in
                do {
                    let listener = try NWListener(using: NWParameters(secret: presharedKey, identity: identity))
                    listener.service = NWListener.Service(
                        name: myPeerID, type: bonjourService, domain: nil, txtRecord: nil
                    )
                    listener.stateUpdateHandler = { subscriber.send(.stateUpdated($0)) }
                    listener.newConnectionHandler = { subscriber.send(.foundNewConnection($0)) }
                    
                    listenerDependencies[id] = listener
                } catch {
                    subscriber.send(.failedToCreate)
                }
                
                return AnyCancellable {
                    browserDependencies[id]?.cancel()
                    browserDependencies[id] = nil
                }
            }
        },
        startListening: { id, queue in
            .fireAndForget {
                listenerDependencies[id]?.start(queue: queue)
            }
        },
        stopListening: { id in
            .fireAndForget {
                listenerDependencies[id]?.cancel()
                listenerDependencies[id] = nil
            }
        }
    )
}

public extension ConnectionClient {
    static var live = Self(
        create: { id, connection in
            .run { subscriber in
                connection.stateUpdateHandler = { subscriber.send(.stateUpdated($0)) }
                
                connectionDependencies[id] = connection
                
                return AnyCancellable {
                    connectionDependencies[id]?.cancel()
                    connectionDependencies[id] = nil
                }
            }
        },
        startConnection: { id, queue in
            .run { subscriber in
                connectionDependencies[id]?.start(queue: queue)
                
                func receiveNextMessage() {
                    connectionDependencies[id]?.receiveMessage { data, context, _, error in
                        if let message = context?.protocolMetadata(definition: TLVMessageProtocol.definition) as? NWProtocolFramer.Message {
                            subscriber.send(.receivedMessage(type: message.messageType, data: data ?? Data()))
                        }
                        
                        if let error = error {
                            subscriber.send(.receivedMessageError)
                        } else {
                            receiveNextMessage()
                        }
                    }
                }
                receiveNextMessage()
                
                return AnyCancellable {}
            }
        },
        stopConnection: { id in
            .fireAndForget {
                connectionDependencies[id]?.cancel()
                connectionDependencies[id] = nil
            }
        },
        sendMessage: { id, messageType, content in
            .fireAndForget {
                guard connectionDependencies[id]?.state == .ready else { return }
                
                let framerMessage = NWProtocolFramer.Message(messageType: messageType.rawValue)
                let context = NWConnection.ContentContext(identifier: "Message", metadata: [framerMessage])
                
                connectionDependencies[id]?.send(
                    content: content, contentContext: context, isComplete: true, completion: .idempotent
                )
            }
        }
    )
}

private var browserDependencies: [AnyHashable: NWBrowser] = [:]
private var listenerDependencies: [AnyHashable: NWListener] = [:]
private var connectionDependencies: [AnyHashable: NWConnection] = [:]
