import SwiftUI
import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    var centralManager: CBCentralManager!
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            // スキャン開始
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("発見: \(peripheral), RSSI: \(RSSI)")
    }
}

struct BluetoothView: View {
    @StateObject private var bluetoothManager = BluetoothManager()
    var body: some View {
        NavigationStack{
            VStack {
                Text("【Bluetooth連携】")

                NavigationLink("ホームに戻る", destination: ContentView())
            }
        }
    }
}
#Preview{
    BluetoothView()
}
