//
//  LFIBViewController.swift
//  Reorder
//
//  Created by Ganesan Rajasekarapandian on 3/2/20.
//  Copyright © 2020 Raj. All rights reserved.
//

import UIKit

class HIWInitialViewController: UIViewController {
    
    var model: HIWCollection!
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
        let storyboard = UIStoryboard(name: "HIW", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "HIWViewController") as? HIWViewController {
            controller.viewModel = HIWViewModel(model: model.collection[currentIndex],questionNumber:Manager.isListeningMock ? Manager.hiwstart + currentIndex : currentIndex + 1, total: model.collection.count)
            controller.delegate = self
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                self.navigationController?.present(controller, animated: true, completion: nil)
            }
        }
    }

    func parsefromJson() {
        if let path = Bundle.main.path(forResource: "HIW", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                model = try JSONDecoder().decode(HIWCollection.self, from: data)
            } catch {
                print(error)
            }
        }
    }

}
extension HIWInitialViewController : RSTimerDelegate {
    func didCompleted() {
        currentIndex += 1
        if model.collection.count > currentIndex {
            DispatchQueue.main.async {
                self.pushWFD()
            }
        }else {
            if let c = callBack {
                navigationController?.popViewController(animated: false)
                c()
            }
        }
    }
}

struct HIWViewModel {
    let model: HIW
    let questionNumber:Int
    let total:Int
    init(model: HIW, questionNumber:Int, total:Int) {
        self.model = model
        self.questionNumber = questionNumber
        self.total = total
    }
}
struct HIWCollection: Decodable {
    let collection: [HIW]
}

struct HIW: Decodable {
    let speech: String
    let question:String
    let order: String
    let answer: String
    let both: [String]
    let highlightingWords: [String]
}
