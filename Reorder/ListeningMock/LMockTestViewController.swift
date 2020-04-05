//
//  MockTestViewController.swift
//  Reorder
//
//  Created by Ganesan Rajasekarapandian on 21/10/19.
//  Copyright © 2019 Raj. All rights reserved.
//

import UIKit

class LMockTestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        Manager.isListeningMock = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PushSST()
    }
    
    fileprivate func PushSST() {
        let storyboard = UIStoryboard(name: "SST", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "SSTInitialViewController") as? SSTInitialViewController {
            controller.callBack = {
                self.pushLFIB()
            }
            navigationController?.pushViewController(controller, animated: false)
        }
    }

    
    fileprivate func pushLFIB() {
        let storyboard = UIStoryboard(name: "LFIB", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "LFIBInitialViewController") as? LFIBInitialViewController {
            controller.callBack = {
                self.pushHIW()
            }
            navigationController?.pushViewController(controller, animated: false)
        }
    }
    
    fileprivate func pushHIW() {
        let storyboard = UIStoryboard(name: "HIW", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "HIWInitialViewController") as? HIWInitialViewController {
            controller.callBack = {
                self.pushWFD()
            }
            navigationController?.pushViewController(controller, animated: false)
        }
    }
    
    fileprivate func pushWFD() {
        let storyboard = UIStoryboard(name: "WFD", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "WFDInitialViewController") as? WFDInitialViewController {
            controller.callBack = {
                Manager.isAnswerOnly = true
                self.pushLFIB()
            }
            navigationController?.pushViewController(controller, animated: false)
        }
    }

}
