//
//  HelloRxSwiftTests.swift
//  HelloRxSwiftTests
//
//  Created by roy on 2019/5/13.
//  Copyright © 2019 roy. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxBlocking
@testable import HelloRxSwift

class HelloRxSwiftTests: XCTestCase {
    var scheduler: ConcurrentDispatchQueueScheduler!
    var viewModel: TodoViewModel!
    var subscription: Disposable!

    class FileManager: FileDataManagerSyncActions {
        private var items = TodoListModel()
        func writeDataToFile(todos: TodoListModel) {
            items = todos
        }

        func getDataFromFile() -> Observable<TodoListModel> {
            return Observable.just(items)
        }

        func removeFile() {
            items = TodoListModel()
        }
    }

    override func setUp() {
        viewModel = TodoViewModel(fileDataManager: FileManager())
        scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testAddItem() {
        let itemObservable = viewModel.todoItems.asObservable().subscribeOn(scheduler)

        viewModel.addItemTrigger.onNext("Hello")

        var result = TodoListModel()
        result.todo.append(TodoModel(name: "Hello", isDone: false, time: 0))

        XCTAssertEqual(try itemObservable.toBlocking(timeout: 1.0).first(), result)
    }

    func testRemoveAllItem() {
        let itemObservable = viewModel.todoItems.asObservable().subscribeOn(scheduler)

        viewModel.deleteAllItemTrigger.onNext(())

        let result = TodoListModel()

        XCTAssertEqual(try itemObservable.toBlocking(timeout: 1.0).first(), result)
    }
}
