// Copyright 2018 eBay Inc.
// Created by Xie,Jinrong on 9/12/18.
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import UIKit
import ARKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication,  willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let wnd = UIWindow(frame: UIScreen.main.bounds)
        
        if ARFaceTrackingConfiguration.isSupported {
            wnd.rootViewController = storyBoard.instantiateViewController(withIdentifier: "mainStoryBoard")
            wnd.makeKeyAndVisible()
            window = wnd
        }else{
            wnd.rootViewController = storyBoard.instantiateViewController(withIdentifier: "unsupportedDevice")
            wnd.makeKeyAndVisible()
            window = wnd
        }
        return true
    }
}

