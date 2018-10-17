//
//  APIClient.swift
//  Model
//
//  Created by kawaharadai on 2018/10/13.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import Alamofire

enum APIRequestResult {
    case success(Data)
    case failure(Error)
    case doNotRequest // オフラインのため通信自体を行わない
}

final class APIClient {
    
    /// API通信を行う
    ///
    /// - Parameters:
    ///   - option: リクエストするパラメータなど
    ///   - completionHandler: 実行結果を返す
    static func request(option: RequestOption, completionHandler: @escaping (APIRequestResult) -> ()) {
        guard onLineNetwork() else {
            completionHandler(.doNotRequest)
            return
        }
        Alamofire.request(option).responseData { response in
            switch response.result {
            case .success(let value):
                completionHandler(.success(value))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    /// 通信状態を返す
    ///
    /// - Returns: true: オンライン, false: オフライン
    static func onLineNetwork() -> Bool {
        if let reachabilityManager = NetworkReachabilityManager() {
            reachabilityManager.startListening()
            return reachabilityManager.isReachable
        }
        return false
    }
    
}
