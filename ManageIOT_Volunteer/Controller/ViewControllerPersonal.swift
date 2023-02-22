import UIKit
import WebKit
import DropDown
import MarqueeLabel

protocol ViewControllerPersonalDelegate: AnyObject {
    func onPersonalSuccess()
}


class ViewControllerPersonal: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var viewAvatar  : UIView!
    @IBOutlet weak var lblUpload   : UILabel!
    @IBOutlet weak var imgAvatar   : UIImageView!
    @IBOutlet weak var lblName     : UILabel!
    @IBOutlet weak var btnMale     : UIButton!
    @IBOutlet weak var btnFemale   : UIButton!
    @IBOutlet weak var lblBirthday : UILabel!
    @IBOutlet weak var txtResidence: UITextField!
    @IBOutlet weak var lblJob      : UILabel!
    @IBOutlet weak var txtCompany: UITextField!
    @IBOutlet weak var lblPhone    : UITextField!

    @IBOutlet weak var imgCardId1 : UIImageView!
    @IBOutlet weak var imgCardId2 : UIImageView!

    @IBOutlet weak var lblCardNo  : UILabel!
    @IBOutlet weak var txtAddress1: UITextView!


    @IBOutlet weak var viewScannedInfo: UIView!
    @IBOutlet weak var viewCardBusiness: UIView!
    @IBOutlet weak var imgCardBusiness: UIImageView!

    @IBOutlet weak var btnConfirm: UIButton!

    //-- Variable
    var delegate: ViewControllerPersonalDelegate? = nil
    private var ddJob: DropDown? = nil
    private var iSex: Int = 1
    private var bViewCardIdInfoShown = true
    private var bClickedConfirm: Bool = false
    private var avatar: String = ""
    private var sImgIdCard: String = ""


    //-- Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        //-- Gesture
        let gestureAvatar = UITapGestureRecognizer(target: self, action: #selector(onTapAvatar(_:)))
        viewAvatar.addGestureRecognizer(gestureAvatar)

//        let gestureBirthday = UITapGestureRecognizer(target: self, action: #selector(onTapBirthday(_:)))
//        lblBirthday.addGestureRecognizer(gestureBirthday)

        let gestureJob = UITapGestureRecognizer(target: self, action: #selector(onTapJob(_:)))
        lblJob.addGestureRecognizer(gestureJob)

        let gestureCardId1 = UITapGestureRecognizer(target: self, action: #selector(onTapCardId1(_:)))
        imgCardId1.addGestureRecognizer(gestureCardId1)

        let gestureCardId2 = UITapGestureRecognizer(target: self, action: #selector(onTapCardId2(_:)))
        imgCardId2.addGestureRecognizer(gestureCardId2)

        let gestureCardBusiness = UITapGestureRecognizer(target: self, action: #selector(onTapCardBusiness(_:)))
        imgCardBusiness.addGestureRecognizer(gestureCardBusiness)

        let gestureScannedInfo = UITapGestureRecognizer(target: self, action: #selector(onTapScannedInfo(_:)))
        viewScannedInfo.addGestureRecognizer(gestureScannedInfo)

        //-- TextField Delegate
        lblName.text = Config.modelUserInfo.sName
        lblPhone.text = Config.modelUserInfo.sMobile
        lblBirthday.text = Config.modelUserInfo.sBirthday
        txtCompany.text = Config.modelUserInfo.sCompany

        //-- Avatar
        avatar = Config.modelUserInfo.sPicture
        if avatar.isEmpty {
            imgAvatar.isHidden = true
            lblUpload.isHidden = false
        }
        else {
            imgAvatar.isHidden = false
            lblUpload.isHidden = true
            if let url = URL(string: Config.modelUserInfo.sPicture) {
                imgAvatar.loadImage(url: url)
            }
        }
        imgAvatar.makeRounded()

        //-- Sex
        iSex = Config.modelUserInfo.iSex
        if iSex == 1 {
            self.btnMale.setImage(  UIImage(named: "img_check_on" ), for: .normal)
            self.btnFemale.setImage(UIImage(named: "img_check_off"), for: .normal)
        }
        else {
            self.btnMale.setImage(  UIImage(named: "img_check_off"), for: .normal)
            self.btnFemale.setImage(UIImage(named: "img_check_on" ), for: .normal)
        }

        //-- Birthday
//        if Config.modelUserInfo.sBirthday.isEmpty {
//            lblBirthday.text = "Enter (Required)".localized()
//            lblBirthday.textColor = UIColor.lightGray
//        }
//        else {
//            lblBirthday.text = Config.modelUserInfo.sBirthday
//            lblBirthday.textColor = UIColor.black
//        }

        //-- Residence
        txtResidence.text = Config.modelUserInfo.sResidence

        //-- Job
        lblJob.backgroundColor = .clear
        lblJob.layer.cornerRadius = 5
        lblJob.layer.borderWidth = 1
        lblJob.layer.borderColor = UIColor.lightGray.cgColor

        ddJob = DropDown()
        ddJob!.dataSource = [
            "Doctor".localized(),
            "Nurse".localized(),
            "Teacher".localized(),
            "Communicator".localized(),
            "Other".localized()
        ]
        ddJob!.anchorView = lblJob
        ddJob!.bottomOffset = CGPoint(x: 0, y: (ddJob!.anchorView!.plainView.bounds.height))

        ddJob!.backgroundColor = .white
        ddJob!.layer.cornerRadius = 0
        ddJob!.layer.borderWidth = 1
        ddJob!.layer.borderColor = UIColor.darkGray.cgColor

        ddJob!.selectionAction = { (index, item) in
            self.lblJob.text = item
        }

        if !Config.modelUserInfo.sJob.isEmpty {
            ddJob!.selectRow(at: ddJob!.dataSource.firstIndex(of: Config.modelUserInfo.sJob))
            lblJob.text = Config.modelUserInfo.sJob
        }

        //-- ID Card
        lblCardNo.text = Config.modelUserInfo.sIdCardNum
        txtAddress1.text = Config.modelUserInfo.sAddress

        imgCardId1.backgroundColor = .clear
        imgCardId1.layer.cornerRadius = 5
        imgCardId1.layer.borderWidth = 1
        imgCardId1.layer.borderColor = UIColor.lightGray.cgColor
        imgCardId1.contentMode = .scaleAspectFit

        imgCardId2.backgroundColor = .clear
        imgCardId2.layer.cornerRadius = 5
        imgCardId2.layer.borderWidth = 1
        imgCardId2.layer.borderColor = UIColor.lightGray.cgColor
        imgCardId2.contentMode = .scaleAspectFit

        imgCardBusiness.backgroundColor = .clear
        imgCardBusiness.layer.cornerRadius = 5
        imgCardBusiness.layer.borderWidth = 1
        imgCardBusiness.layer.borderColor = UIColor.lightGray.cgColor
        imgCardBusiness.contentMode = .scaleAspectFit

        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
            DispatchQueue.main.async {
                if !Config.modelUserInfo.sIdCardFront.isEmpty {
                    if let url = URL(string: Config.modelUserInfo.sIdCardFront) {
                        self.imgCardId1.loadImage(url: url)
                    }
                }

                if !Config.modelUserInfo.sIdCardBack.isEmpty {
                    if let url = URL(string: Config.modelUserInfo.sIdCardBack) {
                        self.imgCardId2.loadImage(url: url)
                    }
                }

                if !Config.modelUserInfo.sCertificatePic.isEmpty {
                    if let url = URL(string: Config.modelUserInfo.sCertificatePic) {
                        self.imgCardBusiness.loadImage(url: url)
                    }
                }
            }
        })
    }


    override func viewDidAppear(_ animated: Bool) {
    }


    @IBAction func onTouchUpBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }


    @IBAction func onTouchUpConfirm(_ sender: Any) {
        if bClickedConfirm { return }
        if lblPhone.text?.isEmpty ?? true {
            self.showToast(message: "Fill in necessary fields".localized(), completion: nil)
            return
        }
        if lblName.text?.isEmpty ?? true {
            self.showToast(message: "Fill in necessary fields".localized(), completion: nil)
            return
        }
        tryUpdateUserInfo()
    }


    @objc func onTapAvatar(_ sender: UIGestureRecognizer) {
        ImagePickerManager().pickImage(self) { image in
            let imageResized = image.resizeImage(dimension: 200, opaque: true, contentMode: .scaleToFill)
            self.imgAvatar.image = imageResized
            self.imgAvatar.isHidden = false
            self.lblUpload.isHidden = true

            self.avatar = imageResized.toBase64() ?? ""
            //let imageData = NSData(base64Encoded: self.avatar, options: .ignoreUnknownCharacters)
            //let imageDec = UIImage(data: imageData! as Data)
            //self.imgAvatar.image = imageDec
        }
    }


    @objc func onTapBirthday(_ sender: UIGestureRecognizer) {
        let storyboard = UIStoryboard(name: "DateTime", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerDateTime") as! ViewControllerDateTime
        vc.modalPresentationStyle = .overCurrentContext
        vc.delegate = self
        vc.mode = .date
        present(vc, animated: true, completion: nil)
        /*
        let storyboard = UIStoryboard(name: "Input", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerInput") as! ViewControllerInput
        vc.modalPresentationStyle = .overCurrentContext
        vc.delegate = self
        vc.setInputMode(mode: ViewControllerInput.INPUT_MODE_BIRTHDAY)
        if (lblBirthday.text ?? "").compare("Enter (Required)".localized()).rawValue == 0 {
            vc.setInitValue(value: "")
        }
        else {
            vc.setInitValue(value: lblBirthday.text ?? "")
        }
        present(vc, animated: true, completion: nil)
        */
    }


    @objc func onTapJob(_ sender: UIGestureRecognizer) {
        ddJob?.show()
    }


    @objc func onTapCardId1(_ sender: UIGestureRecognizer) {
        ImagePickerManager().pickImage(self) { image in
            let imageResized = image.resizeImage(dimension: 1024, opaque: true, contentMode: .scaleToFill)
            self.imgCardId1.image = imageResized
            self.sImgIdCard = imageResized.toBase64() ?? ""
            self.tryGetIdCardFrontInfo()
        }
    }


    @objc func onTapCardId2(_ sender: UIGestureRecognizer) {
        ImagePickerManager().pickImage(self) { image in
            let imageResized = image.resizeImage(dimension: 768, opaque: true, contentMode: .scaleToFill)
            self.imgCardId2.image = imageResized
        }
    }


    @objc func onTapScannedInfo(_ sender: UIGestureRecognizer) {
        onTapCardId1(sender)
    }


    @objc func onTapCardBusiness(_ sender: UIGestureRecognizer) {
        ImagePickerManager().pickImage(self) { image in
            let imageResized = image.resizeImage(dimension: 768, opaque: true, contentMode: .scaleToFill)
            self.imgCardBusiness.image = imageResized
        }
    }


    func touchUpMale() {
        DispatchQueue.main.async {
            self.btnMale.setImage(  UIImage(named: "img_check_on" ), for: .normal)
            self.btnFemale.setImage(UIImage(named: "img_check_off"), for: .normal)
        }
        iSex = 1
    }


    func touchUpFemale() {
        DispatchQueue.main.async {
            self.btnMale.setImage(  UIImage(named: "img_check_off"), for: .normal)
            self.btnFemale.setImage(UIImage(named: "img_check_on" ), for: .normal)
        }
        iSex = 0
    }


    func tryGetIdCardFrontInfo() {
        var stReq: StReqGetIdCardFrontInfo = StReqGetIdCardFrontInfo()
        stReq.token     = Config.modelUserInfo.sToken
        stReq.mobile    = lblPhone.text ?? ""
        stReq.id_card_front_src = sImgIdCard

        API.instance.getIdCardFrontInfo(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    DispatchQueue.main.async {
                        self.lblName.text = stRsp.data!.name
                        self.lblBirthday.text = stRsp.data!.birthday
                        self.lblCardNo.text = stRsp.data!.id_card_num
                        self.txtAddress1.text = stRsp.data!.address
                        if stRsp.data!.sex == 1 {
                            self.touchUpMale()
                        }
                        else {
                            self.touchUpFemale()
                        }
                    }
                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
        }
    }


    func tryUpdateUserInfo() {
        var stReq: StReqUpdateUserInfo = StReqUpdateUserInfo()
        stReq.token     = Config.modelUserInfo.sToken
        stReq.mobile    = Config.modelUserInfo.sMobile
        stReq.name      = lblName.text  ?? ""
        stReq.sex       = iSex
        stReq.birthday  = lblBirthday.text ?? ""
        stReq.address   = txtAddress1.text ?? ""
        stReq.id_card_num = lblCardNo.text ?? ""
        stReq.residence = txtResidence.text ?? ""
        stReq.company   = txtCompany.text ?? ""
        stReq.job       = lblJob.text ?? ""

        if imgAvatar.image != nil {
            stReq.picture_src   = imgAvatar.image!.toBase64() ?? ""
        }
        if imgCardId1.image != nil {
            stReq.id_card_front_src = imgCardId1.image!.toBase64() ?? ""
        }
        if imgCardId2.image != nil {
            stReq.id_card_back_src  = imgCardId2.image!.toBase64() ?? ""
        }
        if imgCardBusiness.image != nil {
            stReq.certificate_src   = imgCardBusiness.image!.toBase64() ?? ""
        }

        bClickedConfirm = true
        API.instance.updateUserInfo(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    Config.modelUserInfo.copyFromApiData(data: stRsp.data!)
                    self.showToast(message: "Successfully updated!".localized(), completion: {
                        self.dismiss(animated: true, completion: nil)
                        self.delegate?.onPersonalSuccess()
                    })

                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
            self.bClickedConfirm = false
        }
    }

}


extension ViewControllerPersonal: ViewControllerDateTimeDelegate {

    func onDateTimeSelected(datetime: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.lblBirthday.text = formatter.string(from: datetime)
        self.lblBirthday.textColor = UIColor.black
    }

}


extension ViewControllerPersonal: ViewControllerInputDelegate {

    func onInputSuccess(mode: Int, value: String) {
        switch mode {
            case ViewControllerInput.INPUT_MODE_BIRTHDAY:
                lblBirthday.text = value
                break
            case ViewControllerInput.INPUT_MODE_RESIDENCE:
                txtResidence.text = value
                break
            case ViewControllerInput.INPUT_MODE_COMPANY:
                txtCompany.text = value
                break
            case ViewControllerInput.INPUT_MODE_PHONE:
                lblPhone.text = value
                break
            default: break
        }
    }

}
