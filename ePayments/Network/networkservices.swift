import Foundation

enum CustomError: Error {
    case invalidUrl
    case invalidData
    case invalidRequestData
    case invalidToken
    case unknownError
    case errMsg(msg: String)
}

public class NetworkServices {

    /// Registers user by email
    /// - Parameters:
    ///   - data: registration payload
    ///   - completion: callback function
    static func register(data: UserRegistrationRequest, completion: @escaping (Result<UserRegistrationResponse, CustomError>) -> Void) {
        makePostRequest(urlStr: Constants.registrationUrl, payload: data, expectingResponseType: UserRegistrationResponse.self, completion: completion)
    }
    
    /// Confirms  the user's email or phone
    /// - Parameters:
    ///   - code: code to confirm by
    ///   - confirmationTarget: what is confirmed
    ///   - token: registration lifetime token
    ///   - session: code cofirmation lifietime token
    ///   - completion: callback function
    static func confirm(code:ConfirmationRequest, for confirmationTarget: ConfirmationTarget, token: String, session: String, completion: @escaping (Result<BaseResponse, CustomError>) -> Void){
        
        guard !token.isEmpty, !session.isEmpty else {
            completion(.failure(.invalidRequestData))
            return
        }
        
        let urlStr = "\(Constants.registrationUrl)/\(token)/confirm/\(session)/\(confirmationTarget.rawValue)"
        makePostRequest(urlStr: urlStr, payload: code, expectingResponseType: BaseResponse.self, completion: completion)
    }
    
    /// Sets user's password
    /// - Parameters:
    ///   - password: passwword with complexity of "(?=.{8,})(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[ !$%&?._-])"
    ///   - token: registration lifetime token
    ///   - completion: callback function
    static func sendPassword(password: PasswordRequest, token: String, completion: @escaping (Result<PasswordReponse, CustomError>) -> Void){
        guard !token.isEmpty else {
            completion(.failure(.invalidRequestData))
            return
        }
        
        let urlStr = "\(Constants.registrationUrl)/\(token)/complete"
     
        makePostRequest(urlStr: urlStr, payload: password, expectingResponseType: PasswordReponse.self, completion: completion)
    }
    
    /// Get access token right after registration by one time token
    /// - Parameters:
    ///   - oneTimeLoginToken: one time token
    ///   - completion: callback function
    static func getToken(oneTimeLoginToken: String, completion: @escaping (Result<TokenResponse, CustomError>) -> Void){
        var urlComponents = URLComponents()
        urlComponents.queryItems = [
            URLQueryItem(name: "grant_type", value: "one_time_login"),
            URLQueryItem(name: "one_time_login_token", value: oneTimeLoginToken.addingPercentEncoding(withAllowedCharacters: .alphanumerics))]
        let requestResult = buildRequest(url: Constants.tokenUrl, contentType: "application/x-www-form-urlencoded")
        
        guard var request = requestResult else {
            completion(.failure(CustomError.invalidUrl))
            return
        }
        
        request.httpBody = urlComponents.query?.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(.failure(CustomError.invalidData))
                return
            }
            do {
                let result = try JSONDecoder().decode(TokenResponse.self, from: data)
                UserDefaults.standard.set(result.access_token, forKey: Constants.tokenObjectKeyName)
                completion(.success(result))
                return
            }
            catch {
                print(error.localizedDescription)
                completion(.failure(.unknownError))
                return
            }
        }
        .resume()
    }
    /// Set user's phone
    /// - Parameters:
    ///   - phone: phone number with format +00000000000. Example: +19876543212
    ///   - token: registration life time tioken
    ///   - completion: callback function
    static func sendPhone(phone: PhoneRequest, token: String, completion: @escaping (Result<UserRegistrationResponse, CustomError>) -> Void){
        guard !token.isEmpty else {
            completion(.failure(.invalidRequestData))
            return
        }
        
        makePostRequest(urlStr: "\(Constants.registrationUrl)/\(token)", payload: phone, expectingResponseType: UserRegistrationResponse.self, completion: completion)
    }
    
    /// Do POST request
    /// - Parameters:
    ///   - urlStr: URL to make a call
    ///   - payload: data to send
    ///   - expectingResponseType: type of response object to decode to
    ///   - contentType: type of HEADER Content-Type
    ///   - completion: callback function
    fileprivate static func makePostRequest<Response:WithErrorCodable,Payload:Codable>(urlStr: String, payload: Payload?, expectingResponseType: Response.Type, contentType: String = "application/json",  completion: @escaping(Result<Response, CustomError>) -> Void) {

        let requestResult = buildRequest(url: urlStr, contentType: contentType)
        guard var request = requestResult else {
            completion(.failure(CustomError.invalidUrl))
            return
        }

        if payload != nil {
            request.httpBody = try? JSONEncoder().encode(payload)
        }

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(.failure(CustomError.invalidData))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(expectingResponseType, from: data)
                if !result.errorMsgs.isEmpty {
                    completion(.failure(CustomError.errMsg(msg: result.errorMsgs.reduce("", {str1, str2 in str1 + str2 + ";"}))))
                    return
                }
                completion(.success(result))
            }
            catch {
                //fix
                completion(.failure(CustomError.invalidData))
            }
        }
        .resume()
    }
    
    /// Build URLRequest
    /// - Parameters:
    ///   - url: URL to call
    ///   - method: HTTP method
    ///   - contentType: type of HEADER Content-Type
    /// - Returns: URLRequest
    static fileprivate func buildRequest(url: String, method: String = "POST", contentType: String = "application/json") -> URLRequest? {
        
        guard let url = URL(string: url) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue(Constants.authKey, forHTTPHeaderField: "Authorization")
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        return request
    }
    
    /// Get News
    /// - Parameters:
    ///   - take: number of news on single page
    ///   - skip: number of news to skip first
    ///   - completion: callback function
    static func getNews(take: Int = 10, skip: Int = 0, completion: @escaping (Result<NewsResponse, CustomError>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: Constants.tokenObjectKeyName), !token.isEmpty else {
            print("no access token")
            return
        }
        
        var request = buildRequest(url: "\(Constants.newsUrl)typeofnew=0&take=\(take)&skip=\(skip)", method: "GET")!
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription as Any)
                return
            }
            do {
               var news = try JSONDecoder().decode(NewsResponse.self, from: data)
                //since back returns emty img raplce it by fake
                (1..<news.news.count).forEach { news.news[$0].img = Constants.imageUrls[$0 % 5] }
                completion(.success(news))
            }
            catch {
                print(error.localizedDescription)
                completion(.failure(.invalidData))
            }
        }
        task.resume()
    }
}

