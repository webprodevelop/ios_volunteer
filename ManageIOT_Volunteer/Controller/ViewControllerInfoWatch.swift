import UIKit
import WebKit


protocol ViewControllerInfoWatchDelegate: AnyObject {
    func onInfoWatchSuccess(model: ModelWatch)
}


class ViewControllerInfoWatch: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtName    : UITextField!
    @IBOutlet weak var txtPhone   : UITextField! {
        didSet {
            txtPhone!.addDoneCancelToolbar()
        }
    }
    @IBOutlet weak var btnMale     : UIButton!
    @IBOutlet weak var btnFemale   : UIButton!
    @IBOutlet weak var viewBirthday: UIView!
    @IBOutlet weak var txtBirthday : UITextField!
    @IBOutlet weak var lblDocument : UILabel!
    @IBOutlet weak var viewHeight  : UIView!
    @IBOutlet weak var txtHeight   : UITextField!
    @IBOutlet weak var viewWeight  : UIView!
    @IBOutlet weak var txtWeight   : UITextField!

    var delegate: ViewControllerInfoWatchDelegate?
    var illList : [String] = []
    var modelWatch: ModelWatch = ModelWatch()
    var iHeight: Int = 51
    var iWeight: Int = 1
    var alertTall   : UIAlertController? = nil
    var alertWeight : UIAlertController? = nil
    var pickerTall  : UIPickerView? = nil
    var pickerWeight: UIPickerView? = nil


    override func viewDidLoad() {
        super.viewDidLoad()

        txtName.delegate = self
        lblDocument.text = ""

        let tapBirthday = UITapGestureRecognizer(target: self, action: #selector(self.onTapBirthday(_:)))
        viewBirthday.addGestureRecognizer(tapBirthday)
        let tapHeight = UITapGestureRecognizer(target: self, action: #selector(self.onTapHeight(_:)))
        viewHeight.addGestureRecognizer(tapHeight)
        let tapWeight = UITapGestureRecognizer(target: self, action: #selector(self.onTapWeight(_:)))
        viewWeight.addGestureRecognizer(tapWeight)

        //-- Call API
        tryGetWatchSetInfo()

        //-- Init
        txtName.text  = modelWatch.sUserName
        txtPhone.text = modelWatch.sUserPhone
        if modelWatch.iUserSex == 1 {
            self.btnMale.setImage(UIImage(named: "img_check_on"), for: .normal)
            self.btnFemale.setImage(UIImage(named: "img_check_off"), for: .normal)
        }
        else {
            self.btnMale.setImage(UIImage(named: "img_check_off"), for: .normal)
            self.btnFemale.setImage(UIImage(named: "img_check_on"), for: .normal)
        }
        txtBirthday.text = modelWatch.sUserBirth
        txtHeight.text   = String(modelWatch.iUserTall)
        txtWeight.text   = String(modelWatch.iUserWeight)
    }


    //-- UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
            case txtName: txtPhone.becomeFirstResponder(); break
            default: break
        }
        return false
    }


    @IBAction func onTouchUpBack(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }


    @IBAction func onTouchUpContinue(_ sender: Any) {
        modelWatch.sUserName   = txtName.text     ?? ""
        modelWatch.sUserPhone  = txtPhone.text    ?? ""
        modelWatch.sUserBirth  = txtBirthday.text ?? ""
        modelWatch.iUserTall   = Int(txtHeight.text ?? "0")!
        modelWatch.iUserWeight = Int(txtWeight.text ?? "0")!

        launchInfoMore()
    }


    @IBAction func onTouchUpMale(_ sender: Any) {
        DispatchQueue.main.async {
            self.btnMale.setImage(UIImage(named: "img_check_on"), for: .normal)
            self.btnFemale.setImage(UIImage(named: "img_check_off"), for: .normal)
        }
        modelWatch.iUserSex = 1
    }


    @IBAction func onTouchUpFemale(_ sender: Any) {
        DispatchQueue.main.async {
            self.btnMale.setImage(UIImage(named: "img_check_off"), for: .normal)
            self.btnFemale.setImage(UIImage(named: "img_check_on"), for: .normal)
        }
        modelWatch.iUserSex = 0
    }


    @objc func onTapBirthday(_ sender: UITapGestureRecognizer? = nil) {
        let selector = UIStoryboard(
            name  : "WWCalendarTimeSelector",
            bundle: nil
        ).instantiateInitialViewController() as! WWCalendarTimeSelector
        selector.delegate = self
        present(selector, animated: true, completion: nil)
    }


    @objc func onTapHeight(_ sender: UITapGestureRecognizer? = nil) {
        if alertTall != nil {
            present(alertTall!, animated: true)
            return
        }

        alertTall = UIAlertController(
            title: "Tall".localized(),
            message: nil,
            preferredStyle: .alert
        )
        //-- Picker
        let pickerFrame: CGRect = CGRect(x: 100, y: 40, width: 100, height: 120)
        pickerTall = UIPickerView(frame: pickerFrame)
        pickerTall!.tag = 1
        pickerTall!.delegate = self
        pickerTall!.dataSource = self

        alertTall!.view.addSubview(pickerTall!)
        let constraintWidth: NSLayoutConstraint = NSLayoutConstraint(
            item      : alertTall!.view!,
            attribute : NSLayoutConstraint.Attribute.width,
            relatedBy : NSLayoutConstraint.Relation.equal,
            toItem    : nil,
            attribute : NSLayoutConstraint.Attribute.notAnAttribute,
            multiplier: 1,
            constant  : 300
        )
        let constraintHeight: NSLayoutConstraint = NSLayoutConstraint(
            item      : alertTall!.view!,
            attribute : NSLayoutConstraint.Attribute.height,
            relatedBy : NSLayoutConstraint.Relation.equal,
            toItem    : nil,
            attribute : NSLayoutConstraint.Attribute.notAnAttribute,
            multiplier: 1,
            constant  : 200
        )
        alertTall!.view.addConstraint(constraintWidth)
        alertTall!.view.addConstraint(constraintHeight)

        //-- OK, Cancel Button
        let alertActionOk: UIAlertAction = UIAlertAction(
            title  : "OK".localized(),
            style  : UIAlertAction.Style.default,
            handler: onPickerTallOk
        )
        let alertActionCancel: UIAlertAction = UIAlertAction(
            title  : "Cancel".localized(),
            style  : UIAlertAction.Style.default,
            handler: onPickerTallCancel
        )
        alertTall!.addAction(alertActionOk)
        alertTall!.addAction(alertActionCancel)

        present(alertTall!, animated: true)
    }


    @objc func onTapWeight(_ sender: UITapGestureRecognizer? = nil) {
        if alertWeight != nil {
            present(alertWeight!, animated: true)
            return
        }
        alertWeight = UIAlertController(
            title: "Weight".localized(),
            message: nil,
            preferredStyle: .alert
        )

        //-- Picker
        let pickerFrame: CGRect = CGRect(x: 100, y: 40, width: 100, height: 120)
        pickerWeight = UIPickerView(frame: pickerFrame)
        pickerWeight!.tag = 2
        pickerWeight!.delegate = self
        pickerWeight!.dataSource = self

        alertWeight!.view.addSubview(pickerWeight!)
        let constraintWidth: NSLayoutConstraint = NSLayoutConstraint(
            item      : alertWeight!.view!,
            attribute : NSLayoutConstraint.Attribute.width,
            relatedBy : NSLayoutConstraint.Relation.equal,
            toItem    : nil,
            attribute : NSLayoutConstraint.Attribute.notAnAttribute,
            multiplier: 1,
            constant  : 300
        )
        let constraintHeight: NSLayoutConstraint = NSLayoutConstraint(
            item      : alertWeight!.view!,
            attribute : NSLayoutConstraint.Attribute.height,
            relatedBy : NSLayoutConstraint.Relation.equal,
            toItem    : nil,
            attribute : NSLayoutConstraint.Attribute.notAnAttribute,
            multiplier: 1,
            constant  : 200
        )
        alertWeight!.view.addConstraint(constraintWidth)
        alertWeight!.view.addConstraint(constraintHeight)

        //-- OK, Cancel Button
        let alertActionOk: UIAlertAction = UIAlertAction(
            title  : "OK".localized(),
            style  : UIAlertAction.Style.default,
            handler: onPickerWeightOk
        )
        let alertActionCancel: UIAlertAction = UIAlertAction(
            title  : "Cancel".localized(),
            style  : UIAlertAction.Style.default,
            handler: onPickerWeightCancel
        )
        alertWeight!.addAction(alertActionOk)
        alertWeight!.addAction(alertActionCancel)

        present(alertWeight!, animated: true)
    }


    func tryGetWatchSetInfo() {
        let stReq: StReqGetWatchSetInfo = StReqGetWatchSetInfo()

        API.instance.getWatchSetInfo(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    DispatchQueue.main.async {
                        self.lblDocument.text = stRsp.data?.watch_birth_desc
                        self.illList = stRsp.data?.ill_list ?? []
                    }
                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
        }
    }


    func launchInfoMore() {
        let storyboard = UIStoryboard(name: "InfoMore", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerInfoMore") as! ViewControllerInfoMore
        vc.modalPresentationStyle = .fullScreen
        vc.illList = illList
        vc.modelWatch = modelWatch
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }


    func onPickerTallOk(action: UIAlertAction) {
        txtHeight.text = String(iHeight)
        alertTall?.dismiss(animated: true)
    }


    func onPickerTallCancel(action: UIAlertAction) {
        alertTall?.dismiss(animated: true)
    }


    func onPickerWeightOk(action: UIAlertAction) {
        txtWeight.text = String(iWeight)
        alertWeight?.dismiss(animated: true)
    }


    func onPickerWeightCancel(action: UIAlertAction) {
        alertWeight?.dismiss(animated: true)
    }

}


extension ViewControllerInfoWatch: WWCalendarTimeSelectorProtocol {
    func WWCalendarTimeSelectorDone(_ selector: WWCalendarTimeSelector, date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        txtBirthday.text = formatter.string(from: date)
    }
}


extension ViewControllerInfoWatch: ViewControllerInfoMoreDelegate {
    func onInfoMoreSuccess(model: ModelWatch) {
        dismiss(animated: false, completion: {
            self.delegate?.onInfoWatchSuccess(model: model)
        })
    }
}


extension ViewControllerInfoWatch: UIPickerViewDelegate, UIPickerViewDataSource {

    //-- UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            //-- Height
            return 200  // 51 ~ 250
        }
        else if pickerView.tag == 2 {
            //-- Weight
            return 200  // 1 ~ 200
        }
        else  {
            return 0
        }
    }


    //-- UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            //-- Height
            return String(row + 51)
        }
        else if pickerView.tag == 2 {
            //-- Weight
            return String(row + 1)
        }
        return ""
    }


    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            //-- Height
            iHeight = row + 51
        }
        else if pickerView.tag == 2 {
            //-- Weight
            iWeight = row + 1
        }

    }

}
