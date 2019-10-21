//
//  RLViewController.swift
//  Reorder
//
//  Created by Ganesan Rajasekarapandian on 10/10/19.
//  Copyright © 2019 Raj. All rights reserved.
//

import UIKit

class RLViewController: UIViewController {
    let speech = Speech()
    var viewModel: RLViewModel!
    let count = 25.0
    let recordTime = 8
    @IBOutlet weak var dotview: UIView!
    @IBOutlet weak var progressbarContainerView: UIView!
    @IBOutlet weak var questionNumberLabel: UILabel!
    @IBOutlet weak var topViewBeginningLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var indicatorLineview: UIView!
    
    @IBOutlet weak var answerTextLabel: UILabel!
    
    @IBOutlet weak var answerBeginningView: UILabel!
    @IBOutlet weak var answerProgressView: UIView!
    @IBOutlet weak var answerView: UIView!
    
    
    @IBOutlet weak var answerTextView: UIView!
    @IBOutlet weak var questionView: UIView!
    
    weak var delegate: RSTimerDelegate?
    
    var questionTime = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        questionTime = Utils.audioLength(fileName: viewModel.name)
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        questionView(yes: false)
        changeQuestion()
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
                    Utils.playAudio(fileName: self.viewModel.name)
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
    
    fileprivate func beginQuestionProgress() {
        viewProgress(animationview: progressbarContainerView, seconds: questionTime) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.topViewBeginningLabel.text = "Completed"
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 8, execute: {
                strongSelf.viewProgress(animationview: strongSelf.answerProgressView, seconds: 40) {
                    DispatchQueue.main.async {
                        strongSelf.answerBeginningView.text = "Completed"
                        UIView.animate(withDuration: 1, animations: {
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                                strongSelf.dismiss(animated: true, completion: nil)
                                strongSelf.delegate?.didCompleted()
                            })
                        })
                    }
                }
            })
        }
        
        answerBeginningView.isHidden = false
        var seconds = questionTime + 8
        self.answerBeginningView.text = "Beginning in \(seconds) seconds."
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            DispatchQueue.main.async {
                self.answerBeginningView.text = "Beginning in \(seconds) seconds."
            }
            seconds -= 1
            if seconds == 0 {
                timer.invalidate()
                DispatchQueue.main.async {
                    Utils.playAudio(fileName: "beep")
                    self.answerBeginningView.text = "Recording"
                }
            }
        }
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
        
        answerProgressView.layer.borderColor = UIColor.gray.cgColor
        answerProgressView.layer.borderWidth = 2.0
        answerProgressView.clipsToBounds = true
        
        var v: UIView
        let index = 10
        for i in 0...11 {
            v = UIView(frame: CGRect(x: index + (i * 39), y: 15, width: 2, height: 8))
            v.backgroundColor = UIColor.gray
            dotview.addSubview(v)
        }
        addIndicators(toView: progressbarContainerView)
        addIndicators(toView: answerProgressView)
        answerBeginningView.isHidden = true
        if Manager.isMockText {
            questionNumberLabel.text = "Question \(viewModel.questionNumber) of \(Manager.totalQuestions)"
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
                if animationview == self.answerProgressView {
                    self.answerBeginningView.text = "Completed"
                } else if animationview == self.progressbarContainerView {
                    self.topViewBeginningLabel.text = "Completed"
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

struct RLViewModel {
    var questionNumber:Int = 0
    let name:String
    init(fileName:String,qnumber:Int) {
        name = fileName
        questionNumber = qnumber
    }
}
