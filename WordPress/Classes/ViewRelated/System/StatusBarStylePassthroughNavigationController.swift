import UIKit

class StatusBarStylePassthroughNavigationController: UINavigationController {
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return topViewController
    }
}
