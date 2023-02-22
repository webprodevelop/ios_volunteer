import Foundation


class API {

    enum ApiError: LocalizedError {
        case errNoUrl
        case errNoData

        var description: String? {
            switch self {
                case .errNoUrl : return "Url is not supported"
                case .errNoData: return "No data".localized()
            }
        }
    }

    static let instance: API = API()

    private lazy var defaultSession = URLSession(configuration: .default)


    private init() {}


    func getWeatherInfo(completion: @escaping (Result<Data?, ApiError>) -> Void) {
        var requestUrl: URLRequest
        let header: [String:String] = ["Content-Type":Config.HTTP_TYPE_CONTENT]

        requestUrl = URLRequest(url: URL(string: Config.URL_WEATHER)!)
        requestUrl.httpMethod = "POST"
        requestUrl.allHTTPHeaderFields = header

        defaultSession.dataTask(with: requestUrl) { data, response, _ in
            if let response = response as? HTTPURLResponse,
                (200..<300).contains(response.statusCode)
            {
                completion(.success(data))
            }
            else {
                completion(.failure(.errNoData))
            }
        }.resume()
    }


    func geoConv(stReq: StReqGeoConv, completion: @escaping (Result<StRspGeoConv, ApiError>) -> Void) {
        let request = RequestPost<StRspGeoConv>(
            url       : Config.URL_GEOCONV,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func getAppInfo(stReq: StReqGetAppInfo, completion: @escaping (Result<StRspGetAppInfo, ApiError>) -> Void) {
        let request = RequestPost<StRspGetAppInfo>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func login(stReq: StReqLogin, completion: @escaping (Result<StRspLogin, ApiError>) -> Void) {
        let request = RequestPost<StRspLogin>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func getCode(stReq: StReqCode, completion: @escaping (Result<StRspCode, ApiError>) -> Void) {
        let request = RequestPost<StRspCode>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func getUpdateUserInfoCode(stReq: StReqUpdateUserInfoCode, completion: @escaping (Result<StRspUpdateUserInfoCode, ApiError>) -> Void) {
        let request = RequestPost<StRspUpdateUserInfoCode>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func register(stReq: StReqRegister, completion: @escaping (Result<StRspRegister, ApiError>) -> Void) {
        let request = RequestPost<StRspRegister>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func forgot(stReq: StReqForgot, completion: @escaping (Result<StRspForgot, ApiError>) -> Void) {
        let request = RequestPost<StRspForgot>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func resetPassword(stReq: StReqResetPassword, completion: @escaping (Result<StRspResetPassword, ApiError>) -> Void) {
        let request = RequestPost<StRspResetPassword>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func getUserInfo(stReq: StReqGetUserInfo, completion: @escaping (Result<StRspGetUserInfo, ApiError>) -> Void) {
        let request = RequestPost<StRspGetUserInfo>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func updateUserInfo(stReq: StReqUpdateUserInfo, completion: @escaping (Result<StRspUpdateUserInfo, ApiError>) -> Void) {
        let request = RequestPost<StRspUpdateUserInfo>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func getNewsList(stReq: StReqGetNewsList, completion: @escaping (Result<StRspGetNewsList, ApiError>) -> Void) {
        let request = RequestPost<StRspGetNewsList>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func getNewsInfo(stReq: StReqGetNewsInfo, completion: @escaping (Result<StRspGetNewsInfo, ApiError>) -> Void) {
        let request = RequestPost<StRspGetNewsInfo>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func setSosContact(stReq: StReqSetSosContact, completion: @escaping (Result<StRspSetSosContact, ApiError>) -> Void) {
        let request = RequestPost<StRspSetSosContact>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func getWatchSetInfo(stReq: StReqGetWatchSetInfo, completion: @escaping (Result<StRspGetWatchSetInfo, ApiError>) -> Void) {
        let request = RequestPost<StRspGetWatchSetInfo>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func registerWatch(stReq: StReqRegisterWatch, completion: @escaping (Result<StRspRegisterWatch, ApiError>) -> Void) {
        let request = RequestPost<StRspRegisterWatch>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func registerSensor(stReq: StReqRegisterSensor, completion: @escaping (Result<StRspRegisterSensor, ApiError>) -> Void) {
        let request = RequestPost<StRspRegisterSensor>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func setWatchInfo(stReq: StReqSetWatchInfo, completion: @escaping (Result<StRspSetWatchInfo, ApiError>) -> Void) {
        let request = RequestPost<StRspSetWatchInfo>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func setSensorInfo(stReq: StReqSetSensorInfo, completion: @escaping (Result<StRspSetSensorInfo, ApiError>) -> Void) {
        let request = RequestPost<StRspSetSensorInfo>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func getWatchList(stReq: StReqGetWatchList, completion: @escaping (Result<StRspGetWatchList, ApiError>) -> Void) {
        let request = RequestPost<StRspGetWatchList>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func getSensorList(stReq: StReqGetSensorList, completion: @escaping (Result<StRspGetSensorList, ApiError>) -> Void) {
        let request = RequestPost<StRspGetSensorList>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func delWatch(stReq: StReqDelWatch, completion: @escaping (Result<StRspDelWatch, ApiError>) -> Void) {
        let request = RequestPost<StRspDelWatch>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func delSensor(stReq: StReqDelSensor, completion: @escaping (Result<StRspDelSensor, ApiError>) -> Void) {
        let request = RequestPost<StRspDelSensor>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func setHeartRate(stReq: StReqSetHeartRate, completion: @escaping (Result<StRspSetHeartRate, ApiError>) -> Void) {
        let request = RequestPost<StRspSetHeartRate>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func setMobile(stReq: StReqSetMobile, completion: @escaping (Result<StRspSetMobile, ApiError>) -> Void) {
        let request = RequestPost<StRspSetMobile>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func getHeartRateRecent(stReq: StReqGetHeartRateRecent, completion: @escaping (Result<StRspGetHeartRateRecent, ApiError>) -> Void) {
        let request = RequestPost<StRspGetHeartRateRecent>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func getHeartRateHistory(stReq: StReqGetHeartRateHistory, completion: @escaping (Result<StRspGetHeartRateHistory, ApiError>) -> Void) {
        let request = RequestPost<StRspGetHeartRateHistory>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func getAlarmSetInfo(stReq: StReqGetAlarmSetInfo, completion: @escaping (Result<StRspGetAlarmSetInfo, ApiError>) -> Void) {
        let request = RequestPost<StRspGetAlarmSetInfo>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func setAlarmSetInfo(stReq: StReqSetAlarmSetInfo, completion: @escaping (Result<StRspSetAlarmSetInfo, ApiError>) -> Void) {
        let request = RequestPost<StRspSetAlarmSetInfo>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func requestPaidService(stReq: StReqRequestPaidService, completion: @escaping (Result<StRspRequestPaidService, ApiError>) -> Void) {
        let request = RequestPost<StRspRequestPaidService>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func inquirePaidService(stReq: StReqInquirePaidService, completion: @escaping (Result<StRspInquirePaidService, ApiError>) -> Void) {
        let request = RequestPost<StRspInquirePaidService>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func cancelPaidService(stReq: StReqCancelPaidService, completion: @escaping (Result<StRspCancelPaidService, ApiError>) -> Void) {
        let request = RequestPost<StRspCancelPaidService>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func getWatchPos(stReq: StReqGetWatchPos, completion: @escaping (Result<StRspGetWatchPos, ApiError>) -> Void) {
        let request = RequestPost<StRspGetWatchPos>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func getWatchPosList(stReq: StReqGetWatchPosList, completion: @escaping (Result<StRspGetWatchPosList, ApiError>) -> Void) {
        let request = RequestPost<StRspGetWatchPosList>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func getElecFenceInfo(stReq: StReqGetElecFenceInfo, completion: @escaping (Result<StRspGetElecFenceInfo, ApiError>) -> Void) {
        let request = RequestPost<StRspGetElecFenceInfo>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func setElecFenceInfo(stReq: StReqSetElecFenceInfo, completion: @escaping (Result<StRspSetElecFenceInfo, ApiError>) -> Void) {
        let request = RequestPost<StRspSetElecFenceInfo>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func setPosUpdateMode(stReq: StReqSetPosUpdateMode, completion: @escaping (Result<StRspSetPosUpdateMode, ApiError>) -> Void) {
        let request = RequestPost<StRspSetPosUpdateMode>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func getTaskDetail(stReq: StReqGetTaskDetail, completion: @escaping (Result<StRspGetTaskDetail, ApiError>) -> Void) {
        let request = RequestPost<StRspGetTaskDetail>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func acceptTask(stReq: StReqAcceptTask, completion: @escaping (Result<StRspAcceptTask, ApiError>) -> Void) {
        let request = RequestPost<StRspAcceptTask>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func finishTask(stReq: StReqFinishTask, completion: @escaping (Result<StRspFinishTask, ApiError>) -> Void) {
        let request = RequestPost<StRspFinishTask>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func cancelTask(stReq: StReqCancelTask, completion: @escaping (Result<StRspCancelTask, ApiError>) -> Void) {
        let request = RequestPost<StRspCancelTask>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func getIdCardFrontInfo(stReq: StReqGetIdCardFrontInfo, completion: @escaping (Result<StRspGetIdCardFrontInfo, ApiError>) -> Void) {
        let request = RequestPost<StRspGetIdCardFrontInfo>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }



    func getPointRule(stReq: StReqGetPointRule, completion: @escaping (Result<StRspGetPointRule, ApiError>) -> Void) {
        let request = RequestPost<StRspGetPointRule>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func getFinancialList(stReq: StReqGetFinancialList, completion: @escaping (Result<StRspGetFinancialList, ApiError>) -> Void) {
        let request = RequestPost<StRspGetFinancialList>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func getRescueList(stReq: StReqGetRescueList, completion: @escaping (Result<StRspGetRescueList, ApiError>) -> Void) {
        let request = RequestPost<StRspGetRescueList>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func getRescueDetail(stReq: StReqGetRescueDetail, completion: @escaping (Result<StRspGetRescueDetail, ApiError>) -> Void) {
        let request = RequestPost<StRspGetRescueDetail>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func registerBankCard(stReq: StReqRegisterBankCard, completion: @escaping (Result<StRspRegisterBankCard, ApiError>) -> Void) {
        let request = RequestPost<StRspRegisterBankCard>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func modifyBankPassword(stReq: StReqModifyBankPassword, completion: @escaping (Result<StRspModifyBankPassword, ApiError>) -> Void) {
        let request = RequestPost<StRspModifyBankPassword>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func forgotBankPassword(stReq: StReqForgotBankPassword, completion: @escaping (Result<StRspForgotBankPassword, ApiError>) -> Void) {
        let request = RequestPost<StRspForgotBankPassword>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func setUserStatusReady(stReq: StReqSetUserStatusReady, completion: @escaping (Result<StRspSetUserStatusReady, ApiError>) -> Void) {
        let request = RequestPost<StRspSetUserStatusReady>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func setUserStatusDisabled(stReq: StReqSetUserStatusDisabled, completion: @escaping (Result<StRspSetUserStatusDisabled, ApiError>) -> Void) {
        let request = RequestPost<StRspSetUserStatusDisabled>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func getVolunteerStatistics(stReq: StReqGetVolunteerStatistics, completion: @escaping (Result<StRspGetVolunteerStatistics, ApiError>) -> Void) {
        let request = RequestPost<StRspGetVolunteerStatistics>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func updateLocation(stReq: StReqUpdateLocation, completion: @escaping (Result<StRspUpdateLocation, ApiError>) -> Void) {
        let request = RequestPost<StRspUpdateLocation>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func requestChat(stReq: StReqRequestChat, completion: @escaping (Result<StRspRequestChat, ApiError>) -> Void) {
        let request = RequestPost<StRspRequestChat>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func getWechatAccessToken(stReq: StReqWechatAccessToken, completion: @escaping (Result<StRspWechatAccessToken, ApiError>) -> Void) {
        /// Get Method
        let request = RequestPost<StRspWechatAccessToken>(
            url          : Config.URL_WECHAT_ACCESS_TOKEN,
            getParameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func getWechatUserInfo(stReq: StReqWechatUserInfo, completion: @escaping (Result<StRspWechatUserInfo, ApiError>) -> Void) {
        /// Get Method
        let request = RequestPost<StRspWechatUserInfo>(
            url          : Config.URL_WECHAT_USER_INFO,
            getParameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func registerPayAccount(stReq: StReqRegisterPayAccount, completion: @escaping (Result<StRspRegisterPayAccount, ApiError>) -> Void) {
        let request = RequestPost<StRspRegisterPayAccount>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func removePayAccount(stReq: StReqRemovePayAccount, completion: @escaping (Result<StRspRemovePayAccount, ApiError>) -> Void) {
        let request = RequestPost<StRspRemovePayAccount>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func requestTransferPay(stReq: StReqRequestTransferPay, completion: @escaping (Result<StRspRequestTransferPay, ApiError>) -> Void) {
        let request = RequestPost<StRspRequestTransferPay>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }


    func getAllNotificationList(stReq: StReqGetAllNotificationList, completion: @escaping (Result<StRspGetAllNotificationList, ApiError>) -> Void) {
        let request = RequestPost<StRspGetAllNotificationList>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }

    func readNotification(stReq: StReqReadNotification, completion: @escaping (Result<StRspReadNotification, ApiError>) -> Void) {
        let request = RequestPost<StRspReadNotification>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }

    func removeNotification(stReq: StReqRemoveNotification, completion: @escaping (Result<StRspRemoveNotification, ApiError>) -> Void) {
        let request = RequestPost<StRspRemoveNotification>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }

    func readAllNotification(stReq: StReqReadAllNotification, completion: @escaping (Result<StRspReadAllNotification, ApiError>) -> Void) {
        let request = RequestPost<StRspReadAllNotification>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }

    func removeAllNotification(stReq: StReqRemoveAllNotification, completion: @escaping (Result<StRspRemoveAllNotification, ApiError>) -> Void) {
        let request = RequestPost<StRspRemoveAllNotification>(
            url       : Config.URL_BASE,
            parameters: stReq.dictionary
        )
        defaultSession.load(request) { rspData, _ in
            guard let data = rspData else {
                completion(.failure(.errNoData))
                return
            }
            completion(.success(data))
        }
    }

}
