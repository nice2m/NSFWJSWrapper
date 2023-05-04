//
//  ViewController.swift
//  NSFWJSWrapper
//
//  Created by hither on 2023/4/27.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        guard let img = UIImage.init(named: "test1") else {
            return
        }
        NSFWJSWrapper.task(image: img) { result in
            print(result);
        }
    }


}

