import Foundation

extension URLSession {
    static var lock: NSLock = NSLock()

    func load<TYPE_RSP>(
        _ request : RequestPost<TYPE_RSP>,
        completion: @escaping (TYPE_RSP?, Bool) -> Void
    ) {
        dataTask(with: request.requestUrl) { data, response, _ in
            if let response = response as? HTTPURLResponse,
                (200..<300).contains(response.statusCode)
            {
                if data == nil {
                    completion(nil, false)
                    return
                }
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: data!, options: [])
                    let dictionary = jsonData as? [String:Any]
                    if dictionary == nil {
                        completion(data.flatMap(request.parse), true)
                        return
                    }
                    let retcode = dictionary!["retcode"] as? Int ?? 200
                    let msg = dictionary!["msg"] as? String ?? "账号已在其他设备登录"
                    if retcode == 265 {
                        if let vcCurrent = UIViewController.currentViewController() {
                            if !vcCurrent.isKind(of: ViewControllerLogin.self) {
                                vcCurrent.showAlert(message: msg) { (UIAlertAction) in
                                    Config.saveLoginInfo()
                                    URLSession.lock.lock()
                                    URLSession.logOut()
                                }
                            }
                        }
                        return
                    }
                    completion(data.flatMap(request.parse), true)
                }
                catch {
                    completion(nil, false)
                }
            }
            else {
                completion(nil, false)
            }
        }.resume()
    }


    static func logOut() {
        Config.vcMain?.stopTimer()
        DispatchQueue.main.async {
            let vcCurrent = UIViewController.currentViewController()
            if vcCurrent == nil {
                URLSession.lock.unlock()
                return
            }

            if vcCurrent!.isKind(of: ViewControllerLogin.self) {
                URLSession.lock.unlock()
//                vcCurrent?.showToast(message: "You logged in on another device".localized(), completion: nil)
                return
            }

            vcCurrent!.dismiss(animated: false, completion: {
                URLSession.logOut()
            })
        }
    }

}
