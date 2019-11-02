import UIKit

class ColorSwitchViewController: UIViewController {

    @IBOutlet weak var connectionsLabel: UILabel!

    let hermes = Hermes()
    var all_messages: [Int] = [555]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hermes.delegate = self
    }

    @IBOutlet weak var typed_text: UITextField!
    @IBOutlet weak var data_got: UILabel!
    @IBOutlet weak var room: UITextField!
    
    @IBAction func send(_ sender: Any) {
        var json = "{\"messageData\": " + "\"" + typed_text.text! + "\"" + "}"
        hermes.send(message: json)
    }
}
//\"messageID\": " + String(id) + ",
//, \"From\": " + source + "

extension ColorSwitchViewController : HermesDelegate {
    
    struct Message: Codable {
        let messageData: String
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
            if(message != nil) {
                self.data_got.text! += message!.messageData + "\n"
            }
            /*
            // if you have not already recieved the message, send it out again
            if(!self.all_messages.contains(555)){
                self.hermes.send(message: colorString)
            }
            */
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
