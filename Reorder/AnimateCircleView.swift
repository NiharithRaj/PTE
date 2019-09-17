//
//  AnimateCircleView.swift
//  ScanAndGo
//
//  Created by Ganesan Rajasekarapandian on 8/11/17.
//  Copyright © 2017 WOW. All rights reserved.
//

import UIKit

class AnimateCircleView: UIView {

    //MARK:- AnimateCircleView properties
    var circleLayer: CAShapeLayer!
    var isAnimating = true
    let lineWidth: CGFloat = 5.0
    var animationCompletion: (() -> ())?
    var strokeColor: CGColor?
    var bgColor: UIColor?
    var timer: Timer?

    private let animationKey = "animateCircle"
    //MARK:- Initializer methods
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(frame: CGRect, bgColor: UIColor, circleAnimationColor: CGColor) {
        self.init(frame: frame)
        backgroundColor = UIColor.clear
        strokeColor = circleAnimationColor
        self.bgColor = bgColor
        configCircleView()
    }

    //MARK:- Setup UI method
    func configCircleView() {
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0), radius: (frame.size.width + lineWidth - 10) / 2, startAngle: CGFloat(-(Double.pi / 2)), endAngle: CGFloat((.pi * 2.0) - (.pi / 2)), clockwise: true)


        let bgCircleLayer = CAShapeLayer()
        bgCircleLayer.path = circlePath.cgPath
        bgCircleLayer.fillColor = UIColor.clear.cgColor
        bgCircleLayer.strokeColor = (bgColor ?? UIColor.green).cgColor
        bgCircleLayer.lineWidth = lineWidth
        layer.addSublayer(bgCircleLayer)

        let outlineView = UIView(frame: bounds)
        circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineWidth = lineWidth
        outlineView.layer.addSublayer(circleLayer)
        addSubview(outlineView)
    }


    //MARK:- Start animation

    func animateCircle(duration: TimeInterval, completion: @escaping (() -> ())) {

        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(self.animationCallBack), userInfo: nil, repeats: false)
        animationCompletion = completion

        circleLayer.strokeColor = strokeColor ?? UIColor.gray.cgColor

        if let animationKeys = circleLayer.animationKeys(), animationKeys.count > 0, animationKeys.contains(animationKey) {
            circleLayer.removeAnimation(forKey: animationKey)
        }

        // We want to animate the strokeEnd property of the circleLayer
        let animation = CABasicAnimation(keyPath: "strokeEnd")

        // Set the animation duration appropriately
        animation.duration = duration

        // Animate from 0 (no circle) to 1 (full circle)
        animation.fromValue = 0
        animation.toValue = 1
        // Do a linear animation (i.e The speed of the animation stays the same)
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)

        // Set the circleLayer's strokeEnd property to 1.0 now so that it's the
        // Right value when the animation ends
        circleLayer.strokeEnd = 2.0

        // Do the actual animation
        circleLayer.add(animation, forKey: animationKey)
    }

    @objc func animationCallBack() {
        if let a = self.animationCompletion {
            a()
        }
    }

    //MARK:- Stop animation

    func stopAnimation() {
        timer?.invalidate()
        animationCompletion = nil
        circleLayer.strokeColor = UIColor.clear.cgColor
    }
}
