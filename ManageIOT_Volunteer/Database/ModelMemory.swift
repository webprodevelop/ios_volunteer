import Foundation

class ModelMemory {
    var iId  : Int = 0
    var iTurn: Int = 0      // 0: Turned Off, 1: Turned On
    var sName: String = ""
    var sTips: String = ""
    var sTime: String = ""
    var wdays: [String] = ["0", "0", "0", "0", "0", "0", "0"]  // "1,0,1,0,1,1,1" for weekdays
    var uuids: [String] = ["", "", "", "", "", "", ""]  // UUIDs for every notification per weekdays


    init() {
        iId   = 0
        iTurn = 0
        sName = ""
        sTips = ""
        sTime = ""
        wdays = ["0", "0", "0", "0", "0", "0", "0"]
        uuids = ["", "", "", "", "", "", ""]
    }


    init(id: Int, turn: Int, name: String, tips: String, time: String, wdays: [String], uuids: [String]) {
        iId   = id
        iTurn = turn
        sName = name
        sTips = tips
        sTime = time
        self.wdays = wdays
        self.uuids = uuids
    }
}
