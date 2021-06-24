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
    
    //var urlString: String = "http://m7.2021.dev.etoday.loc"
    var urlString: String = "https://m.etoday.co.kr"
    let defaultParam: String = "utm_device=IOS"
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet var webView: WKWebView!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var homeButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func loadView() {
        //자바스크립트에서 값 가져오기
        let contentController = WKUserContentController()
        contentController.add(self, name: "Test")
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        webView = WKWebView(frame: .zero, configuration: config)
        view = webView
        
        webView.navigationDelegate = self
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
    
    // MARK: - 네트워크
    private func showOfflinePage() -> Void {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "NetworkUnavailable", sender: self)
        }
    }
    
    @IBAction func unwindToVC(_ segue: UIStoryboardSegue) {
        // 연결되어있지 않으면 다시 오류 화면 보여주기
        if !appDelegate.isConnected {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "NetworkUnavailable", sender: self)
            }
        }
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
        let url = URL(string: "\(urlString)/?\(defaultParam)")
        if let myUrl = url {
            let req = URLRequest(url: myUrl)
            webView.load(req)
        }
    }
    
    
    @IBAction func touchRefresh(_ sender: Any) {
        self.webView.reload()
    }
}

// MARK: - WKNavigationDelegate

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
        showOfflinePage()
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
    }
    
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        backButton.isEnabled = webView.canGoBack
//        forwardButton.isEnabled = webView.canGoForward
//    }
    
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
        if urlAbsoluteString.contains("talk.etoday.co.kr/") ||
            urlAbsoluteString.contains("/channel5/") ||
            urlAbsoluteString.contains("fortune.etoday.co.kr/") ||
            urlAbsoluteString.contains("bravo.etoday.co.kr/") ||
            urlAbsoluteString.contains("biospectator.com") ||
            urlAbsoluteString.contains("enter.etoday.co.kr") ||
            urlAbsoluteString.contains("event.etoday.co.kr") ||
            urlAbsoluteString.contains("company.etoday.co.kr/userguide/notice") ||
            urlAbsoluteString.contains("www.youtube.com/user/etodaycokr") ||
            urlAbsoluteString.contains("www.facebook.com/etoday/") ||
            urlAbsoluteString.contains("post.naver.com/my.nhn?memberNo=6132524") ||
            urlAbsoluteString.contains("blog.naver.com/etoday12") ||
            urlAbsoluteString.contains("twitter.com/etodaynews") ||
            urlAbsoluteString.contains("content.v.daum.net/3558/home") {
            guard let sfUrl = URL(string: urlAbsoluteString) else {
                decisionHandler(.cancel)
                return
            }
            let safariViewController = SFSafariViewController(url: sfUrl)
            present(safariViewController, animated: true, completion: nil)
        }
        
        //처음에 param이 없을 때만 이동을 허용한다
        if !urlAbsoluteString.contains("utm_device=IOS") {
            if urlAbsoluteString == "https://m.etoday.co.kr/channel5/" {
                decisionHandler(.cancel)
                return
            }
            //if host.contains("dev.etoday.loc") {    // log.etoday.co.kr도 있어서 m.etoday.co.kr만 통과시켜야한다
            if host.contains("m.etoday.co.kr") {
                var urlString: String = ""
                if !urlAbsoluteString.contains("?") {
                    urlString += "?" + defaultParam
                } else {
                    urlString += "&" + defaultParam
                }
                
                let url = URL(string: urlAbsoluteString+urlString)
                if let myUrl = url {
                    let req = URLRequest(url: myUrl)
                    webView.load(req)
                }
                
            } else {
                decisionHandler(.cancel)
                return
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
