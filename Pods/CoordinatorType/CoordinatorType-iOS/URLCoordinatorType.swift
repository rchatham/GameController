//
//  URLCoordinatorType.swift
//  CoordinatorType
//
//  Created by Reid Chatham on 5/2/17.
//
//

import UIKit

public protocol URLCoordinatorType: CoordinatorType {
    func viewController(configuredWith url: URL) -> UIViewController
    func start(onViewController viewController: UIViewController, withURL url: URL, animated: Bool)
}

extension URLCoordinatorType {
    public func start(onViewController viewController: UIViewController, withURL url: URL, animated: Bool) {
        viewController.present(self.viewController(configuredWith: url), animated: animated, completion: nil)
    }
}
