import UIKit


protocol ViewControllerCashInHistoryDelegate: AnyObject {
    func onCashInHistoryDismiss()
}


class ViewControllerCashInHistory: UIViewController {

    @IBOutlet weak var tblCashIn: UITableView!

    var delegate: ViewControllerCashInHistoryDelegate? = nil

    private var vStRspGetFinancialListData: [StRspGetFinancialListData] = [StRspGetFinancialListData]()


    override func viewDidLoad() {
        super.viewDidLoad()

        tryGetFinancialList()
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }


    func onBack() {
        dismissFromParent()
        delegate?.onCashInHistoryDismiss()
    }


    func tryGetFinancialList() {
        var stReq: StReqGetFinancialList = StReqGetFinancialList()
        stReq.token     = Config.modelUserInfo.sToken
        stReq.mobile    = Config.modelUserInfo.sMobile

        API.instance.getFinancialList(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    if stRsp.data == nil { break }

                    self.vStRspGetFinancialListData = stRsp.data!

                    DispatchQueue.main.async {
                        self.tblCashIn.reloadData()
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
extension ViewControllerCashInHistory: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vStRspGetFinancialListData.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CellCashIn = tableView.dequeueReusableCell(
            withIdentifier: "rowcashin",
            for           : indexPath
        ) as! CellCashIn

        let stRspGetFinancialListData = vStRspGetFinancialListData[indexPath.row]
        cell.lblDate.text    = stRspGetFinancialListData.time ?? ""
        cell.lblConsume.text = "\(stRspGetFinancialListData.point ?? 0)"
        cell.lblAmount.text  = "\(stRspGetFinancialListData.amount ?? 0)"
        cell.lblStatus.text  = stRspGetFinancialListData.status

        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

}

