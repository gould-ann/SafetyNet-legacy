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
        //let cipherText = RNCryptor.encrypt(data: data as Data, withPassword: chatroomID)
        //let cipherZero = RNCryptor.encrypt(data: zeroes as Data, withPassword: chatroomID)
//        var json = "{\"messageID\":" + String(id)
//        json += ", \"messageData\": \"" + String(decoding: cipherText, as: UTF8.self) + "\""
//        json += ", \"flag\": \"" + String(decoding: cipherZero, as: UTF8.self) + "\"}"
        var json = "{\"messageID\":" + String(id)
        json += ", \"messageData\": \"" + typed_text.text! + "\""
        json += ", \"flag\": \"" + "00000" + "\"}"
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
                
//                let flag_data: NSData = message!.flag.data(using: String.Encoding.utf8)! as NSData
//                do {
//                    let decrypted_flag_data = try RNCryptor.decrypt(data: flag_data as Data, withPassword: chatroomID)
//                    let flag = String(decoding: decrypted_flag_data, as: UTF8.self)
//                    if(flag == "00000") {
//                        let message_data: NSData = message!.messageData.data(using: String.Encoding.utf8)! as NSData
//                        do {
//                            let decrypted_message_data = try RNCryptor.decrypt(data: message_data as Data, withPassword: chatroomID)
//                            let message = String(decoding: decrypted_message_data, as: UTF8.self)
//                            self.data_got.text! += message + "\n"
//                        } catch {
//                            print("Error Decrypting Message")
//                        }
//                    }
//                } catch {
//                    print("Error Decrypting Flag")
//                }
                
                if(message!.flag == "00000") {
                //let message_data: NSData = message!.messageData.data(using: String.Encoding.utf8)! as NSData
                //do {
                    self.data_got.text! += message!.messageData + "\n"
                //} catch {
                  //  print("Error Decrypting Message")
                //}
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