// all below is for testing porpuse only (to get new as qucik as possible)
struct TokenByLogin: Decodable {
    var confirmation_session_id: String
}

func GetTokenByLogin(username: String, password: String, completion: @escaping(Result<TokenByLogin, CustomError>) -> Void){
    var request = NetworkManager.buildRequest(url: Constants.tokenUrl, contentType: "application/x-www-form-urlencoded")!
    
    var urlComponents = URLComponents()
    urlComponents.queryItems = [
        URLQueryItem(name: "grant_type", value: "password_otp"),
        URLQueryItem(name: "username", value: username),
        URLQueryItem(name: "password", value: password)
    ]
    request.httpBody = urlComponents.query?.data(using: .utf8)
    
    URLSession.shared.dataTask(with: request) { (data, response, error) in
        guard let data = data, error == nil else {
            completion(.failure(CustomError.invalidData))
            return
        }
        
        do {
            let result = try JSONDecoder().decode(TokenByLogin.self, from: data)
            completion(.success(result))
        }
        catch {
            print(error)
            completion(.failure(CustomError.invalidData))
        }
    }
    .resume()
}

func second_factor(username: String, password: String, code: Int, sesssionId: String, completion: @escaping (Result<BearerResponse, CustomError>) -> Void){
    var request = NetworkManager.buildRequest(url: Constants.tokenUrl, contentType: "application/x-www-form-urlencoded")!
    
    var urlComponents = URLComponents()
    urlComponents.queryItems = [
        URLQueryItem(name: "grant_type", value: "password_otp"),
        URLQueryItem(name: "username", value: username),
        URLQueryItem(name: "password", value: password),
        URLQueryItem(name: "confirmation_session_id", value: sesssionId),
        URLQueryItem(name: "type_2fa", value: "SmsAuthenticator"),
        URLQueryItem(name: "otpcode", value: String(code))
    ]
    request.httpBody = urlComponents.query?.data(using: .utf8)
    
    URLSession.shared.dataTask(with: request) { (data, response, error) in
        guard let data = data, error == nil else {
            completion(.failure(CustomError.invalidData))
            return
        }
        
        do {
            let result = try JSONDecoder().decode(BearerResponse.self, from: data)
            completion(.success(result))
        }
        catch{
            //fix
            print(error)
            completion(.failure(CustomError.invalidData))
        }
    }
    .resume()
}

class Mock {
    //testing porpuse only
    static var isPaginating: Bool = false
    
    static func GetFakeNews(take: Int = 2, skip: Int = 0, completion: @escaping (Result<[News], CustomError>) -> Void) {
        isPaginating = true
        let news = (1...100).map { index in
            return News(title: "News \(index)", body: "Some texr of fake news \(index)", img: Constants.imageUrls[index % 5])
        }
        print("take:\(take)")
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            print("skipping:\(skip)")
            completion(.success(news.dropFirst(skip).dropLast(news.count - skip - take)))
            self.isPaginating = false
        }
    }
}

