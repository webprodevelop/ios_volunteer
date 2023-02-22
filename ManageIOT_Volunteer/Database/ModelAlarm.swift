import Foundation

class ModelAlarm {
    var bWatchSos   : Bool = false
    var bSensorAlarm: Bool = false
    var bWatchNet   : Bool = false
    var bSensorNet  : Bool = false
    var bHeart      : Bool = false
    var bWatchPower : Bool = false
    var bSensorPower: Bool = false
    var bFence      : Bool = false
    var bMorning    : Bool = false
    var bEvening    : Bool = false


    func copyFromApiData(data: StRspGetAlarmSetInfoData) {
        bWatchSos    = data.sos_status!
        bSensorAlarm = data.fire_status!
        bWatchNet    = data.watch_net_status!
        bSensorNet   = data.fire_net_status!
        bHeart       = data.heart_rate_status!
        bWatchPower  = data.watch_battery_status!
        bSensorPower = data.fire_battery_status!
        bFence       = data.electron_fence_status!
        bMorning     = data.morning_status!
        bEvening     = data.evening_status!
    }
}
