import Foundation

class CommonUtil {
    /**
        * 日付を指定のフォーマットで文字列に変換
        * @param date 変換する日付
        * @param format 日付フォーマット（デフォルトは "yyyy-MM-dd HH:mm:ss"）
        * @return フォーマットされた日付文字列
        * 
        * 使用例: CommonUtil.formatDate(Date(), format: "yyyy-MM-dd")
        */
    static func formatDate(_ date: Date, format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        return formatter.string(from: date)
    }
    
    /**
        * ユーザごとの一意のID(UUID)を取得する
    */
    static func getUserId() -> String {
        let userDefaults = UserDefaults.standard
        if userDefaults.string(forKey: "myAppUUID") == nil {
            userDefaults.set(UUID().uuidString, forKey: "myAppUUID")
        }
        return userDefaults.string(forKey: "myAppUUID") ?? "unknown"
    }

    /**
        * ログファイルにログデータを追記
        * ファイルが存在しない場合は新規作成 
        * @param 追記するログファイル
        * @param log 追記するログデータ
        */
    static func appendLogToFile(_ log: String, _ fileName: String) {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        
        guard let documentsURL = urls.first else {
            print("Documentsディレクトリが取得できません")
            return
        }
        let logFileURL = documentsURL.appendingPathComponent(fileName)

        if let data = log.data(using: .utf8) {
            if fileManager.fileExists(atPath: logFileURL.path) {
                do {
                    let fileHandle = try FileHandle(forWritingTo: logFileURL)
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    fileHandle.closeFile()
                } catch {
                    print("ファイル追記エラー: \(error.localizedDescription)")
                }
            } else {
                do {
                    try data.write(to: logFileURL)
                } catch {
                    print("ファイル新規作成エラー: \(error.localizedDescription)")
                }
            }
        }
    }
}