import UIKit
import WebKit

class ViewControllerIapComplete: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
    }


    @IBAction func onTouchUpBack(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }


    @IBAction func onTouchUpConfirm(_ sender: Any) {
        //navigationController?.popToRootViewController(animated: false)
        navigationController?.dismiss(animated: false, completion: nil)
    }

}
