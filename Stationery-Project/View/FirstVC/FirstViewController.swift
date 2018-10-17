//
//  FirstViewController.swift
//  Stationery-Project
//
//  Created by kawaharadai on 2018/10/13.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import UIKit

final class FirstViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(UINib(nibName: FirstViewCell.identifier, bundle: nil),
                               forCellReuseIdentifier: FirstViewCell.identifier)
            tableView.tableFooterView = UIView()
        }
    }
    
    var presenter: FirstViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // APIからデータを取得
        presenter.requestSampleAPI()
        // LocalDBからデータを取得（ある前提）
//        presenter.fetchSaveData()
    }
    
}

extension FirstViewController: FirstViewPresenterInterface {
    
    func reload() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}

extension FirstViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.sampleDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FirstViewCell.identifier, for: indexPath) as? FirstViewCell else {
            fatalError("cell is nil")
        }
        let cellData = presenter.sampleDataList[indexPath.row]
        cell.setCellData(title: cellData.title, content: cellData.content)
        return cell
    }
    
}

extension FirstViewController: UITableViewDelegate {}
