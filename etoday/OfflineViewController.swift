//
//  OfflineViewController.swift
//  etoday
//
//  Created by 임명심 on 2021/06/10.
//

import UIKit

//여기서 툴바 안보이게 해야할 거 같은데???
//네트워크 연결안되면 어떻게 하는건데???
//뒤로 돌아갈 곳이 어딘데!!!

class OfflineViewController: UIViewController {

    let network = NetworkManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // If the network is reachable show the view controller
        network.reachability.whenReachable = { _ in
            self.showViewController()
        }
    }
    
    private func showViewController() -> Void {
        
        func goToVC(_ segue: UIStoryboardSegue) {
            performSegue(withIdentifier: "unwindId", sender: self)
        }
        
    }
}
