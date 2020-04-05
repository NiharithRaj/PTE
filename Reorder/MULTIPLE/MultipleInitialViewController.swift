//
//  MultipleInitialViewController.swift
//  Reorder
//
//  Created by Ganesan Rajasekarapandian on 10/3/20.
//  Copyright © 2020 Raj. All rights reserved.
//

import UIKit

class MultipleInitialViewController: UIViewController {
    
    var model: MultipleCollection!
    var currentIndex = 0
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
        let storyboard = UIStoryboard(name: "Multiple", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "MultipleViewController") as? MultipleViewController {
            controller.viewModel = MultipleViewModel(model: model.collection[currentIndex],questionNumber: currentIndex + 1, total: model.collection.count)
            controller.delegate = self
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                self.navigationController?.present(controller, animated: true, completion: nil)
            }
        }
    }

    func parsefromJson() {
        if let path = Bundle.main.path(forResource: "Multiple", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                model = try JSONDecoder().decode(MultipleCollection.self, from: data)
            } catch {
                print(error)
            }
        }
    }

}

extension MultipleInitialViewController : RSTimerDelegate {
    func didCompleted() {
        currentIndex += 1
        if model.collection.count > currentIndex {
            DispatchQueue.main.async {
                self.pushWFD()
            }
        }
    }
}

struct MultipleViewModel {
    let model: Multiple
    let questionNumber:Int
    let total:Int
    init(model: Multiple, questionNumber:Int, total:Int) {
        self.model = model
        self.questionNumber = questionNumber
        self.total = total
    }
}
struct MultipleCollection: Decodable {
    let collection: [Multiple]
}
struct Multiple: Decodable {
    let answer: String
    let question:String
    let order: Int
    let options: [String]
    let title:String
}

