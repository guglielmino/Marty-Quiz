//
//  ViewController.swift
//  jurassic Marty
//
//  Created by Fabrizio Guglielmino on 22/11/14.
//  Copyright (c) 2014 Martina Guglielmino. All rights reserved.
//

import UIKit
import QuartzCore


class ViewController: UIViewController, PASImageViewDelegate {

    @IBOutlet weak var imgDino: UIImageView!
    var lblQuestion: UILabel!
    var questionIndex: Int!
    
    var imgMarty: PASImageView!
    
    var status: MartyStatus = MartyStatus.Question
    

    var currentQuestion: JSON? {
        let path = NSBundle.mainBundle().pathForResource("quiz", ofType: "json")
        let localUrl = NSURL(fileURLWithPath: path!)!
        let data = NSData(contentsOfURL: localUrl)!
        let jsonObj = JSON(data: data, options: NSJSONReadingOptions.allZeros, error: nil)
        
        let count = jsonObj.array?.count
        var obj : JSON? = nil
        if count > 0 && questionIndex < count {
             obj =  jsonObj.array![questionIndex]

        }
    
        return obj
    }
    
    func loadQuestion(){
        if let question = currentQuestion {
            let imageDino = UIImage(named: question["image"].string!)!
            imgDino.image = imageDino

            lblQuestion.text = question["question"].string!
        }
    }
    
    let answerPanelTag: Int = 10
    
    func loadAnswersPanel(){
        
        if let previusPanel = self.view.viewWithTag(answerPanelTag) {
            previusPanel.removeFromSuperview()
        }
        
        let panelWidth = self.view.frame.size.width * 0.6
        let panelHeight = self.view.frame.size.height * 0.2
        let panelX = (self.view.frame.size.width - panelWidth) / 2
        let panelY = self.view.frame.size.height - panelHeight
        
        let margin: CGFloat = 10
        
                                                            // Fuori dallo schermo inizialmente
        let answersPanel = UIView(frame: CGRectMake(panelX, panelY + panelHeight, panelWidth, panelHeight))
        answersPanel.tag = answerPanelTag
       
        answersPanel.layer.opacity = 1
        answersPanel.layer.backgroundColor = UIColor(patternImage: UIImage(named: "PanelBackground")!).CGColor
        answersPanel.layer.cornerRadius = 5
        answersPanel.layer.shadowColor = UIColor.darkGrayColor().CGColor
        answersPanel.layer.shadowOpacity = 0.6
        answersPanel.layer.shadowOffset = CGSizeMake(2, 2)
        
        let btnWidth = panelWidth / 2 - 20
        let btnHeight = panelHeight / 3
        let mask: [(Int32, Int32)] = [(0, 0), (1, 0), (0, 1), (1, 1)]
        
        if let question = currentQuestion {
            
            var indexPosition: Int = 0
            for answer in question["answers"].array! {
                
                let maskXY = mask[indexPosition]
                
                let x: CGFloat = margin + ((panelWidth - btnWidth - (2 * margin)) * CGFloat(maskXY.0))
                let y: CGFloat = margin + ((panelHeight - btnHeight - (2 * margin)) * CGFloat(maskXY.1))
                
                let btnAnswer = makeButton(answer.string!, x: x, y: y, btnWidth: btnWidth, btnHeight: btnHeight, indexPosition: indexPosition)
                
                answersPanel.addSubview(btnAnswer)

                indexPosition++
            }
        }        
        
        self.view.addSubview(answersPanel)
        
        UIView.animateWithDuration(1.5, delay: 0.6, options: .CurveEaseOut, animations: { () -> Void in
            answersPanel.frame = CGRectMake(panelX, panelY, panelWidth, panelHeight)
        }, completion: { finished in
            println("Pannello pronto!")
        })
        
    }
    
