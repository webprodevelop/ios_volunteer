import UIKit
import WebKit
import MarqueeLabel

protocol ViewControllerRecommendDelegate {
    func onRecommendDismiss()
}


class ViewControllerRecommend: UIViewController {

    @IBOutlet weak var lblTitle: MarqueeLabel!
    @IBOutlet weak var webContent: WKWebView!

    var delegate: ViewControllerRecommendDelegate? = nil


    override func viewDidLoad() {
        super.viewDidLoad()
    }


    func onBack() {
        dismissFromParent()
        delegate?.onRecommendDismiss()
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
                    /// Get Update Point in User Info
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
