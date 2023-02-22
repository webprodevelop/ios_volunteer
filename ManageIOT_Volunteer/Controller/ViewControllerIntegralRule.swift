import UIKit


protocol ViewControllerIntegralRuleDelegate: AnyObject {
    func onIntegralRuleDismiss()
}


class ViewControllerIntegralRule: UIViewController {

    @IBOutlet weak var tblRule: UITableView!

    var delegate: ViewControllerIntegralRuleDelegate? = nil

    private var arrRule: [String] = [String]()


    override func viewDidLoad() {
        super.viewDidLoad()

        arrRule.append("Perfect personal information for 1 point".localized())
        arrRule.append("View the article for 1 point".localized())
        arrRule.append("An hour of online time for 10 points".localized())
        arrRule.append("Rescue mission with AED equipment for 100 points".localized())
        arrRule.append("10 rescue attempts for 50 points".localized())
        arrRule.append("100 hours of online time for 10 points".localized())
        arrRule.append("100 rescue attempts for 500 points".localized())
        arrRule.append("150 hours of online time for 10 points".localized())
        arrRule.append("Rescue mission led the ambulance for 90 points".localized())
        arrRule.append("1000 rescue attempts for 500 points".localized())
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }


    func onBack() {
        dismissFromParent()
        delegate?.onIntegralRuleDismiss()
    }
}


//-- For UITableView
extension ViewControllerIntegralRule: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrRule.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CellRule = tableView.dequeueReusableCell(
            withIdentifier: "rowrule",
            for           : indexPath
        ) as! CellRule

        cell.lblNum.text = "\(indexPath.row + 1)."
        cell.lblContent.text = arrRule[indexPath.row]

        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

}

