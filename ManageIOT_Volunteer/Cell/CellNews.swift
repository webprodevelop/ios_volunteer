import UIKit

class CellNews: UICollectionViewCell {

    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblDate    : UILabel!
    @IBOutlet weak var imgContent : UIImageView!
    @IBOutlet weak var lblTitle   : UILabel!
    @IBOutlet weak var lblContent : UILabel!
    @IBOutlet weak var viewOverlay: UIView!


    override func prepareForReuse() {
        super.prepareForReuse()

        lblCategory.text = ""
        lblDate.text     = ""
        imgContent.image = nil
        lblTitle.text    = ""
        lblContent.text  = ""
        viewOverlay.isHidden = true
    }


    func updateView(news: ModelNews) {
        lblCategory.text = news.sBranch
        lblTitle.text    = " " + news.sTitle
        lblDate.text     = news.sTime

        var htmlContent = news.sContent
        let index1: String.Index = htmlContent.range(of: "<img")?.lowerBound ?? htmlContent.startIndex
        let index2: String.Index = htmlContent.range(of: "/>"  )?.upperBound ?? htmlContent.startIndex
        if index1 < index2 {
            let range = index1...index2
            htmlContent.removeSubrange(range)
        }
        lblContent.attributedText = htmlContent.htmlAttributed

        do {
            let url = URL(string: news.sPicture)
            let data = try Data(contentsOf: url!)
            imgContent.image = UIImage(data: data)
        } catch {}

        if news.iRead > 0 {
            viewOverlay.isHidden = false
        }
        else {
            viewOverlay.isHidden = true
        }

    }

}
