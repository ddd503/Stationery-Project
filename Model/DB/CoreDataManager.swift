//
//  CoreDataManager.swift
//  Model
//
//  Created by kawaharadai on 2018/10/12.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import CoreData

protocol CoreDataManagerDelegate: class {
    func fetchedSaveData(data: [SaveData])
}

public final class CoreDataManager: NSObject {
    
    /// シングルトン
    public static let shered = CoreDataManager()
    /// プロジェクト名
    private let containerName = "Stationery_Project"
    /// 処理結果を返すプロトコル
    weak var delegate: CoreDataManagerDelegate?
    
    // MARK: - Context
    
    /// 処理の永続化を確定する親のContext(persistentStoreCoordinatorへ直接アクセスする役)
    func whiteContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        return context
    }
    /// メインスレッドで処理を行うためのContext
    func mainThreadContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = whiteContext()
        return context
    }
    /// サブスレッドで処理を行うためのContext
    func subThreadContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = mainThreadContext()
        return context
    }
    
    /// 大元の親Contextを取得する（永続化を行えるContext）
    ///
    /// - Parameter context: 親がいるかどうかをチェックするContext
    /// - Returns: 親Context（親がいない大元Contextが来るまでメソッドを呼び続ける）
    private func getParentContext(context: NSManagedObjectContext) -> NSManagedObjectContext {
        if let parentContext = context.parent {
            return getParentContext(context: parentContext)
        } else {
            // ここで返るのが親のContext
            return context
        }
    }
    
    /// 永続化を行う
    private(set) lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        let fileManager = FileManager.default
        let storeName = "\(containerName).sqlite"
        let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let persistentStoreURL = documentsDirectoryURL.appendingPathComponent(storeName)
        do {
            let options = [NSInferMappingModelAutomaticallyOption: true,
                           NSMigratePersistentStoresAutomaticallyOption: true]
            
            try container.persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                                        configurationName: nil,
                                                                        at: persistentStoreURL,
                                                                        options: options)
        } catch {
            fatalError("Unable to Load Persistent Store")
        }
        return container
    }()
    
    // MARK: - Notification
    
    /// contextのsaveメソッドの呼び出しを通知する（保存完了通知）を登録する
    ///
    /// - Parameters:
    ///   - delegate: 通知を受ける対象（クラス）
    ///   - selector: 通知を受けて走るデリゲートメソッド
    ///   - context: 操作を行うContext
    private func addSaveNotification(delegate: Any?, selector: Selector?, context: NSManagedObjectContext) {
        guard let delegate = delegate, let selector = selector else { return }
        NotificationCenter.default.addObserver(delegate,
                                               selector: selector,
                                               name: NSNotification.Name.NSManagedObjectContextDidSave,
                                               object: context)
    }
    
    /// contextの保存完了通知の登録を解除する
    ///
    /// - Parameters:
    ///   - delegate: 登録を解除するクラス
    ///   - context: 登録を解除するContext
    private func removeSaveNotification(delegate: Any?, context: NSManagedObjectContext) {
        guard let delegate = delegate else { return }
        NotificationCenter.default.removeObserver(delegate,
                                                  name: NSNotification.Name.NSManagedObjectContextDidSave,
                                                  object: context)
    }
    
    // MARK: - ID
    
    /// オブジェクトに対して任意のuniqueIDを発行する
    ///
    /// - Parameters:
    ///   - entityName: entity名
    ///   - idKey: idとするプロパティ名
    /// - Returns: 任意のuniqueID
    private func createNewId(context: NSManagedObjectContext, entityName: String, idKey: String) -> Int {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        do {
            let fetchedArray = try context.fetch(fetchRequest)
            guard !fetchedArray.isEmpty else { return 1 }
            let ids = fetchedArray.compactMap {
                $0.value(forKey: idKey) as? Int
            }
            guard !ids.isEmpty, let maxId = ids.max() else { return 1 }
            return maxId + 1
        } catch {
            return 0
        }
    }
    
    // MARK: - Save
    
    /// 保存処理(アプリ終了時に呼び出す用)
    public func saveContext () {
        let context = mainThreadContext()
        if context.hasChanges {
            do {
                try context.save()
                self.saveParentContext(parent: context.parent)
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    /// 親のContextを更新する
    ///
    /// - Parameter parent: 親のContext
    private func saveParentContext(parent: NSManagedObjectContext?) {
        guard let parent = parent else { return }
        parent.perform {
            do {
                try parent.save()
                if let parent = parent.parent {
                    // 親がさらに存在する場合は再度呼び出す
                    self.saveParentContext(parent: parent)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    /// 非同期でデータ保存（サンプルデータを保存、保存モデル毎にメソッドを分けた方がいいかも）
    ///
    /// - Parameters:
    ///   - sample: サンプルデータ
    ///   - context: 保存データを管理するcontext(必ずサブスレッド用のものを渡す)
    ///   - delegate: 保存完了通知を受ける場合はそのクラスを渡す
    ///   - selector: 保存完了通知を受けて走るメソッド
    public func saveSampleData(samples: [Sample],
                               context: NSManagedObjectContext,
                               delegate: Any?,
                               selector: Selector?) {
        context.perform {
            /// 保存完了通知の登録（subのsave時に走る、親は追えない）
            self.addSaveNotification(delegate: delegate, selector: selector, context: context)
            /// 非同期処理完了後に保存完了通知を消す
            defer { self.removeSaveNotification(delegate: delegate, context: context) }
            
            let entityName = "SaveData"
            samples.forEach {
                let newId = Int64(self.createNewId(context: context,
                                                   entityName: entityName,
                                                   idKey: "id"))
                // midの新規作成に失敗した場合はリターン
                guard newId > 0 else { return }
                guard let entity = NSEntityDescription.entity(forEntityName: entityName,
                                                              in: context) else {
                                                                print("entity is nil")
                                                                return
                }
                guard let saveData = NSManagedObject(entity: entity,
                                                     insertInto: context) as? SaveData else {
                                                        print("saveData is nil")
                                                        return
                }
                saveData.id = newId
                saveData.title = $0.title
                saveData.content = $0.content
            }
            do {
                try context.save()
                self.saveParentContext(parent: context.parent)
            } catch let error as NSError {
                print("error: \(error.localizedDescription)")
            }
        }
        
    }
    
    // MARK: - Fetch
    
    /// 指定したEntityを非同期でfetchして返す
    ///
    /// - Parameters:
    ///   - entityName: Entity名
    ///   - sortKey: ソートキー（必須）
    public func fetchByResultsController(entityName: String,
                                         sortKey: String) {
        
        let context = subThreadContext()
        
        context.perform {
            // NSFetchedResultsControllerの生成
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
            fetchRequest.entity = entity
            /// ソートキーの指定。セクションが存在する場合セクションに対応した属性を最初に指定する(必須)（複数keyの指定は配列の要素を増やす）
            /// ascendind: true 昇順、false 降順
            let sortDescriptor = NSSortDescriptor(key: sortKey, ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                      managedObjectContext: context,
                                                                      sectionNameKeyPath: nil,
                                                                      cacheName: nil)
            do {
                try fetchedResultsController.performFetch()
                self.delegate?.fetchedSaveData(data: (fetchedResultsController.fetchedObjects ?? []).compactMap { $0 as? SaveData })
            } catch let error as NSError {
                print("error: \(error.localizedDescription)")
            }
        }
        
    }
    
}
