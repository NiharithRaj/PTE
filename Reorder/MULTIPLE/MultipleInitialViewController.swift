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
    var callBack:(()->())?

    enum MultipleType:String {
        case single = "MCSA"
        case multiple = "MCMA"
    }
    var fileName:MultipleType = .single

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
            var start = currentIndex + 1
            if Manager.isReadingMock {
                start =  Manager.singleandMultipleStart + currentIndex
            }

            controller.viewModel = MultipleViewModel(model: model.collection[currentIndex],questionNumber:start, total: model.collection.count, isSingle: fileName == .single)
            controller.delegate = self
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                self.navigationController?.present(controller, animated: true, completion: nil)
            }
        }
    }

    func parsefromJson() {
        if let path = Bundle.main.path(forResource: fileName.rawValue, ofType: "json") {
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
        } else {
                   if let c = callBack {
                       navigationController?.popViewController(animated: false)
                       c()
                   }
               }

    }
}

struct MultipleViewModel {
    let model: Multiple
    let questionNumber:Int
    let total:Int
    let isSingle:Bool
    init(model: Multiple, questionNumber:Int, total:Int, isSingle:Bool) {
        self.model = model
        self.questionNumber = questionNumber
        self.total = total
        self.isSingle = model.isSingle
    }
}
struct MultipleCollection: Decodable {
    let collection: [Multiple]
}
struct Multiple: Decodable {
    let answer: String
    let question:String
    let order: Int?
    let isSingle:Bool
    let options: [String]
    let paragraph:String
}

