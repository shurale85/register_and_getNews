internal struct UserRegistrationRequest: Codable{
    var email: String
    var clientType = 2
    let newsEnabled  = true
    let systemTermsAccepted = true
    
    init(with email: String){
        self.email = email
    }
}

struct ConfirmationRequest: Codable {
    var confirmationCode: Int
}

struct PhoneRequest: Codable {
    var phone: String
}

struct PasswordRequest: Codable {
    var password: String
    let lifeTime: Int = 6
    
    init(_ pass: String){
        password = pass
    }
}

struct TokenRequest: Codable {
    
}
