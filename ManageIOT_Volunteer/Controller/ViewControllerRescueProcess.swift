import UIKit
import WebKit


protocol ViewControllerRescueProcessDelegate: AnyObject {
    func onRescueProcessDismiss()
}


class ViewControllerRescueProcess: UIViewController {

    @IBOutlet weak var tblRescueProcess: UITableView!

    var delegate: ViewControllerRescueProcessDelegate? = nil
    var stRspGetRescueDetailData: StRspGetRescueDetailData? = nil


    override func viewDidLoad() {
        super.viewDidLoad()
    }


    func onBack() {
        dismissFromParent()
        delegate?.onRescueProcessDismiss()
    }

}


//-- For UITableView
extension ViewControllerRescueProcess: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CellRescueProcess = tableView.dequeueReusableCell(
            withIdentifier: "rowrescueprocess",
            for           : indexPath
        ) as! CellRescueProcess


        switch indexPath.row {
            case 0:  cell.lblProcess.text = "Notification".localized() ; break;
            case 1:  cell.lblProcess.text = "Contact".localized()      ; break;
            case 2:  cell.lblProcess.text = "Phone".localized()        ; break;
            case 3:  cell.lblProcess.text = "Task".localized()         ; break;
            case 4:  cell.lblProcess.text = "Alarm".localized()        ; break;
            case 5:  cell.lblProcess.text = "Device".localized()       ; break;
            case 6:  cell.lblProcess.text = "Serial".localized()       ; break;
            case 7:  cell.lblProcess.text = "Point".localized()        ; break;
            case 8:  cell.lblProcess.text = "Create".localized()       ; break;
            case 9:  cell.lblProcess.text = "Finish".localized()       ; break;
            default: break
        }

        switch indexPath.row {
            case 0:  cell.lblTime.text = stRspGetRescueDetailData?.alarm_create_time; break;
            case 1:  cell.lblTime.text = stRspGetRescueDetailData?.contactName      ; break;
            case 2:  cell.lblTime.text = stRspGetRescueDetailData?.contactPhone     ; break;
            case 3:  cell.lblTime.text = stRspGetRescueDetailData?.task_content     ; break;
            case 4:  cell.lblTime.text = stRspGetRescueDetailData?.alarm_content    ; break;
            case 5:  cell.lblTime.text = stRspGetRescueDetailData?.device_type      ; break;
            case 6:  cell.lblTime.text = stRspGetRescueDetailData?.device_serial    ; break;
            case 7:  cell.lblTime.text = "\(stRspGetRescueDetailData?.point ?? 0)"  ; break;
            case 8:  cell.lblTime.text = stRspGetRescueDetailData?.create_time      ; break;
            case 9:  cell.lblTime.text = stRspGetRescueDetailData?.finish_time      ; break;

            default: break
        }

        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

}


