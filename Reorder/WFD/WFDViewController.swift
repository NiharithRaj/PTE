//
//  WFDViewController.swift
//  Reorder
//
//  Created by Ganesan Rajasekarapandian on 24/9/19.
//  Copyright © 2019 Raj. All rights reserved.
//

import UIKit

class WFDViewController: UIViewController {
    var viewModel: RSTimerViewModel!
    let count = 25.0
    let recordTime = 6
    var answerCount = 15
    let speech = Speech()

    @IBOutlet weak var dotview: UIView!
    @IBOutlet weak var progressbarContainerView: UIView!
    @IBOutlet weak var questionNumberLabel: UILabel!
    @IBOutlet weak var topViewBeginningLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var indicatorLineview: UIView!
    
    @IBOutlet weak var answerView: UIView!
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var wordCountLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var questionView: UIView!
    
    weak var delegate: RSTimerDelegate?
    
    var questionTime = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        questionTime = viewModel.speechTime + 1
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Manager.isListeningMock && Manager.isAnswerOnly {
            playAnswer()
        } else {
            changeQuestion()
        }
    }
    
    private func timerEvent() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            self.displayAnswer(timer: timer)
        }
    }
    
    private func displayAnswer(timer:Timer) {
        answerCount -= 1
        timerLabel.text = timeFormatted(answerCount) // will show timer
        if self.answerCount == 0 {
            //Do here
            timer.invalidate()
            if Manager.isListeningMock {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                    self.dismiss(animated: true, completion: nil)
                    self.delegate?.didCompleted()
                })
            } else {
                playAnswer()
            }
        }
    }
    
    private func playAnswer() {
        questionNumberLabel.isHidden = true
        answerLabel.isHidden = false
        wordCountLabel.isHidden = false
        answerLabel.text = viewModel.model.sentence
        wordCountLabel.text = "Total Word Count: \(wordCount())"
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
            self.speakNow()
        })
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10, execute: {
            self.dismiss(animated: true, completion: nil)
            self.delegate?.didCompleted()
        })
    }
    private func wordCount() -> Int {
        let chararacterSet = CharacterSet.whitespacesAndNewlines
        var components = viewModel.model.sentence.components(separatedBy: chararacterSet)
        components = components.filter { !$0.isEmpty }
        return components.count
    }
    
    fileprivate func changeQuestion() {
        var seconds = 3
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            DispatchQueue.main.async {
                self.topViewBeginningLabel.text = "Beginning in \(seconds) seconds."
            }
            seconds -= 1
            if seconds == 0 {
                timer.invalidate()
                DispatchQueue.main.async {
                    self.topViewBeginningLabel.text = "Playing"
                    self.beginQuestionProgress()
                }
            }
        }
    }
    
    
    fileprivate func beginQuestionProgress() {
        viewProgress(animationview: progressbarContainerView, seconds: questionTime) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.topViewBeginningLabel.text = "Completed"
//            DispatchQueue.main.async {
                strongSelf.timerLabel.isHidden = false
                strongSelf.timerEvent()
//            }
        }
        speakNow()
    }
    
    private func speakNow() {
        speech.voiceOver(sentence: viewModel.model.sentence, language: languagues[viewModel.questionNumber % 6])
    }
    
    private func setupUI() {
        
        topView.layer.borderColor = UIColor.gray.cgColor
        topView.layer.borderWidth = 2.0
        topView.layer.cornerRadius = 10.0
        
        answerView.layer.borderColor = UIColor.gray.cgColor
        answerView.layer.borderWidth = 2.0
        answerView.layer.cornerRadius = 10.0
        
        indicatorLineview.layer.cornerRadius = 5.0
        indicatorView.layer.cornerRadius = 20.0
        
        progressbarContainerView.layer.borderColor = UIColor.gray.cgColor
        progressbarContainerView.layer.borderWidth = 2.0
        progressbarContainerView.clipsToBounds = true
        
        answerView.layer.borderColor = UIColor.gray.cgColor
        answerView.layer.borderWidth = 2.0
        answerView.clipsToBounds = true
        
        var v: UIView
        let index = 10
        for i in 0...11 {
            v = UIView(frame: CGRect(x: index + (i * 39), y: 15, width: 2, height: 8))
            v.backgroundColor = UIColor.gray
            dotview.addSubview(v)
        }
        addIndicators(toView: progressbarContainerView)
        if Manager.isListeningMock {
            answerCount = 50
            questionNumberLabel.text = "Question \(viewModel.questionNumber) of \(Manager.totalListeningQuestions)"
        } else {
            questionNumberLabel.text = "Question \(viewModel.questionNumber) of \(viewModel.total)"
        }
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
                self.topViewBeginningLabel.text = "Completed"
                if let c = completion {
                    c()
                }
            }
        }
    }
    
    
}
