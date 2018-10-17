//
//  ViewControllerBuilder.swift
//  Stationery-Project
//
//  Created by kawaharadai on 2018/10/13.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import UIKit

final class ViewControllerBuilder {
    
    /// 最初の画面
    static func buildFirstVC() -> FirstViewController {
        let vcName = "FirstViewController"
        let vc = UIStoryboard(name: vcName, bundle: Bundle.main).instantiateViewController(withIdentifier: vcName) as! FirstViewController
        vc.presenter = FirstViewPresenter()
        // PresenterにViewをweakで持たせる
        vc.presenter.applyInterface(view: vc)
        // ModelにPresenterをweakで持たせる
        vc.presenter.datasource.delegate = vc.presenter
        return vc
    }
    
    /// 表示中の画面(UIViewController)を取得する（最前面）
    ///
    /// - Returns: 表示中の画面(失敗した場合はnilを返す)
    static func topVC() -> UIViewController? {
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            var topViewController = rootViewController
            while let presentedViewController = topViewController.presentedViewController {
                topViewController = presentedViewController
            }
            return topViewController
        } else {
            return nil
        }
    }
    
}
