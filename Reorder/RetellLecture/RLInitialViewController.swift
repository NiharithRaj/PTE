//
//  RLInitialViewController.swift
//  Reorder
//
//  Created by Ganesan Rajasekarapandian on 10/10/19.
//  Copyright © 2019 Raj. All rights reserved.
//

import UIKit

class RLInitialViewController: UIViewController {
    var collection = ["1","2"]
    var currentIndex = 0
    var callBack:(()->())?

    override func viewDidLoad() {
        super.viewDidLoad()
//        parsefromJson()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
            self.pushRepeatSentence()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    fileprivate func pushRepeatSentence() {
        let storyboard = UIStoryboard(name: "RL", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "RLViewController") as? RLViewController {
            controller.viewModel = RLViewModel(fileName: collection[currentIndex], qnumber: Manager.isMockText ? Manager.Retellstart + currentIndex : currentIndex + 1)
            controller.delegate = self
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                self.navigationController?.present(controller, animated: true, completion: nil)
            }
        }
    }
    
//    func parsefromJson() {
//        if let path = Bundle.main.path(forResource: "RS", ofType: "json") {
//            do {
//                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
//                model = try JSONDecoder().decode(RepeatSentenceCollection.self, from: data)
//            } catch {
//                print(error)
//            }
//        }
//    }
    
}

extension RLInitialViewController: RSTimerDelegate {
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
