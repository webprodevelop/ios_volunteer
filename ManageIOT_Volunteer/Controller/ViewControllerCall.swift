import UIKit
import WebKit

class ViewControllerCall: UIViewController {

    @IBOutlet weak var viewOutside: UIView!


    override func viewDidLoad() {
        super.viewDidLoad()

        //-- Gesture lblGetCode
        let gestureOutside = UITapGestureRecognizer(target: self, action: #selector(onTapOutside(_:)))
        viewOutside.addGestureRecognizer(gestureOutside)
        viewOutside.isUserInteractionEnabled = true
    }


    @IBAction func onTouchUpCall(_ sender: Any) {
    }


    @objc func onTapOutside(_ sender: UIGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }

}
