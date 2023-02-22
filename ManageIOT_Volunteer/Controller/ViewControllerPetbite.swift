import UIKit
import WebKit
import MarqueeLabel

protocol ViewControllerPetbiteDelegate {
    func onPetbiteDismiss()
}


class ViewControllerPetbite: UIViewController {

    @IBOutlet weak var imgPetbite: UIImageView!
    @IBOutlet weak var tblPetbite: UITableView!
    @IBOutlet weak var lblTitle: MarqueeLabel!
    @IBOutlet weak var webContent: WKWebView!
    
    var delegate: ViewControllerPetbiteDelegate? = nil


    override func viewDidLoad() {
        super.viewDidLoad()

        imgPetbite.isHidden = true
        tblPetbite.isHidden = true
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }


    func onBack() {
        dismissFromParent()
        delegate?.onPetbiteDismiss()
    }


    func setModelNews(model: ModelNews) {
        lblTitle.text = model.sTitle
        tryGetNewsInfo(model: model)
    }


    private func tryGetNewsInfo(model: ModelNews) {
        var stReq: StReqGetNewsInfo = StReqGetNewsInfo()
        stReq.token  = Config.modelUserInfo.sToken
        stReq.mobile = Config.modelUserInfo.sMobile
        stReq.id = model.iId

        API.instance.getNewsInfo(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    self.webContent.loadHTMLString(stRsp.data?.content ?? "", baseURL: nil)
                    self.tryGetUserInfo()
                    break
                case .failure(_):
                    break
            }
        }
    }


    func tryGetUserInfo() {
        var stReq: StReqGetUserInfo = StReqGetUserInfo()
        stReq.mobile   = Config.modelUserInfo.sMobile
        stReq.token    = Config.modelUserInfo.sToken

        API.instance.getUserInfo(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        break
                    }
                    if stRsp.data != nil {
                        Config.modelUserInfo.copyFromApiData(data: stRsp.data!)
                        Config.notifyUpdatedUserInfo()
                    }
                    break

                case .failure(_):
                    break
            }
        }
    }
}


//-- For UITableView : tblHotspot
extension ViewControllerPetbite: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CellPetbite = tableView.dequeueReusableCell(
            withIdentifier: "rowpetbite",
            for           : indexPath
        ) as! CellPetbite

        cell.updateView()

        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

}
