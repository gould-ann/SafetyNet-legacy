import UIKit

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
        let id = generateMessageID()
        hermes.send(id: id, message: typed_text.text!)
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
                self.hermes.send(id: message!.messageID, message: message!.messageData)
                self.all_message_ids.append(message!.messageID)
                
                if(message!.flag == "00000") {
                    self.data_got.text! += message!.messageData + "\n"
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
