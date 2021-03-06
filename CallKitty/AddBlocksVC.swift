//
//  AddBlocksVC.swift
//  CallKitty
//
//  Created by Steve Baker on 11/9/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import UIKit
import CallKit

class AddBlocksVC: UIViewController {

    @IBOutlet private weak var slider: UISlider!
    @IBOutlet private weak var sliderTitleLabel: UILabel!
    @IBOutlet private weak var numberToGenerateLabel: UILabel!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var addIdentifyButton: UIButton!
    @IBOutlet private weak var deleteButton: UIButton!

    var numberDesired = 1

    // MARK: - view lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("ADD_BLOCKS_VC_TITLE", comment: "AddBlocksVC title")
        sliderTitleLabel.text = NSLocalizedString("SLIDER_TITLE_LABEL_TEXT", comment: "AddBlocksVC sliderTitleLabel text")
        numberToGenerateLabel.text = String(numberDesired)
        addButton.setTitle(NSLocalizedString("ADD_BUTTON_TITLE", comment: "AddBlocksVC addButton title"),
                           for: .normal)
        addIdentifyButton.setTitle(NSLocalizedString("ADD_IDENTIFY_BUTTON_TITLE", comment: "AddBlocksVC addIdentifyButton title"),
                           for: .normal)
        deleteButton.setTitle(NSLocalizedString("DELETE_BUTTON_TITLE", comment: "AddBlocksVC delete button title"),
                           for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sliderChanged(sender: UISlider) {
        numberDesired = AddBlocksVC.numberToGenerate(exponent: Double(slider.value))
        numberToGenerateLabel.text = String(numberDesired)
    }

    /// - Parameter exponent: used for base 10 exponentiation
    /// - Returns: 10**exponent, limited to range 1 to 100,000
    static func numberToGenerate(exponent: Double) -> Int {

        var exponentLimited = exponent

        let exponentLimitedMin = 0.0
        let exponentLimitedMax = 5.0

        if exponent < exponentLimitedMin {
            exponentLimited = exponentLimitedMin
        } else if exponent > exponentLimitedMax {
            exponentLimited = exponentLimitedMax
        }

        var numberDesired = Int(pow(10, exponentLimited))

        // limit range again because exponentiation is not exact
        let numberDesiredMin = 1
        let numberDesiredMax = 100_000
        
        if numberDesired < numberDesiredMin {
            numberDesired = numberDesiredMin
        } else if numberDesired > numberDesiredMax {
            numberDesired = numberDesiredMax
        }
        return numberDesired
    }

    @IBAction func addButtonTapped(_ sender: Any) {
        // add in background to avoid blocking UI
        RealmService.backgroundAddBlockingPhoneCallers(count: numberDesired) {
            // completion closure
        }
    }

    @IBAction func addIdentifyButtonTapped(_ sender: Any) {
        // add in background to avoid blocking UI

        RealmService.backgroundAddIdentifyingPhoneCallers(count: numberDesired) {
            // completion closure
        }
    }

    @IBAction func deleteAllButtonTapped(_ sender: Any) {
        // use background method to avoid blocking UI

        RealmService.backgroundAllPhoneCallersShouldDelete()
    }

}
