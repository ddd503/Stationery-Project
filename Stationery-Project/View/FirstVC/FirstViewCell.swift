//
//  FirstViewCell.swift
//  Stationery-Project
//
//  Created by kawaharadai on 2018/10/13.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import UIKit

final class FirstViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    static var identifier: String {
        return String(describing: self)
    }
    
    func setCellData(title: String, content: String) {
        titleLabel.text = title
        contentLabel.text = content
    }
    
}
