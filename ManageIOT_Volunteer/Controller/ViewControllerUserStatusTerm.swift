import UIKit
import WebKit
import SwiftyJSON


protocol ViewControllerUserStatusTermDelegate {
    func onUserStatusTermDismiss()
}


class ViewControllerUserStatusTerm: UIViewController {

    @IBOutlet weak var viewOutside: UIView!
    @IBOutlet weak var btnDontShow: UIButton!

    var delegate: ViewControllerUserStatusTermDelegate? = nil

    private var bDontShow: Bool = false


    override func viewDidLoad() {
        super.viewDidLoad()

        //-- Gesture
//        let gestureOutside = UITapGestureRecognizer(target: self, action: #selector(onTapOutside(_:)))
//        viewOutside.addGestureRecognizer(gestureOutside)
//        viewOutside.isUserInteractionEnabled = true
    }

/*
    @objc func onTapOutside(_ sender: UIGestureRecognizer) {
        dismiss(animated: false, completion: nil)
        delegate?.onTaskStatusDismiss()
    }
*/

    @IBAction func onTouchUpBtnConfirm(_ sender: Any) {
        Config.setHideUserStatusTerm(value: bDontShow)
        dismiss(animated: false, completion: nil)
        delegate?.onUserStatusTermDismiss()
    }


    @IBAction func onTouchUpBtnDontShow(_ sender: Any) {
        bDontShow = !bDontShow
        if bDontShow {
            btnDontShow.setBackgroundImage(UIImage(named: "img_check_on"), for: .normal)
        }
        else {
            btnDontShow.setBackgroundImage(UIImage(named: "img_check_off"), for: .normal)
        }
    }

}
