//
//  WebSocketView.swift
//  WebSocket_Practise
//
//  Created by Satyam Sharma Chingari on 19/01/26.
//

import SwiftUI

struct WebSocketView: View {

    @StateObject private var vm = WebSocketViewModel()
    @State private var message = ""

    var body: some View {
        VStack {

            Text(vm.isConnected ? "🟢 Connected" : "🔴 Disconnected")
                .font(.headline)
            
            HStack {
                Button("Connect") {
                    vm.connect()
                }
                .padding()
                .background(Color(.systemBlue))
                .foregroundColor(.white)
                .cornerRadius(8)
                Button("Disconnect") {
                    vm.disconnect()
                }
                .padding()
                .background(Color(.systemRed))
                .foregroundColor(.white)
                .cornerRadius(8)
            }

            

            HStack {
                TextField("Type message...", text: $message)
                    .padding(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(style: StrokeStyle(lineWidth: 1))
                    )

                Button("Send") {
                    vm.send(text: message)
                    message = ""
                }
                .disabled(!vm.isConnected)
            }
            .padding()

            List(vm.messages, id: \.self) { msg in
                Text(msg)
            }
      
        }
    }
}



#Preview {
    WebSocketView()
}

