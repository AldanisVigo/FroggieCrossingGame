import UIKit
import SpriteKit
import AVFoundation

class MainScene : SKScene, SKPhysicsContactDelegate{
    //Side Idle and Jump Frames
    let froggieSideIdleOne:SKTexture = SKTexture(imageNamed: "side-idle-1.png")
    let froggieSideIdleTwo:SKTexture = SKTexture(imageNamed: "side-idle-2.png")
    let froggieSideHop:SKTexture = SKTexture(imageNamed: "side-hop.png")
    var _froggieSideIdleAnimFrames:[SKTexture]?

    
    //Front Idle and Jump Frames
    let froggieFrontIdleOne:SKTexture = SKTexture(imageNamed: "front-idle-1.png")
    let froggieFrontIdleTwo:SKTexture = SKTexture(imageNamed: "front-idle-2.png")
    let froggieFrontHop:SKTexture = SKTexture(imageNamed: "front-hop.png")
    var _froggieFrontIdleAnimFrames:[SKTexture]?
    
    //Back Idle and Jump Frames
    let froggieBackIdleOne:SKTexture = SKTexture(imageNamed: "back-idle-1.png")
    let froggieBackIdleTwo:SKTexture = SKTexture(imageNamed: "back-idle-2.png")
    let froggieBackHop:SKTexture = SKTexture(imageNamed: "back-hop.png")
    var _froggieBackIdleAnimFrames:[SKTexture]?

    //Explosion Particle Generation
    var carExplosion:SKEmitterNode?
    var frogExplosion:SKEmitterNode?
    
    let frog:SKSpriteNode = SKSpriteNode(imageNamed: "side-idle-1.png")
    let car:SKSpriteNode = SKSpriteNode(imageNamed: "car.png")
    
    //Roads
    var roadOne:SKSpriteNode?
    var roadTwo:SKSpriteNode?
    var roadThree:SKSpriteNode?
    var roadFour:SKSpriteNode?
    var roadFive:SKSpriteNode?
    
    var roads:[SKSpriteNode]?
    
    var background_music:SKAudioNode = SKAudioNode(fileNamed: "themesong.mp3")
    
