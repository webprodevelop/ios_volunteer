import UIKit

protocol ViewControllerIntegralGradeDelegate {
    func onIntegralGradeDismiss()
    func onIntegralGradePresent()
    func onIntegralGradePresentCashInHistory()
    func onIntegralGradePresentIntegralRule()
}

class ViewControllerIntegralGrade: UIViewController {

    @IBOutlet weak var lblMerit: UILabel!
    @IBOutlet weak var btnCashIn: UIButton!
    @IBOutlet weak var btnConsume: UIButton!
    @IBOutlet weak var sliderGrade: SliderSeek!
    @IBOutlet weak var tblGrade: UITableView!

    private let VC_NONE         : Int = 0
    private let VC_CASHINHISTORY: Int = 1
    private let VC_INTEGRALRULE : Int = 2

    var delegate: ViewControllerIntegralGradeDelegate? = nil

    private var vcCashInHistory: ViewControllerCashInHistory? = nil
    private var vcIntegralRule : ViewControllerIntegralRule?  = nil

    private var iVcCurrent: Int = 0 // VC_NONE
    private var vLimit        : [String] = [String]()
    private var vExchangePoint: [String] = [String]()
    private var vExchangePrice: [String] = [String]()
    private var vEquity       : [String] = [String]()
    private var vDescription  : [String] = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        btnCashIn.backgroundColor = .clear
        btnCashIn.layer.cornerRadius = 5
        btnCashIn.layer.borderWidth = 1
        btnCashIn.layer.borderColor = UIColor.gray.cgColor

        btnConsume.backgroundColor = .clear
        btnConsume.layer.cornerRadius = 5
        btnConsume.layer.borderWidth = 1
        btnConsume.layer.borderColor = UIColor.gray.cgColor

        lblMerit.text = "\(Config.modelUserInfo.iBalance) (¥\(Config.modelUserInfo.fCash))"
        sliderGrade.setSlidable(slidable: false)
        sliderGrade.setSeekValue(seekValue: Float(Config.modelUserInfo.iPointLevel - 1) / 3 )
        sliderGrade.setTextThumb(text: String(Config.modelUserInfo.iPointLevel))
        for _ in 0...3 {
            vLimit.append("")
            vExchangePoint.append("")
            vExchangePrice.append("")
            vEquity.append("")
            vDescription.append("")
        }

        tryGetPointRule()
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Config.addUserInfoDelegate(delegate: self)
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Config.delUserInfoDelegate(delegate: self)
    }


    @IBAction func onTouchUpBtnCashIn(_ sender: Any) {
//        if Config.modelUserInfo.iBalance < 1000 {
//            showAlert(message: "Your balance is not sufficient.".localized())
//            return
//        }
        let storyboard = UIStoryboard(name: "CashIn", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerCashIn") as! ViewControllerCashIn
        vc.delegeate = self
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }


    @IBAction func onTouchUpBtnConsume(_ sender: Any) {
        if vcCashInHistory == nil {
            let storyboard = UIStoryboard(name: "CashInHistory", bundle: nil)
            vcCashInHistory = storyboard.instantiateViewController(withIdentifier: "ViewControllerCashInHistory") as? ViewControllerCashInHistory
        }
        vcCashInHistory!.delegate = self
        addChildViewController(child: vcCashInHistory!, container: view, frame: view.bounds)
        iVcCurrent = VC_CASHINHISTORY
        delegate?.onIntegralGradePresentCashInHistory()
    }


    @IBAction func onTouchUpBtnRule(_ sender: Any) {
        if vcIntegralRule == nil {
            let storyboard = UIStoryboard(name: "IntegralRule", bundle: nil)
            vcIntegralRule = storyboard.instantiateViewController(withIdentifier: "ViewControllerIntegralRule") as? ViewControllerIntegralRule
        }
        vcIntegralRule!.delegate = self
        addChildViewController(child: vcIntegralRule!, container: view, frame: view.bounds)
        iVcCurrent = VC_INTEGRALRULE
        delegate?.onIntegralGradePresentIntegralRule()
    }

    func onBack() {
        switch iVcCurrent {
            case VC_NONE:
                dismissFromParent()
                delegate?.onIntegralGradeDismiss()
                break
            case VC_CASHINHISTORY:
                vcCashInHistory?.onBack()
                break
            case VC_INTEGRALRULE:
                vcIntegralRule?.onBack()
                break
            default: break
        }
    }

    func dismissChildren() {
        vcCashInHistory?.dismissFromParent()
        vcCashInHistory = nil
        vcIntegralRule?.dismissFromParent()
        vcIntegralRule = nil
    }

    func tryGetPointRule() {
        var stReq: StReqGetPointRule = StReqGetPointRule()
        stReq.token     = Config.modelUserInfo.sToken
        stReq.mobile    = Config.modelUserInfo.sMobile

        API.instance.getPointRule(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    if stRsp.data == nil { break }

                    self.vLimit.removeAll()
                    self.vExchangePoint.removeAll()
                    self.vExchangePrice.removeAll()
                    self.vEquity.removeAll()
                    self.vDescription.removeAll()

                    self.vLimit.append(stRsp.data!.v1_limit ?? "")
                    self.vLimit.append(stRsp.data!.v2_limit ?? "")
                    self.vLimit.append(stRsp.data!.v3_limit ?? "")
                    self.vLimit.append(stRsp.data!.v4_limit ?? "")

                    self.vExchangePoint.append(stRsp.data!.v1_exchange_point ?? "")
                    self.vExchangePoint.append(stRsp.data!.v2_exchange_point ?? "")
                    self.vExchangePoint.append(stRsp.data!.v3_exchange_point ?? "")
                    self.vExchangePoint.append(stRsp.data!.v4_exchange_point ?? "")

                    self.vExchangePrice.append(stRsp.data!.v1_exchange_price ?? "")
                    self.vExchangePrice.append(stRsp.data!.v2_exchange_price ?? "")
                    self.vExchangePrice.append(stRsp.data!.v3_exchange_price ?? "")
                    self.vExchangePrice.append(stRsp.data!.v4_exchange_price ?? "")

                    self.vEquity.append(stRsp.data!.v1_equity ?? "")
                    self.vEquity.append(stRsp.data!.v2_equity ?? "")
                    self.vEquity.append(stRsp.data!.v3_equity ?? "")
                    self.vEquity.append(stRsp.data!.v4_equity ?? "")

                    self.vDescription.append(stRsp.data!.v1_description ?? "")
                    self.vDescription.append(stRsp.data!.v2_description ?? "")
                    self.vDescription.append(stRsp.data!.v3_description ?? "")
                    self.vDescription.append(stRsp.data!.v4_description ?? "")

                    DispatchQueue.main.async {
                        self.tblGrade.reloadData()
                    }
                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
        }
    }
}

