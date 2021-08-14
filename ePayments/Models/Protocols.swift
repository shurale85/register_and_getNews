protocol WithError {
    var errorCode: Int { get }
    var errorMsgs: [String] { get }
}

typealias WithErrorCodable = WithError & Codable
