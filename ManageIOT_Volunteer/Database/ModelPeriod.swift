import Foundation

class ModelPeriod: Equatable {

    var sStart: String = ""
    var sEnd  : String = ""


    init() {
        sStart = ""
        sEnd   = ""
    }


    init(start: String, end: String) {
        sStart = start
        sEnd   = end
    }


    static func == (lhs: ModelPeriod, rhs: ModelPeriod) -> Bool {
        if lhs.sStart != rhs.sStart { return false }
        if lhs.sEnd   != rhs.sEnd   { return false }
        return true
    }


    func copyFromString(data: String) {
        let parts = data.split(separator: "-").map { String($0) }

        if parts.count > 0 { sStart = parts[0] }
        if parts.count > 1 { sEnd   = parts[1] }
    }


    func copy() -> ModelPeriod {
        let modelCopy = ModelPeriod()
        modelCopy.sStart = sStart
        modelCopy.sEnd   = sEnd
        return modelCopy
    }
}
