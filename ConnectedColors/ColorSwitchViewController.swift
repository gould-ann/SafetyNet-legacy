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
        let data: NSData = typed_text.text!.data(using: String.Encoding.utf8)! as NSData
        let zeroes: NSData = "00000".data(using: String.Encoding.utf8)! as NSData
        let cipherText = RNCryptor.encrypt(data: data as Data, withPassword: chatroomID)
        let cipherZero = RNCryptor.encrypt(data: zeroes as Data, withPassword: chatroomID)
        var json = "{\"messageID\":" + String(id)
        json += ", \"messageData\": \"" + String(decoding: cipherText, as: UTF8.self) + "\""
        json += ", \"flag\": \"" + String(decoding: cipherZero, as: UTF8.self) + "\"}"
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
//            print("RECIEVED", self.room.text!, colorString.description.substring(from: colorString.description.range(of: "%")!.upperBound), self.room.text! == colorString.description.substring(from: colorString.description.range(of: "%")!.upperBound))
            /*
            if(self.room.text! == colorString.description.substring(from: colorString.description.range(of: "%")!.upperBound)) {
                //self.data_got.text! += colorString + "\n"
            }
             */
            let message = self.decodeJSON(colorString: colorString)
            
            
            // if you have not already recieved the message, send it out again
            if(!self.all_message_ids.contains(message!.messageID)){
                self.hermes.send(message: colorString)
                self.all_message_ids.append(message!.messageID)
                
                var flag: String
                do {
                     flag = try String(RNCryptor.decrypt(data: message!.flag.data(using: .ascii)!, withPassword: self.room!.text!), encoding: String.Encoding.utf8) as String!
                } catch {
                    
                }
               
                print(flag)
                
                
                if(flag == "00000") {
                    var message_data: Data
                    do {
                        message_data = try RNCryptor.decrypt(data: message!.messageData.data(using: .ascii)!, withPassword: self.room!.text!)
                    } catch {
                        
                    }
                    self.data_got.text! += message_data + "\n"
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
