//
//  MovieQuizPresenterTests.swift
//  MovieQuizUITests
//
//  Created by Simon Butenko on 26.02.2024.
//

@testable import MovieQuiz
import XCTest

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    var isActionsEnabled = true
    func show(_ viewModel: QuizStepViewModel) {}
    func show(_ viewModel: QuizResultsViewModel) {}
    func show(_ viewModel: QuizErrorViewModel) {}
    func setLoadingIndicator(show: Bool) {}
    func highlightImageBorderAndFeedback(isCorrectAnswer: Bool) {}
    func resetImageBorder() {}
}

final class MovieQuizPresenterTest: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)

        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.fromModelToViewModel(model: question)

        XCTAssertNotNil(viewModel.imageUI)
        XCTAssertEqual(viewModel.questionText, "Question Text")
        XCTAssertEqual(viewModel.questionNumberText, "1/10")
    }
}
