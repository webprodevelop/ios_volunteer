import Foundation
import FMDB

class DbManager {

    static let instance: DbManager = DbManager()

    static let CREATE_SUCCESS: Int = 0
    static let CREATE_DONE   : Int = 1
    static let CREATE_FAIL   : Int = 2

    let sFile: String = "manageiot.sqlite"
    var sPath: String = ""
    var lock: NSLock = NSLock()
    var db: FMDatabase!

    //-- Table Memory
    let TABLE_MEMORY: String = "memory"

    let FIELD_MEMORY_ID   : String = "id"
    let FIELD_MEMORY_TURN : String = "turn"
    let FIELD_MEMORY_NAME : String = "name"
    let FIELD_MEMORY_TIPS : String = "tips"
    let FIELD_MEMORY_TIME : String = "time"
    let FIELD_MEMORY_WDAYS: String = "wdays"
    let FIELD_MEMORY_UUIDS: String = "uuids"

    //-- Table Watch
    let TABLE_WATCH: String = "watch"

    let FIELD_WATCH_ISMANAGER       : String = "ismanager"
    let FIELD_WATCH_ID              : String = "id"
    let FIELD_WATCH_SERIAL          : String = "serial"
    let FIELD_WATCH_USERNAME        : String = "username"
    let FIELD_WATCH_USERPHONE       : String = "userphone"
    let FIELD_WATCH_USERSEX         : String = "usersex"
    let FIELD_WATCH_USERBIRTH       : String = "userbirth"
    let FIELD_WATCH_USERTALL        : String = "usertall"
    let FIELD_WATCH_USERWEIGHT      : String = "userweight"
    let FIELD_WATCH_USERBLOOD       : String = "userblood"
    let FIELD_WATCH_USERILLHISTORY  : String = "userillhistory"
    let FIELD_WATCH_LAT             : String = "lat"
    let FIELD_WATCH_LON             : String = "lon"
    let FIELD_WATCH_PROVINCE        : String = "province"
    let FIELD_WATCH_CITY            : String = "city"
    let FIELD_WATCH_DISTRICT        : String = "district"
    let FIELD_WATCH_ADDRESS         : String = "address"
    let FIELD_WATCH_SERVICESTART    : String = "servicestart"
    let FIELD_WATCH_SERVICEEND      : String = "serviceend"
    let FIELD_WATCH_NETSTATUS       : String = "netstatus"
    let FIELD_WATCH_CHARGESTATUS    : String = "chargestatus"
    let FIELD_WATCH_SOSCONTACTNAME1 : String = "soscontactname1"
    let FIELD_WATCH_SOSCONTACTNAME2 : String = "soscontactname2"
    let FIELD_WATCH_SOSCONTACTNAME3 : String = "soscontactname3"
    let FIELD_WATCH_SOSCONTACTPHONE1: String = "soscontactphone1"
    let FIELD_WATCH_SOSCONTACTPHONE2: String = "soscontactphone2"
    let FIELD_WATCH_SOSCONTACTPHONE3: String = "soscontactphone3"
    let FIELD_WATCH_HEARTRATEHIGH   : String = "heartratehigh"
    let FIELD_WATCH_HEARTRATELOW    : String = "heartratelow"
    let FIELD_WATCH_POSUPDATEMODE   : String = "posupdatemode"

    //-- Table Sensor
    let TABLE_SENSOR: String = "sensor"

    let FIELD_SENSOR_ISMANAGER    : String = "ismanager"
    let FIELD_SENSOR_ID           : String = "id"
    let FIELD_SENSOR_TYPE         : String = "type"
    let FIELD_SENSOR_SERIAL       : String = "serial"
    let FIELD_SENSOR_NETSTATUS    : String = "netstatus"
    let FIELD_SENSOR_BATTERYSTATUS: String = "batterystatus"
    let FIELD_SENSOR_ALARMSTATUS  : String = "alarmstatus"
    let FIELD_SENSOR_LABEL        : String = "label"
    let FIELD_SENSOR_CONTACTNAME  : String = "contactname"
    let FIELD_SENSOR_CONTACTPHONE : String = "contactphone"
    let FIELD_SENSOR_LAT          : String = "lat"
    let FIELD_SENSOR_LON          : String = "lon"
    let FIELD_SENSOR_PROVINCE     : String = "province"
    let FIELD_SENSOR_CITY         : String = "city"
    let FIELD_SENSOR_DISTRICT     : String = "district"
    let FIELD_SENSOR_ADDRESS      : String = "address"
    let FIELD_SENSOR_SERVICESTART : String = "servicestart"
    let FIELD_SENSOR_SERVICEEND   : String = "serviceend"

    //-- Table Heart Rate
    let TABLE_RATE: String = "rate"

    let FIELD_RATE_UID  : String = "uid"   // DATE + " " + Time + " " WATCH
    let FIELD_RATE_WATCH: String = "watch" // ID of Watch
    let FIELD_RATE_DATE : String = "date"
    let FIELD_RATE_TIME : String = "time"
    let FIELD_RATE_VALUE: String = "value"


    //-- Table News
    let TABLE_NEWS: String = "news"

    let FIELD_NEWS_ID     : String = "id"
    let FIELD_NEWS_TITLE  : String = "title"
    let FIELD_NEWS_BRANCH : String = "branch"
    let FIELD_NEWS_PICTURE: String = "picture"
    let FIELD_NEWS_CONTENT: String = "content"
    let FIELD_NEWS_TIME   : String = "time"
    let FIELD_NEWS_READ   : String = "read"


    //-- Table Message
    let TABLE_MESSAGE: String = "message"

    let FIELD_MESSAGE_ID      : String = "id"
    let FIELD_MESSAGE_CATEGORY: String = "category"
    let FIELD_MESSAGE_BODY    : String = "body"
    let FIELD_MESSAGE_DATA    : String = "data"
    let FIELD_MESSAGE_TIME    : String = "time"
    let FIELD_MESSAGE_READ    : String = "read"


