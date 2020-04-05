//
//  Manager.swift
//  Reorder
//
//  Created by Ganesan Rajasekarapandian on 10/10/19.
//  Copyright © 2019 Raj. All rights reserved.
//

import Foundation

struct Manager {
    static let instance = Manager()
    static var isMockText = false
    static var isAnswerOnly = false
    static var isListeningMock = false
    static let totalQuestions = readAloudCount + rsCount + DICount + RetellCount + ASQCount
    static let readAloudCount = 6
    static let rsCount = 12
    static let DICount = 6
    static let RetellCount = 2
    static let ASQCount = 12
    
    static let readAloudStart = 0
    static let rpeatstart = readAloudCount + 1
    static let DIstart = readAloudCount + rsCount + 1
    static let Retellstart = readAloudCount + rsCount + DICount + 1
    static let ASQstart = readAloudCount + rsCount + DICount  + RetellCount + 1

    static let totalListeningQuestions = sst + fib + hiw + wfd
    static let sst = 2
    static let fib = 3
    static let hiw = 2
    static let wfd = 4
    static let sstStart = 1
    static let fibstart = sst + 1
    static let hiwstart = sst + fib + 1
    static let wfdstart = sst + fib + hiw + 1


}
