//
//  InstructionsViewController.swift
//  Reorder
//
//  Created by Ganesan Rajasekarapandian on 4/10/19.
//  Copyright © 2019 Raj. All rights reserved.
//

import UIKit

class InstructionsViewController: UIViewController {
    @IBOutlet weak var instructionlabel: UILabel!
    @IBOutlet weak var tipsimg: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
            self.shouldhideinstructions(yes: false)
        })
        tips()
    }

    func shouldhideinstructions(yes:Bool) {
        self.instructionlabel.isHidden = yes
        self.tipsimg.isHidden = yes
        self.titleLabel.isHidden = yes
    }
    
    func tips() {
        let inst = """
1. As soon as the audio starts you should be ready to write. Use the booklet given for you.
2. Write down the first letter of each word in correct order vertically. Example  👉
3. Verify the answer and type it in the text box. Complete the sentence with full stop or question mark.
4. You shouldn’t take more than a minute for a question.
5. Practice these most repeated exam questions (950+).
6. 95% of exam questions are repeated questions.

- Please follow the above logic if it is working for you. It might seem difficult initially, it will be easy once you get practiced. If you have any other better logic than this, then please comment on the video to help others.
"""
        instructionlabel.attributedText = NSAttributedString(string: inst).paragraphStyle(lineSpace: 20.0, textAlignment: .left)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
