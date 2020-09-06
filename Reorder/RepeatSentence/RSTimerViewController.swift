//
//  RSTimerViewController.swift
//  Reorder
//
//  Created by Ganesan Rajasekarapandian on 20/9/19.
//  Copyright © 2019 Raj. All rights reserved.
//

import UIKit
protocol RSTimerDelegate: class {
    func didCompleted()
}

class RSTimerViewController: UIViewController {
    let speech = Speech()
    var viewModel: RSTimerViewModel!
    let count = 25.0
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var answerNewImageView: UIImageView!
    let recordTime = 8
    @IBOutlet weak var dotview: UIView!
    @IBOutlet weak var progressbarContainerView: UIView!
    @IBOutlet weak var questionNumberLabel: UILabel!
    @IBOutlet weak var answerViewHeightConstriant: NSLayoutConstraint!
    @IBOutlet weak var topViewBeginningLabel: UILabel!
    @IBOutlet weak var anwerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var indicatorLineview: UIView!

    @IBOutlet weak var answerTextLabel: UILabel!

    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var answerBeginningView: UILabel!
    @IBOutlet weak var answerProgressView: UIView!
    @IBOutlet weak var answerView: UIView!

    @IBOutlet weak var newImage: UIImageView!
    
    @IBOutlet weak var answerTextView: UIView!
    @IBOutlet weak var questionView: UIView!

    weak var delegate: RSTimerDelegate?

