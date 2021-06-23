//
//  OfflineViewController.swift
//  etoday
//
//  Created by 임명심 on 2021/06/10.
//

import UIKit

class OfflineViewController: UIViewController {
    
    @IBAction func retryButton(_ sender: Any) {
        showViewController()
    }
    
    private func showViewController() -> Void {
        func goToVC(_ segue: UIStoryboardSegue) {
            performSegue(withIdentifier: "unwindId", sender: self)
        }
    }
    
    // MARK: - 툴바 숨기기
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isToolbarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isToolbarHidden = false
    }
    

}
