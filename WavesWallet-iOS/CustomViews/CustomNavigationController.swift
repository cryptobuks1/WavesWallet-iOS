//
//  CustomNavigationController.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 17/03/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit

extension UINavigationController {

    func popViewController(animated: Bool, completed: @escaping (() -> Void)) -> UIViewController? {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completed)
        let result = popViewController(animated: animated)
        CATransaction.commit()
        return result
    }

    func popToRootViewController(animated: Bool, completed: @escaping (() -> Void)) -> [UIViewController]? {

        CATransaction.begin()
        CATransaction.setCompletionBlock(completed)
        let result = popToRootViewController(animated: animated)
        CATransaction.commit()
        return result
    }

    func popToViewController(_ viewController: UIViewController, animated: Bool, completed: @escaping (() -> Void)) -> [UIViewController]? {

        CATransaction.begin()
        CATransaction.setCompletionBlock(completed)
        let result = popToViewController(viewController, animated: animated)
        CATransaction.commit()
        return result
    }

    func pushViewController(_ viewController: UIViewController, animated: Bool, completed: @escaping (() -> Void)) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completed)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
}

extension UINavigationItem {

    private enum AssociatedKeys {
        static var prefersLargeTitles = "prefersLargeTitles"
        static var backgroundImage = "backgroundImage"
        static var shadowImage = "shadowImage"
        static var barTintColor = "barTintColor"
        static var tintColor = "tintColor"
        static var isNavigationBarHidden = "isNavigationBarHidden"
        static var titleTextAttributes = "titleTextAttributes"
        static var isTranslucent = "isTranslucent"
        static var backIndicatorImage = "backIndicatorImage"
        static var isDisabledGestureBack = "isDisabledGestureBack"
        static var backIndicatorTransitionMaskImage = "backIndicatorTransitionMaskImage"
        static var largeTitleTextAttributes = "largeTitleTextAttributes"
    }

    @objc var largeTitleTextAttributes: [NSAttributedString.Key : Any]? {
        get {
            return associatedObject(for: &AssociatedKeys.largeTitleTextAttributes)
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.largeTitleTextAttributes)
        }
    }

    @objc var backIndicatorImage: UIImage? {
        get {
            return associatedObject(for: &AssociatedKeys.backIndicatorImage)
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.backIndicatorImage)
        }
    }
    
    @objc var backIndicatorTransitionMaskImage: UIImage? {
        get {
            return associatedObject(for: &AssociatedKeys.backIndicatorTransitionMaskImage)
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.backIndicatorTransitionMaskImage)
        }
    }

    @objc var titleTextAttributes: [NSAttributedString.Key : Any]? {
        get {
            return associatedObject(for: &AssociatedKeys.titleTextAttributes) ?? nil
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.titleTextAttributes)
        }
    }

    @objc var isNavigationBarHidden: Bool {
        get {
            return associatedObject(for: &AssociatedKeys.isNavigationBarHidden) ?? false
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.isNavigationBarHidden)
        }
    }

    @objc var barTintColor: UIColor? {
        get {
            return associatedObject(for: &AssociatedKeys.barTintColor) ?? nil
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.barTintColor)
        }
    }

    @objc var tintColor: UIColor? {
        get {
            return associatedObject(for: &AssociatedKeys.tintColor) ?? nil
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.tintColor)
        }
    }

    @objc var prefersLargeTitles: Bool {
        get {
            return associatedObject(for: &AssociatedKeys.prefersLargeTitles) ?? false
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.prefersLargeTitles)
        }
    }

    @objc var isTranslucent: Bool {
        get {
            return associatedObject(for: &AssociatedKeys.isTranslucent) ?? true
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.isTranslucent)
        }
    }

    @objc var backgroundImage: UIImage? {
        get {
            return associatedObject(for: &AssociatedKeys.backgroundImage)
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.backgroundImage)
        }
    }

    @objc var shadowImage: UIImage? {
        get {
            return associatedObject(for: &AssociatedKeys.shadowImage)
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.shadowImage)
        }
    }

    @objc var isDisabledGestureBack: Bool {
        get {
            return associatedObject(for: &AssociatedKeys.isDisabledGestureBack) ?? false
        }

        set {
            setAssociatedObject(newValue, for: &AssociatedKeys.isDisabledGestureBack)
        }
    }
}