    func makeButton(text: String, x: CGFloat, y: CGFloat, btnWidth: CGFloat, btnHeight: CGFloat, indexPosition: Int) -> UIButton {
        let btnAnswer = UIButton.buttonWithType(UIButtonType.System) as UIButton
        btnAnswer.setTitle(text, forState: UIControlState.Normal)
        btnAnswer.frame =  CGRectMake(x, y, btnWidth, btnHeight)
        btnAnswer.backgroundColor = UIColor.greenColor()
        btnAnswer.layer.cornerRadius = 7
        
        btnAnswer.titleLabel?.font = UIFont(name: "Arial", size: 18.0)
        
        btnAnswer.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
        btnAnswer.addTarget(self, action: "onAnswerClick:", forControlEvents: UIControlEvents.TouchUpInside)
        btnAnswer.tag = indexPosition


        return btnAnswer
    }
    
    
    func onAnswerClick(sender:UIButton){
       NSLog("ag = %d ", sender.tag)
        
        if sender.tag ==  currentQuestion!["response"].intValue {
            NSLog("Right")
            
            showMartyPic(MartyStatus.RightResp)
            GameSounds.sharedInstance.playSound(GameSounds.Sounds.Won)
            self.questionIndex!++
            loadQuestion()
            loadAnswersPanel()
        }
        else{
            NSLog("Wrong")
            showMartyPic(MartyStatus.WrongResp)
            GameSounds.sharedInstance.playSound(GameSounds.Sounds.Lost)
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0) * Int64(NSEC_PER_SEC)), dispatch_get_main_queue()) {
            self.showMartyPic(MartyStatus.Question)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "Background.png")!.drawInRect(self.view.bounds)
        
        var imageBackground: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        self.view.backgroundColor = UIColor(patternImage: imageBackground)
        
        
        imgMarty = PASImageView(frame: CGRectMake(35, 35, 120, 120))
        imgMarty.backgroundProgressColor(UIColor.whiteColor())
        imgMarty.progressColor(UIColor.redColor())
        imgMarty.layer.shadowOffset = CGSizeMake(1.0, 1.0)
        imgMarty.layer.shadowColor = UIColor.blackColor().CGColor!
        imgMarty.layer.shadowOpacity = 1.0
        imgMarty.delegate = self
        
        
        view.addSubview(imgMarty)
        
        var viewQuestionContainer = UIView(frame: CGRectMake(imgMarty.frame.origin.x + 140,imgMarty.frame.origin.y,650,80))
        viewQuestionContainer.backgroundColor = UIColor.whiteColor()
        viewQuestionContainer.layer.shadowColor = UIColor.grayColor().CGColor!
        viewQuestionContainer.layer.shadowOffset = CGSizeMake(2.0, 2.0)
        viewQuestionContainer.layer.cornerRadius = 9.0
        viewQuestionContainer.layer.shadowOpacity = 0.8
        
        lblQuestion = UILabel(frame: CGRectMake(4,0,viewQuestionContainer.frame.width - 8, 60))
        
        lblQuestion.textColor = UIColor.blackColor()
        lblQuestion.font = UIFont(name: "Verdana", size: 24)
        lblQuestion.text = "Domanda sul dinosauro"
        viewQuestionContainer.addSubview(lblQuestion)
        
        view.addSubview(viewQuestionContainer)
        
        questionIndex = 0
        loadQuestion()
        loadAnswersPanel()
    }
    
    func PAImageView(didTapped imageView: PASImageView) {
    
        showMartyPic(status)
        switch(status){
        case .Question:
            status = .RightResp
        case .RightResp:
            status = .WrongResp
        case .WrongResp:
            status = .Question
            
        }
    }

    override func viewDidAppear(animated: Bool) {
        showMartyPic(.Question)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func showMartyPic(status: MartyStatus){
        
        var imageName = ""
        switch(status){
            case .Question:
                imageName = "question.png"
            case .RightResp:
                imageName = "right.png"
            case .WrongResp:
                imageName = "wrong.png"
        }

        imgMarty.updateImage(UIImage(named: imageName)!, animated: true)
    }


}

