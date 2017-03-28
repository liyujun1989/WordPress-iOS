import UIKit
import WordPressShared

/// Provides a form and functionality to sign-in and add an existing self-hosted
/// site to the app.
///
@objc class SigninURLViewController: NUXAbstractViewController, SigninWPComSyncHandler {
//    @IBOutlet weak var bottomContentConstraint: NSLayoutConstraint!
//    @IBOutlet weak var verticalCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var siteURLField: WPWalkthroughTextField!
    @IBOutlet weak var submitButton: NUXSubmitButton!
    @IBOutlet var instructionLabel: UILabel!
    @IBOutlet var helpLabel: UILabel!


    lazy var loginFacade: LoginFacade = {
        let facade = LoginFacade()
        facade.delegate = self
        return facade
    }()


    lazy var xmlrpcFacade = WordPressXMLRPCAPIFacade()


    override var sourceTag: SupportSourceTag {
        get {
            return .wpOrgLogin
        }
    }

    /// A convenience method for obtaining an instance of the controller from a storyboard.
    ///
    /// - Parameter loginFields: A LoginFields instance containing any prefilled credentials.
    ///
    class func controller(_ loginFields: LoginFields) -> SigninURLViewController {
        let storyboard = UIStoryboard(name: "Signin", bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(withIdentifier: "SigninURLViewController") as! SigninURLViewController
        return controller
    }


    // MARK: - Lifecycle Methods


    override func viewDidLoad() {
        super.viewDidLoad()

        localizeControls()
        displayLoginMessage("")
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        configureTextFields()
        configureSubmitButton(animating: false)
        configureViewForEditingIfNeeded()
    }

    // MARK: Setup and Configuration


    /// Assigns localized strings to various UIControl defined in the storyboard.
    ///
    func localizeControls() {
//        siteURLField.placeholder = NSLocalizedString("Site Address (URL)", comment: "Site Address placeholder")
//
//        let submitButtonTitle = NSLocalizedString("Add Site", comment: "Title of a button. The text should be uppercase.").localizedUppercase
//        submitButton.setTitle(submitButtonTitle, for: UIControlState())
//        submitButton.setTitle(submitButtonTitle, for: .highlighted)
    }


    /// Configures the content of the text fields based on what is saved in `loginFields`.
    ///
    func configureTextFields() {
        siteURLField.text = loginFields.siteUrl
    }


    /// Configures the appearance and state of the submit button.
    ///
    func configureSubmitButton(animating: Bool) {
        submitButton.showActivityIndicator(animating)

        submitButton.isEnabled = (
            !animating && !loginFields.siteUrl.isEmpty
        )
    }


    /// Sets the view's state to loading or not loading.
    ///
    /// - Parameter loading: True if the form should be configured to a "loading" state.
    ///
    func configureViewLoading(_ loading: Bool) {
        siteURLField.isEnabled = !loading

        configureSubmitButton(animating: loading)

        navigationItem.hidesBackButton = loading
    }


    /// Configure the view for an editing state. Should only be called from viewWillAppear
    /// as this method skips animating any change in height.
    ///
    func configureViewForEditingIfNeeded() {
        // Check the helper to determine whether an editiing state should be assumed.
        if SigninEditingState.signinEditingStateActive {
            siteURLField.becomeFirstResponder()
        }
    }


    // MARK: - Instance Methods


    ///
    ///
    func updateSafariCredentialsIfNeeded() {
        // Noop.  Required by the SigninWPComSyncHandler protocol but the self-hosted
        // controller's implementation does not use safari saved credentials.
    }


    /// Validates what is entered in the various form fields and, if valid,
    /// proceeds with the submit action.
    ///
    func validateForm() {
        view.endEditing(true)

        if !SigninHelpers.validateSiteForSignin(loginFields) {
            WPError.showAlert(withTitle: NSLocalizedString("Error", comment: "Title of an error message"),
                              message: NSLocalizedString("The site's URL appears to be mistyped", comment: "A short prompt alerting to a misformatted URL"),
                              withSupportButton: false)

            return
        }

        configureViewLoading(true)

        xmlrpcFacade.guessXMLRPCURL(forSite: loginFields.siteUrl, success: {[ weak self] (url) in
            DispatchQueue.main.async {
                // Found the URL.
                self?.didValidateForm(url: url)
                self?.configureViewLoading(false)
            }
        }, failure: { [weak self] (error) in
            DispatchQueue.main.async {
                self?.configureViewLoading(false)
                self?.handleGuessXMLRPCError(error: error as NSError)
            }
        })
    }


    func didValidateForm(url: URL) {
        loginFields.xmlrpcUrl = url.absoluteString

        let controller: UIViewController
        if loginFields.siteUrl.contains("wordpress.com/xmlrpc.php") {
            // Show WordPress.com flow
            controller = SigninWPComViewController.controller(loginFields)
        } else {
            // Show selfhosted flow
            controller = SigninSelfHostedViewController.controller(loginFields)
        }
        navigationController?.pushViewController(controller, animated: true)
    }


    func handleGuessXMLRPCError(error: NSError) {
        // TODO: Different error can occur.
        displayError(error as NSError, sourceTag: sourceTag)
    }

    func configureStatusLabel(_ message: String) {}

    func showExplaination() {
        helpLabel.isHidden = false
    }


    // MARK: - Actions


    @IBAction func handleTextFieldDidChange(_ sender: UITextField) {
        loginFields.siteUrl = SigninHelpers.baseSiteURL(string: siteURLField.nonNilTrimmedText())

        configureSubmitButton(animating: false)
    }


    @IBAction func handleSubmitButtonTapped(_ sender: UIButton) {
        validateForm()
    }

    @IBAction func handleExplainTapped(_ sender: UIButton) {
        if helpLabel.isHidden {
            sender.setTitle("Need more help?", for: .normal)
            showExplaination()

        } else {
            displayHelpshiftConversationView(sourceTag: sourceTag)
        }
    }
}


extension SigninURLViewController: LoginFacadeDelegate {

    func finishedLogin(withUsername username: String!, authToken: String!, requiredMultifactorCode: Bool) {
        syncWPCom(username, authToken: authToken, requiredMultifactor: requiredMultifactorCode)
    }


    func finishedLogin(withUsername username: String!, password: String!, xmlrpc: String!, options: [AnyHashable: Any]!) {
        displayLoginMessage("")

        BlogSyncFacade().syncBlog(withUsername: username, password: password, xmlrpc: xmlrpc, options: options) { [weak self] in
            self?.configureViewLoading(false)

            let context = ContextManager.sharedInstance().mainContext
            let service = BlogService(managedObjectContext: context)
            if let blog = service.findBlog(withXmlrpc: xmlrpc, andUsername: username) {
                service.flagBlog(asLastUsed: blog)
            }

            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: SigninHelpers.WPSigninDidFinishNotification), object: nil)

            self?.dismiss()
        }
    }


    func displayLoginMessage(_ message: String!) {
        configureStatusLabel(message)
    }


    func displayRemoteError(_ error: Error!) {
        displayLoginMessage("")
        configureViewLoading(false)
        displayError(error as NSError, sourceTag: sourceTag)
    }

}


extension SigninURLViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if submitButton.isEnabled {
            validateForm()
        }
        return true
    }
}