fileprivate enum Constants {
    static var prefersLargeTitles = "prefersLargeTitles"
    static var backgroundImage = "backgroundImage"
    static var shadowImage = "shadowImage"
    static var barTintColor = "barTintColor"
    static var tintColor = "tintColor"
    static var isNavigationBarHidden = "isNavigationBarHidden"
    static var titleTextAttributes = "titleTextAttributes"
    static var isTranslucent = "isTranslucent"
    static var backIndicatorImage = "backIndicatorImage"
    static var backIndicatorTransitionMaskImage = "backIndicatorTransitionMaskImage"
    static var largeTitleTextAttributes = "largeTitleTextAttributes"
}

final class CustomNavigationController: UINavigationController {

    private let proxyDelegate: ProxyNavigationControllerDelegate = ProxyNavigationControllerDelegate()

    private weak var prevViewContoller: UIViewController?
  
    override var delegate: UINavigationControllerDelegate? {
        get {
            return super.delegate
        }
        set {
            super.delegate = proxyDelegate
            if let newValue = newValue {
                proxyDelegate.delegates.append(Weak(value: newValue))
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        interactivePopGestureRecognizer?.delegate = self
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {

        if let prevViewContoller = prevViewContoller {
            apperanceNavigationItemProperties(prevViewContoller)
        }
    }

    override func popViewController(animated: Bool) -> UIViewController? {

        if viewControllers.count == 2 {
            self.viewControllers.first?.hidesBottomBarWhenPushed = false
        }
        
        return super.popViewController(animated: animated)
    }

    override func popToRootViewController(animated: Bool) -> [UIViewController]? {

        self.viewControllers.first?.hidesBottomBarWhenPushed = false
        return super.popToRootViewController(animated: animated)
    }

    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        return super.popToViewController(viewController, animated: animated)
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        self.viewControllers.first?.hidesBottomBarWhenPushed = true
        super.pushViewController(viewController, animated: animated)
    }
    
    private func apperanceNavigationItemProperties(_ viewController: UIViewController, animated: Bool = false) {

        if viewController != topViewController {
            return
        }

        navigationBar.setBackgroundImage(viewController.navigationItem.backgroundImage, for: .default)

        navigationBar.isTranslucent = viewController.navigationItem.isTranslucent
        navigationBar.shadowImage = viewController.navigationItem.shadowImage
        navigationBar.barTintColor = viewController.navigationItem.barTintColor
        navigationBar.tintColor = viewController.navigationItem.tintColor
        navigationBar.titleTextAttributes = viewController.navigationItem.titleTextAttributes
        
        if #available(iOS 11.0, *) {
            navigationBar.largeTitleTextAttributes = viewController.navigationItem.largeTitleTextAttributes
            navigationBar.prefersLargeTitles = true
        }

        if #available(iOS 13, *) {
            let appereance = UINavigationBarAppearance()
            appereance.configureWithTransparentBackground()
            if viewController.navigationItem.backgroundImage == nil {
                appereance.backgroundColor = viewController.view.backgroundColor
            }
            appereance.titleTextAttributes = viewController.navigationItem.titleTextAttributes ?? [:]
            appereance.largeTitleTextAttributes = viewController.navigationItem.largeTitleTextAttributes ?? [:]

            navigationBar.standardAppearance = appereance
            navigationBar.scrollEdgeAppearance = appereance
        }
        
        setNavigationBarHidden(viewController.navigationItem.isNavigationBarHidden, animated: animated)
    }

