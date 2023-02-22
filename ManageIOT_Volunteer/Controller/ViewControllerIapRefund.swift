import UIKit
import WebKit


protocol ViewControllerIapRefundDelegate: AnyObject {
    func onIapRefundSuccess()
}


class ViewControllerIapRefund: UIViewController {

    @IBOutlet weak var viewOutside: UIView!

    var delegate: ViewControllerIapRefundDelegate?


    override func viewDidLoad() {
        super.viewDidLoad()

        //-- Gesture lblGetCode
        let gestureOutside = UITapGestureRecognizer(target: self, action: #selector(onTapOutside(_:)))
        viewOutside.addGestureRecognizer(gestureOutside)
        viewOutside.isUserInteractionEnabled = true
    }


    @objc func onTapOutside(_ sender: UIGestureRecognizer) {
        dismiss(animated: false, completion: nil)
    }


    @IBAction func onTouchUpOk(_ sender: Any) {
        dismiss(animated: false, completion: nil)
        delegate?.onIapRefundSuccess()
    }


    @IBAction func onTouchUpCancel(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }

}
