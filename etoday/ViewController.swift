//
//  ViewController.swift
//  etoday
//
//  Created by 임명심 on 2021/06/07.
//


import UIKit
import WebKit
import Reachability
import SafariServices

class ViewController: UIViewController {

    let network: NetworkManager = NetworkManager.sharedInstance
    
    var urlString: String = "http://m7.2021.dev.etoday.loc"
    
    let defaultParam: String = "utm_device=IOS"
    
    @IBOutlet var webView: WKWebView!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var homeButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func loadView() {
        print("loadView")
        
        let contentController = WKUserContentController()
        contentController.add(self, name: "Test")
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        webView = WKWebView(frame: .zero, configuration: config)
        view = webView
        
        webView.navigationDelegate = self
        
        NetworkManager.isUnreachable { _ in
            self.showOfflinePage()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
        let url = URL(string: urlString)
        if let myUrl = url {
            let req = URLRequest(url: myUrl)
            webView.load(req)
        }
    }
    
    private func showOfflinePage() -> Void {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "NetworkUnavailable", sender: self)
        }
    }
    
    @IBAction func unwindToVC(_ segue: UIStoryboardSegue) {
           
    }
    
    // MARK: - 툴바
    @IBAction func touchBack(_ sender: Any) {
        if self.webView.canGoBack {
            self.webView.goBack()
        }
    }
    
    @IBAction func touchForward(_ sender: Any) {
        if self.webView.canGoForward {
            self.webView.goForward()
        }
    }
    
    @IBAction func touchHome(_ sender: Any) {
        //
    }
    
    @IBAction func touchRefresh(_ sender: Any) {
        self.webView.reload()
    }
    
    @IBAction func touchStop(_ sender: Any) {
    }
}

// MARK: - WKNavigationDelegate

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        guard let host = url.host else {
            decisionHandler(.cancel)
            return
        }
        
        //host가 m7.2021.dev.etoday.loc을 포함할 때만 이동한다
        let urlAbsoluteString = url.absoluteString
        
        // SFSafariViewController 외부로 이동하기
        if urlAbsoluteString.contains("https://talk.etoday.co.kr/") {
            guard let sfUrl = URL(string: urlAbsoluteString) else {
                decisionHandler(.cancel)
                return
            }
            let safariViewController = SFSafariViewController(url: sfUrl)
            present(safariViewController, animated: true, completion: nil)
        }
        
        //처음에 param이 없을 때만 이동을 허용한다
        if !urlAbsoluteString.contains("utm_device=IOS") {
            if host.contains("dev.etoday.loc") {
                var urlString: String = ""
                if !urlAbsoluteString.contains("?") {
                    urlString += "?" + defaultParam
                } else {
                    urlString += "&" + defaultParam
                }
                
                let url = URL(string: urlAbsoluteString+urlString)
                if let myUrl = url {
                    let req = URLRequest(url: myUrl)
                    print(req)
                    webView.load(req)
                }
                
            }
        }
        
        decisionHandler(.allow)
    }
}

// MARK: - WKScriptMessageHandler
extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "Test" {
            let values: [String:String] = message.body as! Dictionary
            if let idx = values["idx"], let title = values["title"] {
                if let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
                    let linkUrl = urlString+"/view.php?idxno="+idx
                    let textToShare = [ "[\(appName)] \(title) - \(linkUrl)" ]
                    let activityVC = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                    self.present(activityVC, animated: true, completion: nil)
                }
            }
        }
    }
}
