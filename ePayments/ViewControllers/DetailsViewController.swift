import UIKit
import PINRemoteImage

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var titleLable: UILabel!
   
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    public var imageUrl: String?
    public var news: News? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let urlString = news?.img else {
            return
        }
        imageView.pin_setImage(from: URL(string: urlString))
        titleLable.text = news?.title
        textView.text =  news?.body
    }
}
