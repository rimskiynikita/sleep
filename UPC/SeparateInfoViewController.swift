//
//  SeparateInfoViewController.swift
//  UPC
//
//  Created by Никита Римский on 04.03.17.
//  Copyright © 2017 Никита Римский. All rights reserved.
//

import UIKit
import UICircularProgressRing

class SeparateInfoViewController: UIViewController, UICircularProgressRingDelegate {
    
    public func finishedUpdatingProgress(forRing ring: UICircularProgressRingView) {}

    @IBOutlet weak var infoRing: UICircularProgressRingView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var leftNum: UILabel!
    @IBOutlet weak var upperNum: UILabel!
    @IBOutlet weak var rightNum: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var advicesLabels: [UILabel]!
    @IBOutlet var advicesConstraints: [NSLayoutConstraint]!
    
    
    var timer = Timer()
    var ringType: String!
    var startValue: Double!
    var currValue: Double!
    var nums = [Int]()
    var name: String!
    var shown: Bool?
    var advices = [String]()
    var titleText: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        infoRing.delegate = self
        shown = false
        titleLabel.text = titleText
        
        currValue = startValue
        nameLabel.text = name + " conditions:"
        closeButton.isHidden = true
        titleLabel.isHidden = true
        
        leftNum.text = String(nums[0])
        upperNum.text = String(nums[1])
        rightNum.text = String(nums[2])
        
        for constraint in advicesConstraints {
            constraint.constant = -1000
            self.view.layoutIfNeeded()
        }
        
