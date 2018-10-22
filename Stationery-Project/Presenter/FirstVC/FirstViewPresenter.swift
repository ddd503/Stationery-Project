//
//  FirstViewPresenter.swift
//  Stationery-Project
//
//  Created by kawaharadai on 2018/10/13.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import Model

protocol FirstViewPresenterInterface: class {
    func reload()
}

final class FirstViewPresenter: BasePresenter {
    
    weak var interface: FirstViewPresenterInterface?
    let datasource = FirstViewDatasource()
    var sampleDataList = [Sample]()
    
    deinit {
        destroyInterface()
    }
    
    func requestSampleAPI() {
        datasource.callApi(type: .sampleAPI(parameters: [:]))
    }
    
    func fetchSaveData() {
        datasource.fetchSaveData()
    }
    
}

extension FirstViewPresenter: FirstViewDatasourceDelegate {
   
    func receivedSampleData(data: [Sample]) {
        sampleDataList.append(contentsOf: data)
        interface?.reload()
    }
    
    func fetchedSaveData(data: [SaveData]) {
        // SaveDataの初期値はStationery_Project.xcdatamodeldで設定しているためプロパティのnilはない
        sampleDataList.append(contentsOf: data.map { Sample(title: $0.title ?? "", content: $0.content ?? "")})
        interface?.reload()
    }
    
}
