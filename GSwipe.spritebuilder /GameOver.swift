//
//  GameOver.swift
//  Swipe
//
//  Created by Gugsa Gemeda on 7/28/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation
import GameKit



class GameOver: CCNode {
    
    weak var scoreLabel: CCLabelTTF!
    weak var highScore: CCLabelTTF!
    
    weak var restartButton: CCButton!
    
    var points: Int = 0 {
        didSet {
            scoreLabel.string = "\(points)"
        }
    }
    
    func didLoadFromCCB() {
        setUpGameCenter()
        updateHighestScore()
        OALSimpleAudio.sharedInstance().playEffect("sound/Wrong.wav") 
        
    }
    
    func checkForNewHighScores(){
    }
    
    
    func setUpGameCenter() {
        let gameCenterInteractor = GameCenterInteractor.sharedInstance
        gameCenterInteractor.authenticationCheck()
    }
    
    func openGameCenter() {
        showLeaderboard()
    }
    
    func muteAndSound(){
        Gamestate.sharedInstance.toggleSound()
    }
    
    override func update(delta: CCTime) {
        let defaults = NSUserDefaults.standardUserDefaults()
        var currentHighestScore = defaults.integerForKey("highestScore")
        var currentScore = defaults.integerForKey("scoreLabel")
        highScore.string = "\(currentHighestScore)"
        
    }
    
    func updateHighestScore(){
        var newHighScore = NSUserDefaults.standardUserDefaults().integerForKey("highestScore")
        highScore.string = "\(newHighScore)"
        
    }
    
    func restart() {
        let scene = CCBReader.loadAsScene("Gameplay")
        CCDirector.sharedDirector().presentScene(scene)
    }
    
    func setting(){
        let scene = CCBReader.loadAsScene("MainScene")
        CCDirector.sharedDirector().presentScene(scene)
    }
    
    func shareButtonTapped() {
        var scene = CCDirector.sharedDirector().runningScene
        var node: AnyObject = scene.children[0]
        var screenshot = screenShotWithStartNode(node as! CCNode)
        let sharedText = "This is some default text that I want to share with my users. [This is where I put a link to download my awesome game]"
        let itemsToShare = [screenshot, sharedText]
        
        var excludedActivities = [ UIActivityTypeAssignToContact,
            UIActivityTypeAddToReadingList, UIActivityTypePostToTencentWeibo]
        var controller = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        controller.excludedActivityTypes = excludedActivities
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(controller, animated: true, completion: nil)
        
    }
    
    
    func screenShotWithStartNode(node: CCNode) -> UIImage {
        CCDirector.sharedDirector().nextDeltaTimeZero = true
        var viewSize = CCDirector.sharedDirector().viewSize()
        var rtx = CCRenderTexture(width: Int32(viewSize.width), height: Int32(viewSize.height))
        rtx.begin()
        node.visit()
        rtx.end()
        return rtx.getUIImage()
    }
    
}


// MARK: Game Center Handling extension Gameplay: GKGameCenterControllerDelegate {

extension GameOver: GKGameCenterControllerDelegate {
    
    func showLeaderboard() {
        var viewController = CCDirector.sharedDirector().parentViewController!
        var gameCenterViewController = GKGameCenterViewController()
        gameCenterViewController.gameCenterDelegate = self
        viewController.presentViewController(gameCenterViewController, animated: true, completion: nil)
    }
    
    // Delegate methods
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
