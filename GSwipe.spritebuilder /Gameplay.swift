
import Foundation

enum genericColor {
    case blue, green, red, yellow
}

//
enum GameState {
    case Title, Playing, GameOver
}


class Gameplay: CCNode{
    
    // MARK: Variables
    
    weak var scoreLabel : CCLabelTTF!
    weak var lifeBar: CCNode!
    weak var insertionPoint: CCNode!
    weak var gamePhysicsNode : CCPhysicsNode!
    weak var checkpoint: CCNode!
    weak var score: CCNode!
    weak var circleLayer: CCNode!
    var scaleFactor = 1
    var gameState: GameState = .Title
    var circles : [Circle] = []
    var selectedCircle : Circle?
    var startPoint : CGPoint?
    var gameOver = false
    var gameReallyOver = false

    
    
    var points: Int = 0 {
        didSet {
            scoreLabel.string = "\(score)"
        }
    }
    
    
    // MARK: Start
    
    func didLoadFromCCB(){

        OALSimpleAudio.sharedInstance().playBg("background.mp3")
        OALSimpleAudio.sharedInstance().playBgWithLoop(true)
//      gamePhysicsNode.debugDraw = true
        
        
        self.schedule("spawnNewCircle", interval: 0.5)
   
        
        userInteractionEnabled = true
        gamePhysicsNode.collisionDelegate = self
        checkpoint.physicsBody.sensor = true
        
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var playing = userDefaults.objectForKey("gamesound") as? Bool
        if let playing = playing {
            Gamestate.sharedInstance.playing = playing
        }
    }
    
    
    override func onEnter() {
        super.onEnter()
        gameState = .Playing
    }
    
    
    func spawnNewCircle() {
        var circleName: String = ""
        switch Int.random(min:1, max: 4) {
        case 1:
            circleName = "greenCircle"
        case 2:
            circleName = "yellowCircle"
        case 3:
            circleName = "redCircle"
        case 4:
            circleName = "blueCircle"
        default:
            println("Not Supported")
        }
        
        var newCircle = CCBReader.load(circleName) as! Circle
        newCircle.position = ccp(0, -300)
        circles.append(newCircle)
        gamePhysicsNode.addChild(newCircle)
        
//      var halfScreen = CCDirector.sharedDirector().viewSize().width / 2
        
        var screenHalf = Int.random(min:100, max:220)
        insertionPoint.position = (CGPoint(x:screenHalf, y: 650))
        newCircle.position = insertionPoint.position
        newCircle.physicsBody.velocity = ccp(0, 0)
        newCircle.state = .OnScreen
        
    }
    
    
    // MARK: Touch methods
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        detectTouch(touch)
        startPoint = touch.locationInWorld()
    }
    
    
    func detectTouch(touch: CCTouch!){
        
        var currentTouch = convertToNodeSpace(touch.locationInWorld())
        
        for circleGlobal in circles {
            
            var circle = convertToNodeSpace(circleGlobal.position)
            let size = circleGlobal.contentSize
            let minX = circle.x - size.width/2 - 20
            let maxX = circle.x + size.width/2 + 20
            let minY = circle.y - size.height/2 - 20
            let maxY = circle.y + size.height/2 + 20
            
            
            if currentTouch.x > minX && currentTouch.x < maxX && currentTouch.y > minY && currentTouch.y < maxY{
                selectedCircle = circleGlobal
                circleGlobal.state = .UserInteracting
                
            }
        }
    }
    
    
    
    override func touchMoved(touch: CCTouch!, withEvent event: CCTouchEvent!){
        if let c = selectedCircle {
            c.position = touch.locationInWorld()
        }
    }
    
    
    
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        var endPoint = touch.locationInWorld()
        var speed = hypotf(Float(startPoint!.x - endPoint.x), Float((startPoint!.y - endPoint.y)))
        
        let directionVector = startPoint?.directionVectorToPoint(endPoint)
        if let directionVector = directionVector {
            if selectedCircle?.removed == false {
                
                selectedCircle?.physicsBody.applyImpulse(ccp(directionVector.x * 10, directionVector.y * 10))
                selectedCircle?.state = .OnScreen
            }
            selectedCircle = nil
        }
    }
    
    
    
    override func update(delta: CCTime) {
        for circle in circles {
            
            var minVelocityX = -200 * scaleFactor
            var minVelocityY = -200 * scaleFactor
            
            if circle.state != .UserInteracting{
                
                let velocityX = clampf(Float(circle.physicsBody.velocity.x),Float(minVelocityX),100)
                let velocityY = clampf(Float(circle.physicsBody.velocity.y),Float(minVelocityY),100)
                
                circle.physicsBody.velocity = ccp(CGFloat(velocityX), CGFloat(velocityY))
                
            } else{
                circle.physicsBody.velocity = ccp(0, 0)
                
            }
        }
        
    }
    
    
    
    // MARK: Game Logic
    
    func isGameOver(pair: CCPhysicsCollisionPair!, circle: Circle, score: Rectangle) -> Bool {
        
        if circle.typ != score.type {
            triggerGameOver()
        }
        return true
       // return gameState == .GameOver
    }
    
    
    func triggerGameOver() {
        if (gameOver == false) {
            gameOver = true
            gameState = .GameOver
            
            var gameOverScreen = CCBReader.load("GameOver") as! GameOver
        
            gameOverScreen.points = points
            self.addChild(gameOverScreen)
            
            
            
            let defaults = NSUserDefaults.standardUserDefaults()
            var highestScore = defaults.integerForKey("highestScore")
            if self.points > highestScore{
                defaults.setInteger(Int(self.points), forKey: "highestScore")
                GameCenterInteractor.sharedInstance.reportHighScoreToGameCenter(self.points)
            }
        }
    }
    
    func circleRemoved(circle: Circle) {
        let explosion = CCBReader.load("CircleExplosion") as! CCParticleSystem
        // make the particle effect clean itself up, once it is completed
        explosion.autoRemoveOnFinish = true;
        explosion.position = circle.position;
        circle.parent.addChild(explosion)
        circle.removeFromParent()
    }
    
}


// MARK: CCPhysicsCollisionDelegate


extension Gameplay: CCPhysicsCollisionDelegate {
    
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, circle: Circle, checkpoint: CCNode) -> ObjCBool {
        circle.state = .OffScreen
        circle.stopAllActions()
        triggerGameOver()
        return true
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, circle circle1: Circle, circle circle2: Circle) -> ObjCBool {
        return false
    }
    
    
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, circle: Circle, score: Rectangle) -> ObjCBool {
        circle.state = .OffScreen
        if circle.typ == score.type {
            if gameReallyOver == false{
                OALSimpleAudio.sharedInstance().playEffect("sound/Right.wav")
                points++
    
                if points % 15 == 0{
                    scaleFactor += 4
                    gamePhysicsNode.gravity = ccpSub(gamePhysicsNode.gravity, ccp(0,100))
                }
                //println(gamePhysicsNode.gravity)
                
                scoreLabel.string = String(points)
                circle.visible = false
                
                circle.removed = true
                
                for (index, arrayCircles) in enumerate(circles) {
                    if circle == arrayCircles {
                        circles.removeAtIndex(index)
                    }
                }
                
                gamePhysicsNode.space.addPostStepBlock({ () -> Void in
                    self.circleRemoved(circle)
                    }, key: circle)
            }
        } else {
            
            gameReallyOver = true
            triggerGameOver()
        }
        
        return true
    }
}

