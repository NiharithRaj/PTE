//
//  ASQinitialViewController.swift
//  Reorder
//
//  Created by Ganesan Rajasekarapandian on 3/10/19.
//  Copyright © 2019 Raj. All rights reserved.
//

import UIKit

class ASQinitialViewController: UIViewController {
    @IBOutlet weak var instructionlabel: UILabel!
    @IBOutlet weak var tipsimg: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    var model: ASQCollection!
    var currentIndex = 0
    var callBack:(()->())?

    override func viewDidLoad() {
        super.viewDidLoad()
        parsefromJson()

        shouldhideinstructions(yes: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
            self.pushRepeatSentence()
            self.shouldhideinstructions(yes: true)
        })
        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
//            self.shouldhideinstructions(yes: false)
//        })
//        tips()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    fileprivate func pushRepeatSentence() {
        let storyboard = UIStoryboard(name: "ASQ", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "ASQViewController") as? ASQViewController {
            controller.viewModel = ASQViewModel(model: model.collection[currentIndex],questionNumber: Manager.isMockText ? Manager.ASQstart + currentIndex : currentIndex + 1, total: model.collection.count)
            controller.delegate = self
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                self.navigationController?.present(controller, animated: true, completion: nil)
            }
        }
    }
    func shouldhideinstructions(yes:Bool) {
        self.instructionlabel.isHidden = yes
        self.tipsimg.isHidden = yes
        self.titleLabel.isHidden = yes
    }
    func parsefromJson() {
        if let path = Bundle.main.path(forResource: "ASQ", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                model = try JSONDecoder().decode(ASQCollection.self, from: data)
            } catch {
                print(error)
            }
        }
    }
    
    func tips() {
        let inst = """
1. It is vital to listen very carefully to each question to ensure you understand it.
2. Answer it by one or two words based on the question.
3. If you don’t know the answer, don’t skip it, say something, you can get score for speaking at least.
4. Practice these most repeated exam questions.
"""
        instructionlabel.attributedText = NSAttributedString(string: inst).paragraphStyle(lineSpace: 20.0, textAlignment: .left)
    }
    
}
extension ASQinitialViewController: RSTimerDelegate {
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

struct ASQCollection: Decodable {
    let collection: [ASQ]
}

struct ASQ: Decodable {
    let question: String
    let answer: String
}

func bulletPointList(strings: [String]) -> NSAttributedString {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.headIndent = 15
    paragraphStyle.minimumLineHeight = 22
    paragraphStyle.maximumLineHeight = 22
    paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 15)]
    
    let stringAttributes = [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
        NSAttributedString.Key.foregroundColor: UIColor.black,
        NSAttributedString.Key.paragraphStyle: paragraphStyle
    ]
    
    let string = strings.map({ "•\t\($0)" }).joined(separator: "\n")
    
    return NSAttributedString(string: string,
                              attributes: stringAttributes)
}
