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
        hermes.send(message: self.typed_text.text! + "%" + self.room.text!)
    }
    
    
    
    
    
}

extension ColorSwitchViewController : HermesDelegate {

    func connectedDevicesChanged(manager: Hermes, connectedDevices: [String]) {
        print("here")
        OperationQueue.main.addOperation {
            self.connectionsLabel.text = "Connections: \(connectedDevices)"
        }
    }

    func sendMessage(manager: Hermes, colorString: String) {
        OperationQueue.main.addOperation {
//            print("RECIEVED", self.room.text!, colorString.description.substring(from: colorString.description.range(of: "%")!.upperBound), self.room.text! == colorString.description.substring(from: colorString.description.range(of: "%")!.upperBound))
            
            if(self.room.text! == colorString.description.substring(from: colorString.description.range(of: "%")!.upperBound)) {
                self.data_got.text! += colorString + "\n"
            }
            
            // if you have not already recieved the message, send it out again
            if(!self.all_messages.contains(555)){
                self.hermes.send(message: colorString)
            }
            
        }
    }

}
