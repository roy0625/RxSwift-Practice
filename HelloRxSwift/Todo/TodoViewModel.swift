//
//  TodoViewModel.swift
//  HelloRxSwift
//
//  Created by roy on 2019/5/20.
//  Copyright © 2019 roy. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol TodoViewModelInput {
    /// Call when viewWillAppear
    var refreshTrigger: PublishSubject<Void> { get }

    /// Call when add new data
    var addItemTrigger: PublishSubject<String> { get }

    /// Call when click delete all button
    var deleteAllItemTrigger: PublishSubject<Void> { get }
}

protocol TodoViewModelOutput {
    var todoItems: Observable<TodoListModel> { get }
}

protocol TodoViewModelType {
    var inputs: TodoViewModelInput { get }
    var outputs: TodoViewModelOutput { get }
}

struct TodoViewModel: TodoViewModelType,
                      TodoViewModelInput,
                      TodoViewModelOutput {

    // MARK: Inputs & Outputs
    var inputs: TodoViewModelInput { return self }
    var outputs: TodoViewModelOutput { return self }

    // MARK: Input
    let refreshTrigger = PublishSubject<Void>()
    let addItemTrigger = PublishSubject<String>()
    let deleteAllItemTrigger = PublishSubject<Void>()
    let deleteItemTrigger = PublishSubject<IndexPath>()
    let switchItemTrigger = PublishSubject<IndexPath>()

    // MARK: Output
    var todoItems: Observable<TodoListModel> {
        return data.asObservable()
    }

    // MARK: Private
    private let disposeBag = DisposeBag()
    private let data = BehaviorRelay<TodoListModel>(value: TodoListModel())
    private var fileDataManager: FileDataManagerSyncActions

    init(fileDataManager: FileDataManagerSyncActions) {
        self.fileDataManager = fileDataManager

        bindInput()
    }

    func bindInput() {
        addItemTrigger
            .subscribe(onNext: { name in
                self.addItem(name: name)
            })
            .disposed(by: disposeBag)

        deleteAllItemTrigger
            .do(onNext: { _ in
                self.fileDataManager.removeFile()
            })
            .bind(to: refreshTrigger)
            .disposed(by: disposeBag)

        deleteItemTrigger
            .subscribe(onNext: { indexPath in
                self.removeItem(indexPath: indexPath)
                self.refreshTrigger.onNext(())
            })
            .disposed(by: disposeBag)

        switchItemTrigger
            .subscribe(onNext: { indexPath in
                self.switchItemDoneStatus(indexPath: indexPath)
                self.refreshTrigger.onNext(())
            })
            .disposed(by: disposeBag)

        let refreshObservable = refreshTrigger.asObserver().map { $0 as AnyObject }
        let addItemObservable = addItemTrigger.asObserver().map { $0 as AnyObject }
        _ = Observable.of(refreshObservable, addItemObservable)
            .merge()
            .flatMap { _ -> Observable<TodoListModel> in
                return self.fileDataManager.getDataFromFile()
            }
            .bind(to: data)
            .disposed(by: disposeBag)
    }

    func addItem(name: String) {
        let item = TodoModel(name: name, isDone: false, time: 0)
        var model = data.value
        model.todo.append(item)
        fileDataManager.writeDataToFile(todos: model)
    }

    func removeItem(indexPath: IndexPath) {
        var model = data.value
        if indexPath.section == TodoItemType.done.rawValue {
            model.done.remove(at: indexPath.row)
        } else {
            model.todo.remove(at: indexPath.row)
        }
        fileDataManager.writeDataToFile(todos: model)
    }

    func switchItemDoneStatus(indexPath: IndexPath) {

        var model = data.value

        if indexPath.section == TodoItemType.done.rawValue {
            var todoModel = model.done[indexPath.row]
            todoModel.isDone = false
            model.done.remove(at: indexPath.row)
            model.todo.append(todoModel)
        } else {
            var todoModel = model.todo[indexPath.row]
            todoModel.isDone = true
            model.todo.remove(at: indexPath.row)
            model.done.append(todoModel)
        }
        fileDataManager.writeDataToFile(todos: model)
    }
}
