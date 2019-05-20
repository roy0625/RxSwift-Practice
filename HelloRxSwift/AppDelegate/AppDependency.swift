//
//  AppDependency.swift
//  HelloRxSwift
//
//  Created by roy on 2019/5/17.
//  Copyright © 2019 roy. All rights reserved.
//

import Foundation

// Manager
struct AppDependency {
    let fileDataManager = FileDataManager()
}

protocol CoordinatingDependency: class {
    var dependency: AppDependency? { set get }
}
