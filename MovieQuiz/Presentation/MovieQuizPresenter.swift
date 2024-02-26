//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Simon Butenko on 25.02.2024.
//

import UIKit

final class MovieQuizPresenter {
    // MARK: - Constants

    private let questionsAmount = 10
    private let statisticService: StatisticService

    // MARK: - Public Properties

    var isLastQuestion: Bool {
        currentQuestionIndex == questionsAmount - 1
    }

    // MARK: - Private Properties

    private weak var viewController: MovieQuizViewControllerProtocol?
    private var questionFactory: QuestionFactoryProtocol?

    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    private var correctAnswersCounter = 0

    // MARK: - Initializers

    init(viewController: MovieQuizViewControllerProtocol?) {
        self.viewController = viewController

        statisticService = StatisticServiceImpl()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)

        reloadData()
    }

    // MARK: - Public Methods

    func fromModelToViewModel(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            imageUI: UIImage(data: model.image) ?? UIImage(),
            questionText: model.text,
            questionNumberText: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }

    func noButtonClicked() {
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }

    func yesButtonClicked() {
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }

    func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswersCounter, total: questionsAmount)

        let bestGame = statisticService.bestGame

        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswersCounter)\\\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)"
            + " (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"

        let resultMessage = [
            currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
        ].joined(separator: "\n")

        return resultMessage
    }

    func reloadData() {
        questionFactory?.loadData()
        viewController?.setLoadingIndicator(show: true)
    }

    func resetGame() {
        currentQuestionIndex = 0
        correctAnswersCounter = 0
        questionFactory?.requestNextQuestion()
    }

    // MARK: - Private Methods

    private func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer { correctAnswersCounter += 1 }
    }

    private func showNextQuestionOrResults() {
        if isLastQuestion {
            viewController?.show(
                QuizResultsViewModel(
                    title: "Этот раунд окончен!",
                    buttonText: "Сыграть ещё раз"
                )
            )
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }

    private func showAnswerResult(isCorrect: Bool) {
        viewController?.highlightImageBorderAndFeedback(isCorrectAnswer: isCorrect)
        viewController?.isActionsEnabled = false

        didAnswer(isCorrectAnswer: isCorrect)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.viewController?.resetImageBorder()
            self.viewController?.isActionsEnabled = true
            showNextQuestionOrResults()
        }
    }
}

// MARK: - QuestionFactoryDelegate

extension MovieQuizPresenter: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question

        let viewModel = fromModelToViewModel(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(viewModel)
            self?.viewController?.setLoadingIndicator(show: false)
        }
    }

    func didLoadData() {
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        viewController?.show(
            QuizErrorViewModel(
                title: "Ошибка",
                text: "Не удалось получить данные:\n\(error.localizedDescription)",
                buttonText: "Повторить"
            )
        )
    }
}
