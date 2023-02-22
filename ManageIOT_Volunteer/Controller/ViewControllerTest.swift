import UIKit


class ViewControllerTest: UIViewController {

    @IBOutlet weak var viewPageNumber: ViewPageNumber!
    @IBOutlet weak var sliderSeek: SliderSeek!


    override func viewDidLoad() {
        super.viewDidLoad()

        viewPageNumber.setMaxCountPageButton(countPageButton: 5)
        viewPageNumber.setCountPage(count: 7)
        viewPageNumber.setCurrentPage(page: 2)
        viewPageNumber.delegate = self

        sliderSeek.setTextThumb(text: "v3")
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

}

extension ViewControllerTest: ViewPageNumberDelegate {
    func onPageNumberSelected(pageNumber: Int) {
        print("PAGE NUMBER : \(pageNumber)")
    }
}
