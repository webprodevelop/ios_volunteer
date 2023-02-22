import UIKit
import ZXingObjC


protocol ViewControllerQrCodeDelegate: AnyObject {
    func onQrCodeContinue(typeDevice: DeviceType, modelWatch: ModelWatch)
    func onQrCodeContinue(typeDevice: DeviceType, modelSensor: ModelSensor)
    func onQrCodeManual(typeDevice: DeviceType)
}


class ViewControllerQrCode: UIViewController {

    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var viewScan   : UIView!
    @IBOutlet weak var lblResult  : UILabel!
    @IBOutlet weak var lblTutorial: UILabel!

    var delegate: ViewControllerQrCodeDelegate?
    var typeDevice: DeviceType = .SmartWatch
    var serial: String = ""

    var capture: ZXCapture?
    var bScanning: Bool?
    var bFirstOrientation: Bool?
    var transformSize: CGAffineTransform?


    override func viewDidLoad() {
        super.viewDidLoad()

        switch typeDevice {
            case .SmartWatch:
                lblTutorial.text = "Watch > Settings > QR code".localized()
                break
            case .FireSensor, .SmokeSensor:
                lblTutorial.text = "Bottom of the device".localized()
        }
        lblResult.isHidden = true

        setup()
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if bFirstOrientation == true { return }
        bFirstOrientation = true
        applyOrientation()
    }


    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { (context) in
            //-- Do Nothing
        }) { [weak self] (context) in
            guard let weakSelf = self else { return }
            weakSelf.applyOrientation()
        }
    }


    @IBAction func onTouchUpBack(_ sender: Any) {
        capture?.layer.removeFromSuperlayer()   // This must be called, if not, app crashes after dismiss is called
        capture?.stop()                         // This must be called, if not, app crashes after dismiss is called
        dismiss(animated: false, completion: nil)
    }


    @IBAction func onTouchUpManual(_ sender: Any) {
        capture?.layer.removeFromSuperlayer()   // This must be called, if not, app crashes after dismiss is called
        capture?.stop()                         // This must be called, if not, app crashes after dismiss is called
        dismiss(animated: false, completion: nil)
        delegate?.onQrCodeManual(typeDevice: typeDevice)
    }


    func tryRegisterWatch() {
        var stReq: StReqRegisterWatch = StReqRegisterWatch()
        stReq.token  = Config.modelUserInfo.sToken
        stReq.mobile = Config.modelUserInfo.sMobile
        stReq.serial = serial

        API.instance.registerWatch(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }

                    let modelWatch: ModelWatch = ModelWatch()
                    modelWatch.sSerial         = self.serial

                    modelWatch.bIsManager      = stRsp.data?.is_manager          ?? false
                    modelWatch.iId             = stRsp.data?.id                  ?? 0
                    modelWatch.bNetStatus      = stRsp.data?.net_status          ?? false
                    modelWatch.sUserName       = stRsp.data?.user_name           ?? ""
                    modelWatch.sUserPhone      = stRsp.data?.user_phone          ?? ""
                    modelWatch.iUserSex        = stRsp.data?.user_sex            ?? 1
                    modelWatch.sUserBirth      = stRsp.data?.user_birthday       ?? ""
                    modelWatch.iUserTall       = stRsp.data?.user_tall           ?? 0
                    modelWatch.iUserWeight     = stRsp.data?.user_weight         ?? 0
                    modelWatch.sUserBlood      = stRsp.data?.user_blood          ?? ""
                    modelWatch.sUserIllHistory = stRsp.data?.user_ill_history    ?? ""
                    modelWatch.sLat            = stRsp.data?.lat                 ?? ""
                    modelWatch.sLon            = stRsp.data?.lon                 ?? ""
                    modelWatch.sAddress        = stRsp.data?.address             ?? ""
                    modelWatch.sServiceStart   = stRsp.data?.service_start       ?? ""
                    modelWatch.sServiceEnd     = stRsp.data?.service_end         ?? ""
                    modelWatch.iChargeStatus   = stRsp.data?.charge_status       ?? 0
                    //modelWatch.sSosContactName1  = ""
                    //modelWatch.sSosContactName2  = ""
                    //modelWatch.sSosContactName3  = ""
                    //modelWatch.sSosContactPhone1 = ""
                    //modelWatch.sSosContactPhone2 = ""
                    //modelWatch.sSosContactPhone3 = ""
                    //modelWatch.iHeartRateHigh    = 100
                    //modelWatch.iHeartRateLow     = 60

                    if Config.id_watch_monitoring <= 0 {
                        Config.id_watch_monitoring = modelWatch.iId
                        Config.modelWatchMonitoring = modelWatch
                        Config.saveIdWatchMonitoring()
                    }
                    DispatchQueue.main.async {
                        self.dismiss(animated:false) {
                            _ = DbManager.instance.insertWatch(model: modelWatch)
                            self.delegate?.onQrCodeContinue(typeDevice: self.typeDevice, modelWatch: modelWatch)
                        }
                    }
                    break
                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
        }
    }


    func tryRegisterSensor() {
        var stReq: StReqRegisterSensor = StReqRegisterSensor()
        stReq.token  = Config.modelUserInfo.sToken
        stReq.mobile = Config.modelUserInfo.sMobile
        stReq.serial = serial
        stReq.type = (typeDevice == .SmartWatch) ? Config.PREFIX_FIRESENSOR : Config.PREFIX_SMOKESENSOR

        API.instance.registerSensor(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }

                    let modelSensor: ModelSensor = ModelSensor()
                    modelSensor.sSerial        = self.serial

                    modelSensor.bIsManager     = stRsp.data?.is_manager     ?? false
                    modelSensor.iId            = stRsp.data?.id             ?? 0
                    modelSensor.sType          = stRsp.data?.type           ?? ""
                    modelSensor.bNetStatus     = stRsp.data?.net_status     ?? false
                    modelSensor.bBatteryStatus = stRsp.data?.battery_status ?? false
                    modelSensor.bAlarmStatus   = stRsp.data?.alarm_status   ?? false
                    modelSensor.sLabel         = stRsp.data?.label          ?? ""
                    modelSensor.sContactName   = stRsp.data?.contact_name   ?? ""
                    modelSensor.sContactPhone  = stRsp.data?.contact_phone  ?? ""
                    modelSensor.sLat           = stRsp.data?.lat            ?? ""
                    modelSensor.sLon           = stRsp.data?.lon            ?? ""
                    modelSensor.sAddress       = stRsp.data?.address        ?? ""
                    modelSensor.sServiceStart  = stRsp.data?.service_start  ?? ""
                    modelSensor.sServiceEnd    = stRsp.data?.service_end    ?? ""

                    DispatchQueue.main.async {
                        self.dismiss(animated:false) {
                            _ = DbManager.instance.insertSensor(model: modelSensor)
                            self.delegate?.onQrCodeContinue(typeDevice: self.typeDevice, modelSensor: modelSensor)
                        }
                    }
                    break
                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
        }
    }


    //-- ZXing for QR code
    func setup() {
        bScanning = false
        bFirstOrientation = false

        capture = ZXCapture()
        if capture == nil { return }
        capture!.camera = capture!.back()
        capture!.focusMode = .continuousAutoFocus
        capture!.delegate = self
        capture!.layer.frame = viewContent.bounds

        viewContent.layer.addSublayer(capture!.layer)
    }


    func applyOrientation() {
        let orientation = UIApplication.shared.statusBarOrientation
        var captureRotation: Double
        var scanRectRotation: Double

        switch orientation {
            case .portrait:           captureRotation = 0;   scanRectRotation = 90;  break
            case .landscapeLeft:      captureRotation = 90;  scanRectRotation = 180; break
            case .landscapeRight:     captureRotation = 270; scanRectRotation = 0;   break
            case .portraitUpsideDown: captureRotation = 180; scanRectRotation = 270; break
            default:                  captureRotation = 0;   scanRectRotation = 90;  break
        }

        applyRectOfInterest(orientation: orientation)

        let angleRadius = captureRotation / 180.0 * Double.pi
        let captureTranform = CGAffineTransform(rotationAngle: CGFloat(angleRadius))

        capture?.transform = captureTranform
        capture?.rotation = CGFloat(scanRectRotation)
        capture?.layer.frame = view.frame
    }


    func applyRectOfInterest(orientation: UIInterfaceOrientation) {
        guard var transformVideoRect = viewScan?.frame else { return }
        guard let cameraSessionPreset = capture?.sessionPreset else { return }

        var scaleVideoX: CGFloat
        var scaleVideoY: CGFloat
        var videoWidth : CGFloat
        var videoHeight: CGFloat

        //-- Currently support only for 1920x1080 || 1280x720
        if cameraSessionPreset == AVCaptureSession.Preset.hd1920x1080.rawValue {
            videoWidth = 1920.0
            videoHeight = 1080.0
        }
        else {
            videoWidth = 1280.0
            videoHeight = 720.0
        }

        if orientation == UIInterfaceOrientation.portrait {
            scaleVideoX = self.view.frame.width  / videoHeight
            scaleVideoY = self.view.frame.height / videoWidth

            //-- Convert CGPoint under portrait mode to map with orientation of image
            //-- because the image will be cropped before rotate
            //-- reference: https://github.com/TheLevelUp/ZXingObjC/issues/222
            let realX = transformVideoRect.origin.y
            let realY = self.view.frame.size.width - transformVideoRect.size.width - transformVideoRect.origin.x
            let realWidth  = transformVideoRect.size.height
            let realHeight = transformVideoRect.size.width
            transformVideoRect = CGRect(x: realX, y: realY, width: realWidth, height: realHeight)
        }
        else {
            scaleVideoX = self.view.frame.width  / videoWidth
            scaleVideoY = self.view.frame.height / videoHeight
        }

        transformSize = CGAffineTransform(scaleX: 1.0 / scaleVideoX, y: 1.0 / scaleVideoY)
        guard let _transformSize = transformSize else { return }
        let transformRect = transformVideoRect.applying(_transformSize)
        capture?.scanRect = transformRect
    }


    func barcodeFormatToString(format: ZXBarcodeFormat) -> String {
        switch (format) {
            case kBarcodeFormatAztec:           return "Aztec"
            case kBarcodeFormatCodabar:         return "CODA-BAR"
            case kBarcodeFormatCode39:          return "Code 39"
            case kBarcodeFormatCode93:          return "Code 93"
            case kBarcodeFormatCode128:         return "Code 128"
            case kBarcodeFormatDataMatrix:      return "Data Matrix"
            case kBarcodeFormatEan8:            return "EAN-8"
            case kBarcodeFormatEan13:           return "EAN-13"
            case kBarcodeFormatITF:             return "ITF"
            case kBarcodeFormatPDF417:          return "PDF417"
            case kBarcodeFormatQRCode:          return "QR Code"
            case kBarcodeFormatRSS14:           return "RSS 14"
            case kBarcodeFormatRSSExpanded:     return "RSS Expanded"
            case kBarcodeFormatUPCA:            return "UPCA"
            case kBarcodeFormatUPCE:            return "UPCE"
            case kBarcodeFormatUPCEANExtension: return "UPC/EAN extension"
            default:                            return "Unknown"
        }
    }

}


extension ViewControllerQrCode: ZXCaptureDelegate {

    func captureCameraIsReady(_ capture: ZXCapture!) {
        bScanning = true
    }


    func captureResult(_ capture: ZXCapture!, result: ZXResult!) {
        guard let _result = result, bScanning == true else { return }

        capture?.stop()
        bScanning = false
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)

        serial = _result.text ?? "Unknow"
        let _ = barcodeFormatToString(format: _result.barcodeFormat)

        lblResult?.text = serial
        if typeDevice == .SmartWatch {
            tryRegisterWatch()
        }
        else {
            tryRegisterSensor()
        }
    }

}
