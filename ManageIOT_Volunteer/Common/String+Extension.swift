import Foundation

extension String {

    var htmlAttributed: NSAttributedString? {
        guard let data = data(using: .utf8) else {
            return NSAttributedString()

        }
        do {
            return try NSAttributedString(
                data   : data,
                options: [
                    .documentType     : NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )
        }
        catch {
            return NSAttributedString()
        }
    }


    var htmlString: String {
        return htmlAttributed?.string ?? ""
    }


    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "\(self)", comment: "")
    }

}
