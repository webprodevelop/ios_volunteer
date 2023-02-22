import UIKit
import WebKit

class ViewControllerPopup: UIViewController {

    @IBOutlet weak var viewOutside: UIView!
    @IBOutlet weak var viewContent: UIView!

    @IBOutlet weak var lblTitle  : UILabel!
    @IBOutlet weak var lblDate   : UILabel!
    @IBOutlet weak var txtContent: UITextView!

    var message : ModelMessage = ModelMessage()


    override func viewDidLoad() {
        super.viewDidLoad()

        //-- Init View
        lblTitle.text   = message.sCategory
        txtContent.text = message.sBody
        lblDate.text    = message.sTime

        //-- Gesture lblGetCode
        let gestureOutside = UITapGestureRecognizer(target: self, action: #selector(onTapOutside(_:)))
        viewOutside.addGestureRecognizer(gestureOutside)
        viewOutside.isUserInteractionEnabled = true

        //-- Animate Content
        Timer.scheduledTimer(
            timeInterval: 0.5,
            target      : self,
            selector    : #selector(self.animateViewContent),
            userInfo    : nil,
            repeats     : false
        )
    }


    override func viewWillAppear(_ animated: Bool) {
        viewContent.isHidden = true
        viewContent.frame.origin.y = -viewContent.frame.size.height
    }


    @IBAction func onTouchUpView(_ sender: Any) {
        dismiss(animated: true, completion: {
            DispatchQueue.main.async {
                self.showViewControllerMessage()
            }
        })
    }


    @objc func onTapOutside(_ sender: UIGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }


    @objc func animateViewContent() {
        DispatchQueue.main.async {
            self.viewContent.isHidden = false
            UIView.animate(withDuration: 1.0) {
                var frameContent = self.viewContent.frame
                frameContent.origin.y = 50
                self.viewContent.frame = frameContent
            }
        }
    }


    func showViewControllerMessage() {
        let vcCurrent = UIViewController.currentViewController()
        if vcCurrent == nil { return }
        if !vcCurrent!.isKind(of: ViewControllerMain.self) {
            vcCurrent!.dismiss(animated: false, completion: { self.showViewControllerMessage() })
            return
        }
        let vcMain = vcCurrent as! ViewControllerMain
        vcMain.onTouchUpMessage(vcMain)
    }
}
