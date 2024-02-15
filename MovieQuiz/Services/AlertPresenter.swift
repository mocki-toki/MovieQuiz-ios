//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Simon Butenko on 15.02.2024.
//

import Foundation
import UIKit

protocol AlertPresenterProtocol {
    var delegate: UIViewController? { get set }
    func show(model: AlertModel)
}

class AlertPresenter: AlertPresenterProtocol {
    weak var delegate: UIViewController?

    func show(model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: model.buttonText, style: .default) { _ in
                model.completion()
            }
        )

        delegate?.present(alert, animated: true, completion: nil)
    }
}
