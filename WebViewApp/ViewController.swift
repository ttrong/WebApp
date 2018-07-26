//
//  ViewController.swift
//  WebViewApp
//
//  Created by Trong Ton on 7/24/18.
//  Copyright © 2018 trong.ton2003@gmail.com. All rights reserved.
//

import UIKit
import Alamofire
import AdSupport
import CoreTelephony
import SwiftyJSON

class ViewController: UIViewController {
    @IBOutlet weak var loadingProgressView: UIProgressView!
    var linkRequest: String = ""
    var statusApi: StatusApiCall = .none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        var strIDFA : String = "No IDFA"
//        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
//            strIDFA = ASIdentifierManager.shared().advertisingIdentifier.uuidString
//        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getConfigServerFromServer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getConfigServerFromServer() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.checkStatusFromServer(loadingProgressView, { data in
            let swiftyJsonVar = JSON(data)
            self.linkRequest = swiftyJsonVar["url"].string!
            let screenMode = swiftyJsonVar["screen"].string!
            DispatchQueue.main.async {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                if screenMode == "h" {
                    appDelegate.setOrientationMaskSuppor(.portrait)
                } else {
                    appDelegate.setOrientationMaskSuppor(.landscape)
                }
                self.statusApi = .success
                self.performSegue(withIdentifier: "showMainView", sender: self)
            }
        }) { error in
            self.statusApi = .failure
            self.performSegue(withIdentifier: "showMainView", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMainView" {
            let destViewController = segue.destination as! UINavigationController
            let topView = destViewController.topViewController as! WebAppViewController
            topView.urlString = linkRequest
            topView.statusCallAPI = statusApi
        }
    }
}

