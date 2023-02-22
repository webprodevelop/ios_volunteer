import UIKit

class ViewControllerInfo: UIViewController {

    @IBOutlet weak var viewUser   : UIView!
    @IBOutlet weak var viewPhone  : UIView!
    @IBOutlet weak var viewPswd   : UIView!
    @IBOutlet weak var viewPswdNew: UIView!
    @IBOutlet weak var btnSave    : UIButton!
    @IBOutlet weak var btnCancel  : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewUser.layer.cornerRadius    = 10
        viewPhone.layer.cornerRadius   = 10
        viewPswd.layer.cornerRadius    = 10
        viewPswdNew.layer.cornerRadius = 10
        btnSave.layer.borderWidth    = 1
        btnSave.layer.borderColor    = UIColor.white.cgColor
        btnSave.layer.cornerRadius   = 10
        btnCancel.layer.borderWidth  = 1
        btnCancel.layer.borderColor  = UIColor.white.cgColor
        btnCancel.layer.cornerRadius = 10
    }
    
}

