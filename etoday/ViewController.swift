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
    
    let urlString: String = "http://m7.dev.etoday.loc"
    
    @IBOutlet var webView: WKWebView!
    
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var homeButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewDidLoad Call")
        
        // If the network is unreachable show the offline page
        NetworkManager.isUnreachable { _ in
            self.showOfflinePage()
        }
        
//        NetworkManager.isReachable { _ in
//            self.showMainPage()
//        }
        
        //initWebViewThenCallFromJs()
        loadUrl()
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
    
    func loadUrl() {
        view.addSubview(webView)
        
        let url = URL(string: urlString)
        guard let myUrl = url else {
            return
        }
        let req = URLRequest(url: myUrl)
        self.webView.load(req)
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
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
        let url = URL(string: urlString)
        guard let myUrl = url else {
            return
        }
        let req = URLRequest(url: myUrl)
        self.webView.load(req)
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
}


// MARK: - WKNavigationDelegate

extension ViewController: WKNavigationDelegate {
    // 중복적으로 리로드 방지
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        self.webView.reload()
    }

    //스피너 설정
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.spinner.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.spinner.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.spinner.stopAnimating()
        // 상세 페이지를 읽어오지 못했습니다
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.spinner.stopAnimating()
        // 상세 페이지를 읽어오지 못했습니다
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        /*
        //channel5 (제외)
        //https://talk.etoday.co.kr (제외)
        //https://fortune.etoday.co.kr (제외)
        //https://company.etoday.co.kr/userguide/notice(제외)
        //http://bravo.etoday.co.kr (제외)
        
        //etoday.co.kr이 들어가지 않는 외부링크
        //http://www.biospectator.com
        //https://www.youtube.com/user/etodaycokr
        //https://www.facebook.com/etoday/
        //https://post.naver.com/my.nhn?memberNo=6132524
        //https://blog.naver.com/etoday12
        //https://twitter.com/etodaynews
        //https://content.v.daum.net/3558/home
        */
        
        let urlString = url.absoluteString
        if urlString.contains("talk.etoday.co.kr/") {
            print("토크")
            decisionHandler(.cancel)
            return
        } else if urlString.contains("뭐시기 url") {
            //다른 처리
        }
        
        decisionHandler(.allow)
    }
}
