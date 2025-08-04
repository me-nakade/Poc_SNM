//
//  GPSView.swift
//  Next_SECOMMobile_Poc
//
//  Created by 中出恵美 on 2025/07/01.
//

import SwiftUI
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private enum Const{
        static let LOGFILENAME = "location.log"
    }

    private let locationManager = CLLocationManager()
    private var timer: Timer?
    @Published var lastLocation: CLLocation?
    @Published var errorMessage: String?
    @Published var batteryLevel: Float = -1.0
    private var lastLogDate: Date?

    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation() // 常に位置情報を更新
        UIDevice.current.isBatteryMonitoringEnabled = true
        batteryLevel = UIDevice.current.batteryLevel
        startTimer()
    }

    // タイマーで1分ごとにログ記録
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.writeLog()
        }
    }

    // タイマーを停止し、位置情報の更新を停止
    deinit {
        timer?.invalidate()
        locationManager.stopUpdatingLocation()
    }

    // 位置情報を1回だけリクエストするメソッド
    public func requestLocation() {
        locationManager.requestLocation()
    }

    /**
        *位置情報が更新されるたびに呼ばれる
        * @param manager CLLocationManagerのインスタンス
        * @param locations 位置情報の配列
        */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }

    /**
        *位置情報の取得に失敗した場合に呼ばれる
        * @param manager CLLocationManagerのインスタンス
        * @param error エラー情報
        */
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "位置情報取得エラー: \(error.localizedDescription)"
        print("位置情報取得エラー詳細: \(error.localizedDescription)")
    }

    // 1分ごとに最新の位置情報をログに記録
    private func writeLog() {
        guard let location = lastLocation else { return }
        saveLocationToLog(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            horizontalAccuracy: location.horizontalAccuracy,
            speed: location.speed,
            batteryLevel: self.batteryLevel
        )
        lastLogDate = Date()
    }

    /**
        * 位置情報をログファイルに保存
        * @param latitude 緯度
        * @param longitude 経度
        * @param horizontalAccuracy 精度
        * @param speed 速度
        * @param batteryLevel バッテリー残量
        */
    private func saveLocationToLog(latitude: Double, longitude: Double, horizontalAccuracy: Double, speed: Double, batteryLevel: Float) {
        let id = CommonUtil.getUserId()
        let dateString = CommonUtil.formatDate(Date())
        let batteryLevelString = batteryLevel >= 0 ? "\(Int(batteryLevel * 100))%" : "failure"

        let logString: String = "\(id), \(dateString), \(latitude), \(longitude), \(horizontalAccuracy), \(speed), \(batteryLevelString)\n"
        CommonUtil.appendLogToFile(logString, Const.LOGFILENAME) // ログファイルに追記
    }
}

// 画面
struct GPSView: View { 
    @StateObject private var locationManager = LocationManager()
    @State private var now = Date()
    
    var body: some View{
        NavigationStack {
            VStack(alignment: .leading){
                Text("\(CommonUtil.formatDate(now))\n")
                Text("【測定結果(GPS機能)】")
                if let location = locationManager.lastLocation {
                    Text("緯度: \(location.coordinate.latitude)")
                    Text("経度: \(location.coordinate.longitude)")
                    Text("精度: \(location.horizontalAccuracy) m")
                    if(location.speed >= 0) {
                        Text("速度: \(location.speed) m/s")
                    } else {
                        Text("速度: 取得不可")
                    }
                }

                if locationManager.batteryLevel >= 0 {
                    Text("バッテリー残量: \(Int(locationManager.batteryLevel * 100))%")
                } else {
                    Text("バッテリー残量: 取得失敗")
                }

                if let error = locationManager.errorMessage {
                    Text(error).foregroundColor(.red)
                }

                NavigationLink("ホームに戻る", destination: ContentView())
            }
            .padding()
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    now = Date()
                }
                locationManager.requestLocation()
            }
        }
    }
}

#Preview {
    GPSView()
}
