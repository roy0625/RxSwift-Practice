//
//  TodoModel.swift
//  HelloMVVMC
//
//  Created by roy on 2019/5/9.
//  Copyright © 2019 roy. All rights reserved.
//

import Foundation

enum TodoItemType: Int {
    case todo = 0
    case done = 1
}

struct TodoListModel: Codable, Equatable {

    var todo: [TodoModel]
    var done: [TodoModel]

    // Equatable
    static func == (lhs: TodoListModel, rhs: TodoListModel) -> Bool {
        return lhs.todo == rhs.todo && lhs.done == rhs.done
    }

    init() {
        self.todo = []
        self.done = []
    }
}

struct TodoModel : Codable, Equatable {
    var name: String
    var isDone: Bool
    var time: Int
}
