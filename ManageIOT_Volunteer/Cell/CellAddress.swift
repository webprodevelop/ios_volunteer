import UIKit

class CellAddress: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!

    
    override func prepareForReuse() {
        super.prepareForReuse()
        lblName.text = ""
        lblAddress.text  = ""
    }
}
