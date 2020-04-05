//
//  WFDInitialViewController.swift
//  Reorder
//
//  Created by Ganesan Rajasekarapandian on 25/9/19.
//  Copyright © 2019 Raj. All rights reserved.
//

import UIKit

class WFDInitialViewController: UIViewController {
    var model: RepeatSentenceCollection!
    var currentIndex = 0
    var callBack:(()->())?

    override func viewDidLoad() {
        super.viewDidLoad()
        parsefromJson()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
            self.pushWFD()
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    fileprivate func pushWFD() {
        let storyboard = UIStoryboard(name: "WFD", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "WFDViewController") as? WFDViewController {
            controller.viewModel = RSTimerViewModel(model: model.collection[currentIndex],questionNumber: Manager.isListeningMock ? Manager.wfdstart + currentIndex : currentIndex + 1, total: model.collection.count)
            controller.delegate = self
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                self.navigationController?.present(controller, animated: true, completion: nil)
            }
        }
    }

    func parsefromJson() {
        if let path = Bundle.main.path(forResource: "WFD", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                model = try JSONDecoder().decode(RepeatSentenceCollection.self, from: data)
            } catch {
                print(error)
            }
        }
    }

}


extension WFDInitialViewController: RSTimerDelegate {
    func didCompleted() {
        currentIndex += 1
        if model.collection.count > currentIndex {
            DispatchQueue.main.async {
                self.pushWFD()
            }
        } else {
            if let c = callBack {
                navigationController?.popViewController(animated: false)
                c()
            }
        }
    }
}