//-- For UITableView
extension ViewControllerIntegralGrade: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CellGrade = tableView.dequeueReusableCell(
            withIdentifier: "rowgrade",
            for           : indexPath
        ) as! CellGrade

        var limitStart: String = "0"
        var limitEnd  : String = ""

        if indexPath.row != 0 {
            limitStart = vLimit[indexPath.row - 1]
            limitStart = String((Int(limitStart) ?? 0) + 1)
        }
        limitEnd = vLimit[indexPath.row]

        cell.updateView(
            index        : indexPath.row + 1,
            limitStart   : limitStart,
            limitEnd     : limitEnd,
            exchangePoint: vExchangePoint[indexPath.row],
            exchangePrice: vExchangePrice[indexPath.row],
            equity       : vEquity[indexPath.row],
            description  : vDescription[indexPath.row]
        )
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

//-- ViewControllerCashInHistoryDelegate
extension ViewControllerIntegralGrade: ViewControllerCashInHistoryDelegate {
    func onCashInHistoryDismiss() {
        vcCashInHistory = nil
        iVcCurrent = VC_NONE
        delegate?.onIntegralGradePresent()
    }
}

//-- ViewControllerIntegralRuleDelegate
extension ViewControllerIntegralGrade: ViewControllerIntegralRuleDelegate {
    func onIntegralRuleDismiss() {
        vcIntegralRule = nil
        iVcCurrent = VC_NONE
        delegate?.onIntegralGradePresent()
    }
}

//-- UserInfoDelegate
extension ViewControllerIntegralGrade: UserInfoDelegate {
    func onUpdatedUserInfo() {
        DispatchQueue.main.async {
            self.lblMerit.text = "\(Config.modelUserInfo.iBalance) (¥\(Config.modelUserInfo.fCash))"
            self.sliderGrade.setSeekValue(seekValue: Float(Config.modelUserInfo.iPointLevel - 1) / 3 )
            self.sliderGrade.setTextThumb(text: String(Config.modelUserInfo.iPointLevel))
        }
    }
}

// -- CashIn
extension ViewControllerIntegralGrade: ViewControllerCashInDelegate {
    func onCashInSuccess() {
        DispatchQueue.main.async {
            self.lblMerit.text = "\(Config.modelUserInfo.iBalance) (¥\(Config.modelUserInfo.fCash))"
            self.sliderGrade.setSeekValue(seekValue: Float(Config.modelUserInfo.iPointLevel - 1) / 3 )
            self.sliderGrade.setTextThumb(text: String(Config.modelUserInfo.iPointLevel))
        }
    }
}