    override var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.topViewController?.preferredStatusBarStyle ?? .default
    }

    override var prefersStatusBarHidden: Bool {
        return self.topViewController?.prefersStatusBarHidden ?? false
    }

    deinit {
        if let prevViewContoller = prevViewContoller {
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.shadowImage)
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.backgroundImage)
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.barTintColor)
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.tintColor)
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.isNavigationBarHidden)
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.titleTextAttributes)
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.isTranslucent)
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.backIndicatorImage)
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.backIndicatorTransitionMaskImage)

            if #available(iOS 11.0, *) {
                prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.prefersLargeTitles)
                prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.largeTitleTextAttributes)
            }
        }
    }
}

// MARK: UIGestureRecognizerDelegate

extension CustomNavigationController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {

        if viewControllers.count > 1 {

            if let top = viewControllers.last, top.navigationItem.isDisabledGestureBack == true {
                return false
            }

            return true
        }
        return false
    }
}

// MARK: UINavigationControllerDelegate

extension CustomNavigationController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
            
        if let prevViewContoller = prevViewContoller {
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.shadowImage)
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.backgroundImage)
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.barTintColor)
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.tintColor)
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.isNavigationBarHidden)
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.titleTextAttributes)
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.isTranslucent)
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.backIndicatorImage)
            prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.backIndicatorTransitionMaskImage)

            if #available(iOS 11.0, *) {
                prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.prefersLargeTitles)
                prevViewContoller.navigationItem.removeObserver(self, forKeyPath: Constants.largeTitleTextAttributes)
            }
        }

        prevViewContoller = viewController

        apperanceNavigationItemProperties(viewController, animated: animated)

        viewController.navigationItem.addObserver(self, forKeyPath: Constants.backgroundImage, options: [.new, .old], context: nil)
        viewController.navigationItem.addObserver(self, forKeyPath: Constants.shadowImage, options: [.new, .old], context: nil)

        viewController.navigationItem.addObserver(self, forKeyPath: Constants.barTintColor, options: [.new, .old], context: nil)
        viewController.navigationItem.addObserver(self, forKeyPath: Constants.tintColor, options: [.new, .old], context: nil)
        viewController.navigationItem.addObserver(self, forKeyPath: Constants.isNavigationBarHidden, options: [.new, .old], context: nil)
        viewController.navigationItem.addObserver(self, forKeyPath: Constants.titleTextAttributes, options: [.new, .old], context: nil)
        viewController.navigationItem.addObserver(self, forKeyPath: Constants.isTranslucent, options: [.new, .old], context: nil)
        viewController.navigationItem.addObserver(self, forKeyPath: Constants.backIndicatorImage, options: [.new, .old], context: nil)
        viewController.navigationItem.addObserver(self, forKeyPath: Constants.backIndicatorTransitionMaskImage, options: [.new, .old], context: nil)


        if #available(iOS 11.0, *) {
            viewController.navigationItem.addObserver(self, forKeyPath: Constants.prefersLargeTitles, options: [.new, .old], context: nil)
            viewController.navigationItem.addObserver(self, forKeyPath: Constants.largeTitleTextAttributes, options: [.new, .old], context: nil)
        }
        
        self.transitionCoordinator?.notifyWhenInteractionChanges({ [weak self] context in
            guard let self = self else { return }
            guard context.isCancelled else { return }
            guard let fromViewController = context.viewController(forKey: .from) else { return }
            self.navigationController(navigationController, willShow: fromViewController, animated: animated)

            let animationCompletion = context.transitionDuration * Double(context.percentComplete)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + animationCompletion, execute: { [weak self] in
                guard let self = self else { return }
                self.navigationController(navigationController, didShow: fromViewController, animated: animated)
            })
        })
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
        
    }
}

private final class Weak<T> where T: AnyObject {

    private(set) weak var value: T?

    init(value: T?) {
        self.value = value
    }
}

private class ProxyNavigationControllerDelegate: NSObject, UINavigationControllerDelegate {

    var delegates: [Weak<UINavigationControllerDelegate>] = .init()

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        delegates.forEach { (weak) in
            weak.value?.navigationController?(navigationController, willShow: viewController, animated: animated)
        }
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        delegates.forEach { (weak) in
            weak.value?.navigationController?(navigationController, didShow: viewController, animated: animated)
        }
    }
}

