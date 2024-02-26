import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Outlets

    @IBOutlet private var indexLabel: UILabel!
    @IBOutlet private var previewImage: UIImageView!
    @IBOutlet private var questionLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    
    // MARK: - Dependencies

    private var questionFactory: QuestionFactoryProtocol!
    private var alertPresenter: AlertPresenterProtocol!
    private var statisticService: StatisticService!
    
    // MARK: - Properties

    private let questionsAmount = 5
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
        questionFactory = QuestionFactory()
        alertPresenter = AlertPresenter()
        statisticService = StatisticServiceImpl()
        
        questionFactory.delegate = self
        alertPresenter.delegate = self
        
        questionFactory.requestNextQuestion()
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
    
    // MARK: - Private functions

    private func convertFromModelToVM(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            imageUI: UIImage(named: model.image)!,
            questionText: model.text,
            questionNumberText: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    private func setState(_ vm: QuizStepViewModel) {
        indexLabel.text = vm.questionNumberText
        previewImage.image = vm.imageUI
        questionLabel.text = vm.questionText
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
        let model = AlertModel(
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
        alertPresenter.show(model: model)
    }
        
    private func prepareForNewRound() {
        currentQuestionIndex = 0
        correctAnswersCounter = 0
        questionFactory.requestNextQuestion()
    }
}

// MARK: - QuestionFactoryDelegate

extension MovieQuizViewController {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        
        let vm = convertFromModelToVM(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.setState(vm)
        }
    }
}
