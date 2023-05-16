//
//  ViewController.swift
//  NSFWJSWrapper
//
//  Created by hither on 2023/4/27.
//

import UIKit

class ViewController: UIViewController {
    ///
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.text = "点击屏幕空白，查看打印日志"
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        
        view.addSubview(statusLabel)
        NSLayoutConstraint.activate([
            self.statusLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.statusLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.statusLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.statusLabel.topAnchor.constraint(equalTo: self.view.topAnchor)
        ])
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        test()
    }
    
    func test() {
        guard let img = UIImage.init(named: "SCR-20230507-kitz"),
              let img2 = UIImage.init(named: "test1"),
              let img3 = UIImage.init(named: "test2") else {
            return
        }
        
        
        let task = NSFWJSWrapperSingleTask.init(image: img) { results, error in
            print("NSFWJSWrapperSingleTask.init")
            print(String(describing: results))
            print(String(describing:error))
        }
        
        let task2 = NSFWJSWrapperSingleTask.init(image: img2)
        
        let task3 = NSFWJSWrapperSingleTask.init(image: img3)
        
        NSFWJSWrapper.default.resume(task: [task,task2,task3]) { results, error in
            print("NSFWJSWrapper.default.resume")
            print(String(describing: results))
            print(String(describing:error))
            
            let _ = results.map {
                _ = $0.map { model in
                    print("\n\n=======")
                    print(model.uuid)
                    _ = model.classes.map{ aClass in
                        print(aClass.className)
                        print(aClass.probability)
                    }
                }
            }
        }
    }
}

