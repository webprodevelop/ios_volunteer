import UIKit
import WebKit

class ViewControllerBindComplete: UIViewController {

    @IBOutlet weak var lblContent: UILabel!

    var type : DeviceType = .SmartWatch
    var model: Any? = nil
    var sStart: String = ""
    var sEnd  : String = ""


    override func viewDidLoad() {
        super.viewDidLoad()
        if type == .SmartWatch {
            let modelWatch = model as! ModelWatch
            sStart = modelWatch.sServiceStart
            sEnd   = modelWatch.sServiceEnd
        }
        else {
            let modelSensor = model as! ModelSensor
            sStart = modelSensor.sServiceStart
            sEnd   = modelSensor.sServiceEnd
        }
        updateLblContent()
    }


    @IBAction func onTouchUpBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }


    @IBAction func onTouchUpConfirm(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }


    func updateLblContent() {
        let days = daysFromNow(sDate: sEnd)
        var content = "The device has been provided with".localized()
        content = content + " " + String(days)
        content = content + "days of free network notification reminder service, which lasts from:".localized()
        content = content + " " + sStart + " " + "to".localized() + " " + sEnd
        lblContent.text = content
    }
}
