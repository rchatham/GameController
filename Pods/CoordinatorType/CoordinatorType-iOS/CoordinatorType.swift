//
//  CoordinatorType.swift
//  CoordinatorType
//
//  Created by Reid Chatham on 2/26/17.
//
//

import UIKit

public protocol CoordinatorType: CoordinatorTypeDelegate {
    weak var delegate: CoordinatorTypeDelegate? { get }
    var childCoordinators: [CoordinatorType] { get set }
    func viewController() -> UIViewController
    func start(onViewController viewController: UIViewController, animated: Bool)
}

extension CoordinatorType {
    public func start(onViewController viewController: UIViewController, animated: Bool) {
        viewController.present(self.viewController(), animated: animated, completion: nil)
    }
}

public protocol CoordinatorTypeDelegate: class {
    func coordinatorDidFinish(_ coordinator: CoordinatorType)
}

extension CoordinatorTypeDelegate where Self: CoordinatorType {
    public func coordinatorDidFinish(_ coordinator: CoordinatorType) {
        guard let idx = childCoordinators.index(where: { $0 === coordinator }) else { return }
        childCoordinators.remove(at: idx)
    }
}
