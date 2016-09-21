//
//  CoordinatorType.swift
//  GameController
//
//  Created by Reid Chatham on 9/19/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import Foundation

protocol CoordinatorType: class {
    var childCoordinators: [CoordinatorType] { get }
}
