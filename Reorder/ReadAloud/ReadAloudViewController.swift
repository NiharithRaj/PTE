//
//  ReadAloudViewController.swift
//  Reorder
//
//  Created by Ganesan Rajasekarapandian on 1/10/19.
//  Copyright © 2019 Raj. All rights reserved.
//

import UIKit

class ReadAloudViewController: UIViewController {
    let speech = Speech()
    var viewModel: RSTimerViewModel!
    let count = 25.0
    let recordTime = 8
//    @IBOutlet weak var dotview: UIView!
//    @IBOutlet weak var progressbarContainerView: UIView!
    @IBOutlet weak var questionNumberLabel: UILabel!
//    @IBOutlet weak var topViewBeginningLabel: UILabel!
//    @IBOutlet weak var topView: UIView!
//    @IBOutlet weak var indicatorView: UIView!
//    @IBOutlet weak var indicatorLineview: UIView!

    @IBOutlet weak var answerTextLabel: UILabel!

    @IBOutlet weak var answerBeginningView: UILabel!
    @IBOutlet weak var answerProgressView: UIView!
    @IBOutlet weak var answerView: UIView!


    @IBOutlet weak var answerTextView: UIView!
    @IBOutlet weak var questionView: UIView!
    @IBOutlet weak var answerContainerView: UIView!
    
    weak var delegate: RSTimerDelegate?

    @IBOutlet weak var questionLabel: UILabel!
    var questionTime = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        questionTime = 5 // Utils.audioLength(fileName: "\(viewModel.model.fileName)")
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        questionView(yes: false)
        changeQuestion()
    }

    fileprivate func changeQuestion() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
            self.beginQuestionProgress()
        })
    }

    fileprivate func questionView(yes: Bool) {
        questionView.isHidden = yes
        answerTextView.isHidden = !yes
    }

    fileprivate func beginQuestionProgress() {

        func answer() {
            viewProgress(animationview: answerProgressView, seconds: 5) {
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else {return}
                    strongSelf.answerBeginningView.text = "Completed"
                    UIView.animate(withDuration: 1, animations: {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                            strongSelf.dismiss(animated: true, completion: nil)
                            strongSelf.delegate?.didCompleted()
                        })
                    })
                }
            }
        }

        answerBeginningView.isHidden = false
        var seconds = questionTime
        self.answerBeginningView.text = "Beginning in \(seconds) seconds."
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            DispatchQueue.main.async {
                self.answerBeginningView.text = "Beginning in \(seconds) seconds."
            }
            seconds -= 1
            if seconds == 0 {
                timer.invalidate()
                DispatchQueue.main.async {
                    self.answerBeginningView.text = "Recording"
                    answer()
                }
            }
        }
    }
    
    private func speakNow() {
        speech.voiceOver(sentence: viewModel.model.sentence, language: languagues[viewModel.questionNumber % 3])
    }
    private func setupUI() {


        answerView.layer.borderColor = UIColor.gray.cgColor
        answerView.layer.borderWidth = 2.0
        answerView.layer.cornerRadius = 10.0

        answerProgressView.layer.borderColor = UIColor.gray.cgColor
        answerProgressView.layer.borderWidth = 2.0
        answerProgressView.clipsToBounds = true
        
//        answerContainerView.layer.borderColor = UIColor.gray.cgColor
//        answerContainerView.layer.borderWidth = 2.0
//        answerContainerView.clipsToBounds = true
//        answerContainerView.layer.cornerRadius = 10.0
//        questionLabel.padding = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)


//        var v: UIView
//        let index = 10
//        for i in 0...11 {
//            v = UIView(frame: CGRect(x: index + (i * 39), y: 15, width: 2, height: 8))
//            v.backgroundColor = UIColor.gray
//            dotview.addSubview(v)
//        }

        addIndicators(toView: answerProgressView)
        answerBeginningView.isHidden = true
        answerTextLabel.text = viewModel.model.sentence
        if Manager.isMockText {
            questionNumberLabel.text = "Question \(viewModel.questionNumber) of \(Manager.totalQuestions)"
        } else {
            questionNumberLabel.text = "Question \(viewModel.questionNumber) of \(viewModel.total)"
        }
        
        questionLabel.attributedText = NSAttributedString(string: viewModel.model.sentence).paragraphStyle(lineSpace: 10.0, textAlignment: .left)

    }

    fileprivate func addIndicators(toView: UIView) {
        let width = Double(toView.frame.width) / count
        let height = Double(toView.frame.height)
        var v: UIView
        for i in 0..<(Int(count)) {
            v = UIView(frame: CGRect(x: (Double(i) * width), y: 0.0, width: width, height: height))
            v.backgroundColor = rgb(r: 118, g: 141, b: 241)
            v.layer.borderWidth = 1.0
            v.layer.borderColor = UIColor.black.cgColor
            v.isHidden = true
            v.tag = i
            toView.addSubview(v)
        }
    }

    fileprivate func viewProgress(animationview: UIView, seconds: Int, completion: (() -> ())?) {
        var initial = 0
        Timer.scheduledTimer(withTimeInterval: Double(seconds) / count, repeats: true) { (timer) in
            animationview.subviews[initial].isHidden = false
            initial += 1
            if initial > Int(self.count) - 1 {
                timer.invalidate()
                animationview.subviews.forEach({ $0.isHidden = false })
                if animationview == self.answerProgressView {
                    self.answerBeginningView.text = "Completed"
                } else if animationview == self.answerProgressView {
                    self.answerBeginningView.text = "Completed"
                }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                        if let c = completion {
                            c()
                        }
                    })
            }
        }
    }

    
}
