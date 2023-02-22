import UIKit


protocol CellWatchDelegate: AnyObject {
    func onWatchSetDefault(model: ModelWatch)
}


class CellWatch: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnMonitoring: UIButton!

    var model: ModelWatch = ModelWatch()
    var delegate: CellWatchDelegate? = nil


    override func prepareForReuse() {
        super.prepareForReuse()
        lblName.text = ""
        btnMonitoring.backgroundColor = UIColor(red: 50/255.0, green: 145/255.0, blue: 248/255.0, alpha: 1.0)
        btnMonitoring.setTitle("Set to default".localized(), for: .normal)
    }


    @IBAction func onTouchUpMonitoring(_ sender: Any) {
        delegate?.onWatchSetDefault(model: model)
    }


    func updateView() {
        lblName.text = model.sUserName
        if model.iId == Config.id_watch_monitoring {
            btnMonitoring.setTitle("Monitoring".localized(), for: .normal)
            btnMonitoring.backgroundColor = UIColor(red: 39/255.0, green: 177/255.0, blue: 72/255.0, alpha: 1.0)
        }
        else {
            btnMonitoring.setTitle("Set to default".localized(), for: .normal)
            btnMonitoring.backgroundColor = UIColor(red: 50/255.0, green: 145/255.0, blue: 248/255.0, alpha: 1.0)
        }
    }
}
