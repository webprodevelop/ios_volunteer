import UIKit
import WebKit

class ViewControllerIapRefundComplete: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
    }


    @IBAction func onTouchUpBack(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }


    @IBAction func onTouchUpConfirm(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }

}
