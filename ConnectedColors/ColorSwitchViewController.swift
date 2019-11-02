import UIKit

class ColorSwitchViewController: UIViewController {

    @IBOutlet weak var connectionsLabel: UILabel!

    let hermes = Hermes()

    override func viewDidLoad() {
        super.viewDidLoad()
        hermes.delegate = self
    }



    @IBOutlet weak var typed_text: UITextField!
    @IBOutlet weak var data_got: UILabel!
    
    @IBAction func send(_ sender: Any) {
        hermes.send(message: self.typed_text.text!)
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
            self.data_got.text! += colorString + "\n"
        }
    }

}
