//
//  ReorderViewController.swift
//  Reorder
//
//  Created by Ganesan Rajasekarapandian on 13/9/19.
//  Copyright © 2019 Raj. All rights reserved.
//
//NEws
import UIKit
protocol ReorderViewDelegate:class {
    func didReorderCompleted()
}
var timeDuration = 3
var answerDuration = 2
class ReorderViewController: UIViewController {
    var viewModel:ReorderViewModel!
    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var progressContainerView: UIView!
    var timer:Timer?

    @IBOutlet weak var reorderTextLabel: UILabel!
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var questionNoText: UILabel!
    @IBOutlet weak var paragraphTitle: UILabel!
    var count = 60
    weak var delegate:ReorderViewDelegate?
    var arrangedSubviews:[UIView] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        paragraphTitle.text = viewModel.model.paragraphTitle
        count = Manager.isReadingMock ? 90 : 90
        if Manager.isReadingMock {
            reorderTextLabel.textColor = UIColor.black
            questionNoText.textColor = UIColor.black
            questionNoText.text = "Question \(viewModel.questionSet) of \(Manager.totalReadingQuestions)"
        }else {
            questionNoText.text = "Question \(viewModel.questionSet) of \(viewModel.total)"
        }
        answerLabel.isHidden = true
        setupUI()
    }
    
    @objc private func updateTimer() {
        count -= 1
        countDownLabel.text = timeFormatted(count) // will show timer
        if count == 0 {
            timer?.invalidate()
            if Manager.isReadingMock {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) { [weak self] in
                    self?.dismiss(animated: false, completion: nil)
                    self?.delegate?.didReorderCompleted()
                }
            }else {
                correctArrage()
            }
        }
    }


    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Manager.isReadingMock && Manager.isAnswerOnly {
            countDownLabel.isHidden = true
            correctArrage()
        }
    }
    
    private func setupUI() {
        createStackView()
        arrangedSubviews = stackview.arrangedSubviews
        arrangedSubviews = arrangedSubviews.sorted(by: { $0.tag < $1.tag })
    }
    
    private func createStackView() {
        stackview.alignment = .fill
        stackview.distribution = .fill
        stackview.spacing = 10
        var index = 0
        for content in viewModel.model.content {
            let view = createView(string: content.readingDescription)
            view.tag = content.position
//            view.backgroundColor = .red
            stackview.addArrangedSubview(view)
            view.layoutIfNeeded()
            print(view.frame)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.heightAnchor.constraint(equalToConstant: view.frame.height + 70).isActive = true
//            view.leadingAnchor.constraint(equalTo: stackview.leadingAnchor, constant: 20).isActive = true
//            view.trailingAnchor.constraint(equalTo: stackview.trailingAnchor, constant: -20).isActive = true
//            view.topAnchor.constraint(equalTo:     index == 0 ? stackview.topAnchor : stackview.arrangedSubviews[index].topAnchor, constant: 10).isActive = true
//            view.backgroundColor = .white
//            if  index == viewModel.model.content.count - 1 {
//                view.bottomAnchor.constraint(equalTo: stackview.bottomAnchor, constant: 10).isActive = true
//            }
            view.layoutIfNeeded()
            view.layer.shadowColor = rgb(r: 148, g: 181, b: 246).cgColor
            view.layer.shadowOpacity = 0.5
            view.layer.shadowOffset = CGSize(width: 10, height: 10)
            view.layer.shadowRadius = 5
            view.layer.masksToBounds = false
            view.backgroundColor = .white
            index += 1
       }
        stackview.layoutIfNeeded()
        print(stackview.frame.size.height)
        if stackview.frame.height > 800 {
            for v in stackview.subviews {
                let label = (v.subviews[0] as! UILabel)
                label.font = UIFont(name: label.font.fontName, size: label.font.pointSize - 3)
                v.translatesAutoresizingMaskIntoConstraints = false
                v.heightAnchor.constraint(equalToConstant: v.frame.height - 20).isActive = true
            }
        }
        stackview.layoutIfNeeded()
        print(stackview.frame.size.height)
        
        if stackview.frame.height > 800 {
            for v in stackview.subviews {
                let label = (v.subviews[0] as! UILabel)
                label.font = UIFont(name: label.font.fontName, size: label.font.pointSize - 3)
                v.translatesAutoresizingMaskIntoConstraints = false
                v.heightAnchor.constraint(equalToConstant: v.frame.height - 10).isActive = true
            }
        }

    }
    
    private func correctArrage() {
        answerLabel.isHidden = false
        
        var views = stackview.arrangedSubviews
        views = views.sorted(by: { $0.tag < $1.tag })

        UIView.animate(withDuration: 2.0) { [weak self] in
            guard let strongSelf = self else { return }
            for v in strongSelf.arrangedSubviews {
                strongSelf.stackview.addArrangedSubview(v)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 12) { [weak self] in
            self?.dismiss(animated: false, completion: nil)
            self?.delegate?.didReorderCompleted()
        }
    }
    
    private func createView(string:String) -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 25.0
        view.clipsToBounds = true
        //        label.layer.shadowPath =
        //            UIBezierPath(roundedRect: label.bounds,
        //                         cornerRadius: label.layer.cornerRadius).cgPath
        view.layer.shadowColor = rgb(r: 148, g: 181, b: 246).cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 10, height: 10)
        view.layer.shadowRadius = 5
        view.layer.masksToBounds = false
        view.tag = 98
        let label = UILabel()
        label.numberOfLines = 0
