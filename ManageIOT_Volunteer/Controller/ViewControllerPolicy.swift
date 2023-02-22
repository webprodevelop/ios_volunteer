import UIKit
import WebKit


class ViewControllerPolicy: UIViewController {

    @IBOutlet weak var webContent: WKWebView!


    override func viewDidLoad() {
        super.viewDidLoad()

        let appInfo = Config.getAppInfo()

        //-- WebView
        if appInfo.sPolicy.isEmpty {
            return
        }
        //let request = URLRequest(url: URL(string: appInfo.sPolicy)!)
        //webContent.load(request)
        webContent.loadHTMLString(appInfo.sPolicy, baseURL: nil)
    }


    @IBAction func onTouchUpBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }


}
