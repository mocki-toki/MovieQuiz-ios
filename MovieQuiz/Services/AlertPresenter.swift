//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Simon Butenko on 15.02.2024.
//

import UIKit

protocol AlertPresenterProtocol {
    func show(_ viewModel: AlertViewModel)
}

class AlertPresenter: AlertPresenterProtocol {
    // MARK: - Public Properties

    private weak var delegate: UIViewController?

    // MARK: - Initializers

    init(delegate: UIViewController?) {
        self.delegate = delegate
    }

    // MARK: - Public Methods

    func show(_ viewModel: AlertViewModel) {
        let alert = UIAlertController(
            title: viewModel.title,
            message: viewModel.message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: viewModel.buttonText, style: .default) { _ in
                viewModel.completion()
            }
        )

        delegate?.present(alert, animated: true, completion: nil)
    }
}
