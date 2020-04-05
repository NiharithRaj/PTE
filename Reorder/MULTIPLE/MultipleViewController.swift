//
//  MultipleViewController.swift
//  Reorder
//
//  Created by Ganesan Rajasekarapandian on 10/3/20.
//  Copyright © 2020 Raj. All rights reserved.
//

import UIKit

class MultipleViewController: UIViewController {

    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var optionsLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    var viewModel: MultipleViewModel!
    weak var delegate: RSTimerDelegate?
    var timerCount = 60
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
    }

    func setupUI() {
        questionLabel.text = viewModel.model.question
        answerLabel.text = "Answer: " + (viewModel.model.answer.trimmingCharacters(in: CharacterSet.whitespaces))
        titleLabel.text = viewModel.model.title
        optionsLabel.text = viewModel.model.options[0]
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            self.displayAnswer(timer: timer)
        }
    }

    func displayAnswer(timer: Timer) {
        timerLabel.text = timeFormatted(timerCount)
        timerCount -= 1

        if timerCount == 0 {
            //Do here
            timer.invalidate()
            answerLabel.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                    self.dismiss(animated: true, completion: nil)
                    self.delegate?.didCompleted()
                })
        }
    }

    @objc func updateUI() {

        let bullet = ["A. ", "B. ", "C. ", "D. ", "E. ", "F. ", "G. ", "H. ", "I. ", "J. ",]
        var count = -1
        var strings = [String]()
        strings = viewModel.model.options.map {
            count += 1
            return bullet[count] + " " + $0
        }

        var attributes = [NSAttributedString.Key: Any]()

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = (bullet[0] as NSString).size(withAttributes: attributes).width * 3.1
        attributes[.paragraphStyle] = paragraphStyle
//        paragraphStyle.lineSpacing = 1.0

        let string = strings.joined(separator: "\n\n")
        optionsLabel.attributedText = NSAttributedString(string: string, attributes: attributes)
    }
}
