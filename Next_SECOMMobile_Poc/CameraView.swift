import SwiftUI

struct CameraView: View {
    var body: some View {
        VStack {
            Text("【カメラ機能】")
        }
        
        NavigationStack{
            VStack {
                NavigationLink("ホームに戻る", destination: ContentView())
            }
        }
    }
}

#Preview{
    CameraView()
}
