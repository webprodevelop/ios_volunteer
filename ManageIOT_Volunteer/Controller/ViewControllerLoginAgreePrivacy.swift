import UIKit
import WebKit


class ViewControllerLoginAgreePrivacy: UIViewController {

    @IBOutlet weak var lblAgree: UILabel!
    @IBOutlet weak var lblPrivacy: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector( ViewControllerLoginAgreePrivacy.tapAgree))
        lblAgree.isUserInteractionEnabled = true
        lblAgree.addGestureRecognizer(tap1)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector( ViewControllerLoginAgreePrivacy.tapPrivacy))
        lblPrivacy.isUserInteractionEnabled = true
        lblPrivacy.addGestureRecognizer(tap2)
    }


    @objc func tapAgree(sender:UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Agree", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerAgree")
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }


    @objc func tapPrivacy(sender:UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Policy", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerPolicy")
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }


    @IBAction func onTouchUpCancel(_ sender: Any) {
        Config.pswd = ""
        Config.saveLoginInfo()
        dismiss(animated: false, completion: nil)
        exit(0)
    }


    @IBAction func onTouchUpOk(_ sender: Any) {
        Config.login_agree_privacy = true
        Config.saveLoginInfo()
        dismiss(animated: true, completion: nil)
    }

}