    //-- Init
    init() {
        let dirDocument = (NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true
        )[0] as NSString) as String
        sPath = dirDocument.appending("/\(sFile)")
    }


    func deleteDb() {
        do {
            try FileManager.default.removeItem(atPath: sPath)
        } catch {}
    }


    func createDb() -> Int {
        if FileManager.default.fileExists(atPath: sPath) {
            return DbManager.CREATE_DONE
        }

        db = FMDatabase(path: sPath)
        if db == nil  { return DbManager.CREATE_FAIL }
        if !db.open() { return DbManager.CREATE_FAIL }

        do {
            if !createTableMemory()  { db.close();  try FileManager.default.removeItem(atPath: sPath);  return DbManager.CREATE_FAIL }
            if !createTableWatch()   { db.close();  try FileManager.default.removeItem(atPath: sPath);  return DbManager.CREATE_FAIL }
            if !createTableSensor()  { db.close();  try FileManager.default.removeItem(atPath: sPath);  return DbManager.CREATE_FAIL }
            if !createTableRate()    { db.close();  try FileManager.default.removeItem(atPath: sPath);  return DbManager.CREATE_FAIL }
            if !createTableNews()    { db.close();  try FileManager.default.removeItem(atPath: sPath);  return DbManager.CREATE_FAIL }
            if !createTableMessage() { db.close();  try FileManager.default.removeItem(atPath: sPath);  return DbManager.CREATE_FAIL }
        }
        catch {
            db.close()
            return DbManager.CREATE_FAIL
        }
        db.close()

        return DbManager.CREATE_SUCCESS
    }


    func openDb() -> Bool {
        if db == nil {
            if FileManager.default.fileExists(atPath: sPath) {
                db = FMDatabase(path: sPath)
            }
        }

        if db == nil { return false }

        return db.open()
    }


    //-- Memory
    func createTableMemory() -> Bool {
        var bCreated = true

        let sQueryCreateTable = """
            CREATE TABLE \(TABLE_MEMORY) ( \
                \(FIELD_MEMORY_ID   ) INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, \
                \(FIELD_MEMORY_TURN ) INTEGER      , \
                \(FIELD_MEMORY_NAME ) TEXT NOT NULL, \
                \(FIELD_MEMORY_TIPS ) TEXT NOT NULL, \
                \(FIELD_MEMORY_TIME ) TEXT NOT NULL, \
                \(FIELD_MEMORY_WDAYS) TEXT NOT NULL, \
                \(FIELD_MEMORY_UUIDS) TEXT NOT NULL  \
            )
        """

        do {
            try db.executeUpdate(sQueryCreateTable, values: nil)
        }
        catch {
            print("Failed to create table \(TABLE_MEMORY).")
            bCreated = false
        }

        return bCreated
    }


    func loadMemories() -> [ModelMemory] {
        var models: [ModelMemory] = [ModelMemory]()

        lock.lock()
        if !openDb() {
            lock.unlock()
            return models
        }

        let sQuery = "SELECT * FROM \(TABLE_MEMORY) ORDER BY \(FIELD_MEMORY_TIME) ASC"

        do {
            let result = try db.executeQuery(sQuery, values: nil)

            while result.next() {
                let model = ModelMemory(
                    id   : Int(result.int(forColumn: FIELD_MEMORY_ID)),
                    turn : Int(result.int(forColumn: FIELD_MEMORY_TURN)),
                    name : result.string(forColumn: FIELD_MEMORY_NAME) ?? "",
                    tips : result.string(forColumn: FIELD_MEMORY_TIPS) ?? "",
                    time : result.string(forColumn: FIELD_MEMORY_TIME) ?? "",
                    wdays: (result.string(forColumn: FIELD_MEMORY_WDAYS) ?? "").components(separatedBy: ","),
                    uuids: (result.string(forColumn: FIELD_MEMORY_UUIDS) ?? "").components(separatedBy: ",")
                )

                models.append(model)
            }
        }
        catch {
            print(error.localizedDescription)
        }

        db.close()
        lock.unlock()
        return models
    }


    func loadMemory(id: Int, completion: (_ model: ModelMemory?) -> Void) {
        var model: ModelMemory? = nil

        lock.lock()
        if !openDb() {
            completion(model)
            lock.unlock()
            return
        }

        let sQuery = "SELECT * FROM \(TABLE_MEMORY) WHERE \(FIELD_MEMORY_ID)=?"

        do {
            let result = try db.executeQuery(sQuery, values: [id])

            if result.next() {
                model = ModelMemory(
                    id   : Int(result.int(   forColumn: FIELD_MEMORY_ID   )),
                    turn : Int(result.int(   forColumn: FIELD_MEMORY_TURN )),
                    name :     result.string(forColumn: FIELD_MEMORY_NAME ) ?? "",
                    tips :     result.string(forColumn: FIELD_MEMORY_TIPS ) ?? "",
                    time :     result.string(forColumn: FIELD_MEMORY_TIME ) ?? "",
                    wdays:    (result.string(forColumn: FIELD_MEMORY_WDAYS) ?? "").components(separatedBy: ","),
                    uuids:    (result.string(forColumn: FIELD_MEMORY_UUIDS) ?? "").components(separatedBy: ",")
                )
            }
            else {
                print(db.lastError())
            }
        }
        catch {
            print(error.localizedDescription)
        }

        db.close()
        lock.unlock()

        completion(model)
    }


    func insertMemory(model: ModelMemory) {
        lock.lock()
        if !openDb() {
            lock.unlock()
            return
        }

        let sQuery = """
            INSERT INTO \(TABLE_MEMORY) ( \
                \(FIELD_MEMORY_ID   ), \
                \(FIELD_MEMORY_TURN ), \
                \(FIELD_MEMORY_NAME ), \
                \(FIELD_MEMORY_TIPS ), \
                \(FIELD_MEMORY_TIME ), \
                \(FIELD_MEMORY_WDAYS), \
                \(FIELD_MEMORY_UUIDS)  \
            ) \
            VALUES ( \
                 null           , \
                 \(model.iTurn) , \
                '\(model.sName)', \
                '\(model.sTips)', \
                '\(model.sTime)', \
                '\(model.wdays.joined(separator: ","))', \
                '\(model.uuids.joined(separator: ","))'  \
            );
        """

        if !db.executeStatements(sQuery) {
            print("Failed to insert data.")
            print(db.lastError(), db.lastErrorMessage())
        }

        db.close()
        lock.unlock()
    }


    func updateMemory(model: ModelMemory) {
        lock.lock()
        if !openDb() {
            lock.unlock()
            return
        }

        let sQuery = """
            UPDATE \(TABLE_MEMORY) SET \
                \(FIELD_MEMORY_TURN )=?, \
                \(FIELD_MEMORY_NAME )=?, \
                \(FIELD_MEMORY_TIPS )=?, \
                \(FIELD_MEMORY_TIME )=?, \
                \(FIELD_MEMORY_WDAYS)=?, \
                \(FIELD_MEMORY_UUIDS)=?  \
            WHERE \(FIELD_MEMORY_ID)=?
        """

        do {
            try db.executeUpdate(
                sQuery,
                values: [
                    model.iTurn,
                    model.sName,
                    model.sTips,
                    model.sTime,
                    model.wdays.joined(separator: ","),
                    model.uuids.joined(separator: ","),
                    model.iId
                ]
            )
        }
        catch {
            print(error.localizedDescription)
        }
        db.close()
        lock.unlock()
    }


    func deleteMemory(id: Int) -> Bool {
        var bDeleted = false

        lock.lock()
        if !openDb() {
            lock.unlock()
            return bDeleted
        }

        let sQuery = "DELETE FROM \(TABLE_MEMORY) WHERE \(FIELD_MEMORY_ID)=?"

        do {
            try db.executeUpdate(sQuery, values: [id])
            bDeleted = true
        }
        catch {
            print(error.localizedDescription)
        }

        db.close()
        lock.unlock()
        return bDeleted
    }


    //-- Watch
    func createTableWatch() -> Bool {
        var bCreated = true

        let sQueryCreateTable = """
            CREATE TABLE \(TABLE_WATCH) ( \
                \(FIELD_WATCH_ID              ) INTEGER PRIMARY KEY NOT NULL, \
                \(FIELD_WATCH_ISMANAGER       ) INTEGER      , \
                \(FIELD_WATCH_SERIAL          ) TEXT NOT NULL, \
                \(FIELD_WATCH_USERNAME        ) TEXT NOT NULL, \
                \(FIELD_WATCH_USERPHONE       ) TEXT NOT NULL, \
                \(FIELD_WATCH_USERSEX         ) INTEGER      , \
                \(FIELD_WATCH_USERBIRTH       ) TEXT NOT NULL, \
                \(FIELD_WATCH_USERTALL        ) INTEGER      , \
                \(FIELD_WATCH_USERWEIGHT      ) INTEGER      , \
                \(FIELD_WATCH_USERBLOOD       ) TEXT NOT NULL, \
                \(FIELD_WATCH_USERILLHISTORY  ) TEXT NOT NULL, \
                \(FIELD_WATCH_LAT             ) TEXT NOT NULL, \
                \(FIELD_WATCH_LON             ) TEXT NOT NULL, \
                \(FIELD_WATCH_PROVINCE        ) TEXT NOT NULL, \
                \(FIELD_WATCH_CITY            ) TEXT NOT NULL, \
                \(FIELD_WATCH_DISTRICT        ) TEXT NOT NULL, \
                \(FIELD_WATCH_ADDRESS         ) TEXT NOT NULL, \
                \(FIELD_WATCH_SERVICESTART    ) TEXT NOT NULL, \
                \(FIELD_WATCH_SERVICEEND      ) TEXT NOT NULL, \
                \(FIELD_WATCH_NETSTATUS       ) INTEGER      , \
                \(FIELD_WATCH_CHARGESTATUS    ) INTEGER      , \
                \(FIELD_WATCH_SOSCONTACTNAME1 ) TEXT NOT NULL, \
                \(FIELD_WATCH_SOSCONTACTNAME2 ) TEXT NOT NULL, \
                \(FIELD_WATCH_SOSCONTACTNAME3 ) TEXT NOT NULL, \
                \(FIELD_WATCH_SOSCONTACTPHONE1) TEXT NOT NULL, \
                \(FIELD_WATCH_SOSCONTACTPHONE2) TEXT NOT NULL, \
                \(FIELD_WATCH_SOSCONTACTPHONE3) TEXT NOT NULL, \
                \(FIELD_WATCH_HEARTRATEHIGH   ) INTEGER      , \
                \(FIELD_WATCH_HEARTRATELOW    ) INTEGER      , \
                \(FIELD_WATCH_POSUPDATEMODE   ) INTEGER        \
            )
        """

        do {
            try db.executeUpdate(sQueryCreateTable, values: nil)
        }
        catch {
            print("Failed to create table \(TABLE_WATCH).")
            bCreated = false
        }
        return bCreated
    }


    func loadWatches() -> [ModelWatch] {
        var models: [ModelWatch] = [ModelWatch]()

        lock.lock()
        if !openDb() {
            lock.unlock()
            return models
        }

        let sQuery = "SELECT * FROM \(TABLE_WATCH) ORDER BY \(FIELD_WATCH_ID) ASC"

        do {
            let result = try db.executeQuery(sQuery, values: nil)

            while result.next() {
                let model = ModelWatch()
                model.iId               = Int(result.int(   forColumn: FIELD_WATCH_ID              ))
                model.bIsManager        =     result.int(   forColumn: FIELD_WATCH_ISMANAGER       ) == 1 ? true : false
                model.sSerial           =     result.string(forColumn: FIELD_WATCH_SERIAL          ) ?? ""
                model.sUserName         =     result.string(forColumn: FIELD_WATCH_USERNAME        ) ?? ""
                model.sUserPhone        =     result.string(forColumn: FIELD_WATCH_USERPHONE       ) ?? ""
                model.iUserSex          = Int(result.int(   forColumn: FIELD_WATCH_USERSEX         ))
                model.sUserBirth        =     result.string(forColumn: FIELD_WATCH_USERBIRTH       ) ?? ""
                model.iUserTall         = Int(result.int(   forColumn: FIELD_WATCH_USERTALL        ))
                model.iUserWeight       = Int(result.int(   forColumn: FIELD_WATCH_USERWEIGHT      ))
                model.sUserBlood        =     result.string(forColumn: FIELD_WATCH_USERBLOOD       ) ?? ""
                model.sUserIllHistory   =     result.string(forColumn: FIELD_WATCH_USERILLHISTORY  ) ?? ""
                model.sLat              =     result.string(forColumn: FIELD_WATCH_LAT             ) ?? ""
                model.sLon              =     result.string(forColumn: FIELD_WATCH_LON             ) ?? ""
                model.sProvince         =     result.string(forColumn: FIELD_WATCH_PROVINCE        ) ?? ""
                model.sCity             =     result.string(forColumn: FIELD_WATCH_CITY            ) ?? ""
                model.sDistrict         =     result.string(forColumn: FIELD_WATCH_DISTRICT        ) ?? ""
                model.sAddress          =     result.string(forColumn: FIELD_WATCH_ADDRESS         ) ?? ""
                model.sServiceStart     =     result.string(forColumn: FIELD_WATCH_SERVICESTART    ) ?? ""
                model.sServiceEnd       =     result.string(forColumn: FIELD_WATCH_SERVICEEND      ) ?? ""
                model.bNetStatus        =     result.int(   forColumn: FIELD_WATCH_NETSTATUS       ) == 1 ? true : false
                model.iChargeStatus     = Int(result.int(   forColumn: FIELD_WATCH_CHARGESTATUS    ))
                model.sSosContactName1  =     result.string(forColumn: FIELD_WATCH_SOSCONTACTNAME1 ) ?? ""
                model.sSosContactName2  =     result.string(forColumn: FIELD_WATCH_SOSCONTACTNAME2 ) ?? ""
                model.sSosContactName3  =     result.string(forColumn: FIELD_WATCH_SOSCONTACTNAME3 ) ?? ""
                model.sSosContactPhone1 =     result.string(forColumn: FIELD_WATCH_SOSCONTACTPHONE1) ?? ""
                model.sSosContactPhone2 =     result.string(forColumn: FIELD_WATCH_SOSCONTACTPHONE2) ?? ""
                model.sSosContactPhone3 =     result.string(forColumn: FIELD_WATCH_SOSCONTACTPHONE3) ?? ""
                model.iHeartRateHigh    = Int(result.int(   forColumn: FIELD_WATCH_HEARTRATEHIGH   ))
                model.iHeartRateLow     = Int(result.int(   forColumn: FIELD_WATCH_HEARTRATELOW    ))
                model.iPosUpdateMode    = Int(result.int(   forColumn: FIELD_WATCH_POSUPDATEMODE   ))

                models.append(model)
            }
        }
        catch {
            print(error.localizedDescription)
        }

        db.close()
        lock.unlock()

        return models
    }


    func loadWatch(id: Int, completion: (_ model: ModelWatch?) -> Void) {
        var model: ModelWatch? = nil

        lock.lock()
        if !openDb() {
            completion(model)
            lock.unlock()
            return
        }

        let sQuery = "SELECT * FROM \(TABLE_WATCH) WHERE \(FIELD_WATCH_ID)=?"

        do {
            let result = try db.executeQuery(sQuery, values: [id])

            if result.next() {
                model = ModelWatch()

                model!.iId               = Int(result.int(   forColumn: FIELD_WATCH_ID              ))
                model!.bIsManager        =     result.int(   forColumn: FIELD_WATCH_ISMANAGER       ) == 1 ? true : false
                model!.sSerial           =     result.string(forColumn: FIELD_WATCH_SERIAL          ) ?? ""
                model!.sUserName         =     result.string(forColumn: FIELD_WATCH_USERNAME        ) ?? ""
                model!.sUserPhone        =     result.string(forColumn: FIELD_WATCH_USERPHONE       ) ?? ""
                model!.iUserSex          = Int(result.int(   forColumn: FIELD_WATCH_USERSEX         ))
                model!.sUserBirth        =     result.string(forColumn: FIELD_WATCH_USERBIRTH       ) ?? ""
                model!.iUserTall         = Int(result.int(   forColumn: FIELD_WATCH_USERTALL        ))
                model!.iUserWeight       = Int(result.int(   forColumn: FIELD_WATCH_USERWEIGHT      ))
                model!.sUserBlood        =     result.string(forColumn: FIELD_WATCH_USERBLOOD       ) ?? ""
                model!.sUserIllHistory   =     result.string(forColumn: FIELD_WATCH_USERILLHISTORY  ) ?? ""
                model!.sLat              =     result.string(forColumn: FIELD_WATCH_LAT             ) ?? ""
                model!.sLon              =     result.string(forColumn: FIELD_WATCH_LON             ) ?? ""
                model!.sProvince         =     result.string(forColumn: FIELD_WATCH_PROVINCE        ) ?? ""
                model!.sCity             =     result.string(forColumn: FIELD_WATCH_CITY            ) ?? ""
                model!.sDistrict         =     result.string(forColumn: FIELD_WATCH_DISTRICT        ) ?? ""
                model!.sAddress          =     result.string(forColumn: FIELD_WATCH_ADDRESS         ) ?? ""
                model!.sServiceStart     =     result.string(forColumn: FIELD_WATCH_SERVICESTART    ) ?? ""
                model!.sServiceEnd       =     result.string(forColumn: FIELD_WATCH_SERVICEEND      ) ?? ""
                model!.bNetStatus        =     result.int(   forColumn: FIELD_WATCH_NETSTATUS       ) == 1 ? true : false
                model!.iChargeStatus     = Int(result.int(   forColumn: FIELD_WATCH_CHARGESTATUS    ))
                model!.sSosContactName1  =     result.string(forColumn: FIELD_WATCH_SOSCONTACTNAME1 ) ?? ""
                model!.sSosContactName2  =     result.string(forColumn: FIELD_WATCH_SOSCONTACTNAME2 ) ?? ""
                model!.sSosContactName3  =     result.string(forColumn: FIELD_WATCH_SOSCONTACTNAME3 ) ?? ""
                model!.sSosContactPhone1 =     result.string(forColumn: FIELD_WATCH_SOSCONTACTPHONE1) ?? ""
                model!.sSosContactPhone2 =     result.string(forColumn: FIELD_WATCH_SOSCONTACTPHONE2) ?? ""
                model!.sSosContactPhone3 =     result.string(forColumn: FIELD_WATCH_SOSCONTACTPHONE3) ?? ""
                model!.iHeartRateHigh    = Int(result.int(   forColumn: FIELD_WATCH_HEARTRATEHIGH   ))
                model!.iHeartRateLow     = Int(result.int(   forColumn: FIELD_WATCH_HEARTRATELOW    ))
                model!.iPosUpdateMode    = Int(result.int(   forColumn: FIELD_WATCH_POSUPDATEMODE   ))
            }
            else {
                print(db.lastError())
            }
        }
        catch {
            print(error.localizedDescription)
        }

        db.close()
        lock.unlock()

        completion(model)
    }


    func insertWatch(model: ModelWatch) -> Bool {
        lock.lock()
        if !openDb() {
            lock.unlock()
            return false
        }

        let sQuery = """
            INSERT INTO \(TABLE_WATCH) ( \
                \(FIELD_WATCH_ID              ), \
                \(FIELD_WATCH_ISMANAGER       ), \
                \(FIELD_WATCH_SERIAL          ), \
                \(FIELD_WATCH_USERNAME        ), \
                \(FIELD_WATCH_USERPHONE       ), \
                \(FIELD_WATCH_USERSEX         ), \
                \(FIELD_WATCH_USERBIRTH       ), \
                \(FIELD_WATCH_USERTALL        ), \
                \(FIELD_WATCH_USERWEIGHT      ), \
                \(FIELD_WATCH_USERBLOOD       ), \
                \(FIELD_WATCH_USERILLHISTORY  ), \
                \(FIELD_WATCH_LAT             ), \
                \(FIELD_WATCH_LON             ), \
                \(FIELD_WATCH_PROVINCE        ), \
                \(FIELD_WATCH_CITY            ), \
                \(FIELD_WATCH_DISTRICT        ), \
                \(FIELD_WATCH_ADDRESS         ), \
                \(FIELD_WATCH_SERVICESTART    ), \
                \(FIELD_WATCH_SERVICEEND      ), \
                \(FIELD_WATCH_NETSTATUS       ), \
                \(FIELD_WATCH_CHARGESTATUS    ), \
                \(FIELD_WATCH_SOSCONTACTNAME1 ), \
                \(FIELD_WATCH_SOSCONTACTNAME2 ), \
                \(FIELD_WATCH_SOSCONTACTNAME3 ), \
                \(FIELD_WATCH_SOSCONTACTPHONE1), \
                \(FIELD_WATCH_SOSCONTACTPHONE2), \
                \(FIELD_WATCH_SOSCONTACTPHONE3), \
                \(FIELD_WATCH_HEARTRATEHIGH   ), \
                \(FIELD_WATCH_HEARTRATELOW    ), \
                \(FIELD_WATCH_POSUPDATEMODE   )  \
            ) \
            VALUES ( \
                 \(model.iId               ) , \
                 \(model.bIsManager ? 1 : 0) , \
                '\(model.sSerial           )', \
                '\(model.sUserName         )', \
                '\(model.sUserPhone        )', \
                 \(model.iUserSex          ) , \
                '\(model.sUserBirth        )', \
                 \(model.iUserTall         ) , \
                 \(model.iUserWeight       ) , \
                '\(model.sUserBlood        )', \
                '\(model.sUserIllHistory   )', \
                '\(model.sLat              )', \
                '\(model.sLon              )', \
                '\(model.sProvince         )', \
                '\(model.sCity             )', \
                '\(model.sDistrict         )', \
                '\(model.sAddress          )', \
                '\(model.sServiceStart     )', \
                '\(model.sServiceEnd       )', \
                 \(model.bNetStatus ? 1 : 0) , \
                 \(model.iChargeStatus     ) , \
                '\(model.sSosContactName1  )', \
                '\(model.sSosContactName2  )', \
                '\(model.sSosContactName3  )', \
                '\(model.sSosContactPhone1 )', \
                '\(model.sSosContactPhone2 )', \
                '\(model.sSosContactPhone3 )', \
                 \(model.iHeartRateHigh    ) , \
                 \(model.iHeartRateLow     ) , \
                 \(model.iPosUpdateMode    )   \
            );
        """

        if !db.executeStatements(sQuery) {
            print("Failed to insert data.")
            print(db.lastError(), db.lastErrorMessage())
            db.close()
            lock.unlock()
            return false
        }

        db.close()
        lock.unlock()
        return true
    }


    func updateWatch(model: ModelWatch) {
        lock.lock()
        if !openDb() {
            lock.unlock()
            return
        }

        let sQuery = """
            UPDATE \(TABLE_WATCH) SET \
                \(FIELD_WATCH_ISMANAGER       )=?, \
                \(FIELD_WATCH_SERIAL          )=?, \
                \(FIELD_WATCH_USERNAME        )=?, \
                \(FIELD_WATCH_USERPHONE       )=?, \
                \(FIELD_WATCH_USERSEX         )=?, \
                \(FIELD_WATCH_USERBIRTH       )=?, \
                \(FIELD_WATCH_USERTALL        )=?, \
                \(FIELD_WATCH_USERWEIGHT      )=?, \
                \(FIELD_WATCH_USERBLOOD       )=?, \
                \(FIELD_WATCH_USERILLHISTORY  )=?, \
                \(FIELD_WATCH_LAT             )=?, \
                \(FIELD_WATCH_LON             )=?, \
                \(FIELD_WATCH_PROVINCE        )=?, \
                \(FIELD_WATCH_CITY            )=?, \
                \(FIELD_WATCH_DISTRICT        )=?, \
                \(FIELD_WATCH_ADDRESS         )=?, \
                \(FIELD_WATCH_SERVICESTART    )=?, \
                \(FIELD_WATCH_SERVICEEND      )=?, \
                \(FIELD_WATCH_NETSTATUS       )=?, \
                \(FIELD_WATCH_CHARGESTATUS    )=?, \
                \(FIELD_WATCH_SOSCONTACTNAME1 )=?, \
                \(FIELD_WATCH_SOSCONTACTNAME2 )=?, \
                \(FIELD_WATCH_SOSCONTACTNAME3 )=?, \
                \(FIELD_WATCH_SOSCONTACTPHONE1)=?, \
                \(FIELD_WATCH_SOSCONTACTPHONE2)=?, \
                \(FIELD_WATCH_SOSCONTACTPHONE3)=?, \
                \(FIELD_WATCH_HEARTRATEHIGH   )=?, \
                \(FIELD_WATCH_HEARTRATELOW    )=?, \
                \(FIELD_WATCH_POSUPDATEMODE   )=?  \
            WHERE \(FIELD_WATCH_ID)=?
        """

        do {
            try db.executeUpdate(
                sQuery,
                values: [
                    model.bIsManager ? 1 : 0,
                    model.sSerial           ,
                    model.sUserName         ,
                    model.sUserPhone        ,
                    model.iUserSex          ,
                    model.sUserBirth        ,
                    model.iUserTall         ,
                    model.iUserWeight       ,
                    model.sUserBlood        ,
                    model.sUserIllHistory   ,
                    model.sLat              ,
                    model.sLon              ,
                    model.sProvince         ,
                    model.sCity             ,
                    model.sDistrict         ,
                    model.sAddress          ,
                    model.sServiceStart     ,
                    model.sServiceEnd       ,
                    model.bNetStatus ? 1 : 0,
                    model.iChargeStatus     ,
                    model.sSosContactName1  ,
                    model.sSosContactName2  ,
                    model.sSosContactName3  ,
                    model.sSosContactPhone1 ,
                    model.sSosContactPhone2 ,
                    model.sSosContactPhone3 ,
                    model.iHeartRateHigh    ,
                    model.iHeartRateLow     ,
                    model.iPosUpdateMode    ,
                    model.iId
                ]
            )
        }
        catch {
            print(error.localizedDescription)
        }
        db.close()
        lock.unlock()
    }


    func deleteWatches() -> Bool {
        var bDeleted = false

        lock.lock()
        if !openDb() {
            lock.unlock()
            return bDeleted
        }

        let sQuery = "DELETE FROM \(TABLE_WATCH)"

        do {
            try db.executeUpdate(sQuery, values: nil)
            bDeleted = true
        }
        catch {
            print(error.localizedDescription)
        }

        db.close()
        lock.unlock()

        return bDeleted
    }


    func deleteWatch(id: Int) -> Bool {
        var bDeleted = false

        lock.lock()
        if !openDb() {
            lock.unlock()
            return bDeleted
        }

        let sQuery = "DELETE FROM \(TABLE_WATCH) WHERE \(FIELD_WATCH_ID)=?"

        do {
            try db.executeUpdate(sQuery, values: [id])
            bDeleted = true
        }
        catch {
            print(error.localizedDescription)
        }

        db.close()
        lock.unlock()

        return bDeleted
    }


    //-- Sensor
    func createTableSensor() -> Bool {
        var bCreated = true

        let sQueryCreateTable = """
            CREATE TABLE \(TABLE_SENSOR) ( \
                \(FIELD_SENSOR_ID           ) INTEGER PRIMARY KEY NOT NULL, \
                \(FIELD_SENSOR_ISMANAGER    ) INTEGER      , \
                \(FIELD_SENSOR_TYPE         ) TEXT NOT NULL, \
                \(FIELD_SENSOR_SERIAL       ) TEXT NOT NULL, \
                \(FIELD_SENSOR_NETSTATUS    ) INTEGER      , \
                \(FIELD_SENSOR_BATTERYSTATUS) INTEGER      , \
                \(FIELD_SENSOR_ALARMSTATUS  ) INTEGER      , \
                \(FIELD_SENSOR_LABEL        ) TEXT NOT NULL, \
                \(FIELD_SENSOR_CONTACTNAME  ) TEXT NOT NULL, \
                \(FIELD_SENSOR_CONTACTPHONE ) TEXT NOT NULL, \
                \(FIELD_SENSOR_LAT          ) TEXT NOT NULL, \
                \(FIELD_SENSOR_LON          ) TEXT NOT NULL, \
                \(FIELD_SENSOR_PROVINCE     ) TEXT NOT NULL, \
                \(FIELD_SENSOR_CITY         ) TEXT NOT NULL, \
                \(FIELD_SENSOR_DISTRICT     ) TEXT NOT NULL, \
                \(FIELD_SENSOR_ADDRESS      ) TEXT NOT NULL, \
                \(FIELD_SENSOR_SERVICESTART ) TEXT NOT NULL, \
                \(FIELD_SENSOR_SERVICEEND   ) TEXT NOT NULL  \
            )
        """

        do {
            try db.executeUpdate(sQueryCreateTable, values: nil)
        }
        catch {
            print("Failed to create table \(TABLE_SENSOR).")
            bCreated = false
        }
        return bCreated
    }


    func loadSensors(type: DeviceType) -> [ModelSensor] {
        var models: [ModelSensor] = [ModelSensor]()
        let sType: String = type == .FireSensor
            ? Config.PREFIX_FIRESENSOR
            : Config.PREFIX_SMOKESENSOR

        lock.lock()
        if !openDb() {
            lock.unlock()
            return models
        }

        let sQuery = "SELECT * FROM \(TABLE_SENSOR) WHERE \(FIELD_SENSOR_TYPE) LIKE '\(sType)' ORDER BY \(FIELD_SENSOR_ID) ASC"

        do {
            let result = try db.executeQuery(sQuery, values: nil)

            while result.next() {
                let model = ModelSensor()
                model.bIsManager     =     result.int(   forColumn: FIELD_SENSOR_ISMANAGER    ) == 1 ? true : false
                model.iId            = Int(result.int(   forColumn: FIELD_SENSOR_ID           ))
                model.sType          =     result.string(forColumn: FIELD_SENSOR_TYPE         ) ?? ""
                model.sSerial        =     result.string(forColumn: FIELD_SENSOR_SERIAL       ) ?? ""
                model.bNetStatus     =     result.int(   forColumn: FIELD_SENSOR_NETSTATUS    ) == 1 ? true : false
                model.bBatteryStatus =     result.int(   forColumn: FIELD_SENSOR_BATTERYSTATUS) == 1 ? true : false
                model.bAlarmStatus   =     result.int(   forColumn: FIELD_SENSOR_ALARMSTATUS  ) == 1 ? true : false
                model.sLabel         =     result.string(forColumn: FIELD_SENSOR_LABEL        ) ?? ""
                model.sContactName   =     result.string(forColumn: FIELD_SENSOR_CONTACTNAME  ) ?? ""
                model.sContactPhone  =     result.string(forColumn: FIELD_SENSOR_CONTACTPHONE ) ?? ""
                model.sLat           =     result.string(forColumn: FIELD_SENSOR_LAT          ) ?? ""
                model.sLon           =     result.string(forColumn: FIELD_SENSOR_LON          ) ?? ""
                model.sProvince      =     result.string(forColumn: FIELD_SENSOR_PROVINCE     ) ?? ""
                model.sCity          =     result.string(forColumn: FIELD_SENSOR_CITY         ) ?? ""
                model.sDistrict      =     result.string(forColumn: FIELD_SENSOR_DISTRICT     ) ?? ""
                model.sAddress       =     result.string(forColumn: FIELD_SENSOR_ADDRESS      ) ?? ""
                model.sServiceStart  =     result.string(forColumn: FIELD_SENSOR_SERVICESTART ) ?? ""
                model.sServiceEnd    =     result.string(forColumn: FIELD_SENSOR_SERVICEEND   ) ?? ""

                models.append(model)
            }
        }
        catch {
            print(error.localizedDescription)
        }

        db.close()
        lock.unlock()
        return models
    }


    func insertSensor(model: ModelSensor) -> Bool {
        lock.lock()
        if !openDb() {
            lock.unlock()
            return false
        }

        let sQuery = """
            INSERT INTO \(TABLE_SENSOR) ( \
                \(FIELD_SENSOR_ISMANAGER    ), \
                \(FIELD_SENSOR_ID           ), \
                \(FIELD_SENSOR_TYPE         ), \
                \(FIELD_SENSOR_SERIAL       ), \
                \(FIELD_SENSOR_NETSTATUS    ), \
                \(FIELD_SENSOR_BATTERYSTATUS), \
                \(FIELD_SENSOR_ALARMSTATUS  ), \
                \(FIELD_SENSOR_LABEL        ), \
                \(FIELD_SENSOR_CONTACTNAME  ), \
                \(FIELD_SENSOR_CONTACTPHONE ), \
                \(FIELD_SENSOR_LAT          ), \
                \(FIELD_SENSOR_LON          ), \
                \(FIELD_SENSOR_PROVINCE     ), \
                \(FIELD_SENSOR_CITY         ), \
                \(FIELD_SENSOR_DISTRICT     ), \
                \(FIELD_SENSOR_ADDRESS      ), \
                \(FIELD_SENSOR_SERVICESTART ), \
                \(FIELD_SENSOR_SERVICEEND   )  \
            ) \
            VALUES ( \
                 \(model.bIsManager     ? 1 : 0) , \
                 \(model.iId                   ) , \
                '\(model.sType                 )', \
                '\(model.sSerial               )', \
                 \(model.bNetStatus     ? 1 : 0) , \
                 \(model.bBatteryStatus ? 1 : 0) , \
                 \(model.bAlarmStatus   ? 1 : 0) , \
                '\(model.sLabel                )', \
                '\(model.sContactName          )', \
                '\(model.sContactPhone         )', \
                '\(model.sLat                  )', \
                '\(model.sLon                  )', \
                '\(model.sProvince             )', \
                '\(model.sCity                 )', \
                '\(model.sDistrict             )', \
                '\(model.sAddress              )', \
                '\(model.sServiceStart         )', \
                '\(model.sServiceEnd           )'  \
            );
        """

        if !db.executeStatements(sQuery) {
            print("Failed to insert data.")
            print(db.lastError(), db.lastErrorMessage())
            db.close()
            lock.unlock()
            return false
        }

        db.close()
        lock.unlock()
        return true
    }


    func updateSensor(model: ModelSensor) {
        lock.lock()
        if !openDb() {
            lock.unlock()
            return
        }

        let sQuery = """
            UPDATE \(TABLE_SENSOR) SET \
                \(FIELD_SENSOR_ISMANAGER    )=?, \
                \(FIELD_SENSOR_TYPE         )=?, \
                \(FIELD_SENSOR_SERIAL       )=?, \
                \(FIELD_SENSOR_NETSTATUS    )=?, \
                \(FIELD_SENSOR_BATTERYSTATUS)=?, \
                \(FIELD_SENSOR_ALARMSTATUS  )=?, \
                \(FIELD_SENSOR_LABEL        )=?, \
                \(FIELD_SENSOR_CONTACTNAME  )=?, \
                \(FIELD_SENSOR_CONTACTPHONE )=?, \
                \(FIELD_SENSOR_LAT          )=?, \
                \(FIELD_SENSOR_LON          )=?, \
                \(FIELD_SENSOR_PROVINCE     )=?, \
                \(FIELD_SENSOR_CITY         )=?, \
                \(FIELD_SENSOR_DISTRICT     )=?, \
                \(FIELD_SENSOR_ADDRESS      )=?, \
                \(FIELD_SENSOR_SERVICESTART )=?, \
                \(FIELD_SENSOR_SERVICEEND   )=?  \
            WHERE \(FIELD_SENSOR_ID)=?
        """

        do {
            try db.executeUpdate(
                sQuery,
                values: [
                    model.bIsManager     ? 1 : 0,
                    model.sType                 ,
                    model.sSerial               ,
                    model.bNetStatus     ? 1 : 0,
                    model.bBatteryStatus ? 1 : 0,
                    model.bAlarmStatus   ? 1 : 0,
                    model.sLabel                ,
                    model.sContactName          ,
                    model.sContactPhone         ,
                    model.sLat                  ,
                    model.sLon                  ,
                    model.sProvince             ,
                    model.sCity                 ,
                    model.sDistrict             ,
                    model.sAddress              ,
                    model.sServiceStart         ,
                    model.sServiceEnd           ,
                    model.iId
                ]
            )
        }
        catch {
            print(error.localizedDescription)
        }
        db.close()
        lock.unlock()
    }


    func deleteSensors() -> Bool {
        var bDeleted = false
        lock.lock()
        if !openDb() {
            lock.unlock()
            return bDeleted
        }

        let sQuery = "DELETE FROM \(TABLE_SENSOR)"

        do {
            try db.executeUpdate(sQuery, values: nil)
            bDeleted = true
        }
        catch {
            print(error.localizedDescription)
        }

        db.close()
        lock.unlock()
        return bDeleted
    }


    func deleteSensor(id: Int) -> Bool {
        var bDeleted = false

        lock.lock()
        if !openDb() {
            lock.unlock()
            return bDeleted
        }

        let sQuery = "DELETE FROM \(TABLE_SENSOR) WHERE \(FIELD_SENSOR_ID)=?"

        do {
            try db.executeUpdate(sQuery, values: [id])
            bDeleted = true
        }
        catch {
            print(error.localizedDescription)
        }

        db.close()
        lock.unlock()

        return bDeleted
    }


    //-- Heart Rate
    func createTableRate() -> Bool {
        var bCreated = true

        let sQueryCreateTable = """
            CREATE TABLE \(TABLE_RATE) ( \
                \(FIELD_RATE_UID  ) TEXT PRIMARY KEY NOT NULL, \
                \(FIELD_RATE_WATCH) INTEGER      , \
                \(FIELD_RATE_DATE ) TEXT NOT NULL, \
                \(FIELD_RATE_TIME ) TEXT NOT NULL, \
                \(FIELD_RATE_VALUE) INTEGER        \
            )
        """

        do {
            try db.executeUpdate(sQueryCreateTable, values: nil)
        }
        catch {
            print("Failed to create table \(TABLE_RATE).")
            bCreated = false
        }
        return bCreated
    }


    func loadRates() -> [ModelRate] {
        var models: [ModelRate] = [ModelRate]()

        lock.lock()
        if !openDb() {
            lock.unlock()
            return models
        }

        let sQuery = "SELECT * FROM \(TABLE_RATE) ORDER BY \(FIELD_RATE_UID) ASC"

        do {
            let result = try db.executeQuery(sQuery, values: nil)

            while result.next() {
                let model = ModelRate()
                model.sUid   =     result.string(forColumn: FIELD_RATE_UID  ) ?? ""
                model.iWatch = Int(result.int(   forColumn: FIELD_RATE_WATCH))
                model.sDate  =     result.string(forColumn: FIELD_RATE_DATE ) ?? ""
                model.sTime  =     result.string(forColumn: FIELD_RATE_TIME ) ?? ""
                model.iValue = Int(result.int(   forColumn: FIELD_RATE_VALUE))

                models.append(model)
            }
        }
        catch {
            print(error.localizedDescription)
        }

        db.close()
        lock.unlock()

        return models
    }


    func loadRates(date: String) -> [ModelRate] {
        var models: [ModelRate] = [ModelRate]()

        lock.lock()
        if !openDb() {
            lock.unlock()
            return models
        }

        let sQuery = "SELECT * FROM \(TABLE_RATE) WHERE \(FIELD_RATE_DATE) LIKE '\(date)' ORDER BY \(FIELD_RATE_TIME) ASC"

        do {
            let result = try db.executeQuery(sQuery, values: nil)

            while result.next() {
                let model = ModelRate()
                model.sUid   =     result.string(forColumn: FIELD_RATE_UID  ) ?? ""
                model.iWatch = Int(result.int(   forColumn: FIELD_RATE_WATCH))
                model.sDate  =     result.string(forColumn: FIELD_RATE_DATE ) ?? ""
                model.sTime  =     result.string(forColumn: FIELD_RATE_TIME ) ?? ""
                model.iValue = Int(result.int(   forColumn: FIELD_RATE_VALUE))

                models.append(model)
            }
        }
        catch {
            print(error.localizedDescription)
        }

        db.close()
        lock.unlock()
        return models
    }


    func insertRate(model: ModelRate) -> Bool {
        lock.lock()
        if !openDb() {
            lock.unlock()
            return false
        }

        let sQuery = """
            INSERT INTO \(TABLE_RATE) ( \
                \(FIELD_RATE_UID  ), \
                \(FIELD_RATE_WATCH), \
                \(FIELD_RATE_DATE ), \
                \(FIELD_RATE_TIME ), \
                \(FIELD_RATE_VALUE)  \
            ) \
            VALUES ( \
                '\(model.sUid  )', \
                 \(model.iWatch) , \
                '\(model.sDate )', \
                '\(model.sTime )', \
                 \(model.iValue)   \
            );
        """

        if !db.executeStatements(sQuery) {
            print("Failed to insert data.")
            print(db.lastError(), db.lastErrorMessage())
            db.close()
            lock.unlock()
            return false
        }

        db.close()
        lock.unlock()
        return true
    }


    func updateRate(model: ModelRate) {
        lock.lock()
        if !openDb() {
            lock.unlock()
            return
        }

        let sQuery = """
            UPDATE \(TABLE_RATE) SET \
                \(FIELD_RATE_WATCH)=?, \
                \(FIELD_RATE_DATE )=?, \
                \(FIELD_RATE_TIME )=?, \
                \(FIELD_RATE_VALUE)=?  \
            WHERE \(FIELD_RATE_UID) LIKE '\(model.sUid)'
        """

        do {
            try db.executeUpdate(
                sQuery,
                values: [
                    model.iWatch,
                    model.sDate ,
                    model.sTime ,
                    model.iValue
                ]
            )
        }
        catch {
            print(error.localizedDescription)
        }
        db.close()
        lock.unlock()
    }


    func deleteRates() -> Bool {
        var bDeleted = false

        lock.lock()
        if !openDb() {
            lock.unlock()
            return bDeleted
        }

        let sQuery = "DELETE FROM \(TABLE_RATE)"

        do {
            try db.executeUpdate(sQuery, values: nil)
            bDeleted = true
        }
        catch {
            print(error.localizedDescription)
        }

        db.close()
        lock.unlock()

        return bDeleted
    }


    func deleteRate(uid: String) -> Bool {
        var bDeleted = false

        lock.lock()
        if !openDb() {
            lock.unlock()
            return bDeleted
        }

        let sQuery = "DELETE FROM \(TABLE_RATE) WHERE \(FIELD_RATE_UID) LIKE '\(uid)'"

        do {
            try db.executeUpdate(sQuery, values: nil)
            bDeleted = true
        }
        catch {
            print(error.localizedDescription)
        }

        db.close()
        lock.unlock()

        return bDeleted
    }


    //-- News
    func createTableNews() -> Bool {
        var bCreated = true

        let sQueryCreateTable = """
            CREATE TABLE \(TABLE_NEWS) ( \
                \(FIELD_NEWS_ID     ) INTEGER PRIMARY KEY NOT NULL, \
                \(FIELD_NEWS_TITLE  ) TEXT NOT NULL, \
                \(FIELD_NEWS_BRANCH ) TEXT NOT NULL, \
                \(FIELD_NEWS_PICTURE) TEXT NOT NULL, \
                \(FIELD_NEWS_CONTENT) TEXT NOT NULL, \
                \(FIELD_NEWS_TIME   ) TEXT NOT NULL, \
                \(FIELD_NEWS_READ   ) INTEGER \
            )
        """

        do {
            try db.executeUpdate(sQueryCreateTable, values: nil)
        }
        catch {
            print("Failed to create table \(TABLE_NEWS).")
            bCreated = false
        }
        return bCreated
    }


    func loadNews() -> [ModelNews] {
        var models: [ModelNews] = [ModelNews]()

        lock.lock()
        if !openDb() {
            lock.unlock()
            return models
        }

        let sQuery = "SELECT * FROM \(TABLE_NEWS) ORDER BY \(FIELD_NEWS_TIME) DESC"

        do {
            let result = try db.executeQuery(sQuery, values: nil)

            while result.next() {
                let model = ModelNews(
                    id     : Int(result.int(forColumn: FIELD_NEWS_ID)),
                    title  : result.string( forColumn: FIELD_NEWS_TITLE  ) ?? "",
                    branch : result.string( forColumn: FIELD_NEWS_BRANCH ) ?? "",
                    picture: result.string( forColumn: FIELD_NEWS_PICTURE) ?? "",
                    content: result.string( forColumn: FIELD_NEWS_CONTENT) ?? "",
                    time   : result.string( forColumn: FIELD_NEWS_TIME   ) ?? "",
                    read   : Int(result.int(forColumn: FIELD_NEWS_READ))
                )

                models.append(model)
            }
        }
        catch {
            print(error.localizedDescription)
        }

        db.close()
        lock.unlock()

        return models
    }


    func loadNews(branch: String) -> [ModelNews] {
        var models: [ModelNews] = [ModelNews]()

        lock.lock()
        if !openDb() {
            lock.unlock()
            return models
        }

        let sQuery = "SELECT * FROM \(TABLE_NEWS) WHERE \(FIELD_NEWS_BRANCH) LIKE '\(branch)' ORDER BY \(FIELD_NEWS_TIME) DESC"

        do {
            let result = try db.executeQuery(sQuery, values: nil)

            while result.next() {
                let model = ModelNews(
                    id     : Int(result.int(forColumn: FIELD_NEWS_ID)),
                    title  : result.string( forColumn: FIELD_NEWS_TITLE  ) ?? "",
                    branch : result.string( forColumn: FIELD_NEWS_BRANCH ) ?? "",
                    picture: result.string( forColumn: FIELD_NEWS_PICTURE) ?? "",
                    content: result.string( forColumn: FIELD_NEWS_CONTENT) ?? "",
                    time   : result.string( forColumn: FIELD_NEWS_TIME   ) ?? "",
                    read   : Int(result.int(forColumn: FIELD_NEWS_READ))
                )

                models.append(model)
            }
        }
        catch {
            print(error.localizedDescription)
        }

        db.close()
        lock.unlock()

        return models
    }


    func insertNews(model: ModelNews) {
        lock.lock()
        if !openDb() {
            lock.unlock()
            return
        }

        let sQuery = """
            INSERT INTO \(TABLE_NEWS) ( \
                \(FIELD_NEWS_ID     ), \
                \(FIELD_NEWS_TITLE  ), \
                \(FIELD_NEWS_BRANCH ), \
                \(FIELD_NEWS_PICTURE), \
                \(FIELD_NEWS_CONTENT), \
                \(FIELD_NEWS_TIME   ), \
                \(FIELD_NEWS_READ   )  \
            ) \
            VALUES ( \
                 \(model.iId     ) , \
                '\(model.sTitle  )', \
                '\(model.sBranch )', \
                '\(model.sPicture)', \
                '\(model.sContent)', \
                '\(model.sTime   )', \
                 \(model.iRead   )  \
            );
        """

        if !db.executeStatements(sQuery) {
            print("Failed to insert data.")
            print(db.lastError(), db.lastErrorMessage())
        }

        db.close()
        lock.unlock()
    }


    func updateNews(model: ModelNews) {
        lock.lock()
        if !openDb() {
            lock.unlock()
            return
        }

        let sQuery = """
            UPDATE \(TABLE_NEWS) SET \
                \(FIELD_NEWS_TITLE  )=?, \
                \(FIELD_NEWS_BRANCH )=?, \
                \(FIELD_NEWS_PICTURE)=?, \
                \(FIELD_NEWS_CONTENT)=?, \
                \(FIELD_NEWS_TIME   )=?, \
                \(FIELD_NEWS_READ   )=?  \
            WHERE \(FIELD_NEWS_ID)=?
        """

        do {
            try db.executeUpdate(
                sQuery,
                values: [
                    model.sTitle,
                    model.sBranch,
                    model.sPicture,
                    model.sContent,
                    model.sTime,
                    model.iRead,
                    model.iId
                ]
            )
        }
        catch {
            print(error.localizedDescription)
        }
        db.close()
        lock.unlock()
    }


    func deleteNews(id: Int) -> Bool {
        var bDeleted = false

        lock.lock()
        if !openDb() {
            lock.unlock()
            return bDeleted
        }

        let sQuery = "DELETE FROM \(TABLE_NEWS) WHERE \(FIELD_NEWS_ID)=?"

        do {
            try db.executeUpdate(sQuery, values: [id])
            bDeleted = true
        }
        catch {
            print(error.localizedDescription)
        }

        db.close()
        lock.unlock()

        return bDeleted
    }


    //-- Message
    func createTableMessage() -> Bool {
        var bCreated = true

        let sQueryCreateTable = """
            CREATE TABLE \(TABLE_MESSAGE) ( \
                \(FIELD_MESSAGE_ID      ) INTEGER PRIMARY KEY NOT NULL, \
                \(FIELD_MESSAGE_CATEGORY) TEXT NOT NULL, \
                \(FIELD_MESSAGE_BODY    ) TEXT NOT NULL, \
                \(FIELD_MESSAGE_DATA    ) TEXT NOT NULL, \
                \(FIELD_MESSAGE_TIME    ) TEXT NOT NULL, \
                \(FIELD_MESSAGE_READ    ) INTEGER \
            )
        """

        do {
            try db.executeUpdate(sQueryCreateTable, values: nil)
        }
        catch {
            print("Failed to create table \(TABLE_MESSAGE).")
            bCreated = false
        }
        return bCreated
    }


    func loadMessages() -> [ModelMessage] {
        var models: [ModelMessage] = [ModelMessage]()

        lock.lock()
        if !openDb() {
            lock.unlock()
            return models
        }

        let sQuery = "SELECT * FROM \(TABLE_MESSAGE) ORDER BY \(FIELD_MESSAGE_TIME) DESC"

        do {
            let result = try db.executeQuery(sQuery, values: nil)

            while result.next() {
                let model = ModelMessage(
                    id      : Int(result.int(forColumn: FIELD_MESSAGE_ID)),
                    category: result.string( forColumn: FIELD_MESSAGE_CATEGORY) ?? "",
                    body    : result.string( forColumn: FIELD_MESSAGE_BODY    ) ?? "",
                    data    : result.string( forColumn: FIELD_MESSAGE_DATA    ) ?? "",
                    time    : result.string( forColumn: FIELD_MESSAGE_TIME    ) ?? "",
                    read    : Int(result.int(forColumn: FIELD_MESSAGE_READ))
                )

                models.append(model)
            }
        }
        catch {
            print(error.localizedDescription)
        }
        db.close()
        lock.unlock()
        return models
    }


    func loadMessageLast() -> ModelMessage {
        var model = ModelMessage()

        lock.lock()
        if !openDb() {
            lock.unlock()
            return model
        }

        let sQuery = "SELECT * FROM \(TABLE_MESSAGE) ORDER BY \(FIELD_MESSAGE_ID) DESC LIMIT 1"
        do {
            let result = try db.executeQuery(sQuery, values: nil)

            while result.next() {
                model = ModelMessage(
                    id      : Int(result.int(forColumn: FIELD_MESSAGE_ID)),
                    category: result.string( forColumn: FIELD_MESSAGE_CATEGORY) ?? "",
                    body    : result.string( forColumn: FIELD_MESSAGE_BODY    ) ?? "",
                    data    : result.string( forColumn: FIELD_MESSAGE_DATA    ) ?? "",
                    time    : result.string( forColumn: FIELD_MESSAGE_TIME    ) ?? "",
                    read    : Int(result.int(forColumn: FIELD_MESSAGE_READ))
                )
                db.close()
                lock.unlock()
                return model
            }
        }
        catch {
            print(error.localizedDescription)
        }
        db.close()
        lock.unlock()

        return model
    }


    func insertMessage(model: ModelMessage) {
        lock.lock()
        if !openDb() {
            lock.unlock()
            return
        }

        model.sBody = model.sBody.replacingOccurrences(of: "\'", with: "")  /// Errors could be occured by "'"

        let sQuery = """
            INSERT INTO \(TABLE_MESSAGE) ( \
                \(FIELD_MESSAGE_ID      ), \
                \(FIELD_MESSAGE_CATEGORY), \
                \(FIELD_MESSAGE_BODY    ), \
                \(FIELD_MESSAGE_DATA    ), \
                \(FIELD_MESSAGE_TIME    ), \
                \(FIELD_MESSAGE_READ    )  \
            ) \
            VALUES ( \
                 null               , \
                '\(model.sCategory)', \
                '\(model.sBody    )', \
                '\(model.sData    )', \
                '\(model.sTime    )', \
                 \(model.iRead    )   \
            );
        """

        if !db.executeStatements(sQuery) {
            print("Failed to insert data.")
            print(db.lastError(), db.lastErrorMessage())
        }
        db.close()
        lock.unlock()
    }


    func updateMessage(model: ModelMessage) {
        lock.lock()
        if !openDb() {
            lock.unlock()
            return
        }

        let sQuery = """
            UPDATE \(TABLE_MESSAGE) SET \
                \(FIELD_MESSAGE_CATEGORY)=?, \
                \(FIELD_MESSAGE_BODY    )=?, \
                \(FIELD_MESSAGE_DATA    )=?, \
                \(FIELD_MESSAGE_TIME    )=?, \
                \(FIELD_MESSAGE_READ    )=?  \
            WHERE \(FIELD_MESSAGE_ID)=?
        """

        do {
            try db.executeUpdate(
                sQuery,
                values: [
                    model.sCategory,
                    model.sBody,
                    model.sData,
                    model.sTime,
                    model.iRead,
                    model.iId
                ]
            )
        }
        catch {
            print(error.localizedDescription)
        }
        db.close()
        lock.unlock()
    }


    func deleteMessage(id: Int) -> Bool {
        var bDeleted = false

        lock.lock()
        if !openDb() {
            lock.unlock()
            return bDeleted
        }

        let sQuery = "DELETE FROM \(TABLE_MESSAGE) WHERE \(FIELD_MESSAGE_ID)=?"

        do {
            try db.executeUpdate(sQuery, values: [id])
            bDeleted = true
        }
        catch {
            print(error.localizedDescription)
        }
        db.close()
        lock.unlock()

        return bDeleted
    }


    func countMessageUnread() -> Int {
        lock.lock()
        if !openDb() {
            lock.unlock()
            return 0
        }

        let sQuery = "SELECT COUNT(*) FROM \(TABLE_MESSAGE) WHERE \(FIELD_MESSAGE_READ) = 0"
        do {
            let result = try db.executeQuery(sQuery, values: nil)

            while result.next() {
                let count = Int(result.int(forColumnIndex: 0))
                db.close()
                lock.unlock()
                return count
            }
        }
        catch {
            print(error.localizedDescription)
        }
        db.close()
        lock.unlock()

        return 0
    }

}
