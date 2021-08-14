import UIKit

class NewsViewController: UITableViewController {
       
    public var data: NewsResponse = NewsResponse()
    private var take: Int = 2
    private var skip: Int = 2
    private var pageIndex = 0
    private var isPaginating = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.news.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.accessoryType = .none
        cell.textLabel?.text = data.news[indexPath.row].title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedNews = data.news[indexPath.row]
        print(selectedNews)
        let detailsVC = self.storyboard?.instantiateViewController(identifier: "DetailsViewController") as! DetailsViewController;
        detailsVC.news = selectedNews
        self.show(detailsVC, sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Новости"
    }
    
    private func createSpinner() -> UIView {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100) )
        let spinner = UIActivityIndicatorView()
        spinner.center = footer.center
        footer.addSubview(spinner)
        spinner.startAnimating()
        return footer
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (tableView.contentSize.height - 100 - scrollView.frame.size.height) {
            
            self.tableView.tableFooterView = createSpinner()
            if self.isPaginating {
                return
            }
            self.isPaginating = true
            NetworkManager.getNews(take: take, skip: skip * pageIndex){ result in
                switch(result) {
                case(.success(let newsCollection)):
                    print(newsCollection)
                    self.data.news.append(contentsOf: newsCollection.news)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.tableView.tableFooterView = nil
                        self.pageIndex += 1
                        self.isPaginating = false
                    }
                case .failure(let err):
                    print("error during the fetching data: \(err)")
                    return
                }
            }
        }
    }
}
