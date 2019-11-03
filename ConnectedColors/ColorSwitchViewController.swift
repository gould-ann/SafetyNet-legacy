import UIKit
import RNCryptor
class ColorSwitchViewController: UIViewController {

    @IBOutlet weak var connectionsLabel: UILabel!

    let hermes = Hermes()
    var all_message_ids: [Int] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hermes.delegate = self
    }

    @IBOutlet weak var typed_text: UITextField!
    @IBOutlet weak var data_got: UILabel!
    @IBOutlet weak var room: UITextField!
    
    @IBAction func send(_ sender: Any) {
        var chatroomID = "General"
        if(room.text! != "") {
            chatroomID = room.text!
        }
        let id = generateMessageID()
        
        let encrypted_message = try? encryptMessage(message: typed_text!.text!, encryptionKey: chatroomID)
        let encrypted_flag = try?encryptMessage(message: "00000", encryptionKey: chatroomID)
        
        var json = "{\"messageID\":" + String(id)
        json += ", \"messageData\": \"" + encrypted_message! + "\""
        json += ", \"flag\": \"" + encrypted_flag! + "\"}"
        print(json)
        
        hermes.send(message: json)
    }
    
    func generateMessageID() -> Int {
        var id = 0
        var contains = true;
        
        while(contains) {
            id = Int.random(in: 0 ..< 100000)
            contains = false
            if(all_message_ids.contains(id)) {
                contains = true
            }
        }
        all_message_ids.append(id)
        return id
    }
}
//\"messageID\": " + String(id) + ",
//, \"From\": " + source + "

extension ColorSwitchViewController : HermesDelegate {
    
    struct Message: Codable {
        let messageID: Int
        let messageData: String
        let flag: String
    }

    func connectedDevicesChanged(manager: Hermes, connectedDevices: [String]) {
        print("here")
        OperationQueue.main.addOperation {
            self.connectionsLabel.text = "Connections: \(connectedDevices)"
        }
    }

    func sendMessage(manager: Hermes, colorString: String) {
        OperationQueue.main.addOperation {
            let message = self.decodeJSON(colorString: colorString)
            
            // if you have not already recieved the message, send it out again
            if(!self.all_message_ids.contains(message!.messageID)){
                self.hermes.send(message: colorString)
                
                var chatroomID = "General"
                if(self.room.text! != "") {
                    chatroomID = self.room.text!
                }
              
                let flag = try? decryptMessage(encryptedMessage: message!.flag, encryptionKey: chatroomID)
                if(flag == "00000") {
                    let message_data = try? decryptMessage(encryptedMessage: message!.messageData, encryptionKey: chatroomID)
                    self.data_got.text! += message_data! + "\n"
                }
            }
            
        }
    }
    
    func decodeJSON(colorString: String) -> Message? {
        //Decode
        guard let data = colorString.data(using: String.Encoding.utf8) else { fatalError("☠️") }
        do {
            let newMessage = try JSONDecoder().decode(Message.self, from: data)
            print(newMessage)
            return newMessage
        } catch {
            print(error)
        }
        return nil
    }
}

extension String {
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}

func encryptMessage(message: String, encryptionKey: String) throws -> String {
    let messageData = message.data(using: .utf8)!
    let cipherData = RNCryptor.encrypt(data: messageData, withPassword: encryptionKey)
    return cipherData.base64EncodedString()
}


func decryptMessage(encryptedMessage: String, encryptionKey: String) throws -> String {

    let encryptedData = Data.init(base64Encoded: encryptedMessage)!
    let decryptedData = try RNCryptor.decrypt(data: encryptedData, withPassword: encryptionKey)
    let decryptedString = String(data: decryptedData, encoding: .utf8)!

    return decryptedString
}
