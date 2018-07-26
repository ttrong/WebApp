//
//  WebAppViewController.swift
//  WebViewApp
//
//  Created by Trong Ton on 7/25/18.
//  Copyright © 2018 trong.ton2003@gmail.com. All rights reserved.
//

import UIKit
import EVURLCache
import SwiftyJSON
import AMScrollingNavbar

enum StatusApiCall {
    case none
    case success
    case failure
}

class WebAppViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    var urlString: String = ""
    var statusCallAPI: StatusApiCall = .none
    var handlingCacheRequest: Bool = false
    let urlCache = URLCache.shared
    var currentURL: String?
    var newBackButton: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.hidesBackButton = true
        newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(backButtonPress(_:)))
        self.navigationItem.leftBarButtonItem = newBackButton;
        
        if urlString.count <= 0 {
            urlString = "https://www.google.com"//"https://www.youtube.com"
        }
        
        webView.backgroundColor = UIColor.black
        webView.delegate = self
        webView.scalesPageToFit = true
        loadWebView(urlString)
        tryLoadAPI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if webView.canGoBack {
            self.navigationItem.leftBarButtonItem = newBackButton;
        } else {
            self.navigationItem.leftBarButtonItem = nil;
        }
        if let navigationController = navigationController as? ScrollingNavigationController {
            navigationController.followScrollView(webView.scrollView, delay: 50.0)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let navigationController = navigationController as? ScrollingNavigationController {
            navigationController.stopFollowingScrollView()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func backButtonPress(_ sender: UIBarButtonItem) {
        if(webView.canGoBack) {
            webView.goBack()
        }
    }
    
    func loadWebView(_ url: String) {
        let url = URL(string: url)
        let urlRequest = URLRequest(url: url!)
        webView.loadRequest(urlRequest)
    }
    
    func tryLoadAPI() {
        if statusCallAPI == .failure {
            perform(#selector(callApiService), with: nil, afterDelay: 0.5)
        }
    }
    
    @objc func callApiService() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.checkStatusFromServer(nil, { data in
            let swiftyJsonVar = JSON(data)
            self.urlString = swiftyJsonVar["url"].string!
            let screenMode = swiftyJsonVar["screen"].string!
            self.statusCallAPI = .success
            DispatchQueue.main.async {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                if screenMode == "h" {
                    appDelegate.setOrientationMaskSuppor(.portrait)
                } else {
                    appDelegate.setOrientationMaskSuppor(.landscape)
                }
                self.loadWebView(self.urlString)
            }
        }) { error in
            self.statusCallAPI = .failure
            self.tryLoadAPI()
        }
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let redirectURL = EVURLCache.shouldRedirect(request: request) {
            let r = URLRequest(url: redirectURL)
            webView.loadRequest(r)
            return false
        }
        
        return true
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
//        if webView.canGoBack {
//            self.navigationItem.leftBarButtonItem = newBackButton;
//        } else {
//            self.navigationItem.leftBarButtonItem = nil;
//        }
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if webView.canGoBack {
            self.navigationItem.leftBarButtonItem = newBackButton;
        } else {
            self.navigationItem.leftBarButtonItem = nil;
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
