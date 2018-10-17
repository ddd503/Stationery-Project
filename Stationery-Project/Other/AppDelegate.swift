//
//  AppDelegate.swift
//  Stationery-Project
//
//  Created by kawaharadai on 2018/10/11.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import Model

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setRootVC(vc: ViewControllerBuilder.buildFirstVC())
        return true
    }
    
    /// 初回表示画面をセットする
    ///
    /// - Parameter vc: 表示するUIViewController
    private func setRootVC(vc: UIViewController) {
        /// 画面Windowを用意
        window = UIWindow(frame: UIScreen.main.bounds)
        /// rootVCにセット
        window?.rootViewController = UINavigationController(rootViewController: vc)
        /// 表示実行
        window?.makeKeyAndVisible()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {}
    
    func applicationDidEnterBackground(_ application: UIApplication) {}
    
    func applicationWillEnterForeground(_ application: UIApplication) {}
    
    func applicationDidBecomeActive(_ application: UIApplication) {}
    
    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataManager.shered.saveContext()
    }
    
}
