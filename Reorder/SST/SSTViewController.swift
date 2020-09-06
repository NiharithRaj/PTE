//
//  RLViewController.swift
//  Reorder
//
//  Created by Ganesan Rajasekarapandian on 10/10/19.
//  Copyright © 2019 Raj. All rights reserved.
//

import UIKit

class SSTViewController: UIViewController {
    let speech = Speech()
    var viewModel: SSTViewModel!
    let count = 25.0
    var answerTime = 600
    @IBOutlet weak var answertextLabel: UILabel!
    @IBOutlet weak var dotview: UIView!
    @IBOutlet weak var progressbarContainerView: UIView!
    @IBOutlet weak var questionNumberLabel: UILabel!
    @IBOutlet weak var topViewBeginningLabel: UILabel!
    @IBOutlet weak var summaryView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var indicatorLineview: UIView!
    @IBOutlet weak var answerTextView: UIView!
    @IBOutlet weak var questionView: UIView!
    
    @IBOutlet weak var totalCountLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    weak var delegate: RSTimerDelegate?
    let fileType = "m4a"
    var questionTime = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        questionTime = Utils.audioLength(fileName: viewModel.sst.qno.lowercased(), fileType: fileType)
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        answerTime = Manager.isListeningMock ? 600 : 90
        if Manager.isListeningMock && Manager.isAnswerOnly {
            showAnswer()
        } else {
//            questionView(yes: false)
            changeQuestion()
        }
    }
    
    fileprivate func changeQuestion() {
        var seconds = 7
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            DispatchQueue.main.async {
                self.topViewBeginningLabel.text = "Beginning in \(seconds) seconds."
            }
            seconds -= 1
            if seconds == 0 {
                timer.invalidate()
                DispatchQueue.main.async {
                    Utils.playAudio(fileName: self.viewModel.sst.qno.lowercased(), fileType: self.fileType)
                    self.topViewBeginningLabel.text = "Playing"
                    self.beginQuestionProgress()
                }
            }
        }
    }
    
    fileprivate func questionView(yes: Bool) {
        questionView.isHidden = yes
        answerTextView.isHidden = !yes
    }
    private func startTimer() {
        timerLabel.isHidden = false
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            DispatchQueue.main.async {
                self.timerLabel.text = timeFormatted(self.answerTime)
                self.answerTime -= 1
                if self.answerTime == 0 {
                    if Manager.isListeningMock {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
                            self.dismiss(animated: true, completion: nil)
                            self.delegate?.didCompleted()
                        })
                    } else {
                        self.showAnswer()
                    }
                    timer.invalidate()
                }
            }
        }
    }
    
    func  showAnswer() {
        answertextLabel.attributedText = NSMutableAttributedString(string: viewModel.sst.answer).lineHeightParagraphStyle(height: 1.3, textAlignment: .left)
        let count = viewModel.sst.answer.components(separatedBy: " ").count
        totalCountLabel.text = "Total Word Count: \(count)"
        var time = Double(60)
        if Manager.isListeningMock {
            time = Double(questionTime) + 30
            Utils.playAudio(fileName: self.viewModel.sst.qno.lowercased(), fileType: fileType)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time, execute: {
            self.dismiss(animated: true, completion: nil)
            self.delegate?.didCompleted()
        })
    }
    
    fileprivate func beginQuestionProgress() {
        viewProgress(animationview: progressbarContainerView, seconds: questionTime) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.topViewBeginningLabel.text = "Completed"
            strongSelf.startTimer()
        }
        
//        answerBeginningView.isHidden = false
//        var seconds = questionTime + 8
//        self.answerBeginningView.text = "Beginning in \(seconds) seconds."
//        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
//            DispatchQueue.main.async {
//                self.answerBeginningView.text = "Beginning in \(seconds) seconds."
//            }
//            seconds -= 1
//            if seconds == 0 {
//                timer.invalidate()
//                DispatchQueue.main.async {
////                    Utils.playAudio(fileName: "beep")
//                    self.answerBeginningView.text = "Recording"
//                }
//            }
//        }
    }
    
    private func setupUI() {
        
        topView.layer.borderColor = UIColor.gray.cgColor
        topView.layer.borderWidth = 2.0
        topView.layer.cornerRadius = 10.0
        
        summaryView.layer.borderColor = UIColor.gray.cgColor
        summaryView.layer.borderWidth = 2.0
        summaryView.layer.cornerRadius = 10.0
        
        indicatorLineview.layer.cornerRadius = 5.0
        indicatorView.layer.cornerRadius = 20.0
        
        progressbarContainerView.layer.borderColor = UIColor.gray.cgColor
        progressbarContainerView.layer.borderWidth = 2.0
        progressbarContainerView.clipsToBounds = true
                
        var v: UIView
        let index = 10
        for i in 0...11 {
            v = UIView(frame: CGRect(x: index + (i * 39), y: 15, width: 2, height: 8))
            v.backgroundColor = UIColor.gray
            dotview.addSubview(v)
        }
        addIndicators(toView: progressbarContainerView)
        if Manager.isListeningMock {
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
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                    if let c = completion {
                        c()
                    }
                })
            }
        }
    }
    
    
}

