import UIKit
///MARK - is not used
class NewsTableViewCell: UITableViewCell {
    static let cellIdentifier = "newsCell"
    
    private let imageContainer : UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    private let newsImageView: UIImageView = {
        let image = UIImageView()
        image.tintColor = .blue
        return image
    }()
    
    private let title: UILabel = {
        let label = UILabel()
        label.backgroundColor = .green
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier :String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        super.layoutSubviews()
        contentView.addSubview(imageContainer)
        imageContainer.addSubview(newsImageView)
        contentView.addSubview(title)
        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews(){
        //sizing containers
        let size: CGFloat = contentView.frame.size.height - 20
        imageContainer.frame = CGRect(x: 10, y: 6, width: size, height: size)
        
        let imageSize: CGFloat = size/1.5
        newsImageView.frame = CGRect(x: 0, y: 0, width: imageSize, height: imageSize)
        newsImageView.center = imageContainer.center
        
        title.frame = CGRect(
            x: 15 + imageContainer.frame.size.width,
            y:0,
            width: contentView.frame.size.width - 15 - imageContainer.frame.size.width,
            height: contentView.frame.size.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView?.image = nil
    }
    
    public func configure(with model: News) {
       // imageView.
        title.text = model.title
    
    }
}