    //Contact Categories
    let CarCategory:UInt32 = 0x01 << 0
    let FrogCategory:UInt32 = 0x01 << 1
    func AddRoads(){
        roadOne = SKSpriteNode(imageNamed: "road.png")
        roadOne!.name = "roadone"
        roadTwo = SKSpriteNode(imageNamed: "road.png")
        roadTwo!.name = "roadtwo"
        roadThree = SKSpriteNode(imageNamed: "road.png")
        roadThree!.name = "roadthree"
        roadFour = SKSpriteNode(imageNamed: "road.png")
        roadFour!.name = "roadfour"
        roadFive = SKSpriteNode(imageNamed: "road.png")
        roadFive!.name = "roadfive"
        
        roads = [roadOne!,roadTwo!,roadThree!,roadFour!,roadFive!]
        let roadSize = CGSize(width: frame.width,height: 30)
        var currentYPos:CGFloat = 100
        let verticalSpacing:CGFloat = 0
        //let bottomOffset:CGFloat = 10
        for eachRoad in roads!{
            eachRoad.size = roadSize
            let curRoadPosition = CGPoint(x:frame.width / 2, y: currentYPos)
            eachRoad.position = curRoadPosition
            currentYPos += eachRoad.frame.height + verticalSpacing
            addChild(eachRoad)
        }
    }
    func addFrog(){
        let initFrogPosition = CGPoint(x: frame.width / 2, y: frame.height * 0.27)
        let initFrogSize = CGSize(width: 22, height: 22)
        frog.size = initFrogSize
        frog.position = initFrogPosition
        
        //Create physics body for frog
        let frogBody = SKPhysicsBody(rectangleOf: frog.size)
        frog.physicsBody = frogBody
        frog.physicsBody?.categoryBitMask = FrogCategory
        frog.physicsBody?.contactTestBitMask = CarCategory
        frog.physicsBody?.affectedByGravity = false
        frog.name = "frog"
        addChild(frog)
        let idleAnimation = SKAction.repeatForever(SKAction.animate(with: _froggieBackIdleAnimFrames!, timePerFrame: 0.3))
        frog.run(idleAnimation, withKey: "idle")
    }
    func addControls(){
        let upControlSprite = SKSpriteNode(imageNamed: "upkey.png")
        let leftControlSprite = SKSpriteNode(imageNamed: "leftkey.png")
        let rightControlSprite = SKSpriteNode(imageNamed: "rightkey.png")
        let downControlSprite = SKSpriteNode(imageNamed: "downkey.png")
        
        let initialSize = CGSize(width: 50, height: 50)
        let initialY = frame.height * 0.1
        leftControlSprite.position = CGPoint(x: frame.width * 0.1, y: initialY)
        downControlSprite.position = CGPoint(x: frame.width * 0.2, y: initialY)
        upControlSprite.position = CGPoint(x: frame.width * 0.2, y: initialY + upControlSprite.frame.height / 2 + 3)
        rightControlSprite.position = CGPoint(x: frame.width * 0.3, y: initialY)
        leftControlSprite.size = initialSize
        upControlSprite.size = initialSize
        downControlSprite.size = initialSize
        rightControlSprite.size = initialSize
        
        leftControlSprite.name = "leftbtn"
        upControlSprite.name = "upbtn"
        downControlSprite.name = "downbtn"
        rightControlSprite.name = "rightbtn"
        
        leftControlSprite.alpha = 0.3
        upControlSprite.alpha = 0.3
        downControlSprite.alpha = 0.3
        rightControlSprite.alpha = 0.3
        addChild(leftControlSprite)
        addChild(upControlSprite)
        addChild(downControlSprite)
        addChild(rightControlSprite)
    }
    var lastPosition:CGPoint?
    func addCar(position:CGPoint, direction:Character, travelSpeed:CGFloat){
        //print("Adding Car Direction:\(direction) Position:\(position)")
        let car = SKSpriteNode(imageNamed: "car.png")
        car.position = position
        let initialCarSize = CGSize(width: 60, height: 20)
        car.size = initialCarSize
        car.name = "car"
        let carBody = SKPhysicsBody(rectangleOf: car.size)
        car.physicsBody  = carBody
        car.physicsBody!.affectedByGravity = false
        car.physicsBody!.categoryBitMask = CarCategory
        car.physicsBody!.contactTestBitMask = FrogCategory
        //Temporary Movement
        let speed:CGFloat = travelSpeed
        if lastPosition != position{
            if(direction == "R"){
                let moveForever = SKAction.repeatForever(SKAction.moveBy(x: speed, y: 0, duration: 0.1))
                let faceRight = SKAction.scaleX(to: 1.0, duration: 0.1)
                car.run(SKAction.sequence([faceRight,moveForever]))
                addChild(car)
            }
            if(direction == "L"){
                let moveForever = SKAction.repeatForever(SKAction.moveBy(x: -speed, y: 0, duration: 0.1))
                let faceLeft = SKAction.scaleX(to: -1.0, duration: 0.1)
                car.run(SKAction.sequence([faceLeft,moveForever]))
                addChild(car)
            }
        }
        lastPosition = position
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Hop Sound 
        let hopSound = SKAction.playSoundFileNamed("froggie_hop_sound.mp3", waitForCompletion: false)

        //Sides idle anim
        let sideIdleAnim = SKAction.repeatForever(SKAction.animate(with: _froggieSideIdleAnimFrames!, timePerFrame: 0.1, resize: false, restore: true))
        //Up idle anim
        let upIdleAnim = SKAction.repeatForever(SKAction.animate(with: _froggieBackIdleAnimFrames!, timePerFrame: 0.2))
        //Down idle anim
        let downIdleAnim = SKAction.repeatForever(SKAction.animate(with: _froggieFrontIdleAnimFrames!, timePerFrame: 0.2))
        
        let moveAmt = roadOne!.frame.height
        //Action for right button
        let moveRight = SKAction.moveBy(x: moveAmt, y: 0.0, duration: 0.1)
        let faceRight = SKAction.scaleX(to: 1.0, duration: 0.1)
        let rightButtonSequence = SKAction.sequence([faceRight,moveRight,hopSound,sideIdleAnim])
        
        //Action for left button
        let moveLeft = SKAction.moveBy(x: -moveAmt, y: 0.0, duration: 0.1)
        let faceLeft = SKAction.scaleX(to: -1.0, duration: 0.1)
        let leftButtonSequence = SKAction.sequence([faceLeft,moveLeft,hopSound,sideIdleAnim])
        
        //Action for up button
        let moveUp = SKAction.moveBy(x: 0, y: moveAmt , duration: 0.2)
        let upButtonSequence = SKAction.sequence([moveUp,hopSound,upIdleAnim])
        
        //Action for down button 
        let moveDown = SKAction.moveBy(x: 0, y: -moveAmt, duration: 0.2)
        let downButtonSequence = SKAction.sequence([moveDown,hopSound,downIdleAnim])
        
        if let touchLocation = touches.first?.location(in: self){
            if childNode(withName: "leftbtn")!.contains(touchLocation){
                //Move Left
                print("Move Left")
                frog.run(SKAction.wait(forDuration: 0.1))
                frog.removeAllActions()
                frog.run(faceLeft)
                frog.texture = froggieSideHop
                frog.run(leftButtonSequence)
            }
            if childNode(withName: "downbtn")!.contains(touchLocation){
                //Move Down
                print("Move Down")
                frog.removeAllActions()
                frog.texture = froggieFrontHop
                frog.run(downButtonSequence)
            }
            if childNode(withName: "upbtn")!.contains(touchLocation){
                //Move Up
                print("Move Up")
                frog.removeAllActions()
                frog.texture = froggieBackHop
                frog.run(upButtonSequence)
            }
            if childNode(withName: "rightbtn")!.contains(touchLocation){
                //Move Right
                print("Move Right")
                frog.run(SKAction.wait(forDuration: 0.1))
                frog.removeAllActions()
                frog.texture = froggieSideHop
                frog.run(rightButtonSequence)
            }
        }
    }
    func AddBackground(){
        let bgImage = SKSpriteNode(imageNamed: "seamless-grass-texture.png")
        let bgImageSize = CGSize(width: frame.width, height: frame.height)
        bgImage.size = bgImageSize
        bgImage.alpha = 0.4
        bgImage.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        bgImage.zPosition = -2
        addChild(bgImage);
    }
    override func didMove(to view: SKView) {
        addChild(background_music)
        
        //Setup animation frames
        _froggieSideIdleAnimFrames = [froggieSideIdleOne,froggieSideIdleTwo]
        _froggieFrontIdleAnimFrames = [froggieFrontIdleOne,froggieFrontIdleTwo]
        _froggieBackIdleAnimFrames = [froggieBackIdleOne,froggieBackIdleTwo]
        //backgroundColor = UIColor.init(colorLiteralRed: 0.7, green: 1.0, blue: 0.0, alpha: 1.0)
        //AddBackground()
        backgroundColor = UIColor.black
        AddRoads()
        addFrog()
        addControls()
        generateTraffic()
        for eachRoad in roads!{
            eachRoad.zPosition = -1.0
        }
        car.zPosition = 1.0
        physicsWorld.contactDelegate = self
        //Explosion Particle
        carExplosion = SKEmitterNode(fileNamed: "Explosion.sks")
        frogExplosion = SKEmitterNode(fileNamed: "Explosion.sks")
        
        //Add river background
        //let riverbackground = SKSpriteNode(imageNamed: "river.png")
    }
    var dead:Bool = false
    func didBegin(_ contact: SKPhysicsContact) {
        //Contact
        print("contact")
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == (CarCategory | FrogCategory){
            if(dead != true){
                dead = true
                frogExplosion!.position = contact.bodyB.node!.position
                carExplosion!.position = contact.bodyA.node!.position
                addChild(carExplosion!)
                addChild(frogExplosion!)
                let explosionSound = SKAction.playSoundFileNamed("Explosion.mp3", waitForCompletion: false)
                self.run(explosionSound)
                contact.bodyA.node?.removeFromParent()
                contact.bodyB.node?.removeFromParent()
                print("collision")
                let transition = SKTransition.reveal(with: SKTransitionDirection.left, duration: 7.0)
                let nextScene = GameOverScene(size: self.size)
                transition.pausesOutgoingScene = false
                //Kill background music
                background_music.run(SKAction.stop())
                self.view!.presentScene(nextScene, transition: transition)
            }
        }
    }
    func didEnd(_ contact: SKPhysicsContact) {
        //End Contact
    }
    //level set velocity
    let lvlVelocity:CGFloat = 15.0
    var lastLane:UInt32 = 0
    func pickRandomLane()-> (()->(),String){
        //Locations
        //Lane One
        //var laneOneLeft = CGPoint(x: -car.frame.width - 10, y: roadOne!.position.y)
        let laneOneRight = CGPoint(x: frame.width, y: roadOne!.position.y)
        
        //Lane Two
        let laneTwoLeft = CGPoint(x:0, y:roadTwo!.position.y)
        //var laneTwoRight = CGPoint(x: frame.width + car.frame.width + 10, y: roadTwo!.position.y)
        
        //Lane Three
        //var laneThreeLeft = CGPoint(x: -car.frame.width - 10, y: roadThree!.position.y)
        let laneThreeRight = CGPoint(x: frame.width + 10, y: roadThree!.position.y)
        
        //Lane Four
        let laneFourLeft = CGPoint(x:0, y:roadFour!.position.y)
        //var laneFourRight = CGPoint(x: frame.width + car.frame.width + 10, y: roadFour!.position.y)
        
        //Lane Five
        //var laneFiveLeft = CGPoint(x: -car.frame.width - 10, y:roadFive!.position.y)
        let laneFiveRight = CGPoint(x: frame.width, y: roadFive!.position.y)
        
        let whichLane = arc4random_uniform(5) + 1
        if (whichLane != lastLane){
            lastLane = whichLane
            switch whichLane{
            case 1:
                return ({self.addCar(position: laneOneRight, direction: "L", travelSpeed: self.lvlVelocity)},"laneOneRight")
            case 2:
                return ({self.addCar(position: laneTwoLeft, direction: "R", travelSpeed: self.lvlVelocity)},"laneTwoLeft")
            case 3:
                return ({self.addCar(position: laneThreeRight, direction: "L", travelSpeed: self.lvlVelocity)},"laneThreeRight")
            case 4:
                return ({self.addCar(position: laneFourLeft, direction: "R", travelSpeed: self.lvlVelocity)},"laneFourLeft")
            case 5:
                return ({self.addCar(position: laneFiveRight, direction: "L", travelSpeed: self.lvlVelocity)},"laneFiveRight")
            default:
                print("Error while picking which of the five lanes to trigger by itself.")
                break
            }
        }
        return({},"")
    }
    func generateTraffic(){
        let numOfLanesToTrigger = arc4random_uniform(5) + 1
        var alreadyGenerated:[String] = [""]
        for _ in 0...numOfLanesToTrigger{
            let (codeToRun,dropLocation) = pickRandomLane()
            //If the car has not been added this lane
            if(alreadyGenerated.contains(dropLocation) == false){
                codeToRun()//Execute the clousure to add the car
                alreadyGenerated.append(dropLocation)
            }
        }
        //Clear it
        alreadyGenerated.removeAll()
    }
    var frameCount:Int = 0
    var numberOfSecondsElapsed:Int = 0
    var secondsToNextFireCalculation = 0
    var whenToUpdate = 60
    override func update(_ currentTime: TimeInterval) {
        let min_time_to_fire = 1
        let max_time_to_fire = 2
        //Update every frame
        frameCount += 1
        if frameCount == whenToUpdate{
            numberOfSecondsElapsed += 1
            frameCount = 0
            secondsToNextFireCalculation -= 1
        }
        if numberOfSecondsElapsed == 0{
            secondsToNextFireCalculation = Int(arc4random_uniform(UInt32(max_time_to_fire)))
            secondsToNextFireCalculation += min_time_to_fire
        }
        //print(secondsToNextFireCalculation)
        if secondsToNextFireCalculation == 0{
            //Calculate and fire lanes again
            //print("Generating Nrw Traffic")
            generateTraffic()
            //Reset
            numberOfSecondsElapsed = 0
        }
    }
}
