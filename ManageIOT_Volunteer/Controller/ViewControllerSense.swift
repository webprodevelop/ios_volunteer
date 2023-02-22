import UIKit


protocol ViewControllerSenseDelegate {
    func onSenseDismiss()
    func onSensePresent()
    func onSensePresentPetbite()
}


class ViewControllerSense: UIViewController {

    @IBOutlet weak var cltSense: UICollectionView!

    //-- Variables
    var delegate: ViewControllerSenseDelegate? = nil

    private var vcPetbite: ViewControllerPetbite? = nil
    private var vModelNews: [ModelNews] = [ModelNews]()

    //-- Functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }


    func onBack() {
        if vcPetbite == nil {
            dismissFromParent()
            delegate?.onSenseDismiss()
        }
        else {
            vcPetbite!.onBack()
        }
    }


    func dismissChildren() {
        vcPetbite?.dismissFromParent()
        vcPetbite = nil
    }


    func setModelNewsList(models: [ModelNews]) {
        vModelNews = models
        cltSense.reloadData()
    }


    private func showViewControllerPetbite(model: ModelNews) {
        if vcPetbite == nil {
            let storyboard = UIStoryboard(name: "Petbite", bundle: nil)
            vcPetbite = storyboard.instantiateViewController(withIdentifier: "ViewControllerPetbite") as? ViewControllerPetbite
        }
        vcPetbite!.delegate = self
        addChildViewController(child: vcPetbite!, container: view, frame: view.bounds)
        /// setModelNews must be called after present
        vcPetbite!.setModelNews(model: model)
    }


}


//-- For UICollectionView : cltSense
extension ViewControllerSense: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return vModelNews.count
    }


    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: CellSense = collectionView.dequeueReusableCell(
            withReuseIdentifier: "cellsense",
            for                : indexPath
        ) as! CellSense

        let modelSense = vModelNews[indexPath.row]
        cell.updateView(model: modelSense)

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
        let model = vModelNews[indexPath.row]
        showViewControllerPetbite(model: model)
        delegate?.onSensePresentPetbite()
    }
}


extension ViewControllerSense: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath    : IndexPath
    ) -> CGSize {
        return CGSize(width: 128, height: 128)
    }


    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
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
        return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
}


//-- ViewControllerPetbiteDelegate
extension ViewControllerSense: ViewControllerPetbiteDelegate {

    func onPetbiteDismiss() {
        delegate?.onSensePresent()
        vcPetbite = nil
    }

}
