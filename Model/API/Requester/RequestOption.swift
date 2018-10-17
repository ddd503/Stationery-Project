//
//  RequestOption.swift
//  Model
//
//  Created by kawaharadai on 2018/10/13.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import Alamofire

/// 使用するAPIのペースURL
private let baseURL = "任意のベースURLを入れる"

public enum RequestOption: URLRequestConvertible {
    case sampleAPI() // 必要に応じて引数でパラメータにセットする値を受け取る
    
    public func asURLRequest() throws -> URLRequest {
        
        /// path: 叩くAPIのpath, method: request形式, parameters: 渡すパラメータ、をそれぞれセット
        let (path, method, parameters): (String, HTTPMethod, [String: Any]) = {
            switch self {
            case .sampleAPI:
                return ("任意のAPIPathを入れる", .get, searchParameters())
            }
        }()
        
        if let url = URL(string: baseURL) {
            var urlRequest = URLRequest(url: url.appendingPathComponent(path))
            urlRequest.httpMethod = method.rawValue
            return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
        } else {
            fatalError("url is nil")
        }
        
    }
    
    /// 必要の際はここでパラメータをセットする
    private func searchParameters() -> [String: Any] {
        return [:]
    }
    
}
