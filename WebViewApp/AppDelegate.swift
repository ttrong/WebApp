//
//  AppDelegate.swift
//  WebViewApp
//
//  Created by Trong Ton on 7/24/18.
//  Copyright © 2018 trong.ton2003@gmail.com. All rights reserved.
//

import UIKit
import EVURLCache
import Alamofire
import AdSupport
import CoreTelephony

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var orientationMaskSupport: UIInterfaceOrientationMask = .portrait
    var urlCache = URLCache.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        EVURLCache.LOGGING = true // We want to see all caching actions
        EVURLCache.MAX_FILE_SIZE = 24 // We want more than the default: 2^26 = 64MB
        EVURLCache.MAX_CACHE_SIZE = 30 // We want more than the default: 2^28 = 1GB
        EVURLCache.activate()
        
//        let kB = 1024
//        let MB = 1024 * kB
//        urlCache = URLCache(memoryCapacity: 20 * MB, diskCapacity: 20 * MB, diskPath: nil)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return orientationMaskSupport
    }

    func setOrientationMaskSuppor(_ mask: UIInterfaceOrientationMask) {
        orientationMaskSupport = mask
        if mask == .portrait {
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        } else {
            let value = UIInterfaceOrientation.landscapeRight.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
    }
    
    func checkStatusFromServer(_ loadingView: UIProgressView?,_ completion: @escaping (_ result: Any) -> Void,_ failure: @escaping (_ errorObject: Error) -> Void) {
        let uuid: String = NSUUID().uuidString.lowercased()
        let localeCode: String = Locale.current.regionCode!
        let networkFlag = NetworkReachabilityManager()!.networkReachabilityStatus
        let networkType: String = networkFlag == .unknown ? "unknown" : networkFlag == .notReachable ? "unknown" : networkFlag == .reachable(.ethernetOrWiFi) ? "wifi" : "4G/3G/2G"
        var carrier: String = (CTTelephonyNetworkInfo().subscriberCellularProvider?.carrierName!)!
        if  carrier.count == 0 {
            carrier = "no_service"
        }
        let urlString = "http://dist.app.xunya.io/im.test.com/launch?uuid=\(uuid)&cc=\(localeCode)&net=\(networkType)&isp=\(carrier)&mp="
        let urlGet = URL(string: urlString)
//        let parameters: Parameters = ["uuid" : uuid, "cc" : localeCode, "net" : networkType, "isp" : carrier, "mp" : ""]
        
        Alamofire.request(urlGet!, method: .get, parameters: nil, encoding: JSONEncoding.default)
            .downloadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
                if loadingView != nil {
                    DispatchQueue.main.async {
                        loadingView?.setProgress(Float(progress.fractionCompleted), animated: true)
                    }
                }
            }
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    completion(value)
                    break
                case .failure(let error):
                    if loadingView != nil {
                        DispatchQueue.main.async {
                            loadingView?.setProgress(1.0, animated: true)
                        }
                    }
                    failure(error)
                }
            }
            .responseJSON { response in
                debugPrint(response)
        }
    }
}

