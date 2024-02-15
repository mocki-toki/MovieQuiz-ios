//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Simon Butenko on 15.02.2024.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}
