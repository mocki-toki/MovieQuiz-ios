import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    var isActionsEnabled: Bool { get set }
    func show(_ viewModel: QuizStepViewModel)
    func show(_ viewModel: QuizResultsViewModel)
    func show(_ viewModel: QuizErrorViewModel)

    func setLoadingIndicator(show: Bool)

    func highlightImageBorderAndFeedback(isCorrectAnswer: Bool)
    func resetImageBorder()
}

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    // MARK: - Public Properties

    var isActionsEnabled: Bool {
        get {
            return noButton.isEnabled && yesButton.isEnabled
        }
        set(value) {
            noButton.isEnabled = value
            yesButton.isEnabled = value
        }
    }

    // MARK: - Outlets

    @IBOutlet private var indexLabel: UILabel!
    @IBOutlet private var previewImage: UIImageView!
    @IBOutlet private var questionLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var body: UIStackView!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!

    // MARK: - Private Properties

    private var presenter: MovieQuizPresenter!
    private var alertPresenter: AlertPresenterProtocol!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        alertPresenter = AlertPresenter(viewController: self)
        presenter = MovieQuizPresenter(viewController: self)
    }

    // MARK: - Public Methods

    func show(_ viewModel: QuizStepViewModel) {
        indexLabel.text = viewModel.questionNumberText
        previewImage.image = viewModel.imageUI
        questionLabel.text = viewModel.questionText
    }

    func show(_ viewModel: QuizResultsViewModel) {
        let message = presenter.makeResultsMessage()
        alertPresenter.show(
            title: viewModel.title,
            message: message,
            buttonText: viewModel.buttonText
        ) { [weak self] in
            self?.presenter.resetGame()
        }
    }

    func show(_ viewModel: QuizErrorViewModel) {
        alertPresenter.show(
            title: viewModel.title,
            message: viewModel.text,
            buttonText: viewModel.buttonText
        ) { [weak self] in
            self?.presenter.reloadData()
        }
    }

    func setLoadingIndicator(show: Bool) {
        activityIndicator.isHidden = !show
        body.isHidden = show
    }

    func highlightImageBorderAndFeedback(isCorrectAnswer: Bool) {
        previewImage.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor

        let notificationGenerator = UINotificationFeedbackGenerator()
        notificationGenerator.notificationOccurred(isCorrectAnswer ? .success : .error)
    }

    func resetImageBorder() {
        previewImage.layer.borderColor = UIColor.clear.cgColor
    }

    // MARK: - Actions

    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
    }

    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
    }
}
