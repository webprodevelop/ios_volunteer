import UIKit
import WebKit

class ViewControllerChatError: UIViewController {
    
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var viewOutside: UIView!
    
    var message: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        lblMessage.text = message;

        let gestureOutside = UITapGestureRecognizer(target: self, action: #selector(onTapOutside(_:)))
        viewOutside.addGestureRecognizer(gestureOutside)
        viewOutside.isUserInteractionEnabled = true
    }


    @objc func onTapOutside(_ sender: UIGestureRecognizer) {
        dismiss(animated: false, completion: nil)
    }


    @IBAction func onTouchUpOk(_ sender: Any) {
        dismiss(animated: false, completion: {
        })
    }

}
