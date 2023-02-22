import UIKit
import MarqueeLabel

class CellCashIn: UITableViewCell {

    @IBOutlet weak var lblDate: MarqueeLabel!
    @IBOutlet weak var lblConsume: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblStatus: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()

    }

}
