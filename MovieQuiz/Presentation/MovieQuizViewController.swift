import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Constants

    private let questionsAmount = 10

    // MARK: - Outlets

    @IBOutlet private var indexLabel: UILabel!
    @IBOutlet private var previewImage: UIImageView!
    @IBOutlet private var questionLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var body: UIStackView!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!

    // MARK: - Private Properties

    private var questionFactory: QuestionFactoryProtocol!
    private var alertPresenter: AlertPresenterProtocol!
    private var statisticService: StatisticService!

    private var currentQuestionIndex = 0
    private var correctAnswersCounter = 0
    private var currentQuestion: QuizQuestion?

    private var isActionsEnabled: Bool {
        get {
            return noButton.isEnabled && yesButton.isEnabled
        }
        set(value) {
            noButton.isEnabled = value
            yesButton.isEnabled = value
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        alertPresenter = AlertPresenter(delegate: self)
        statisticService = StatisticServiceImpl()

        setLoadingIndicator(show: true)
        questionFactory.loadData()
    }

    // MARK: - Actions

    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }

    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }

    // MARK: - Private Methods

    private func setState(_ viewModel: QuizStepViewModel) {
        indexLabel.text = viewModel.questionNumberText
        previewImage.image = viewModel.imageUI
        questionLabel.text = viewModel.questionText
    }

    private func setLoadingIndicator(show: Bool) {
        activityIndicator.isHidden = !show
        body.isHidden = show
    }

    private func showNetworkError(message: String) {
        setLoadingIndicator(show: false)

        let viewModel = AlertViewModel(
            title: "Ошибка",
            message: "Не удалось получить данные:\nmessage",
            buttonText: "Повторить"
        ) { [weak self] in
            self?.prepareForNewRound()
        }
        alertPresenter.show(viewModel)
    }

    private func showAnswerResult(isCorrect: Bool) {
        previewImage.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        if isCorrect { correctAnswersCounter += 1 }
        isActionsEnabled = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.resetAfterAnswer()
        }
    }

    private func resetAfterAnswer() {
        previewImage.layer.borderColor = UIColor.clear.cgColor
        isActionsEnabled = true
        showNextQuestionOrResults()
    }

    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            showResults()
        } else {
            currentQuestionIndex += 1
            questionFactory.requestNextQuestion()
        }
    }

    private func showResults() {
        statisticService.store(correct: correctAnswersCounter, total: questionsAmount)
        let best = statisticService.bestGame
        let viewModel = AlertViewModel(
            title: "Этот раунд окончен!",
            message:
            "Ваш результат: \(correctAnswersCounter)/\(questionsAmount)\n" +
                "Всего игр: \(statisticService.gamesCount)\n" +
                "Общая аккуратность: \(String(format: "%.2f", statisticService.totalAccuracy))%\n" +
                "Лучший рекорд: \(best.correct) (\(best.date.dateTimeString))",
            buttonText: "Сыграть ещё раз"
        ) { [weak self] in
            self?.prepareForNewRound()
        }
        alertPresenter.show(viewModel)
    }

    private func prepareForNewRound() {
        currentQuestionIndex = 0
        correctAnswersCounter = 0
        questionFactory.requestNextQuestion()
    }

    private func fromModelToViewModel(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            imageUI: UIImage(data: model.image) ?? UIImage(),
            questionText: model.text,
            questionNumberText: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
}

// MARK: - QuestionFactoryDelegate

extension MovieQuizViewController {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question

        let viewModel = fromModelToViewModel(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.setState(viewModel)
            self?.setLoadingIndicator(show: false)
        }
    }

    func didLoadData() {
        questionFactory.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
}