    var questionTime = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        instructionLabel.text =  viewModel.isWFDInstrucion ? "You will hear a sentence. Type the sentence in the box below exactly as you hear it. Write as much of the sentence as you can. You will hear the sentence only once." : "You will hear a sentence. Please repeat the sentence exactly as you hear it. You will hear the sentence only one."
        if viewModel.isWFDInstrucion {
            answerView.isHidden = true
            answerViewHeightConstriant.constant = answerViewHeightConstriant.constant * 0.45
            anwerViewTopConstraint.constant = anwerViewTopConstraint.constant * 3
        }
        questionTime = viewModel.speechTime // Utils.audioLength(fileName: "\(viewModel.model.fileName)")
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Manager.isMockText && Manager.isAnswerOnly {
            questionView(yes: true)
            playOnlyAnswer()
        } else {
            questionView(yes: false)
            changeQuestion()
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

    fileprivate func questionView(yes: Bool) {
        questionView.isHidden = yes
        answerTextView.isHidden = !yes
    }

    fileprivate func beginQuestionProgress() {

        viewProgress(animationview: progressbarContainerView, seconds: questionTime + 1) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.topViewBeginningLabel.text = "Completed"
            strongSelf.viewProgress(animationview: strongSelf.answerProgressView, seconds: (strongSelf.viewModel.isWFDInstrucion ? 15 : strongSelf.questionTime + 2)) {
                DispatchQueue.main.async {
                    strongSelf.answerBeginningView.text = "Completed"

                    if Manager.isMockText {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                            strongSelf.dismiss(animated: true, completion: nil)
                            strongSelf.delegate?.didCompleted()
                        })
                    } else {
                    UIView.animate(withDuration: 1, animations: {
                        UIView.transition(from: strongSelf.questionView, to: strongSelf.answerTextView, duration: 1.0
                            , options: [[.transitionFlipFromRight,
                                         .showHideTransitionViews]]) { _ in
                                            strongSelf.questionView(yes: true)
                        }
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                            strongSelf.speakNow()
                        })
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10, execute: {
                            strongSelf.dismiss(animated: true, completion: nil)
                            strongSelf.delegate?.didCompleted()
                        })
                    })
                    }

                }
            }
        }

        answerBeginningView.isHidden = false
        var seconds = questionTime + 1
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
                }
            }
        }
        DispatchQueue.main.async {
            self.speakNow()
        }
    }
    private func playOnlyAnswer() {
        
            questionView(yes: true)
             DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                 self.speakNow()
             })
             DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10, execute: {
                 self.dismiss(animated: true, completion: nil)
                 self.delegate?.didCompleted()
             })
    }
    
    private func speakNow() {
        speech.voiceOver(sentence: viewModel.model.sentence, language: languagues[viewModel.questionNumber % 5], utterance: 0.45)
    }
    private func setupUI() {

        topView.layer.borderColor = UIColor.gray.cgColor
        topView.layer.borderWidth = 2.0
        topView.layer.masksToBounds = true
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
        answerTextLabel.text = viewModel.model.sentence
        questionNumberLabel.text = "Question \(viewModel.questionNumber) of \(viewModel.total)"
        if Manager.isMockText {
            questionNumberLabel.text = "Question \(viewModel.questionNumber) of \(Manager.totalQuestions)"
        }
        newImage.isHidden = !(viewModel.model.isNew ?? false)
        answerNewImageView.isHidden = !(viewModel.model.isNew ?? false)
        if let isnew = viewModel.model.isNew, !isnew {
            leadingConstraint.constant = 25
        }
        
        if let repeatRate = viewModel.model.repeatRate, let isnew = viewModel.model.isNew, !isnew {
            let starView = StarRatingView(frame: CGRect(x: view.frame.size.width - 600, y: 200, width: 480, height: 60), starCount: repeatRate)
            view.addSubview(starView)
            starView.translatesAutoresizingMaskIntoConstraints = false
            starView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
            starView.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 30).isActive = true
            starView.widthAnchor.constraint(equalToConstant: 480).isActive = true
            starView.heightAnchor.constraint(equalToConstant: 60).isActive = true
            view.bringSubviewToFront(starView)
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

struct RSTimerViewModel {
    let model: RepeatSentence
    let questionNumber:Int
    let total:Int
    let isWFDInstrucion:Bool
    init(model: RepeatSentence, questionNumber:Int, total:Int, isWFDInstrucion:Bool = false) {
        self.model = model
        self.questionNumber = questionNumber
        self.total = total
        self.isWFDInstrucion = isWFDInstrucion
    }
    
    var speechTime:Int {
        var time = 5
        let arr = model.sentence.components(separatedBy: CharacterSet.init(charactersIn: " "))
        if arr.count > 10 && arr.count <= 13 {
            time = 5
        } else if arr.count > 13 && arr.count <= 16 {
            time = 6
        } else if arr.count > 16 {
            time = 7
        }
        if isWFDInstrucion {
            return time + 1
        }else {
            return time
        }
    }
}


class StarRatingView: UIView {
    required init?(coder: NSCoder) {
        count = 0
        super.init(coder: coder)
    }
    let count: Int
    init(frame: CGRect, starCount: Int) {
        count = starCount
        super.init(frame: frame)
        commonInt()
    }
    
    
    func commonInt() {
        let mainStackView:UIStackView = UIStackView()
        mainStackView.axis = .horizontal
        mainStackView.alignment = .fill
        mainStackView.distribution = .fill
        mainStackView.spacing = 10
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.size.width - 50 / 2, height: 60))
        label.attributedText = NSAttributedString(string:"Repeat rate:",
                                                  attributes:[NSAttributedString.Key.font: UIFont(name: "TimesNewRomanPS-BoldMT", size: 35) as Any])
        label.textAlignment = .left
//        label.font = UIFont(name: "Times New Roman", size: 35)

        mainStackView.addArrangedSubview(label)

        let stackView:UIStackView = UIStackView()
        stackView.frame = frame
        stackView.distribution = .fillEqually
        stackView.alignment = .leading
        stackView.axis = .horizontal
        var imview : UIImageView!
        let width = 55
        let startCount = 5
        for v in 0..<startCount {
            imview = UIImageView()
            imview.frame = CGRect(x: v * width, y: 5, width: width, height: width)
            imview.image = UIImage(named: v < count ? "Star-1": "Star")
            imview.contentMode = .scaleAspectFill
            stackView.addSubview(imview)
        }
        stackView.frame.size.width = CGFloat(startCount * width)
        mainStackView.addArrangedSubview(stackView)

        addSubview(mainStackView)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        mainStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
    }
}
