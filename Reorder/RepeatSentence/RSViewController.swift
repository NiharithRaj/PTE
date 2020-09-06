//
//  RSViewController.swift
//  Reorder
//
//  Created by Ganesan Rajasekarapandian on 20/9/19.
//  Copyright © 2019 Raj. All rights reserved.
//

import UIKit
let languagues = ["en-IE", "en-AU","en-US","en-GB","en-ZA"]

class RSViewController: UIViewController {
    var model: RepeatSentenceCollection!
    var currentIndex = 167
    let fileName = "RS"
    var callBack:(()->())?

    var isWFD: Bool {
        return fileName == "WFD_Listen"
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        parsefromJson()
        model.collection.shuffle()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
            self.pushRepeatSentence()
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    fileprivate func pushRepeatSentence() {
        view.backgroundColor = .white
        let storyboard = UIStoryboard(name: "RS", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "RSTimerViewController") as? RSTimerViewController {
            controller.viewModel = RSTimerViewModel(model: model.collection[currentIndex],questionNumber: Manager.isMockText ? (Manager.rpeatstart + currentIndex) : currentIndex + 1, total: model.collection.count, isWFDInstrucion: isWFD)
            controller.delegate = self
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                self.navigationController?.present(controller, animated: true, completion: nil)
            }
        }
    }

    func parsefromJson() {
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                model = try JSONDecoder().decode(RepeatSentenceCollection.self, from: data)
            } catch {
                print(error)
            }
        }
    }

}

extension RSViewController: RSTimerDelegate {
    func didCompleted() {
        currentIndex += 1
        if model.collection.count > currentIndex {
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

struct RepeatSentenceCollection: Decodable {
    var collection: [RepeatSentence]
}

struct RepeatSentence: Decodable {
    let sentence: String
    let time: Int
    let isNew: Bool?
    let repeatRate:Int?
    let fileName: Int?
}

