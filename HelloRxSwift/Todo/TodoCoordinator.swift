//
//  TodoCoordinator.swift
//  HelloRxSwift
//
//  Created by roy on 2019/5/20.
//  Copyright © 2019 roy. All rights reserved.
//

import UIKit

class TodoCoordinator: Coordinator<UINavigationController> {

    var dependency: AppDependency?

    override func start() {
        guard !started,
            let fileDataManager = dependency?.fileDataManager
            else { return }

        let todoViewModel = TodoViewModel(fileDataManager: fileDataManager)
        let vc = TodoViewController(viewModel: todoViewModel)
        vc.coordinator = self
        rootViewController.viewControllers = [vc]

        super.start()
    }
}
