import UIKit
import InputMask

class PhoneViewController: UIViewController, MaskedTextFieldDelegateListener {

    public var token: String = ""
    @IBOutlet weak var listener: MaskedTextFieldDelegate!
    
    @IBAction func continueButtonAction(_ sender: Any) {
        confirmPhone()
    }
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var phoneTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Helper.configureButton(continueButton)
    }
    
    fileprivate func makeABuz() {
        phoneTextField.layer.borderColor = UIColor.red.cgColor
        phoneTextField.layer.borderWidth = 1
    }
    
    func confirmPhone(){
        guard var phone = phoneTextField.text else {
            makeABuz()
            return
        }
        phone.removeAll(where: {["(", ")", " "].contains($0)})
        
        guard !self.token.isEmpty else {
            print("token is empty")
            return
        }
        
        NetworkManager.sendPhone(phone: PhoneRequest(phone: phone), token: token) { result in
            switch result {
            case .success(let response):
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Подтвердите телефон", message: "Введите код подтерждения из смс", preferredStyle: .alert)
                        
                        alert.addTextField { (confirmationCode) in
                            confirmationCode.placeholder = "conformation code"
                        }
                        
                        let cancelAction = UIAlertAction(title: "Отмена", style: .destructive)
                        
                        let acceptAction = UIAlertAction(title: "Ok", style: .default) { [weak alert] (_) in
                            guard let code = alert?.textFields?[0] else {
                                return
                            }
                            
                            guard let text = code.text, !text.isEmpty, let codeValue = Int(text) else {
                                return
                            }
                            
                            let confirmationCode = ConfirmationRequest(confirmationCode: codeValue)
                           
                            NetworkManager.confirm(code: confirmationCode, for: ConfirmationTarget.phone, token: response.token, session: response.confirmationSessionId) { result in
                                switch result {
                                    case .success(let response):
                                        print("conf email response: \(response)")
                                        DispatchQueue.main.async {
                                            let passwordViewController = self.storyboard?.instantiateViewController(withIdentifier: "PasswordViewController") as! PasswordViewController
                                            passwordViewController.token = self.token
                                            self.show(passwordViewController, sender: nil)
                                            return
                                        }
                                        
                                    case .failure:
                                        print("email confirmation is failed")
                                        return
                                }
                            }
                        }
                        
                        alert.addAction(cancelAction)
                        alert.addAction(acceptAction)
                        self.present(alert, animated: true)
                    }
                    return
                
            case .failure(let err):
                print(err.localizedDescription)
                return
            }
            
        }
    }
}
