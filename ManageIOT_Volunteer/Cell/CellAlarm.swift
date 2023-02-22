import UIKit

class CellAlarm: UITableViewCell {

    @IBOutlet weak var colDate  : UILabel!
    @IBOutlet weak var colSensor: UILabel!
    @IBOutlet weak var colDesc  : UILabel!
    @IBOutlet weak var colGroup : UILabel!
    @IBOutlet weak var cellContentView: UIView!

    override func prepareForReuse() {
        super.prepareForReuse()
        colDate.text   = nil
        colSensor.text = nil
        colDesc.text   = nil
        colGroup.text  = nil
    }

}
