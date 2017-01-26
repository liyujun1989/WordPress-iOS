import UIKit


/// Acts as the delegate for a view controller's presentation controller
/// and manages the appearance of a Done button as part of the view controller's
/// navigationItem. If the view controller is displayed in a popover, the Done
/// button is hidden. If the view controller is displayed modally, the Done
/// button is shown.
class AdaptivePopoverDelegate: NSObject, UIAdaptivePresentationControllerDelegate {
    private weak var presentedViewController: UINavigationController? = nil

    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        guard let presentedViewController = controller.presentedViewController as? UINavigationController else { return nil }

        self.presentedViewController = presentedViewController
        return nil
    }

    func presentationController(_ presentationController: UIPresentationController, willPresentWithAdaptiveStyle style: UIModalPresentationStyle, transitionCoordinator: UIViewControllerTransitionCoordinator?) {
        if style == .none {
            removeDoneButton()
        } else if style == .fullScreen {
            addDoneButton()
        }
    }

    private func makeDoneButton() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
    }

    private func addDoneButton() {
        if let viewController = presentedViewController?.viewControllers.first {
            viewController.navigationItem.leftBarButtonItem = makeDoneButton()
        }
    }

    private func removeDoneButton() {
        if let viewController = presentedViewController?.viewControllers.first {
            viewController.navigationItem.leftBarButtonItem = nil
        }
    }

    @objc private func doneTapped() {
        presentedViewController?.dismiss(animated: true, completion: {
            self.presentedViewController = nil
        })
    }
}
