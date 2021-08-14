internal struct BaseResponse: WithErrorCodable {
    var errorCode: Int
    var errorMsgs: [String]
}


internal struct UserRegistrationResponse: WithErrorCodable {
    var token: String
    var confirmationSessionId: String
    var errorCode: Int
    var errorMsgs: [String]
}

internal struct PasswordReponse: WithErrorCodable {
    var oneTimeLoginToken: String
    var errorCode: Int
    var errorMsgs: [String]
}

internal struct TokenResponse: Decodable {
    var scope: String
    var token_type: String
    var access_token: String
    var expires_in: Int
    var refresh_token: String
}

struct News: Decodable {
    //var creationDate:String
    var title: String
    var body: String
    var img: String?
    
    init(title: String, body: String, img: String?){
        self.title = title
        self.body = body
        self.img = img
    }
}

internal struct NewsResponse: Decodable {
    var news: [News]
    
    init() {news = []}
}

struct BearerResponse: Codable {
    var access_token: String
}
