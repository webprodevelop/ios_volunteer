import UIKit
import SwiftyJSON

protocol ViewControllerMessageDelegate: AnyObject {
    func onMessageClicked()
}


class ViewControllerMessage: UIViewController {

    @IBOutlet weak var tblMessage: UITableView!
    @IBOutlet weak var btnDeleteAll: UIButton!
    @IBOutlet weak var btnMarkAll: UIButton!
    
    var delegate: ViewControllerMessageDelegate? = nil
    var messages: [ModelMessage] = [ModelMessage]()


    override func viewDidLoad() {
        super.viewDidLoad()

        messages = DbManager.instance.loadMessages()
        arrangeMessages()
    }


    @IBAction func onTouchUpBack(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }


    @IBAction func onTouchUpMarkAll(_ sender: Any) {
        if self.messages.count == 0 { return }
        showConfirm(
            title  : "Notice".localized(),
            message: "Do you want to read all messages?".localized(),
            handlerOk: { alertAction in
                self.tryReadAllNotification()
            },
            handlerCancel: { alertAction in
            }
        )
    }


    @IBAction func onTouchUpDeleteAll(_ sender: Any) {
        if self.messages.count == 0 { return }
        showConfirm(
            title  : "Notice".localized(),
            message: "Do you want to delete all messages?".localized(),
            handlerOk: { alertAction in
                self.tryRemoveAllNotification()
            },
            handlerCancel: { alertAction in
            }
        )
    }


    func checkSelectedMessage(model: ModelMessage) {
        if model.sCategory != "新任务" {
            return
        }

        var sType: String = ""
        let jsonBody = JSON(parseJSON: model.sData)
        sType = jsonBody["type"].string ?? ""
        if sType.isEmpty { return }

        if sType != Config.TYPE_NOTIFY_TASK {
            return
        }
        var iTaskId: Int = 0
        var sTaskStatus: String = Config.TASK_STATUS_CANCEL

        iTaskId = jsonBody["task_id"].int ?? 0
        sTaskStatus = jsonBody["task_status"].string ?? Config.TASK_STATUS_CANCEL

        if sTaskStatus == Config.TASK_STATUS_CANCEL
        || sTaskStatus == Config.TASK_STATUS_FINISH {
            return
        }

        if iTaskId == Config.modelUserInfo.iIdTask {
            dismiss(animated: false, completion: {
                self.delegate?.onMessageClicked()
            })
        }
    }


    func arrangeMessages() {
        var countSos: Int = 0
        for i in 0..<self.messages.count {
            let msg = self.messages[i]
            if msg.sCategory == "新任务" {
                self.messages.remove(at: i)
                self.messages.insert(msg, at: countSos)
                countSos += 1
            }
        }
    }


    func tryReadAllNotification() {
        var stReq: StReqReadAllNotification = StReqReadAllNotification()
        stReq.token  = Config.modelUserInfo.sToken
        stReq.mobile = Config.modelUserInfo.sMobile

        API.instance.readAllNotification(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }

                    DispatchQueue.main.async {
                        for model in self.messages {
                            model.iRead = 1
                            if model.sCategory == "alarm" {
                                DbManager.instance.updateMessage(model: model)
                            }
                        }

                        self.tblMessage.reloadData()
                    }

                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
        }
    }


    func tryRemoveAllNotification() {
        var stReq: StReqRemoveAllNotification = StReqRemoveAllNotification()
        stReq.token  = Config.modelUserInfo.sToken
        stReq.mobile = Config.modelUserInfo.sMobile

        API.instance.removeAllNotification(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }

                    DispatchQueue.main.async {
                        for model in self.messages {
                            DbManager.instance.deleteMessage(id: model.iId)
                        }
                        self.messages.removeAll()
                        self.tblMessage.reloadData()
                    }

                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
        }
    }


    func tryReadNotification(model: ModelMessage) {
        var stReq: StReqReadNotification = StReqReadNotification()
        stReq.token  = Config.modelUserInfo.sToken
        stReq.mobile = Config.modelUserInfo.sMobile
        stReq.id = model.iId

        API.instance.readNotification(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        break
                    }
                    model.iRead = 1
                    DbManager.instance.updateMessage(model: model)
                    self.tblMessage.reloadData()
                    break

                case let .failure(error):
                    break
            }
        }
    }


    func tryRemoveNotification(model: ModelMessage) {
        var stReq: StReqRemoveNotification = StReqRemoveNotification()
        stReq.token  = Config.modelUserInfo.sToken
        stReq.mobile = Config.modelUserInfo.sMobile
        stReq.id = model.iId

        API.instance.removeNotification(stReq: stReq) { result in
            switch result {
                case let .success(stRsp):
                    if stRsp.retcode != Config.RET_SUCCESS {
                        self.showAlert(message: stRsp.msg!)
                        break
                    }
                    DbManager.instance.deleteMessage(id: model.iId)
                    self.messages.removeAll(where: { $0 === model})
                    self.tblMessage.reloadData()

                    break

                case let .failure(error):
                    self.showAlert(message: error.description!)
                    break
            }
        }
    }

}


extension ViewControllerMessage: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CellMessage = tableView.dequeueReusableCell(
            withIdentifier: "rowmessage",
            for           : indexPath
        ) as! CellMessage

        cell.delegate = self
        cell.message = messages[indexPath.row]
        cell.updateView()

        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = messages[indexPath.row]
        tryReadNotification(model: model)
        checkSelectedMessage(model: model)
    }

}


extension ViewControllerMessage: CellMessageDelegate {

    func onMessageDelete(model: ModelMessage) {
        showConfirm(
            title  : "Notice".localized(),
            message: "Do you want to delete it?".localized(),
            handlerOk: { alertAction in
                self.tryRemoveNotification(model: model)
            },
            handlerCancel: { alertAction in
            }
        )
    }

}
