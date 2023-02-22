import UIKit
import WebKit


protocol ViewControllerDateTimeDelegate: AnyObject {
    func onDateTimeSelected(datetime: Date)
}


class ViewControllerDateTime: UIViewController {

    @IBOutlet weak var viewOutside: UIView!
    @IBOutlet weak var pickerDate: UIDatePicker!
    var delegate: ViewControllerDateTimeDelegate? = nil
    var mode: UIDatePicker.Mode = .time


    override func viewDidLoad() {
        super.viewDidLoad()

        pickerDate.datePickerMode = mode

        //-- Gesture lblGetCode
        let gestureOutside = UITapGestureRecognizer(target: self, action: #selector(onTapOutside(_:)))
        viewOutside.addGestureRecognizer(gestureOutside)
        viewOutside.isUserInteractionEnabled = true
    }


    @objc func onTapOutside(_ sender: UIGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }


    @IBAction func onTouchUpOk(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        delegate?.onDateTimeSelected(datetime: pickerDate.date)
    }


    @IBAction func onTouchUpCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
