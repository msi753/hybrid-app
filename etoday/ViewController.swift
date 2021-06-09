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

    //딱히 안쓰는 중...
    enum buttonTag: Int {
        case backbutton     = 10
        case forwardbutton  = 20
        case homebutton     = 30
        case refreshButton  = 40
        case closeButton    = 50
    }
    
    let urlString: String = "http://m7.dev.etoday.loc"
    
    @IBOutlet var webView: WKWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewDidLoad Call")
        
        //initWebViewThenCallFromJs()
        loadUrl()
    }

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

}
