import UIKit
import WebKit

class ViewControllerUpdate: UIViewController {

    @IBOutlet weak var viewOutside: UIView!
    @IBOutlet weak var lblCurVersionIfno: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()

        //-- Gesture lblGetCode
        let gestureOutside = UITapGestureRecognizer(target: self, action: #selector(onTapOutside(_:)))
        viewOutside.addGestureRecognizer(gestureOutside)
        viewOutside.isUserInteractionEnabled = true
        /*
        let oldVersion : String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let appInfo = Config.getAppInfo()
        let newVersion : String = appInfo.sAppVerIos
        */
        lblCurVersionIfno.text = "The new version is up. Please download the installation from the app market.".localized()
    }


    @objc func onTapOutside(_ sender: UIGestureRecognizer) {
        dismiss(animated: false, completion: nil)
    }


    @IBAction func onTouchUpOk(_ sender: Any) {
        dismiss(animated: false, completion: {
//            let appInfo = Config.getAppInfo()
//
//            if let url = URL(string: appInfo.sStoreUrlIos) {
//                UIApplication.shared.open(url, options: [:], completionHandler: nil)
//            }
        })
    }

}
