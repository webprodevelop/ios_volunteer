import UIKit
import WebKit


class ViewControllerAgree: UIViewController {

    @IBOutlet weak var webContent: WKWebView!


    override func viewDidLoad() {
        super.viewDidLoad()

        let appInfo = Config.getAppInfo()

        //-- WebView
        if appInfo.sAgreement.isEmpty {
            return
        }
        //let request = URLRequest(url: URL(string: appInfo.sAgreement)!)
        //webContent.load(request)
        webContent.loadHTMLString(appInfo.sAgreement, baseURL: nil)
    }


    @IBAction func onTouchUpBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }


}
