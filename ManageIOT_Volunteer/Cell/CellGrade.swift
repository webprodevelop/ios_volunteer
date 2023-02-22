import UIKit

class CellGrade: UITableViewCell {

    @IBOutlet weak var lblGrade: UILabel!
    @IBOutlet weak var lblRange: UILabel!
    @IBOutlet weak var lblConversion: UILabel!
    @IBOutlet weak var lblPremium: UILabel!
    @IBOutlet weak var lblMisc: UILabel!


    override func prepareForReuse() {
        super.prepareForReuse()

    }


    func updateView(
        index        : Int,
        limitStart   : String,
        limitEnd     : String,
        exchangePoint: String,
        exchangePrice: String,
        equity       : String,
        description  : String
    ) {
        lblGrade.text = "V\(index)"
        lblRange.text = limitStart + "-" + limitEnd
        lblConversion.text = exchangePoint + ":" + exchangePrice
        lblPremium.text = equity
        lblMisc.text = description
    }

}
