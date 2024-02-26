//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Simon Butenko on 15.02.2024.
//

import UIKit

protocol AlertPresenterProtocol {
    func show(title: String, message: String, buttonText: String, completion: @escaping () -> Void)
}

final class AlertPresenter: AlertPresenterProtocol {
    // MARK: - Public Properties

    private weak var viewController: UIViewController?

    // MARK: - Initializers

    init(viewController: UIViewController?) {
        self.viewController = viewController
    }

    // MARK: - Public Methods

    func show(title: String, message: String, buttonText: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.view.accessibilityIdentifier = "Alert"

        alert.addAction(
            UIAlertAction(title: buttonText, style: .default) { _ in
                completion()
            }
        )

        viewController?.present(alert, animated: true, completion: nil)
    }
}
