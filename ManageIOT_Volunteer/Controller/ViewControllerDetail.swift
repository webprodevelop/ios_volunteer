import UIKit
import WebKit

class ViewControllerDetail: UIViewController {

    @IBOutlet weak var webContent: WKWebView!

    var sHtml: String = ""


    override func viewDidLoad() {
        super.viewDidLoad()

        //-- WebView
        //let request = URLRequest(url: URL(string: "https://www.test.com")!)
        //webContent.load(request)
        webContent.loadHTMLString(sHtml, baseURL: nil)
    }


    @IBAction func onTouchUpBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
