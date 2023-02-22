import UIKit

class ViewControllerMemory: UIViewController {

    @IBOutlet weak var tblMemory: UITableView!
    @IBOutlet weak var lblNoMemory: UILabel!

    var memories: [ModelMemory] = [ModelMemory]()


    override func viewDidLoad() {
        super.viewDidLoad()
        lblNoMemory.isHidden = true
    }


    override func viewWillAppear(_ animated: Bool) {
        //-- LoadMemory from Database
        memories = DbManager.instance.loadMemories()
        if memories.count == 0 { lblNoMemory.isHidden = false }
        tblMemory.reloadData()
    }


    @IBAction func onTouchUpBack(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }


    @IBAction func onTouchUpAdd(_ sender: Any) {
        let storyboard = UIStoryboard(name: "MemoEdit", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerMemoEdit")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }


    func removeNotification(memory: ModelMemory) {
        let center = UNUserNotificationCenter.current()
        center.removeDeliveredNotifications(withIdentifiers: memory.uuids)
        center.removePendingNotificationRequests(withIdentifiers: memory.uuids)
    }


    func scheduleNotification(memory: ModelMemory) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.setLocalizedDateFormatFromTemplate("HH:mm")

        let hour   = formatter.date(from: memory.sTime)?.hour
        let minute = formatter.date(from: memory.sTime)?.minute
        var date = Date()
        date = date.change(year: date.year, month: date.month, day: date.day, hour: hour, minute: minute, second: 0)

        let center = UNUserNotificationCenter.current()
        center.removeDeliveredNotifications(withIdentifiers: memory.uuids)
        center.removePendingNotificationRequests(withIdentifiers: memory.uuids)

        let content = UNMutableNotificationContent()
        content.title = memory.sName
        content.body = memory.sTips
        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound.default
        if memory.wdays.joined(separator: ",") == "0,0,0,0,0,0,0" {
            // No Repeat
            var components = DateComponents()
            components.hour   = hour
            components.minute = minute
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: memory.uuids[0], content: content, trigger: trigger)
            center.add(request)
        }
        else {
            for i in 0..<7 {
                if memory.wdays[i] == "0" { continue }
                date = date.change(weekday: (i + 1) % 7 + 1)
                let components = Calendar.current.dateComponents([.weekday, .hour, .minute, .second], from: date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                let request = UNNotificationRequest(identifier: memory.uuids[i], content: content, trigger: trigger)
                center.add(request)
            }
        }
    }

}


extension ViewControllerMemory: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memories.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CellMemory = tableView.dequeueReusableCell(
            withIdentifier: "rowmemory",
            for           : indexPath
        ) as! CellMemory

        let memory = memories[indexPath.row]
        cell.memory = memory
        cell.updateView()

        cell.delegate = self
        return cell
    }

}


extension ViewControllerMemory: CellMemoryDelegate {

    func onMemorySwitch(memory: ModelMemory, isOn: Bool) {
        DbManager.instance.updateMemory(model: memory)
        if isOn {
            scheduleNotification(memory: memory)
        }
        else {
            removeNotification(memory: memory)
        }
    }


    func onMemoryEdit(memory: ModelMemory) {
        let storyboard = UIStoryboard(name: "MemoEdit", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerMemoEdit") as! ViewControllerMemoEdit
        vc.modalPresentationStyle = .fullScreen
        vc.bAdding = false
        vc.memory = memory
        self.present(vc, animated: true, completion: nil)
    }


    func onMemoryDelete(memory: ModelMemory) {
        _ = DbManager.instance.deleteMemory(id: memory.iId)
        removeNotification(memory: memory)
        viewWillAppear(false)   // Refresh Table
    }

}
