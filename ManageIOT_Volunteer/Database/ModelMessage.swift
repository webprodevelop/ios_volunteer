import Foundation

class ModelMessage {

    var iId      : Int = 0
    var sCategory: String = ""
    var sBody    : String = ""
    var sData    : String = ""
    var sTime    : String = ""
    var iRead    : Int = 0   // 0: Not read yet, 1: Did read


    init() {
        iId       = 0
        sCategory = ""
        sBody     = ""
        sData     = ""
        sTime     = ""
        iRead     = 0
    }


    init(id: Int, category: String, body: String, data: String, time: String, read: Int) {
        iId       = id
        sCategory = category
        sBody     = body
        sData     = data
        sTime     = time
        iRead     = read
    }

}
