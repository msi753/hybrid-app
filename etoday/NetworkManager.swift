//
//  NetworkManager.swift
//  etoday
//
//  Created by 임명심 on 2021/06/10.
//

import Foundation
import Reachability

class NetworkManager: NSObject {

    var reachability: Reachability!

    // NetworkManager 클래스의 싱글톤 인스턴스 sharedInstance 생성하기
    static let sharedInstance: NetworkManager = {
        return NetworkManager()
    }()


    override init() {
        super.init()

        // reachability 초기화
        //reachability = Reachability()!
        reachability = try! Reachability()
        
        // 네트워크 상태에 대한 observer 등록하기
        // 네트워크 상태가 바뀌면 networkStatusChanged 콜백함수가 실행된다
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged(_:)),
            name: .reachabilityChanged,
            object: reachability
        )

        do {
            // Start the network status notifier
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }

    @objc func networkStatusChanged(_ notification: Notification) {
        // Do something globally here!
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        NetworkManager.isReachable { networkManagerInstance in
            appDelegate.isConnected = true
            print("Network is available")
        }
        NetworkManager.isUnreachable { networkManagerInstance in
            appDelegate.isConnected = false
            print("Network is Unavailable")
        }
        
        //NetworkManager.sharedInstance.reachability.whenReachable
    }

    static func stopNotifier() -> Void {
        do {
            // Stop the network status notifier
            try (NetworkManager.sharedInstance.reachability).startNotifier()
        } catch {
            print("Error stopping notifier")
        }
    }

    // Network is reachable
    static func isReachable(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.sharedInstance.reachability).connection != .unavailable {
            completed(NetworkManager.sharedInstance)
        }
    }

    // Network is unreachable
    static func isUnreachable(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.sharedInstance.reachability).connection == .unavailable {
            completed(NetworkManager.sharedInstance)
        }
    }

    // Network is reachable via WWAN/Cellular
    static func isReachableViaWWAN(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.sharedInstance.reachability).connection == .cellular {
            completed(NetworkManager.sharedInstance)
        }
    }

    // Network is reachable via WiFi
    static func isReachableViaWiFi(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.sharedInstance.reachability).connection == .wifi {
            completed(NetworkManager.sharedInstance)
        }
    }
}


