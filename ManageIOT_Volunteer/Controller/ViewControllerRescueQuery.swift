import UIKit


protocol ViewControllerRescueQueryDelegate: AnyObject {
    func onRescueQueryDismiss()
    func onRescueQueryPresent()
    func onRescueQueryPresentRescueDetail()
    func onRescueQueryPresentRescueProcess()
}


class ViewControllerRescueQuery: UIViewController {

    @IBOutlet weak var tblRescue: UITableView!
    @IBOutlet weak var viewPageNumber: ViewPageNumber!

    var delegate: ViewControllerRescueQueryDelegate? = nil

    private var vcRescueDetail: ViewControllerRescueDetail? = nil

    private var vStRspGetRescueListData: [StRspGetRescueListData] = [StRspGetRescueListData]()
    private var iCountData: Int = 0
    private var iPage: Int = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewPageNumber.setMaxCountPageButton(countPageButton: 5)
        viewPageNumber.setCountPage(count: 7)
        viewPageNumber.setCurrentPage(page: 0)
        viewPageNumber.delegate = self

        tryGetRescueList()
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }


    func onBack() {
        if vcRescueDetail == nil {
            dismissFromParent()
            delegate?.onRescueQueryDismiss()
        }
        else {
            vcRescueDetail?.onBack()
        }
    }


    func dismissChildren() {
        vcRescueDetail?.dismissChildren()
        vcRescueDetail?.dismissFromParent()
        vcRescueDetail = nil
    }


    private func initViewPageNumber() {
        iCountData = vStRspGetRescueListData.count
        var iCountPage = iCountData / 10
        if iCountData % 10 != 0 {
            iCountPage += 1
        }
        viewPageNumber.setCountPage(count: iCountPage)
        iPage = 0
        viewPageNumber.setCurrentPage(page: 0)
        tblRescue.reloadData()
    }


    func tryGetRescueList() {
        var stReq: StReqGetRescueList = StReqGetRescueList()
        stReq.token     = Config.modelUserInfo.sToken
        stReq.mobile    = Config.modelUserInfo.sMobile

        API.instance.getRescueList(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    if stRsp.data == nil { break }

                    self.vStRspGetRescueListData = stRsp.data!

                    DispatchQueue.main.async {
                        self.initViewPageNumber()
                    }
                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
        }
    }

}


//-- For ViewPgaeNumber
extension ViewControllerRescueQuery: ViewPageNumberDelegate {

    func onPageNumberSelected(pageNumber: Int) {
        iPage = pageNumber
        tblRescue.reloadData()
    }
}


//-- For ViewControllerRescueDetailDelegate
extension ViewControllerRescueQuery: ViewControllerRescueDetailDelegate {

    func onRescueDetailDismiss() {
        vcRescueDetail = nil
        delegate?.onRescueQueryPresent()
    }


    func onRescueDetailPresent() {
        delegate?.onRescueQueryPresentRescueDetail()
    }


    func onRescueDetailPresentRescueProcess() {
        delegate?.onRescueQueryPresentRescueProcess()
    }
}


//-- For UITableView
extension ViewControllerRescueQuery: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var iCount = iCountData - iPage * 10
        if iCount > 10 {
            iCount = 10
        }
        return iCount
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CellRescue = tableView.dequeueReusableCell(
            withIdentifier: "rowrescue",
            for           : indexPath
        ) as! CellRescue

        var iIndex = iPage * 10
        iIndex += indexPath.row

        let data = vStRspGetRescueListData[iIndex]

        cell.lblPetitionist.text = data.contactName
        cell.lblDateTime.text    = data.finish_time
        cell.lblStatus.text      = "End".localized()
        cell.lblIntegral.text    = "\(data.point ?? 0)"

        return cell
    }


    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.white
            cell.contentView.backgroundColor = UIColor.white
        }
        else {
            cell.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
            cell.contentView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var iIndex = iPage * 10
        iIndex += indexPath.row

        let data = vStRspGetRescueListData[iIndex]

        if vcRescueDetail == nil {
            let storyboard = UIStoryboard(name: "RescueDetail", bundle: nil)
            vcRescueDetail = storyboard.instantiateViewController(withIdentifier: "ViewControllerRescueDetail") as? ViewControllerRescueDetail
        }
        vcRescueDetail!.delegate = self
        vcRescueDetail!.iRescueId = data.task_id ?? 0
        addChildViewController(child: vcRescueDetail!, container: view, frame: view.bounds)
        delegate?.onRescueQueryPresentRescueDetail()
    }

}

