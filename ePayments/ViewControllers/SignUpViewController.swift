import UIKit

class SignUpViewController: UIViewController {

    let emailPattern = #"^\S+@\S+\.\S+$"#
    
    @IBOutlet weak var emailTextField: UITextField!
    
    fileprivate func handleWithWrongEmail(errorText: String) {
        errorLabel.text = errorText
        errorLabel.alpha = 1
        emailTextField.layer.borderColor = UIColor.red.cgColor
        emailTextField.layer.borderWidth = 1
    }
    
    @IBAction func continueWithEmailButton(_ sender: Any) {
        guard let email = validateEmail() else {
            return
        }
        let body = UserRegistrationRequest(with: email)
        
        NetworkManager.register(data:body){(result)in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.confirmEmail(result: result)
                    return
                }
            case .failure(let err):
                print(err)
                return
            }
        }
            
    }
    
    @IBOutlet weak var continueWithEmailButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Helper.configureButton(continueWithEmailButton)
    }
    
    func validateEmail() -> String? {
        guard let email = emailTextField.text, !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            handleWithWrongEmail(errorText: "Введите email")
            return nil
        }
        let isCorrectFormat = email.range(
            of: emailPattern,
            options: .regularExpression
        ) != nil
        guard isCorrectFormat else {
            handleWithWrongEmail(errorText: "Неверный формат")
            return nil
        }
        return email
    }
    
    func confirmEmail(result: Result<UserRegistrationResponse, CustomError>) {
        switch result {
        case .success(let response):
            let token = response.token
            let sessionId = response.confirmationSessionId
            guard !token.isEmpty, !sessionId.isEmpty else {
                print("no token or sessionId")
                return
            }
            
            let alert = UIAlertController(title: "Подтвердите email", message: "Введите код подтерждения из почты", preferredStyle: .alert)
            
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
               
                
                NetworkManager.confirm(code: confirmationCode, for: ConfirmationTarget.email, token: token, session: sessionId) { result in
                    switch result {
                        case .success(let response):
                            print("conf email response: \(response)")
                            DispatchQueue.main.async {
                                let phoneViewController = self.storyboard?.instantiateViewController(withIdentifier: "PhoneViewController") as! PhoneViewController
                                phoneViewController.token = token
                                self.show(phoneViewController, sender: nil)
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
            
        case .failure(let err):
            print(err.localizedDescription)
            return
        }   
    }
}
