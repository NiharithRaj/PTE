//
//  MultipleViewController.swift
//  Reorder
//
//  Created by Ganesan Rajasekarapandian on 10/3/20.
//  Copyright © 2020 Raj. All rights reserved.
//

import UIKit

class MultipleViewController: UIViewController {

    @IBOutlet weak var optionsStackVoew: UIStackView!
    @IBOutlet weak var paragraphLabel: UILabel!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var questionNumberLabel: UILabel!
    var viewModel: MultipleViewModel!
    weak var delegate: RSTimerDelegate?
    var timerCount = 90
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        optionsStackVoew.spacing = 25
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Manager.isReadingMock && Manager.isAnswerOnly {
            answer()
        }
    }

    func setupUI() {
        questionLabel.text = viewModel.model.question
        paragraphLabel.text = viewModel.model.paragraph
        instructionLabel.text = viewModel.isSingle ? "Read the text and answer the multiple-choice question by selecting the correct response. Only one response is correct." : "Read the text and answer the multiple-choice question by selecting all the correct responses. You will need to select more than one response."
        titleLabel.text = viewModel.isSingle ? "Reading - Multiple Choice Single Answer" : "Reading - Multiple Choice Multiple Answer"
        var stackview:UIStackView
        let optionsABC = ["(A)","(B)","(C)","(D)","(E)","(F)","(G)","(H)","(I)","(J)"]
        var index = 0
        for value in viewModel.model.options {
            stackview = UIStackView()
            stackview.axis = .horizontal
            stackview.distribution = .fillProportionally
            stackview.spacing = 5
            optionsStackVoew.addArrangedSubview(stackview)
            let viewcontainer = UIView()
//            viewcontainer.backgroundColor = .red
            stackview.addArrangedSubview(viewcontainer)
//            viewcontainer.translatesAutoresizingMaskIntoConstraints = false
//            viewcontainer.widthAnchor.constraint(equalToConstant: 100).isActive = true
//            viewcontainer.heightAnchor.constraint(equalToConstant: 100).isActive = true

            let imageView = UIImageView(image: UIImage(named: viewModel.isSingle ? "radio_unselected" : "check_unselected"))
            let abcLabel = UILabel()
            abcLabel.text = optionsABC[index]
            abcLabel.tag = 1
            abcLabel.font = UIFont(name: "Times New Roman", size: CGFloat(32))
            viewcontainer.addSubview(abcLabel)
            abcLabel.translatesAutoresizingMaskIntoConstraints = false
            abcLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
            abcLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
            abcLabel.topAnchor.constraint(equalTo: viewcontainer.topAnchor).isActive = true
            abcLabel.centerXAnchor.constraint(equalTo: viewcontainer.centerXAnchor).isActive = true
            let label = UILabel()
            label.text = value
            label.tag = 2
            label.textAlignment = .justified
            label.numberOfLines = 0
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.8
            label.font = UIFont(name: "Times New Roman", size: CGFloat(32))
            stackview.addArrangedSubview(label)
            
//            imageView.leadingAnchor.constraint(equalTo: stackview.leadingAnchor, constant: 50).isActive = true
//            imageView.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: 50).isActive = true
//            imageView.centerYAnchor.constraint(equalTo: stackview.centerYAnchor, constant: 10).isActive = true
            
            label.translatesAutoresizingMaskIntoConstraints = false
            label.topAnchor.constraint(equalTo: stackview.topAnchor, constant: 5).isActive = true
            label.bottomAnchor.constraint(equalTo: stackview.bottomAnchor, constant: 5).isActive = true
            label.trailingAnchor.constraint(equalTo: stackview.trailingAnchor, constant: 5).isActive = true
            label.leadingAnchor.constraint(equalTo: stackview.leadingAnchor, constant: 60).isActive = true

            stackview.layoutIfNeeded()
            optionsStackVoew.layoutIfNeeded()
            index += 1
        }
        
        if Manager.isReadingMock {
            questionNumberLabel.text = "Question \(viewModel.questionNumber) of \(Manager.totalReadingQuestions)"
          }else {
            questionNumberLabel.text = "Question \(viewModel.questionNumber) of \(viewModel.total)"
        }

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            self.displayAnswer(timer: timer)
        }
    }

    private func answer() {
        timerLabel.isHidden = true
        let answerArray = viewModel.model.answer.components(separatedBy: " ").filter{!$0.isEmpty}
        for value in answerArray
        {
            if let number = Int(value) {
                let vc = optionsStackVoew.arrangedSubviews[number - 1]
                let imageView = vc.subviews[0].subviews.filter {$0.tag == 1}
                (imageView[0] as? UILabel)?.backgroundColor = .yellow
//                (imageView[0] as? UIImageView)?.image = UIImage(named: viewModel.isSingle ? "radio_selected" : "check_selected")
                let label = vc.subviews.filter {$0.tag == 2}
                label[0].backgroundColor = .yellow
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 6, execute: {
                self.dismiss(animated: true, completion: nil)
                self.delegate?.didCompleted()
            })
    }
    func displayAnswer(timer: Timer) {
        timerLabel.text = timeFormatted(timerCount)
        timerCount -= 1

        if timerCount == 0 {
            timer.invalidate()
            if Manager.isReadingMock {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
                        self.dismiss(animated: true, completion: nil)
                        self.delegate?.didCompleted()
                    })
            } else {
                answer()
            }
        }
    }
}
