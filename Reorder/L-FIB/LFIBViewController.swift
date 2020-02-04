//
//  LFIBViewController.swift
//  Reorder
//
//  Created by Ganesan Rajasekarapandian on 4/2/20.
//  Copyright © 2020 Raj. All rights reserved.
//

import UIKit

class LFIBViewController: UIViewController {
    var viewModel: LFIBViewModel!
    let count = 25.0
    let recordTime = 6
    var answerCount = 10
    let speech = Speech()

    @IBOutlet weak var dotview: UIView!
    @IBOutlet weak var progressbarContainerView: UIView!
    @IBOutlet weak var questionNumberLabel: UILabel!
    @IBOutlet weak var topViewBeginningLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var indicatorLineview: UIView!
    
//    @IBOutlet weak var answerView: UIView!
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var questionView: UIView!
    
    weak var delegate: RSTimerDelegate?
    
    var questionTime = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        questionTime =  Utils.audioLength(fileName: "\(viewModel.model.order)", fileType: "aifc") + 1
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeQuestion()
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
            answerLabel.isHidden = false
//            answerLabel.text = viewModel.model.sentence
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                self.displayCorrectAnswer()
            })
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 8, execute: {
                self.dismiss(animated: true, completion: nil)
                self.delegate?.didCompleted()
            })
        }
    }
    
    private func displayCorrectAnswer() {
        var question = viewModel.model.question
        var ranges:[NSRange] = []
        for index in 0..<viewModel.model.answer.count {
            let tupple = question.replaceFirst(of: "_______", with: viewModel.model.answer[index])
            question = tupple.0
            if let r = tupple.1 {
                ranges.append(r)
            }

        }
        let attri = NSMutableAttributedString(string: question)
        for range in ranges {
            attri.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.red,NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue], range: range)
        }

        UIView.animate(withDuration: 3.0) {
            self.answerLabel.attributedText = attri.paragraphStyle(lineSpace: 15.0, textAlignment: .left)
        }        
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
        Utils.playAudio(fileName: "\(viewModel.model.order)", fileType: "aifc")
    }
    
    private func setupUI() {
        
        topView.layer.borderColor = UIColor.gray.cgColor
        topView.layer.borderWidth = 2.0
        topView.layer.cornerRadius = 10.0
        
//        answerView.layer.borderColor = UIColor.gray.cgColor
//        answerView.layer.borderWidth = 2.0
//        answerView.layer.cornerRadius = 10.0
        
        indicatorLineview.layer.cornerRadius = 5.0
        indicatorView.layer.cornerRadius = 20.0
        
        progressbarContainerView.layer.borderColor = UIColor.gray.cgColor
        progressbarContainerView.layer.borderWidth = 2.0
        progressbarContainerView.clipsToBounds = true
        
//        answerView.layer.borderColor = UIColor.gray.cgColor
//        answerView.layer.borderWidth = 2.0
//        answerView.clipsToBounds = true
        
        answerLabel.attributedText = NSAttributedString(string: viewModel.model.question).paragraphStyle(lineSpace: 15.0, textAlignment: .left)
        
        var v: UIView
        let index = 10
        for i in 0...11 {
            v = UIView(frame: CGRect(x: index + (i * 39), y: 15, width: 2, height: 8))
            v.backgroundColor = UIColor.gray
            dotview.addSubview(v)
        }
        addIndicators(toView: progressbarContainerView)
        questionNumberLabel.text = "Question \(viewModel.questionNumber) of \(viewModel.total)"
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


struct LFIBViewModel {
    let model: LFIB
    let questionNumber:Int
    let total:Int
    init(model: LFIB, questionNumber:Int, total:Int) {
        self.model = model
        self.questionNumber = questionNumber
        self.total = total
    }
}

extension String {

public func replaceFirst(of pattern:String,
                         with replacement:String) -> (String, NSRange?) {
  if let range = self.range(of: pattern){
    print(range.lowerBound)
    var range1 = NSRange(range: range, in: self)
    range1.length = range1.length + replacement.count - pattern.count
    return (self.replacingCharacters(in: range, with: replacement), range1)
  }else{
    return (self, nil)
  }
}
}
public extension NSRange {
    private init(string: String, lowerBound: String.Index, upperBound: String.Index) {
        let utf16 = string.utf16

        let lowerBound = lowerBound.samePosition(in: utf16)!
            let location = utf16.distance(from: utf16.startIndex, to: lowerBound)
            let length = utf16.distance(from: lowerBound, to: upperBound.samePosition(in: utf16)!)

            self.init(location: location, length: length)
        
    }

    init(range: Range<String.Index>, in string: String) {
        self.init(string: string, lowerBound: range.lowerBound, upperBound: range.upperBound)
    }

    init(range: ClosedRange<String.Index>, in string: String) {
        self.init(string: string, lowerBound: range.lowerBound, upperBound: range.upperBound)
    }
}
