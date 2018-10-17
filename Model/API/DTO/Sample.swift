//
//  Sample.swift
//  Model
//
//  Created by kawaharadai on 2018/10/13.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import Foundation

/// APIごとに任意のマッピングモデルを用意する
public struct Sample: Codable {
    // 外部からのinitを許可
    public init(title: String, content: String) {
        self.title = title
        self.content = content
    }
    public var title = ""
    public var content = ""
    private enum CodingKeys: String, CodingKey {
        case title = "title"
        case content = "description"
    }
}
