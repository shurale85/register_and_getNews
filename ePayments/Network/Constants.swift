import Foundation
import CoreGraphics

class Constants{
    
    // MARK: Urls
    private static let domen = "https://api.some.com"
    public static let newsUrl = "\(domen)news"
    public static let loginUrl = ""
    public static let registrationUrl = "\(domen)user_reg"
    public static let tokenUrl = "\(domen)/token"
    public static let authKey = "Basic"
    
    public static let imageUrls = [
         "https://image.shutterstock.com/image-photo/summer-landscape-country-road-fields-600w-603001217.jpg",
         "https://image.shutterstock.com/z/stock-photo-classic-dutch-landscape-polder-ditch-canal-on-a-green-grass-field-604642631.jpg",
        "https://cdn.profile.ru/wp-content/uploads/2021/05/Letnee-solncestoyanie.jpg",
        "https://cdn.profile.ru/wp-content/uploads/2021/09/5fbb2769bec6ec0199a5aacf9c750254.jpg",
        "https://cdn5.vedomosti.ru/crop/image/2019/8q/1mfbg/original-23r.jpg?height=698&width=1240"]
    
    public static let cornerRadius: CGFloat = 8
    public static let tokenObjectKeyName = "TokenObject"
}
