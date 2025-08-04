//
//  ContentView.swift
//  Next_SECOMMobile_Poc
//
//  Created by 中出恵美 on 2025/07/01.
//

import SwiftUI

// 画面
struct ContentView: View {  
    var body: some View{
        NavigationStack {
            VStack {
                Text("【Poc開発】")
                NavigationLink(destination: GPSView()) {
                    Text("GPS機能")
                        .frame(maxWidth: 150 , maxHeight: 25)
                        .padding()
                        .background(Color.teal)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                NavigationLink(destination: NFCTagView()){
                    Text("NFCタグ機能")
                        .frame(maxWidth: 150 , maxHeight: 25)
                        .padding()
                        .background(Color.teal)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                NavigationLink(destination: CameraView()){
                    Text("カメラ機能")
                        .frame(maxWidth: 150 , maxHeight: 25)
                        .padding()
                        .background(Color.teal)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                NavigationLink(destination: BluetoothView()){
                    Text("Bluetooth連携機能")
                        .frame(maxWidth: 150 , maxHeight: 25)
                        .padding()
                        .background(Color.teal)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                NavigationLink(destination: GPSView2()) {
                    Text("GPS機能２")
                        .frame(maxWidth: 150 , maxHeight: 25)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
