//
//  WebSocketViewModel.swift
//  WebSocket_Practise
//
//  Created by Satyam Sharma Chingari on 19/01/26.
//


import Foundation
import Combine

final class WebSocketViewModel: NSObject, ObservableObject {

    @Published var isConnected = false
    @Published var messages: [String] = []

    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession!
    private let url = URL(string: "wss://echo.websocket.org")!

    func connect() {
        session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }

    func send(text: String) {
        webSocketTask?.send(.string(text)) { error in
            if let error = error {
                print("Send error:", error)
            }
        }
    }

    private func receive() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("Receive error:", error)

            case .success(let message):
                switch message {
                case .string(let text):
                    DispatchQueue.main.async {
                        self?.messages.append("📩 \(text)")
                    }
                case .data(let data):
                    DispatchQueue.main.async {
                        self?.messages.append("📦 Data: \(data.count) bytes")
                    }
                @unknown default:
                    break
                }
            }
            self?.receive()
        }
    }

    private func ping() {
        webSocketTask?.sendPing { [weak self] _ in
            DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                self?.ping()
            }
        }
    }
}

extension WebSocketViewModel : URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didOpenWithProtocol protocol: String?) {

        DispatchQueue.main.async {
            self.isConnected = true
        }
        ping()
        receive()
    }

    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
                    reason: Data?) {

        DispatchQueue.main.async {
            self.isConnected = false
        }
    }
}

