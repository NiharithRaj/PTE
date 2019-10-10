//
//  Utils.swift
//  Reorder
//
//  Created by Ganesan Rajasekarapandian on 23/9/19.
//  Copyright © 2019 Raj. All rights reserved.
//

import Foundation
import AVFoundation
import AudioToolbox
import UIKit

struct Utils {
    static var player: AVAudioPlayer?
    
    static func playAudio(fileName:String) {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "mp3") else { return}
        
        do {
            let url = URL(fileURLWithPath: path)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category(rawValue: AVAudioSession.Category.playback.rawValue), mode: .default, options: AVAudioSession.CategoryOptions.mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            if fileName == "beep" {
                player.rate = 2.0
            }
            player.play()
        
        } catch  {
        }
    }
    
    static func audioLength(fileName:String) ->Int {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "mp3") else { return 6}
        let url = URL(fileURLWithPath: path)
        do{
            let player = try AVAudioPlayer(contentsOf: url)
            print(player.duration)
            print(player.duration.rounded())
            print(Int(player.duration.rounded()) + 1)
            return Int(player.duration.rounded()) + 1
        } catch  {
        }
        
        return 6
    }
    

    //English (Australia) - en-AU
    //English (Ireland) - en-IE
    //English (South Africa) - en-ZA
    //English (United Kingdom) - en-GB
    //English (United States) - en-US

}

class Speech :NSObject, AVSpeechSynthesizerDelegate {
    
    let speechSynthesizer = AVSpeechSynthesizer()

    func voiceOver(sentence: String, language: String? = "en-US") {
        print(language)
        // Do any additional setup after loading the view.
        // Line 1. Create an instance of AVSpeechSynthesizer.
        // Line 2. Create an instance of AVSpeechUtterance and pass in a String to be spoken.
        let speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: sentence)
        //Line 3. Specify the speech utterance rate. 1 = speaking extremely the higher the values the slower speech patterns. The default rate, AVSpeechUtteranceDefaultSpeechRate is 0.5
        speechUtterance.rate = 0.50
        // Line 4. Specify the voice. It is explicitly set to English here, but it will use the device default if not specified.
        speechUtterance.voice = AVSpeechSynthesisVoice(language: language)
        speechSynthesizer.speak(speechUtterance)
    }
}

extension UILabel {
    private struct AssociatedKeys {
        static var padding = UIEdgeInsets()
    }
    
    public var padding: UIEdgeInsets? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.padding) as? UIEdgeInsets
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.padding, newValue as UIEdgeInsets?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    override open func draw(_ rect: CGRect) {
        if let insets = padding {
            self.drawText(in: rect.inset(by: insets))
        } else {
            self.drawText(in: rect)
        }
}
    
    override open var intrinsicContentSize: CGSize {
        guard let text = self.text else { return super.intrinsicContentSize }
        
        var contentSize = super.intrinsicContentSize
        var textWidth: CGFloat = frame.size.width
        var insetsHeight: CGFloat = 0.0
        var insetsWidth: CGFloat = 0.0
        
        if let insets = padding {
            insetsWidth += insets.left + insets.right
            insetsHeight += insets.top + insets.bottom
            textWidth -= insetsWidth
        }
        
        let newSize = text.boundingRect(with: CGSize(width: textWidth, height: CGFloat.greatestFiniteMagnitude),
                                        options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                        attributes: [NSAttributedString.Key.font: self.font], context: nil)
        
        contentSize.height = ceil(newSize.size.height) + insetsHeight
        contentSize.width = ceil(newSize.size.width) + insetsWidth
        
        return contentSize
        
    }

}
