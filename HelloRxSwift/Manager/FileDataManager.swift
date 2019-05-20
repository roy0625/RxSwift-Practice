//
//  FileDataManager.swift
//  HelloMVVMC
//
//  Created by roy on 2019/5/9.
//  Copyright © 2019 roy. All rights reserved.
//

import Foundation
import RxSwift

protocol FileDataManagerSyncActions {
    func writeDataToFile(todos: TodoListModel)
    func getDataFromFile() -> Observable<TodoListModel>
    func removeFile()
}

open class FileDataManager: FileDataManagerSyncActions {

    private let filePath: String = {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/todo.txt"
    }()

    final func writeDataToFile(todos: TodoListModel) {

        do {
            let data = try JSONEncoder().encode(todos)
            try data.write(to: URL(fileURLWithPath: filePath), options: .atomic)
        } catch {
            print("wite file error: \(error)")
        }
    }

    func getDataFromFile() -> Observable<TodoListModel> {
        return Observable.create({ [weak self] subscriber in
            guard
                let self = self,
                FileManager.default.fileExists(atPath: self.filePath) else {
                    subscriber.onNext(TodoListModel())
                    return Disposables.create()
            }

            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: self.filePath, isDirectory: false))
                let decoder = JSONDecoder()
                let list = try decoder.decode(TodoListModel.self, from: data)
                print("list: \(list)")

                subscriber.onNext(list)
                subscriber.onCompleted()

            } catch {
                print("error: \(error)")
                subscriber.onError(error)
            }

            return Disposables.create()
        })
    }

    func removeFile() {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: filePath)
            print("delete file success")
        } catch {
            print("remove data fail: \(error)")
        }
    }
}
