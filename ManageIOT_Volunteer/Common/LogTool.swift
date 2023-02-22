import Foundation

struct LogTool: TextOutputStream {

    static var instance: LogTool = LogTool()


    private init() {
    }


    /// Appends the given string to the stream.
    mutating func write(_ string: String) {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)
        let documentDirectoryPath = paths.first!
        let logfile = documentDirectoryPath.appendingPathComponent("log.txt")

        do {
            let handle = try FileHandle(forWritingTo: logfile)
            handle.seekToEndOfFile()
            handle.write(string.data(using: .utf8)!)
            handle.closeFile()
        }
        catch {
            print(error.localizedDescription)
            do {
                try string.data(using: .utf8)?.write(to: logfile)
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }


    static func insert(log: String) {
        print(log, to: &LogTool.instance)
    }
}
