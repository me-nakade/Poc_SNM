import SwiftUI

struct BluetoothView: View {
    var body: some View {
        VStack {
            Text("【Bluetooth連携】")
        }
        
        NavigationStack{
            VStack {
                NavigationLink("ホームに戻る", destination: ContentView())
            }
        }
    }
}

#Preview{
    BluetoothView()
}
