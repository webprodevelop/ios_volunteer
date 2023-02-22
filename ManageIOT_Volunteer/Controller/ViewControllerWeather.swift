import UIKit
import WebKit

class ViewControllerWeather: UIViewController {

    @IBOutlet weak var viewOutside: UIView!
    @IBOutlet weak var viewContent: UIView!

    @IBOutlet weak var lblDistrictTime: UILabel!
    @IBOutlet weak var lblTemperature : UILabel!
    @IBOutlet weak var lblTemperCurrent: UILabel!
    @IBOutlet weak var lblCondition: UILabel!
    @IBOutlet weak var lblAqi      : UILabel!
    @IBOutlet weak var lblQlty     : UILabel!
    @IBOutlet weak var imgWeather  : UIImageView!

    var temperCurrent: String = ""
    var temperMin: String = ""
    var temperMax: String = ""
    var condition: String = ""
    var condCode : String = ""
    var district : String = ""
    var datetime : String = ""
    var time: String = ""
    var qlty: String = ""
    var aqi : String = ""
    var msg : String = ""



    override func viewDidLoad() {
        super.viewDidLoad()

        //-- Gesture lblGetCode
        let gestureOutside = UITapGestureRecognizer(target: self, action: #selector(onTapOutside(_:)))
        viewOutside.addGestureRecognizer(gestureOutside)
        viewOutside.isUserInteractionEnabled = true

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let date: Date = formatter.date(from: datetime) ?? Date()
        formatter.dateFormat = "HH:mm"
        time = formatter.string(from: date)

        if msg.isEmpty {
            lblDistrictTime.text = district + " " + time + "update".localized()
        }
        else {
            lblDistrictTime.text = msg
        }
        lblTemperature.text = "Temperature:".localized() + " " + temperMin + "º" + " ~ " + temperMax + "º"
        lblTemperCurrent.text = temperCurrent
        lblCondition.text = condition
        lblAqi.text = aqi
        lblQlty.text = qlty
        imgWeather.image = UIImage(named: "weather_" + condCode) ?? UIImage(named: "img_shine")!

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


    @IBAction func onTouchUpCall(_ sender: Any) {
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
}