//        view.backgroundColor = .red
        view.addSubview(label)
//        let string = string + "\n"
        label.attributedText = NSAttributedString(string:string,
                                                  attributes:[NSAttributedString.Key.foregroundColor: rgb(r: 36, g: 36, b: 36),
                                                              NSAttributedString.Key.font: UIFont(name: "Times New Roman", size: CGFloat(35)) as Any])
        label.attributedText = label.attributedText?.paragraphStyle(lineSpace: 10.0, textAlignment: .left)
        label.layoutIfNeeded()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        label.backgroundColor = .white
        label.tag = 99
        return view
    }
    
//    func createProgressBar() {
//        progressBar.progress = CGFloat(count/120.0)
//        progressBar.barBorderColor = UIColor.defaultBGColor
//        progressBar.barFillColor = UIColor.defaultBGColor
//        progressBar.barBackgroundColor = rgb(r: 148, g: 181, b: 246, alpha: 0.5)
//        progressBar.barBorderWidth = 1
//        progressBar.barFillInset = 2
//        progressBar.progressLabelInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
//        progressBar.font = UIFont.boldSystemFont(ofSize: 18)
//        progressBar.barMaxHeight = 20
//        progressBar.direction = GTProgressBarDirection.clockwise
//        progressBar.displayLabel = false
//        progressContainerView.addSubview(progressBar)
//        progressBar.addConstrainToSuperView(superView: progressContainerView,leading: 60, trailling: 60, top: 20)
//    }

}


class ReorderViewModel {
//    let count:Int = 0
    let model:Reorder
    let questionSet:Int
    let total:Int
    init(collection:Reorder, set:Int, total:Int) {
        self.model = collection
        questionSet = set
        self.total = total
    }
}

extension UIView {
    func addConstrainToSuperView(superView: UIView, leading: CGFloat = 0.0, trailling: CGFloat = 0.0, top: CGFloat = 0.0, bottom: CGFloat = 0.0) {
        translatesAutoresizingMaskIntoConstraints = false
        leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: leading).isActive = true
        trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: -(trailling)).isActive = true
        topAnchor.constraint(equalTo: superView.topAnchor, constant: top).isActive = true
        bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -(bottom)).isActive = true
    }
    
    func addCenterConstrainToSuperView(superView: UIView, leading: CGFloat = 0.0, trailling: CGFloat = 0.0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: superView.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: superView.centerYAnchor).isActive = true
        leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: leading).isActive = true
        trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant:trailling).isActive = true
    }
}


func rgb(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat = 1.0) -> UIColor {
    return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: alpha)
}

extension UIColor {
    open class var defaultBGColor: UIColor {
        return rgb(r: 51, g: 98, b: 158, alpha: 1.0)
    } // 0.0 white
}

extension NSAttributedString {
    /// set attributed string paragraph style with lineSpace and text alignment
    func paragraphStyle(lineSpace: CGFloat = 0.0, textAlignment: NSTextAlignment = .center) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpace
        paragraphStyle.alignment = textAlignment

        let mutableAttributedString = NSMutableAttributedString(attributedString: self)
        mutableAttributedString.addAttributes([.paragraphStyle: paragraphStyle], range: NSMakeRange(0, self.length))
        return mutableAttributedString
    }
    
    func lineHeightParagraphStyle(height: CGFloat = 0.0, textAlignment: NSTextAlignment = .center) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = height
        paragraphStyle.alignment = textAlignment
        return NSAttributedString(string: self.string, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
    }

}

func timeFormatted(_ totalSeconds: Int) -> String {
    let seconds: Int = totalSeconds % 60
    let minutes: Int = (totalSeconds / 60) % 60
    return String(format: "%02d:%02d", minutes, seconds)
}