        if ringType != "light" {
            valueChanged(ringType: ringType, value: startValue, label: infoLabel)
            infoRing.setProgress(value: CGFloat(startValue), animationDuration: 1, completion: nil)
        } else {
            startValue = startValue < 15 ? startValue : 15
            UIView.animate(withDuration: 1, animations: {
                let color: UIColor = self.checker(value: CGFloat(self.startValue), minValue: 0, maxValue: 5)
                self.infoRing.outerRingColor = color
                self.infoRing.innerRingColor = color
                self.infoLabel.textColor = color
                self.infoRing.maxValue = 15
                self.infoLabel.text = DataViewController().nameLabel(color: color)
            })
            infoRing.setProgress(value: CGFloat(startValue), animationDuration: 1, completion: nil)
        }
        scheduledTimerWithTimeInterval()
        nameLabels()
    }
    
    func nameLabels() {
        for i in 0...3 {
            advicesLabels[i].text = advices[i]
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.closeButton.isHidden = false

        if !goodOrBad(value: currValue) {
            showAdvice()
            shown = true
        } else {
            hideAdvice()
            shown = false
        }
    }
    
    func showAdvice() {
        self.titleLabel.isHidden = false
        
        var x: CGFloat = 21
        var delay = 0.0
        for constraint in self.advicesConstraints {
            animateAdvice(duration: 1, delay: delay, constraint: constraint, value: x)
            x += 10
            delay += 0.5
        }
        shown = true
    }
    
    func hideAdvice() {
        self.titleLabel.isHidden = true
        
        let x: CGFloat = -2000
        var delay = 0.0
        for constraint in self.advicesConstraints {
            animateAdvice(duration: 1, delay: delay, constraint: constraint, value: x)
            delay += 0.5
        }
        shown = false
    }
    
    func goodOrBad(value: Double) -> Bool {
        var good = true
        switch ringType {
        case "light":
            if value >= 5 {
                good = false
            } else {
                good = true
            }
        case "temp":
            if (value <= 24) || (value > 26) {
                good = false
            } else {
                good = true
            }
        case "hum":
            if (value <= 45) || (value > 55) {
                good = false
            } else {
                good = true
            }
        case "noise":
            if (value <= 30) || (value > 35) {
                good = false
            } else {
                good = true
            }
        default:
            good = true
        }
        return good
    }
    
    func animateAdvice(duration: Double, delay: Double, constraint: NSLayoutConstraint, value: CGFloat) {
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseIn, animations: { 
            constraint.constant += 1000 + value
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func scheduledTimerWithTimeInterval(){
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.getData), userInfo: nil, repeats: true)
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        self.hideAdvice()
    }
    
    func getData() {
        InternetManager.sharedInstance.getTemper(completionHandler: {success, error in
            if let light = success?["light"],
                let temp = success?["temperature"],
                let hum = success?["humidity"],
                let noise = success?["noise"]
            {
                if let response1 = temp as? String,
                    let response2 = hum as? String,
                    let response3 = noise as? String,
                    let response4 = light as? String
                {
                    self.updateData(response1: Double(response1)!, response2: Double(response2)!, response3: Double(response3)!, response4: Double(response4)!, ringType: self.ringType)
                } else if let response1 = temp as? Double,
                    let response2 = hum as? Double,
                    let response3 = noise as? Double,
                    let response4 = light as? Double {
                    self.updateData(response1: response1, response2: response2, response3: response3, response4: response4, ringType: self.ringType)
                }
            }})
        
        if !goodOrBad(value: currValue) && !shown! {
            showAdvice()
        } else if goodOrBad(value: currValue) {
            hideAdvice()
        }
    }
    
    func updateData(response1: Double, response2: Double, response3: Double, response4: Double, ringType: String) {
        let value = response1 < 50 ? response1 : 50
        let value2 =  response2 < 100 ? response2 : 100
        let value3 = response3 < 65 ? response3 : 65
        let value4 = response4 < 15 ? response4 : 15
        var infoValue: Double = 0
        
        switch ringType {
        case "temp":
            infoValue = Double(value)
        case "hum":
            infoValue = Double(value2)
        case "noise":
            infoValue = Double(value3)
        case "light":
            infoValue = Double(value4)
        default:
            break
        }
        
        self.currValue = infoValue
        
        if ringType != "light" {
                UIView.animate(withDuration: 1.0, delay: 0.0, options: .transitionCrossDissolve, animations: {
                self.valueChanged(ringType: self.ringType, value: infoValue, label: self.infoLabel)
            }, completion: nil)
            infoRing.setProgress(value: CGFloat(infoValue), animationDuration: 1, completion: nil)
        } else {
            UIView.animate(withDuration: 1, animations: {
                let color: UIColor = self.checker(value: CGFloat(infoValue), minValue: 0, maxValue: 5)
            self.infoRing.outerRingColor = color
            self.infoRing.innerRingColor = color
            self.infoRing.maxValue = 15
            self.infoLabel.textColor = color
            self.infoLabel.text = DataViewController().nameLabel(color: color)
            })
            infoRing.setProgress(value: CGFloat(infoValue), animationDuration: 1, completion: nil)
        }
    }
    
    func valueChanged(ringType: String, value: Double, label: UILabel) {
        var minValue: CGFloat = 0
        var maxValue: CGFloat = 0
        var color: UIColor = .gray
        
        switch ringType {
        case "temp":
            minValue = 24
            maxValue = 26
        case "hum":
            minValue = 45
            maxValue = 55
        case "noise":
            minValue = 30
            maxValue = 35
        default:
            break
        }
        
        infoRing.maxValue = maxValue + minValue
        color = DataViewController().checker(value: value, minValue: Double(minValue), maxValue: Double(maxValue))
        
        infoRing.innerRingColor = color
        infoRing.outerRingColor = color
        infoLabel.textColor = color
        infoLabel.text = DataViewController().nameLabel(color: color)
    }
    
    func presentAlert() {
        let alertController = UIAlertController(title: "Ooops", message:
            "You have problems with connection", preferredStyle: .alert)
        let tryAgainAction = UIAlertAction(title: "Try again", style: .default) {
            UIAlertAction in
            self.scheduledTimerWithTimeInterval()
        }
        alertController.addAction(tryAgainAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func checker(value: CGFloat, minValue: CGFloat, maxValue: CGFloat) -> UIColor {
        var color: UIColor = .gray
        if value >= minValue && value <= maxValue {
            color = Colours.green
        } else if value < minValue - 5 || value > maxValue + 5 {
            color = Colours.red
        } else {
            color = Colours.yellow
        }
        return color
    }
}
