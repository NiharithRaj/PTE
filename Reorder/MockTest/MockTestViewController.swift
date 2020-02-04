//
//  MockTestViewController.swift
//  Reorder
//
//  Created by Ganesan Rajasekarapandian on 21/10/19.
//  Copyright © 2019 Raj. All rights reserved.
//

import UIKit

class MockTestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        Manager.isMockText = false

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pushASQ()
    }
    
    fileprivate func pushReadAloud() {
        let storyboard = UIStoryboard(name: "ReadAloud", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "ReadAloudInititalViewController") as? ReadAloudInititalViewController {
            controller.callBack = {
                self.pushRepeatSentence()
            }
            navigationController?.pushViewController(controller, animated: false)
        }
    }

    
    fileprivate func pushRepeatSentence() {
        let storyboard = UIStoryboard(name: "RS", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "RSViewController") as? RSViewController {
            controller.callBack = {
                self.pushDescribeImage()
            }
            navigationController?.pushViewController(controller, animated: false)
        }
    }
    
    fileprivate func pushDescribeImage() {
        let storyboard = UIStoryboard(name: "DI", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "DIInitialViewController") as? DIInitialViewController {
            controller.callBack = {
                self.pushRetellLecture()
            }
            navigationController?.pushViewController(controller, animated: false)
        }
    }
    
    fileprivate func pushRetellLecture() {
        let storyboard = UIStoryboard(name: "RL", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "RLInitialViewController") as? RLInitialViewController {
            controller.callBack = {
                self.pushASQ()
            }
            navigationController?.pushViewController(controller, animated: false)
        }
    }
    
    fileprivate func pushASQ() {
        let storyboard = UIStoryboard(name: "ASQ", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "ASQinitialViewController") as? ASQinitialViewController {
            controller.callBack = {
                print("Done")
            }
            navigationController?.pushViewController(controller, animated: false)
        }
    }
}
