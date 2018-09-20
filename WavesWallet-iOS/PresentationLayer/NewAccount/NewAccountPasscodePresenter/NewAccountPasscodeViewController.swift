//
//  LightPasscodeViewController.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 19/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxFeedback

final class NewAccountPasscodeViewController: UIViewController {

    fileprivate typealias Types = NewAccountPasscodeTypes

//    enum State: Hashable {
//        case newPassword
//        case repeatPassword
//    }

    @IBOutlet private var passcodeView: PasscodeView!
    private lazy var backButtonItem: UIBarButtonItem = UIBarButtonItem(image: Images.btnBack.image, style: .plain, target: self, action: #selector(backButtonDidTap))

    private var eventInput: PublishSubject<Types.Event> = PublishSubject<Types.Event>()


    var presenter: NewAccountPasscodePresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        passcodeView.hiddenButton(by: .biometric, isHidden: true)
        passcodeView.delegate = self

        navigationItem.backgroundImage = UIImage()
        navigationItem.shadowImage = UIImage()

        setupSystem()
    }

    @objc private func backButtonDidTap() {
        eventInput.onNext(.tapBack)
    }
}

// MARK: RxFeedback

private extension NewAccountPasscodeViewController {

    func setupSystem() {

        let uiFeedback: NewAccountPasscodePresenterProtocol.Feedback = bind(self) { (owner, state) -> (Bindings<Types.Event>) in
            return Bindings(subscriptions: owner.subscriptions(state: state), events: owner.events())
        }

        presenter.system(feedbacks: [uiFeedback])
    }

    func events() -> [Signal<Types.Event>] {
        return [eventInput.asSignal(onErrorSignalWith: Signal.empty())]
    }

    func subscriptions(state: Driver<Types.State>) -> [Disposable] {

        let subscriptionSections = state.drive(onNext: { [weak self] state in

            guard let strongSelf = self else { return }

            strongSelf.updateView(with: state.displayState)
        })

        return [subscriptionSections]
    }

    func updateView(with state: Types.DisplayState) {

        switch state.kind {
        case .newPassword:
            passcodeView.update(with: .init(numbers: state.numbers, text: "newPassword"))

        case .repeatPassword:
            passcodeView.update(with: .init(numbers: state.numbers, text: "repeatPassword"))
        }

        if state.isHiddenBackButton {
            navigationItem.leftBarButtonItem = UIBarButtonItem()
        } else {
            navigationItem.leftBarButtonItem = backButtonItem
        }

        if let error = state.error {
            switch error {
            case .incorrectPasscode:
                passcodeView.showInvalidateState()
            }
        }

        if state.isLoading {
            passcodeView.startLoadingIndicator()
        } else {
            passcodeView.stopLoadingIndicator()
        }
    }
}

extension NewAccountPasscodeViewController: PasscodeViewDelegate {

    func completedInput(with numbers: [Int]) {
        eventInput.onNext(.completedInputNumbers(numbers))
    }

    func biometricButtonDidTap() { }
}
