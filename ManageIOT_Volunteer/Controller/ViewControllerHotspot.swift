import UIKit


protocol ViewControllerHotspotDelegate {
    func onHotspotDismiss()
    func onHotspotPresent()
    func onHotspotPresentRecommend()
}


class ViewControllerHotspot: UIViewController {

    @IBOutlet weak var tblHotspot: UITableView!

    //-- Variables
    var delegate: ViewControllerHotspotDelegate? = nil

    private var vcRecommend: ViewControllerRecommend? = nil
    private var vModelNews: [ModelNews] = [ModelNews]()


    //-- Functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }


    func onBack() {
        if vcRecommend == nil {
            dismissFromParent()
            delegate?.onHotspotDismiss()
        }
        else {
            vcRecommend!.onBack()
        }
    }

    func dismissChildren() {
        vcRecommend?.dismissFromParent()
        vcRecommend = nil
    }


    func setModelNewsList(models: [ModelNews]) {
        vModelNews = models
        tblHotspot.reloadData()
    }


    private func showViewControllerRecommend(model: ModelNews) {
        if vcRecommend == nil {
            let storyboard = UIStoryboard(name: "Recommend", bundle: nil)
            vcRecommend = storyboard.instantiateViewController(withIdentifier: "ViewControllerRecommend") as? ViewControllerRecommend
        }
        vcRecommend!.delegate = self
        addChildViewController(child: vcRecommend!, container: view, frame: view.bounds)
        /// setModelNews must be called after present
        vcRecommend!.setModelNews(model: model)
    }

}


//-- For UITableView : tblHotspot
extension ViewControllerHotspot: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vModelNews.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CellHotspot = tableView.dequeueReusableCell(
            withIdentifier: "rowhotspot",
            for           : indexPath
        ) as! CellHotspot

        let model = vModelNews[indexPath.row]
        cell.updateView(model: model)

        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: CellHotspot = tableView.cellForRow(at: indexPath) as! CellHotspot
        let model = vModelNews[indexPath.row]
        showViewControllerRecommend(model: model)
        delegate?.onHotspotPresentRecommend()
    }

}


//-- ViewControllerRecommendDelegate
extension ViewControllerHotspot: ViewControllerRecommendDelegate {

    func onRecommendDismiss() {
        delegate?.onHotspotPresent()
        vcRecommend = nil
    }

}

