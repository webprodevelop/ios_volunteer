import UIKit
import WebKit


protocol ViewControllerAskBindDelegate: AnyObject {
    func onAskBindSuccess()
}


class ViewControllerAskBind: UIViewController {

    @IBOutlet weak var viewOutside: UIView!

    var delegate: ViewControllerAskBindDelegate? = nil


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
        delegate?.onAskBindSuccess()
    }


    @IBAction func onTouchUpCancel(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }

}
