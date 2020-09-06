//
//  DIInitialViewController.swift
//  Reorder
//
//  Created by Ganesan Rajasekarapandian on 10/10/19.
//  Copyright © 2019 Raj. All rights reserved.
//

import UIKit

class DIInitialViewController: UIViewController {
    var currentIndex = 0
    var collection:[String] = [] //["1","2","3","4","5","6"]
    var callBack:(()->())?

    override func viewDidLoad() {
        super.viewDidLoad()
        if Manager.isMockText {
            collection = ["i1","i2","i3","i4","i5","i6"]
        } else {
            for index in 1...171 {
                if index % 6 == 0 {
                    collection.append("\(index)")
                }
            }
        }

        
        // Do any additional setup after loading the view.
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
            self.pushRepeatSentence()
        })
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    fileprivate func pushRepeatSentence() {
        let storyboard = UIStoryboard(name: "DI", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "DIViewController") as? DIViewController {
            controller.viewModel = DIViewModel(name: collection[currentIndex], questionNumber: Manager.isMockText ? Manager.DIstart + currentIndex : currentIndex + 1, total: Manager.isMockText ? 0 : collection.count)
            controller.delegate = self
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                self.navigationController?.present(controller, animated: true, completion: nil)
            }
        }
    }
}

extension DIInitialViewController: RSTimerDelegate {
    func didCompleted() {
        currentIndex += 1
        if collection.count > currentIndex {
            DispatchQueue.main.async {
                self.pushRepeatSentence()
            }
        }else {
            if let c = callBack {
                navigationController?.popViewController(animated: false)
                c()
            }
        }
    }
}
