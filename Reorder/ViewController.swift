//
//  ViewController.swift
//  Reorder
//
//  Created by Ganesan Rajasekarapandian on 13/9/19.
//  Copyright © 2019 Raj. All rights reserved.
//

import UIKit
import Hero
class ViewController: UIViewController {
    var model: ReorderCollection!
    var currentReorder:Int = 0
    var questionSet = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        self.navigationController?.hero.isEnabled = true
//        self.hero.isEnabled = true
//        self.view.hero.id = "Home"
        view.backgroundColor = .white
        parsefromJson()
        pushReorderVC()

    }
    

    fileprivate func pushReorderVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "ReorderViewController") as? ReorderViewController {
            controller.hero.isEnabled = true
            controller.viewModel = ReorderViewModel(collection: model.collection[currentReorder], set: questionSet, total: model.collection.count)
            controller.delegate = self
//            controller.hero.modalAnimationType = .selectBy(presenting: .zoomSlide(direction: .left), dismissing: .zoomSlide(direction: .right))
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                self.navigationController?.present(controller, animated: true, completion: nil)
            }
        }
    }

    func parsefromJson() {
        if let path = Bundle.main.path(forResource: "ROP1", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                model = try JSONDecoder().decode(ReorderCollection.self, from: data)
            } catch {
                print(error)
            }
        }
    }

}

extension ViewController: ReorderViewDelegate {
    func didReorderCompleted() {
        currentReorder += 1
        questionSet += 1
        if model.collection.count > currentReorder {
            if questionSet == 6 {
                questionSet = 1
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5, execute: {
                    self.pushReorderVC()
                })
            } else {
                pushReorderVC()
            }

        }
    }
}

class ReorderCollection: Decodable {
    let collection: [Reorder]
}

class Reorder: Decodable {
    let content: [ReorderContent]
    let paragraphTitle: String
    let fontSize:Int?
}

class ReorderContent: Decodable {
    let position: Int
    let readingDescription: String
}


