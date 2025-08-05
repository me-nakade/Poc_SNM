//
//  NFCTagView.swift
//  Next_SECOMMobile_Poc
//
//  Created by 中出恵美 on 2025/07/28.
//

import SwiftUI
import CoreNFC

class NFCManager: NSObject, ObservableObject, NFCTagReaderSessionDelegate {
    @Published var message: String = ""
    @Published var errorDetail: String = ""
    private var session: NFCTagReaderSession?

    func startScan() {
        guard session == nil else { return }
        message = "タグをかざしてください"
        errorDetail = ""
        session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
        session?.alertMessage = "NFCタグを読み取ります"
        session?.begin()
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        DispatchQueue.main.async {
            self.message = "読み取り成功"
            self.errorDetail = ""
        }
        session.invalidate()
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            self.message = "読み取り失敗"
            self.errorDetail = error.localizedDescription
            self.session = nil
        }
    }
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        // セッションがアクティブになった時に呼ばれます（何もしなくてOK）
    }
}

// NFCタグの読み取り画面
struct NFCTagView: View {
    @StateObject private var nfcReader = NFCManager()

    var body: some View {
        VStack(spacing: 20) {
            Text("【NFCタグの読込】")
            Button(action: {
                nfcReader.startScan()
            }) {
                Text("NFCタグを読み取る")
                    .frame(maxWidth: 150, maxHeight: 25)
                    .padding()
                    .background(Color.teal)
                    .foregroundColor(.white)
                    .cornerRadius(5)
            }
            if !nfcReader.message.isEmpty {
                Text(nfcReader.message)
                    .foregroundColor(nfcReader.errorDetail.isEmpty ? .green : .red)
            }
            if !nfcReader.errorDetail.isEmpty {
                Text(nfcReader.errorDetail)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding()
        NavigationStack {
            VStack {
                NavigationLink("ホームに戻る", destination: ContentView())
            }
        }
    }
}

#Preview{
    NFCTagView()
}
