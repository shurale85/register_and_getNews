import UIKit

class PasswordViewController: UIViewController {

    var token = ""
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var passwordLAbel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    
    let passwordPattern = #"(?=.{8,})(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[ !$%&?._-])"#
    
    @IBAction func passwordEntered(_ sender: Any){
        guard let password = validatePassword() else {
            print("password problems")
            return
        }
        let passwordRequest = PasswordRequest(password)
        NetworkManager.sendPassword(password: passwordRequest, token: self.token) { result in
            switch result {
            case .failure(let err):
                print(err)
                return
            case .success(let passResponse):
                self.getToken(oneTimeToken: passResponse.oneTimeLoginToken)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    fileprivate func handleWithWrongPass(errorText: String) {
        passwordTextField.layer.borderColor = UIColor.red.cgColor
        passwordTextField.layer.borderWidth = 1
        passwordLAbel.alpha = 1
        passwordLAbel.text = errorText
        //add err label
    }
    
    func validatePassword() -> String? {
        guard let password = passwordTextField.text, !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            handleWithWrongPass(errorText: "Введите пароль")
            return nil
        }
        let isCorrectFormat = password.range(
            of: passwordPattern,
            options: .regularExpression
        ) != nil
        guard isCorrectFormat else {
            handleWithWrongPass(errorText: "Неверный формат")
            return nil
        }
        return password
    }
    
    func getToken(oneTimeToken: String){
        NetworkManager.getToken(oneTimeLoginToken: oneTimeToken){ result in
            switch result {
                case .success(let tokenResponse):
                    print(tokenResponse.access_token)
                    DispatchQueue.main.async {
                        let vc = self.storyboard?.instantiateViewController(identifier: "NewsViewController") as! NewsViewController
                        self.view.window?.rootViewController = vc
                        self.view.window?.makeKeyAndVisible()
                        return
                    }
            case .failure(let err):
                print(err)
                
            }
        }
    }
}
