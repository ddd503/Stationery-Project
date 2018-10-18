//
//  CoreDataManagerTest.swift
//  ModelTests
//
//  Created by kawaharadai on 2018/10/14.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import XCTest
import CoreData
@testable import Model

final class CoreDataManagerTest: XCTestCase {
    
    private var expectation: XCTestExpectation?
    
    override func setUp() {
        allDelete(entityName: "SaveData")
    }
    
    override func tearDown() {
        allDelete(entityName: "SaveData")
    }
    
    func test_saveSampleData_非同期でデータの保存テスト() {
        expectation = self.expectation(description: "データの保存テスト")
        let testSamples = [Sample(title: "テストタイトル1", content: "テストコンテンツ1")]
        CoreDataManager.shered.saveSampleData(samples: testSamples,
                                              context: CoreDataManager.shered.subThreadContext(),
                                              delegate: self,
                                              selector: #selector(self.finisedSave(notification:)))
        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    /// 上記の処理をハンドリングして保存結果を判定
    @objc func finisedSave(notification: Notification) {
        expectation?.fulfill()
        if let userInfo = notification.userInfo, let insertedData = userInfo[NSInsertedObjectsKey] as? Set<SaveData> {
            let saveData: [SaveData] = insertedData.compactMap { $0 } // nilを省く
            XCTAssertNotNil(saveData)
            XCTAssertEqual(saveData.first!.title, "テストタイトル1")
            XCTAssertEqual(saveData.first!.content, "テストコンテンツ1")
        } else {
            XCTFail()
        }
    }
    
    // TODO: - 現状データの永続化完了(親ContextのSave)の通知を受ける方法がないため、このテストは失敗する
    func test_fetchByResultsController_指定したEntityのデータを全件取得するテスト() {
        expectation = self.expectation(description: "データの取得テスト")
        let sampleData = [Sample(title: "fetch用タイトル1", content: "fetch用コンテンツ1"),
                           Sample(title: "fetch用タイトル2", content: "fetch用コンテンツ2")]
        CoreDataManager.shered.saveSampleData(samples: sampleData,
                                              context: CoreDataManager.shered.subThreadContext(),
                                              delegate: self,
                                              selector: #selector(self.callFetch(notification:)))
        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    /// 上記の処理をハンドリングして保存結果を判定
    @objc func callFetch(notification: Notification) {
        CoreDataManager.shered.delegate = self
        CoreDataManager.shered.fetchByResultsController(entityName: "SaveData", sortKey: "id")
    }
    
    /// 全件削除
    private func allDelete(entityName: String) {
        let context = CoreDataManager.shered.mainThreadContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try! context.execute(deleteRequest)
    }
    
}

extension CoreDataManagerTest: CoreDataManagerDelegate {
    
    func fetchedSaveData(data: [SaveData]) {
        expectation?.fulfill()
        XCTAssertEqual(data.count, 2)
        XCTAssertEqual(data.first!.title, "fetch用タイトル1")
        XCTAssertEqual(data.first!.content, "fetch用コンテンツ1")
    }
    
}
