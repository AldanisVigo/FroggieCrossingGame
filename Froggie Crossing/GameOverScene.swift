//
//  GameOverScene.swift
//  Froggie Crossing
//
//  Created by Aldanis Vigo on 12/24/16.
//  Copyright © 2016 Aldanis Vigo. All rights reserved.
//

import SpriteKit
import UIKit

class GameOverScene: SKScene{
    let ReplayButton:SKSpriteNode = SKSpriteNode(imageNamed: "start-over-btn.png")
    let QuitButton:SKSpriteNode = SKSpriteNode(imageNamed: "quit-btn.png")
    var background_music:SKAudioNode = SKAudioNode(fileNamed: "game_over.mp3")
    
    func addMenuButtons(){
        ReplayButton.position = CGPoint(x: frame.width / 2 - ReplayButton.size.width / 4, y: frame.height / 2)
        QuitButton.position = CGPoint(x:  frame.width / 2 + QuitButton.size.width / 4, y: frame.height / 2)
        ReplayButton.size = CGSize(width: frame.width / 2 - 150, height: ReplayButton.size.height / 2)
        QuitButton.size = ReplayButton.size
        ReplayButton.name = "replay"
        QuitButton.name = "quit"
        addChild(ReplayButton)
        addChild(QuitButton)
    }
    override func didMove(to view: SKView) {
        addChild(background_music)
        //View Loaded
        addMenuButtons()
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            let touchLocation = touch.location(in: self)
            if(childNode(withName: "replay")!.contains(touchLocation)){
                //Replay the game
                let transition = SKTransition.reveal(with: SKTransitionDirection.left, duration: 2.0)
                let nextScene = MainScene(size: self.size)
                transition.pausesOutgoingScene = true
                transition.pausesIncomingScene = true
                background_music.run(SKAction.stop())
                view!.presentScene(nextScene, transition: transition)
            }
            if(childNode(withName: "quit")!.contains(touchLocation)){
                //Exit the game
                exit(0)
            }
        }
        
    }
}
