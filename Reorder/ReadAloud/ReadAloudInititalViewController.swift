//
//  ReadAloudInititalViewController.swift
//  Reorder
//
//  Created by Ganesan Rajasekarapandian on 10/10/19.
//  Copyright © 2019 Raj. All rights reserved.
//

import UIKit

class ReadAloudInititalViewController: UIViewController {
    var model: RepeatSentenceCollection!
    var currentIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        parsefromJson()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
            self.pushRepeatSentence()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    fileprivate func pushRepeatSentence() {
        let storyboard = UIStoryboard(name: "ReadAloud", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "ReadAloudViewController") as? ReadAloudViewController {
            controller.viewModel = RSTimerViewModel(model: model.collection[currentIndex],questionNumber: currentIndex + 1, total: model.collection.count)
            controller.delegate = self
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                self.navigationController?.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    func parsefromJson() {
        if let path = Bundle.main.path(forResource: "RA", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                model = try JSONDecoder().decode(RepeatSentenceCollection.self, from: data)
            } catch {
                print(error)
            }
        }
    }
    
}

extension ReadAloudInititalViewController: RSTimerDelegate {
    func didCompleted() {
        currentIndex += 1
        if model.collection.count > currentIndex {
            DispatchQueue.main.async {
                self.pushRepeatSentence()
            }
        }
    }
}
