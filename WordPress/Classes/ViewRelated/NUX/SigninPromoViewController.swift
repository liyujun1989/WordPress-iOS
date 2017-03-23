//
//  SigninPromoViewController.swift
//  WordPress
//
//  Created by Nate Heagy on 2017-03-23.
//  Copyright © 2017 WordPress. All rights reserved.
//

import UIKit

class SigninPromoViewController: NUXAbstractViewController {

    override func viewWillAppear(_ animated: Bool) {
        replace(loginFields: LoginFields())
    }

}
