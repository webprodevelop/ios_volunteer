import UIKit
import WebKit

class ViewControllerMemoEdit: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewTime: UIView!
    @IBOutlet weak var txtName : UITextField!
    @IBOutlet weak var txtTime : UITextField!
    @IBOutlet weak var txtTips : UITextField!
    @IBOutlet weak var lblDays : UILabel!
    @IBOutlet weak var swtWeekday1: UISwitch!
    @IBOutlet weak var swtWeekday2: UISwitch!
    @IBOutlet weak var swtWeekday3: UISwitch!
    @IBOutlet weak var swtWeekday4: UISwitch!
    @IBOutlet weak var swtWeekday5: UISwitch!
    @IBOutlet weak var swtWeekday6: UISwitch!
    @IBOutlet weak var swtWeekday7: UISwitch!

    var bAdding: Bool = true  // whether editing or adding
    var memory: ModelMemory = ModelMemory()
    let timePicker: UIDatePicker = UIDatePicker()


    override func viewDidLoad() {
        super.viewDidLoad()

        txtName.delegate = self
        txtTips.delegate = self

        swtWeekday1.isOn = false
        swtWeekday2.isOn = false
        swtWeekday3.isOn = false
        swtWeekday4.isOn = false
        swtWeekday5.isOn = false
        swtWeekday6.isOn = false
        swtWeekday7.isOn = false

        let gestureTime = UITapGestureRecognizer(target: self, action: #selector(onTapTime(_:)))
        viewTime.addGestureRecognizer(gestureTime)

        //-- Init if bIsAdding is false
        if bAdding {
            lblTitle.text = "New Memory".localized()
        }
        else {
            lblTitle.text = "Edit Memory".localized()
            txtName.text = memory.sName
            txtTips.text = memory.sTips
            txtTime.text = memory.sTime
            updateLblDays()
            updateSwitch()
        }
    }


    //-- UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
            case txtName: txtTips.becomeFirstResponder(); break
            case txtTips: txtTips.resignFirstResponder(); break
            default: break
        }
        return false
    }


    @IBAction func onTouchUpBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }


    @IBAction func onTouchUpConfirm(_ sender: Any) {
        let sName = txtName.text ?? ""
        let sTips = txtTips.text ?? ""
        let sTime = txtTime.text ?? ""
        if sName.count == 0 { return }
        if sTime.count == 0 { return }

        memory.sName = sName
        memory.sTips = sTips
        memory.sTime = sTime

        if bAdding {
            memory.iTurn = 1    // Turned On
            for i in 0..<7 {
                memory.uuids[i] = UUID().uuidString
            }
            scheduleNotification()
            DbManager.instance.insertMemory(model: memory)
        }
        else {
            if memory.iTurn == 1 {
                scheduleNotification()
            }
            DbManager.instance.updateMemory(model: memory)
        }
        dismiss(animated: true, completion: nil)
    }


    @objc func onTapTime(_ sender: UITapGestureRecognizer? = nil) {
        let storyboard = UIStoryboard(name: "DateTime", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerDateTime") as! ViewControllerDateTime
        vc.modalPresentationStyle = .overCurrentContext
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }


    @IBAction func onChangedSwitchWeekday1(_ sender: Any) {
        memory.wdays[0] = (sender as! UISwitch).isOn ? "1" : "0"
        updateLblDays()
    }


    @IBAction func onChangedSwitchWeekday2(_ sender: Any) {
        memory.wdays[1] = (sender as! UISwitch).isOn ? "1" : "0"
        updateLblDays()
    }


    @IBAction func onChangedSwitchWeekday3(_ sender: Any) {
        memory.wdays[2] = (sender as! UISwitch).isOn ? "1" : "0"
        updateLblDays()
    }


    @IBAction func onChangedSwitchWeekday4(_ sender: Any) {
        memory.wdays[3] = (sender as! UISwitch).isOn ? "1" : "0"
        updateLblDays()
    }


    @IBAction func onChangedSwitchWeekday5(_ sender: Any) {
        memory.wdays[4] = (sender as! UISwitch).isOn ? "1" : "0"
        updateLblDays()
    }


    @IBAction func onChangedSwitchWeekday6(_ sender: Any) {
        memory.wdays[5] = (sender as! UISwitch).isOn ? "1" : "0"
        updateLblDays()
    }


    @IBAction func onChangedSwitchWeekday7(_ sender: Any) {
        memory.wdays[6] = (sender as! UISwitch).isOn ? "1" : "0"
        updateLblDays()
    }


    func updateLblDays() {
        var sDays: String = ""
        if memory.wdays[0] == "1" { sDays += "Mo".localized() + "," }
        if memory.wdays[1] == "1" { sDays += "Tu".localized() + "," }
        if memory.wdays[2] == "1" { sDays += "We".localized() + "," }
        if memory.wdays[3] == "1" { sDays += "Th".localized() + "," }
        if memory.wdays[4] == "1" { sDays += "Fr".localized() + "," }
        if memory.wdays[5] == "1" { sDays += "Sa".localized() + "," }
        if memory.wdays[6] == "1" { sDays += "Su".localized() + "," }
        if sDays.count == 0 {
            sDays = "No repeat".localized()
        }
        else {
            sDays = String(sDays.prefix(sDays.count - 1))  // Remove Last Comma
        }
        lblDays.text = sDays
    }


    func updateSwitch() {
        swtWeekday1.isOn = memory.wdays[0] == "1" ? true : false
        swtWeekday2.isOn = memory.wdays[1] == "1" ? true : false
        swtWeekday3.isOn = memory.wdays[2] == "1" ? true : false
        swtWeekday4.isOn = memory.wdays[3] == "1" ? true : false
        swtWeekday5.isOn = memory.wdays[4] == "1" ? true : false
        swtWeekday6.isOn = memory.wdays[5] == "1" ? true : false
        swtWeekday7.isOn = memory.wdays[6] == "1" ? true : false
    }


    func scheduleNotification() {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.setLocalizedDateFormatFromTemplate("HH:mm")

        let hour   = formatter.date(from: memory.sTime)?.hour
        let minute = formatter.date(from: memory.sTime)?.minute
        var date = Date()
        date = date.change(year: date.year, month: date.month, day: date.day, hour: hour, minute: minute, second: 0)

        let center = UNUserNotificationCenter.current()
        center.removeDeliveredNotifications(withIdentifiers: memory.uuids)
        center.removePendingNotificationRequests(withIdentifiers: memory.uuids)

        let content = UNMutableNotificationContent()
        content.title = memory.sName
        content.body = memory.sTips
        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound.default
        if memory.wdays.joined(separator: ",") == "0,0,0,0,0,0,0" {
            // No Repeat
            var components = DateComponents()
            components.hour   = hour
            components.minute = minute
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: memory.uuids[0], content: content, trigger: trigger)
            center.add(request)
        }
        else {
            for i in 0..<7 {
                if memory.wdays[i] == "0" { continue }
                date = date.change(weekday: (i + 1) % 7 + 1)
                let components = Calendar.current.dateComponents([.weekday, .hour, .minute, .second], from: date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                let request = UNNotificationRequest(identifier: memory.uuids[i], content: content, trigger: trigger)
                center.add(request)
            }
        }
    }
}


extension ViewControllerMemoEdit: ViewControllerDateTimeDelegate {

    func onDateTimeSelected(datetime: Date) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.setLocalizedDateFormatFromTemplate("HH:mm")
        txtTime.text = formatter.string(from: datetime)
    }

}
