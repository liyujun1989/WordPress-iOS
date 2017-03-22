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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
