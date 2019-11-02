import Foundation
import MultipeerConnectivity
import RNCryptor

protocol HermesDelegate {

    func connectedDevicesChanged(manager : Hermes, connectedDevices: [String])
    func sendMessage(manager : Hermes, colorString: String)

}

class Hermes : NSObject {

    // Service type must be a unique string, at most 15 characters long
    // and can contain only ASCII lowercase letters, numbers and hyphens.
    private let HermesType = "hermes"

    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    private let serviceBrowser : MCNearbyServiceBrowser

    var delegate : HermesDelegate?

    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()

    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: HermesType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: HermesType)

        super.init()

        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()

        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }

    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }

    func send(id : Int, message : String) {
        

        if session.connectedPeers.count > 0 {
            
            var json = "{\"messageID\":" + String(id)
            json += ", \"messageData\": \"" + message + "\""
            json += ", \"flag\": \"00000\"}"
            print(json)
            
            do {
                try self.session.send(json.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            }
            catch let error {
                print(error)
            }
        }

    }

}

extension Hermes : MCNearbyServiceAdvertiserDelegate {

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        // did not advertise self. We have another error...
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // a peer invited us
        invitationHandler(true, self.session)
    }

}

extension Hermes : MCNearbyServiceBrowserDelegate {

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        // had an error...
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        // invite peer
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        // we lost a peer!!!
    }

}

extension Hermes : MCSessionDelegate {

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        // some peer changed their state
        self.delegate?.connectedDevicesChanged(manager: self, connectedDevices:
            session.connectedPeers.map{$0.displayName})
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // recieived the data
        let str = String(data: data, encoding: .utf8)!
        self.delegate?.sendMessage(manager: self, colorString: str)
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // recieved a stream
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // started recieveing a resource
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // done recieving a resource
    }

}
