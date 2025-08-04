//
//  NFCTagView.swift
//  Next_SECOMMobile_Poc
//
//  Created by 中出恵美 on 2025/07/28.
//

import SwiftUI
import CoreNFC

class NFCReader: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    @Published var message: String = ""
    @Published var errorDetail: String = ""
    private var session: NFCNDEFReaderSession?

    func startScan() {
        guard session == nil else { return } // セッションがなければ開始
        message = "タグをかざしてください"
        errorDetail = ""
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.begin()
    }

    // 読み取り成功時
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        DispatchQueue.main.async {
            self.message = "読み取り成功"
            self.errorDetail = ""
        }
        session.invalidate()
    }

    // 読み取り失敗時
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            self.message = "読み取り失敗"
            self.errorDetail = error.localizedDescription
            self.session = nil // セッションを解放
        }
    }
}

// NFCタグの読み取り画面
struct NFCTagView: View {
    @StateObject private var nfcReader = NFCReader()

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
