//
//  ViewController.swift
//  etoday
//
//  Created by 임명심 on 2021/06/07.
//


import UIKit
import WebKit
import Reachability

class ViewController: UIViewController {

    let network: NetworkManager = NetworkManager.sharedInstance
    
    var urlString: String = "http://m7.2021.dev.etoday.loc"
    
    let defaultParam: String = "utm_device=IOS"
    
    var navigationUrlString: String = ""
    
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var homeButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad 호출")
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        // 네트워크가 unreachable이 되면 OfflineVC를 보여준다
        NetworkManager.isUnreachable { _ in
            self.showOfflinePage()
        }
        
//        NetworkManager.isReachable { _ in
//            self.showMainPage()
//        }
        
        //initWebViewThenCallFromJs()
        loadUrl(urlString)
    }
    
    private func showOfflinePage() -> Void {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "NetworkUnavailable", sender: self)
        }
    }
    
//    private func showMainPage() -> Void {
//        DispatchQueue.main.async {
//            self.performSegue(withIdentifier: "MainController", sender: self)
//        }
//    }
    

    func loadUrl(_ urlString: String) {
        //view.addSubview(self.webView)
        
        print("\(urlString): loadURL메소드 호출")
        
        let url = URL(string: urlString)
        if let myUrl = url {
            let req = URLRequest(url: myUrl)
            self.webView.load(req)
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
//        let url = URL(string: self.urlString)
//        guard let myUrl = url else {
//            return
//        }
//        let req = URLRequest(url: myUrl)
//        self.webView.load(req)
        loadUrl(urlString)
    }
    
    @IBAction func touchRefresh(_ sender: Any) {
        self.webView.reload()
    }
    
    @IBAction func touchStop(_ sender: Any) {
        //마지막 기능을 뭘로 해야할지 모르겠다...
        //검색? 이 페이지 공유하기? 설정? 확대?
        self.webView.stopLoading()
    }
}

// MARK: - WKUIDelegate

extension ViewController: WKUIDelegate {
    //toolbar IBOutlet으로 선언하고
    //load가 시작되면 refresh를 stop으로
    //load가 끝나면 stop을 refresh로?
    //completion Handler를 호출하지 않으면 자바스크립트의 alert가 blocking하기 때문이다
//    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
//        let ac = UIAlertController(title: "Hey, listen!", message: message, preferredStyle: .alert)
//        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        present(ac, animated: true)
//        completionHandler()
//    }
//
//    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
//        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: {(action) in completionHandler(false)})
//        let okAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in completionHandler(true)})
//        alert.addAction(cancelAction)
//        alert.addAction(okAction)
//        self.present(alert, animated: true, completion: nil)
//    }
}


// MARK: - WKNavigationDelegate

extension ViewController: WKNavigationDelegate {

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        print("중복 리로드 방지")
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("스피너 돌기 시작")
        self.spinner.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("didFinish")
        self.spinner.stopAnimating()
        
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.spinner.stopAnimating()
        print(" didFail 상세 페이지를 읽어오지 못했습니다")
    }
    

    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("리다이렉트")
        print("serverRedirect")
    }
    
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        print("start")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
        print("캔슬이 사용됨")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.spinner.stopAnimating()
        print(" didFailProvisionalNavigation 상세 페이지를 읽어오지 못했습니다")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("decidePolicyFor navigationAction")
        print(navigationAction.request.url)
//        for page in webView.backForwardList.backList {
//            print("User visited \(page.url.absoluteString)")
//        }
        
        guard let url = navigationAction.request.url else {
            print(5)
            decisionHandler(.cancel)
            return
        }
        
        guard let host = url.host else {
            print(6)
            decisionHandler(.cancel)
            return
        }
        
        //host가 m7.2021.dev.etoday.loc을 포함할 때만 이동한다
        let urlAbsoluteString = url.absoluteString
        //처음에 param이 없을 때만 이동을 허용한다
        if !urlAbsoluteString.contains("utm_device=IOS") {
            //print(1)
            if host.contains("dev.etoday.loc") {
                //print(2)
                var urlString: String = ""
                if !urlAbsoluteString.contains("?") {
                    urlString += "?" + defaultParam
                } else {
                    urlString += "&" + defaultParam
                }
                print(urlString)
                self.loadUrl(urlAbsoluteString + urlString)
                //decisionHandler(.allow)
                //return
            }
        }
        
        //print(3)
        decisionHandler(.allow)
    }
}
