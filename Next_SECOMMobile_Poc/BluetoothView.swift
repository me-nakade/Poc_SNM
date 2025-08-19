import SwiftUI
import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    @Published var discoveredPeripherals: [CBPeripheral] = []
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
        if !discoveredPeripherals.contains(where: { $0.identifier == peripheral.identifier }) {
            discoveredPeripherals.append(peripheral)
        }
        print("発見: \(peripheral.name ?? "Unknown"), RSSI: \(RSSI)")
    }
    
    func stopScan() {
        centralManager.stopScan()
    }
}

struct BluetoothView: View {
    @StateObject private var bluetoothManager = BluetoothManager()
    @State private var isScanning = false

    var body: some View {
        NavigationStack{
            VStack {
                Text("【Bluetooth連携】")
                    .font(.headline)
                    .padding(.bottom)

                if isScanning {
                    Button("スキャン停止") {
                        bluetoothManager.stopScan()
                        isScanning = false
                    }
                } else {
                    Button("スキャン開始") {
                        bluetoothManager.centralManager.scanForPeripherals(withServices: nil, options: nil)
                        isScanning = true
                    }
                }

                List(bluetoothManager.discoveredPeripherals, id: \.identifier) { peripheral in
                    Text(peripheral.name ?? "Unknown Peripheral")
                }
                .frame(height: 200)

                NavigationLink("ホームに戻る", destination: ContentView())
            }
            .padding()
        }
    }
}

#Preview{
    BluetoothView()
}
