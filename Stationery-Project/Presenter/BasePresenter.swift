//
//  BasePresenter.swift
//  Stationery-Project
//
//  Created by kawaharadai on 2018/10/13.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

protocol BasePresenter: class {
    // それぞれの準拠元で柔軟的に型を決定できる値（protcol版ジェネリクス）
    associatedtype ViewObject
    // Presenterクラス側でViewクラスを保持する用propatie
    // デフォルト実装で、自動的に渡されたViewクラスをPresenterクラスのinterface変数(protcol)にセットする
    var interface: ViewObject? { get set }
    
    func applyInterface(view: ViewObject)
    
    func destroyInterface()
}

/// 今回はデフォルト実装でPresenter側でのViewクラスの保持方を共通化
extension BasePresenter {
    /// Presenterクラス側で状態を管理するViewクラスを設定する()
    ///
    /// - Parameter view: viewクラス
    func applyInterface(view: ViewObject) {
        interface = view
    }
    /// presenterはdeinit時にこれを呼んで自身が持つViewクラスインスタンスを破棄する（相互参照でVとMが消えないことの防止）
    func destroyInterface() {
        interface = nil
    }
}
