import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var openAccount: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Helper.configureButton(openAccount)
    }
}

