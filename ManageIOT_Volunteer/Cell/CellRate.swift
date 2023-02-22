import UIKit

class CellRate: UITableViewCell {

    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblRate: UILabel!


    override func prepareForReuse() {
        super.prepareForReuse()
        lblDate.text = ""
        lblTime.text = ""
        lblRate.text = ""
    }

}
