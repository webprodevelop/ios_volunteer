import Foundation


class RequestPost<TYPE_RSP> where TYPE_RSP: Decodable {

    var requestUrl: URLRequest
    let parse     : (Data) -> TYPE_RSP?


    init(url: URL) {
        requestUrl = URLRequest(url: url)
        parse = { data in
            try? JSONDecoder().decode(TYPE_RSP.self, from: data)
        }
    }


    init(url: String, parameters: [String: Any]) {
        //-- This is for HttpPost and x-www-form-urlencoded Body
        let url = URL(string: url)!
        requestUrl = URLRequest(url: url)
        requestUrl.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        requestUrl.httpMethod = "POST"
        requestUrl.httpBody = parameters.percentEncoded()

        self.parse = { data in
            try? JSONDecoder().decode(TYPE_RSP.self, from: data)
        }
    }

    /*
    init(url: String, parameters: [String:Any]) {
        //-- This is for HttpPost and x-www-form-urlencoded Body, But have some problem while uploading image
        let header: [String:String] = ["Content-Type":Config.HTTP_TYPE_CONTENT]
        var component = URLComponents()
        var params = [URLQueryItem]()

        for (name, value) in parameters {
            if name.isEmpty { continue }
            params.append(URLQueryItem(name: name, value: String(describing: value)))
        }
        if !params.isEmpty {
          component.queryItems = params
        }

        requestUrl = URLRequest(url: URL(string: url)!)
        requestUrl.httpMethod = "POST"
        requestUrl.allHTTPHeaderFields = header
        requestUrl.httpBody = component.query?.data(using: .utf8)

        self.parse = { data in
            try? JSONDecoder().decode(TYPE_RSP.self, from: data)
        }
    }
    */

    init(url: String, getParameters: [String: Any]) {
        //-- This is for Http Get Method
        //-- Parameters are embeded in URL
        var component = URLComponents(string: url)
        var params = [URLQueryItem]()
        for (name, value) in getParameters {
            if name.isEmpty { continue }
            params.append(URLQueryItem(name: name, value: String(describing: value)))
        }

        if !params.isEmpty {
          component?.queryItems = params
        }

        if let componentURL = component?.url {
            self.requestUrl = URLRequest(url: componentURL)
        }
        else {
            self.requestUrl = URLRequest(url: URL(string: url)!)
        }

        self.parse = { data in
            try? JSONDecoder().decode(TYPE_RSP.self, from: data)
        }
    }


    init<Body: Encodable>(url: URL, method: HttpMethod<Body>) {
        //-- This is for JSON Body
        requestUrl = URLRequest(url: url)
        requestUrl.httpMethod = method.method

        switch method {
            case .post(let body):
                requestUrl.httpBody = try? JSONEncoder().encode(body)
                requestUrl.addValue(Config.HTTP_TYPE_CONTENT, forHTTPHeaderField: "Content-Type")
                requestUrl.addValue(Config.HTTP_TYPE_ACCEPT,  forHTTPHeaderField: "Accept")
                break
            case .delete(_): break
            case .patch(_) : break
            case .put(_)   : break
            default: break
        }

        self.parse = { data in
            try? JSONDecoder().decode(TYPE_RSP.self, from: data)
        }
    }
}
