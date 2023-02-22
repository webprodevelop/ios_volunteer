import Foundation
import UIKit

class ViewControllerNews: UIViewController {

    @IBOutlet weak var tblNews: UICollectionView!

    var vNews: [ModelNews] = [ModelNews]()


    override func viewDidLoad() {
        super.viewDidLoad()
        vNews = DbManager.instance.loadNews()
    }

}


extension ViewControllerNews: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return vNews.count
    }


    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: CellNews = collectionView.dequeueReusableCell(
            withReuseIdentifier: "cellnews",
            for                : indexPath
        ) as! CellNews

        let news = vNews[indexPath.row]
        cell.updateView(news: news)

        return cell
    }


    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        return UICollectionReusableView()
    }


    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let news = vNews[indexPath.row]

        //-- Set Read Flag
        news.iRead = 1
        DbManager.instance.updateNews(model: news)

        //-- Show Detail View
        let storyboard = UIStoryboard(name: "Detail", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerDetail") as! ViewControllerDetail
        vc.modalPresentationStyle = .fullScreen
        vc.sHtml = news.sContent
        self.present(vc, animated: true, completion: nil)
    }
}


extension ViewControllerNews: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath    : IndexPath
    ) -> CGSize {
        return CGSize(width: 380, height: 250)
    }


    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 20
    }


    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }


    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section  : Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 8, left: 8, bottom: 8, right: 8)
    }
}
