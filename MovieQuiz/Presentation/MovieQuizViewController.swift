import UIKit

class Movie {
    let name: String
    let rating: Double
    
    init(name: String, rating: Double) {
        self.name = name
        self.rating = rating
    }
}

struct QuizQuestion {
    let image: String
    let text: String
    let correctAnswer: Bool
}

struct QuizStepViewModel {
    let imageUI: UIImage
    let questionText: String
    let questionNumberText: String
}

struct QuizResultsViewModel {
    let title: String
    let text: String
    let buttonText: String
}

final class MovieQuizViewController: UIViewController {
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        ),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        ),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        ),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        )
    ]
    
    private var currentQuestionIndex = 0
    private var correctAnswersCounter = 0
    
    @IBOutlet private var indexLabel: UILabel!
    @IBOutlet private var previewImage: UIImageView!
    @IBOutlet private var questionLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    
    private var isActionsEnabled: Bool {
        get {
            return noButton.isEnabled
        }
        set(value) {
            noButton.isEnabled = value
            yesButton.isEnabled = value
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        show(convertFromModelToVM(model: questions[currentQuestionIndex]))
    }
    
    private func convertFromModelToVM(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            imageUI: UIImage(named: model.image)!,
            questionText: model.text,
            questionNumberText: "\(currentQuestionIndex + 1)/\(questions.count)"
        )
    }
    
    private func show(_ vm: QuizStepViewModel) {
        indexLabel.text = vm.questionNumberText
        previewImage.image = vm.imageUI
        questionLabel.text = vm.questionText
    }
    
    private func show(_ vm: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: vm.title,
            message: vm.text,
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(title: vm.buttonText, style: .default) { _ in
                self.currentQuestionIndex = 0
                self.correctAnswersCounter = 0
                self.showCurrentQuestion()
            }
        )
        
        present(alert, animated: true, completion: nil)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        previewImage.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        if isCorrect { correctAnswersCounter += 1 }
        isActionsEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isActionsEnabled = true
            self.previewImage.layer.borderColor = UIColor.clear.cgColor
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            show(
                QuizResultsViewModel(
                    title: "Этот раунд окончен!",
                    text: "Ваш результат: \(correctAnswersCounter)/\(questions.count)",
                    buttonText: "Сыграть ещё раз"
                )
            )
        } else {
            currentQuestionIndex += 1
            showCurrentQuestion()
        }
    }
    
    private func showCurrentQuestion() {
        let currentQuestion = questions[currentQuestionIndex]
        let viewModel = convertFromModelToVM(model: currentQuestion)
        
        show(viewModel)
    }

    @IBAction private func noButtonClicked(_ sender: Any) {
        let isCorrect = questions[currentQuestionIndex].correctAnswer == false
        showAnswerResult(isCorrect: isCorrect)
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        let isCorrect = questions[currentQuestionIndex].correctAnswer == true
        showAnswerResult(isCorrect: isCorrect)
    }
}
