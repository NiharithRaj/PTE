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
}
