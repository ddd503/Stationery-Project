//
//  FirstViewDatasource.swift
//  Model
//
//  Created by kawaharadai on 2018/10/13.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

public protocol FirstViewDatasourceDelegate: class {
    // TODO: - API、DBそれぞれのレスポンスの型が違うのは問題
    /// APIから取得したSampleデータを返す
    func receivedSampleData(data: [Sample])
    /// DBから取得したSaveDataを返す
    func fetchedSaveData(data: [SaveData])
}

public final class FirstViewDatasource {
    
    public weak var delegate: FirstViewDatasourceDelegate?
    
    /// 外部からの参照のため改めてpublicでイニシャライザを定義
    public init() {}
    
    public func callApi(type: RequestOption) {
        APIClient.request(option: type) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let data):
                self.returnResponse(type: type, data: data)
            case .failure(let error):
                print(error)
            case .doNotRequest:
                print("not")
            }
        }
    }
    
    /// APIからのレスポンスを指定したモデルクラス(Codable準拠)にマッピングしてデリゲートを返す
    ///
    /// - Parameters:
    ///   - type: APIの種別
    ///   - data: APIからのレスポンス
    public func returnResponse(type: RequestOption, data: Data) {
        do {
            let decoder = JSONDecoder()
            switch type {
            case .sampleAPI():
                let samples = try decoder.decode([Sample].self, from: data)
                // DBにレスポンスデータを保存
                CoreDataManager.shered.saveSampleData(samples: samples, context: CoreDataManager.shered.subThreadContext(), delegate: nil, selector: nil)
                // レスポンスをデリゲートで返す
                self.delegate?.receivedSampleData(data: samples)
            }
        } catch let error {
            print("failure mapping")
            print("error: \(error.localizedDescription)")
        }
    }
    
    public func fetchSaveData() {
        CoreDataManager.shered.delegate = self
        CoreDataManager.shered.fetchByResultsController(entityName: "SaveData", sortKey: "id")
    }
    
}

extension FirstViewDatasource: CoreDataManagerDelegate {
    
    /// DBからfetchしたデータを返す
    func fetchedSaveData(data: [SaveData]) {
        delegate?.fetchedSaveData(data: data)
    }
    
}
