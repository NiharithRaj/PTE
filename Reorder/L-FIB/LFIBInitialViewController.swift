//
//  LFIBViewController.swift
//  Reorder
//
//  Created by Ganesan Rajasekarapandian on 3/2/20.
//  Copyright © 2020 Raj. All rights reserved.
//

import UIKit

class LFIBInitialViewController: UIViewController {
    
    var model: LFIBCollection!
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
        let storyboard = UIStoryboard(name: "LFIB", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "LFIBViewController") as? LFIBViewController {
            controller.viewModel = LFIBViewModel(model: model.collection[currentIndex],questionNumber:Manager.isListeningMock ? Manager.fibstart + currentIndex :  currentIndex + 1, total: model.collection.count)
            controller.delegate = self
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                self.navigationController?.present(controller, animated: true, completion: nil)
            }
        }
    }

    func parsefromJson() {
        if let path = Bundle.main.path(forResource: "LFIB", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                model = try JSONDecoder().decode(LFIBCollection.self, from: data)
            } catch {
                print(error)
            }
        }
    }

}
extension LFIBInitialViewController : RSTimerDelegate {
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

struct LFIBCollection: Decodable {
    let collection: [LFIB]
}

struct LFIB: Decodable {
    let speech: String
    let question:String
    let order: Int
    let answer: [String]
}
