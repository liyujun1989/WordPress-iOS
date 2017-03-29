//
//  SigninWPComPasswordViewController.swift
//  WordPress
//
//  Created by Nate Heagy on 2017-03-21.
//  Copyright © 2017 WordPress. All rights reserved.
//

import UIKit

class SigninWPComPasswordViewController: NUXAbstractViewController {

    @IBOutlet var emailTextField: UILabel?
    @IBOutlet weak var passwordField: WPWalkthroughTextField?

    lazy var loginFacade: LoginFacade = {
        let facade = LoginFacade()
        facade.delegate = self
        return facade
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        guard let emailTextField = emailTextField else {
            return
        }

        let email = loginFields.username // because the email screen puts this in username instead of emailAddress ¯\_(ツ)_/¯
        emailTextField.text = email // TODO: make this work, -nh
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextTapped() {
        attemptLogin()
    }
    
    @IBAction func handleSubmitForm() {
        attemptLogin()
    }
    
    func attemptLogin() {
        guard let passwordField = passwordField else {
            return
        }
        loginFields.password = passwordField.nonNilTrimmedText()
        
        loginFacade.signIn(with: loginFields)
    }
}

extension SigninWPComPasswordViewController: SigninWPComSyncHandler {
    func configureViewLoading(_ loading: Bool) {
    }
    func configureStatusLabel(_ message: String) {
    }
    func updateSafariCredentialsIfNeeded() {
    }
}

extension SigninWPComPasswordViewController: LoginFacadeDelegate {
    
    func finishedLogin(withUsername username: String!, authToken: String!, requiredMultifactorCode: Bool) {
        syncWPCom(username, authToken: authToken, requiredMultifactor: requiredMultifactorCode)
    }
    
    
    func displayLoginMessage(_ message: String!) {
        configureStatusLabel(message)
    }
    
    
    func displayRemoteError(_ error: Error!) {
        configureStatusLabel("")
        configureViewLoading(false)
        //displayError(error as NSError, sourceTag: sourceTag)
        displayError(message: "Unable to login with that password", sourceTag: sourceTag)
    }
    
    
    func needsMultifactorCode() {
        configureStatusLabel("")
        configureViewLoading(false)
        
        WPAppAnalytics.track(.twoFactorCodeRequested)
        // Credentials were good but a 2fa code is needed.
        loginFields.shouldDisplayMultifactor = true // technically not needed
        let controller = Signin2FAViewController.controller(loginFields)
        controller.dismissBlock = dismissBlock
        navigationController?.pushViewController(controller, animated: true)
    }
}
