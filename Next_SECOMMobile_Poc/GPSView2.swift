//
//  GPSView2.swift
//  Next_SECOMMobile_Poc
//
//  Created by 中出恵美 on 2025/08/04.
//

import SwiftUI
import CoreLocation

@MainActor
class LocationInfo: ObservableObject {
    private enum Const{
        static let LOGFILENAME = "location_2.log"
    }
    
    let backgroundActivity = CLBackgroundActivitySession()
    let updates = CLLocationUpdate.liveUpdates()
    
    @Published var lastLocation: CLLocation?
    @Published var errorMessage: String?
    @Published var batteryLevel: Float = -1.0

    private var logTimer: Timer?
    
    static var shared: LocationInfo = {
        let instance = LocationInfo()
        return instance
    }()

    private init() {
        print("LocationInfoインスタンス生成")
        UIDevice.current.isBatteryMonitoringEnabled = true
        batteryLevel = UIDevice.current.batteryLevel
        startLogTimer()
    }

    func updatesLocationInfo() async {
        do {
            for try await update in updates {
                if let location = update.location {
                    DispatchQueue.main.async {
                        let isFirst = self.lastLocation == nil
                        self.lastLocation = location
                        self.batteryLevel = UIDevice.current.batteryLevel
                        self.errorMessage = ""
                        if isFirst {
                            self.writeLog() // 初回のみ
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "位置情報が取得できません"
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "位置情報の取得中にエラーが発生しました: \(error.localizedDescription)"
            }
        }
        self.backgroundActivity.invalidate()
    }
    
    private func startLogTimer() {
        print("タイマー起動")
        logTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                self.writeLog()
            }
        }
    }
    
    private func writeLog() {
        guard let location = lastLocation else { 
            print("lastLocationがnilです")
            return }
        print("ログ書き込み: \(location.coordinate.latitude), \(location.coordinate.longitude)")

        let id = CommonUtil.getUserId()
        let dateString = CommonUtil.formatDate(Date())
        let batteryLevelString = batteryLevel >= 0 ? "\(Int(batteryLevel * 100))%" : "failure"
        let logString: String = "\(id), \(dateString), \(location.coordinate.latitude), \(location.coordinate.longitude), \(location.horizontalAccuracy), \(location.speed), \(batteryLevelString)\n"
        CommonUtil.appendLogToFile(logString, Const.LOGFILENAME)
    }
    
    deinit {
        logTimer?.invalidate()
        backgroundActivity.invalidate()
    }
}

// 画面
struct GPSView2: View {
    @ObservedObject private var locationInfo = LocationInfo.shared
    @State private var now = Date()
    
    var body: some View{
        NavigationStack {
            VStack(alignment: .leading){
                Text("GPS_2")
                Text("\(CommonUtil.formatDate(now))\n")
                Text("【測定結果(GPS機能)】")
                if let location = locationInfo.lastLocation {
                    Text("緯度: \(location.coordinate.latitude)")
                    Text("経度: \(location.coordinate.longitude)")
                    Text("精度: \(location.horizontalAccuracy) m")
                    if location.speed >= 0 {
                        Text("速度: \(location.speed) m/s")
                    } else {
                        Text("速度: 取得不可")
                    }
                }
                if locationInfo.batteryLevel >= 0 {
                    Text("バッテリー残量: \(Int(locationInfo.batteryLevel * 100))%")
                } else {
                    Text("バッテリー残量: 取得失敗")
                }
                if let error = locationInfo.errorMessage {
                    Text(error).foregroundColor(.red)
                }
                NavigationLink("ホームに戻る", destination: ContentView())
            }
            .padding()
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    now = Date()
                }
            }
            .task {
                await locationInfo.updatesLocationInfo()
            }
        }
    }
}

#Preview {
    GPSView2()
}
