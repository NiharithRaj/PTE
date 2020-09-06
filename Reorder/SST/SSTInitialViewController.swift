//
//  RLInitialViewController.swift
//  Reorder
//
//  Created by Ganesan Rajasekarapandian on 10/10/19.
//  Copyright © 2019 Raj. All rights reserved.
//

import UIKit

class SSTInitialViewController: UIViewController {
//    var collection:[String] = []
    var currentIndex = 0
    var callBack:(()->())?
    var model:SSTCollection!
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
        let storyboard = UIStoryboard(name: "SST", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "SSTViewController") as? SSTViewController {
            controller.viewModel = SSTViewModel(qnumber: Manager.isListeningMock ? Manager.sstStart + currentIndex : currentIndex + 1, total: model.collection.count, sst: model.collection[currentIndex])
            controller.delegate = self
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                self.navigationController?.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    func parsefromJson() {
        if let path = Bundle.main.path(forResource: "SST", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                model = try JSONDecoder().decode(SSTCollection.self, from: data)
            } catch {
                print(error)
            }
        }
    }
    
}

extension SSTInitialViewController: RSTimerDelegate {
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

struct SSTCollection: Decodable {
    let collection: [SST]
}

struct SST: Decodable {
    let qno: String
    let question: String
    let answer:String
}

struct SSTViewModel {
    var questionNumber:Int = 0
    let total:Int
    let sst:SST
    init(qnumber:Int, total:Int, sst:SST) {
        questionNumber = qnumber
        self.sst = sst
        self.total = total
    }
}
