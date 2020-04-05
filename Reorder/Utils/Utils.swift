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
    static let shared = Utils()
    
    static var player: AVAudioPlayer?
    
    static func playAudio(fileName:String, fileType: String = "mp3", volume: Float = 1.0) {
        print(Bundle.main.path(forResource: fileName, ofType: fileType))
        print(fileName)
        print(fileType)
        guard let path = Bundle.main.path(forResource: fileName, ofType: fileType) else { return}
        
        do {
            let url = URL(fileURLWithPath: path)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category(rawValue: AVAudioSession.Category.playback.rawValue), mode: .default, options: AVAudioSession.CategoryOptions.mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            if fileName == "beep" {
                player.rate = 2.0
                player.volume = volume
            }
            player.play()
        
        } catch  {
        }
    }
    

    static func audioLength(fileName:String, fileType: String = "mp3") ->Int {
        guard let path = Bundle.main.path(forResource: fileName, ofType: fileType) else { return 6}
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

    func voiceOver(sentence: String, language: String? = "en-US", utterance: Float = 0.50) {
        print(language)
        // Do any additional setup after loading the view.
        // Line 1. Create an instance of AVSpeechSynthesizer.
        // Line 2. Create an instance of AVSpeechUtterance and pass in a String to be spoken.
        let speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: sentence)
        //Line 3. Specify the speech utterance rate. 1 = speaking extremely the higher the values the slower speech patterns. The default rate, AVSpeechUtteranceDefaultSpeechRate is 0.5
        speechUtterance.rate = utterance
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
class GSAudio: NSObject, AVAudioPlayerDelegate {

    static let sharedInstance = GSAudio()

    private override init() { }

    var players: [URL: AVAudioPlayer] = [:]
    var duplicatePlayers: [AVAudioPlayer] = []

    func playSound(soundFileName: String, volume: Float = 1.0) {

        guard let bundle = Bundle.main.path(forResource: soundFileName, ofType: "aifc") else { return }
        let soundFileNameURL = URL(fileURLWithPath: bundle)

        if let player = players[soundFileNameURL] { //player for sound has been found
            
            if !player.isPlaying { //player is not in use, so use that one
                player.prepareToPlay()
                player.volume = volume
                player.play()
            } else { // player is in use, create a new, duplicate, player and use that instead

                do {
                    let duplicatePlayer = try AVAudioPlayer(contentsOf: soundFileNameURL)

                    duplicatePlayer.delegate = self
                    //assign delegate for duplicatePlayer so delegate can remove the duplicate once it's stopped playing

                    duplicatePlayers.append(duplicatePlayer)
                    //add duplicate to array so it doesn't get removed from memory before finishing
                    duplicatePlayer.volume = volume
                    duplicatePlayer.prepareToPlay()
                    duplicatePlayer.play()
                } catch let error {
                    print(error.localizedDescription)
                }

            }
        } else { //player has not been found, create a new player with the URL if possible
            do {
                let player = try AVAudioPlayer(contentsOf: soundFileNameURL)
                players[soundFileNameURL] = player
                player.prepareToPlay()
                player.play()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }


    func playSounds(soundFileNames: [String]) {
        for soundFileName in soundFileNames {
            playSound(soundFileName: soundFileName)
        }
    }

    func playSounds(soundFileNames: String...) {
        for soundFileName in soundFileNames {
            playSound(soundFileName: soundFileName)
        }
    }

    func playSounds(soundFileNames: [String], withDelay: Double) { //withDelay is in seconds
        for (index, soundFileName) in soundFileNames.enumerated() {
            let delay = withDelay * Double(index)
            let _ = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(playSoundNotification(_:)), userInfo: ["fileName": soundFileName], repeats: false)
        }
    }

    @objc func playSoundNotification(_ notification: NSNotification) {
        if let soundFileName = notification.userInfo?["fileName"] as? String {
            playSound(soundFileName: soundFileName)
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let index = duplicatePlayers.index(of: player) {
            duplicatePlayers.remove(at: index)
        }
    }
    
    static func audioLength(fileName:String) ->Int {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "aifc") else { return 6}
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

}
