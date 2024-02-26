//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Simon Butenko on 14.02.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
