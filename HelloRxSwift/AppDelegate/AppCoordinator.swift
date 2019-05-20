//
//  AppCoordinator.swift
//  HelloRxSwift
//
//  Created by roy on 2019/5/17.
//  Copyright © 2019 roy. All rights reserved.
//

import UIKit

class AppCoordinator: Coordinator<UINavigationController> {

    private let dependency = AppDependency()
    private let navigationDelegateProxy = NavigationDelegateProxy()


    override func start() {
        rootViewController.delegate = navigationDelegateProxy
        let todoCoordinator = TodoCoordinator(viewController: rootViewController)
        todoCoordinator.dependency = dependency
        startChild(coordinator: todoCoordinator)
        super.start()
    }
}
