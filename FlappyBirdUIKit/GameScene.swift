//
//  GameScene.swift
//  FlappyBirdUIKit
//  FlappyBirdUIKit
//
//  Created by vko on 05/09/22.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scrollNode: SKNode!
    var meteorNode: SKNode!
    var rocket: SKSpriteNode!
    
    let rocketCategory: UInt32 = 1 << 0
    let groundCategory: UInt32 = 1 << 1
    let meteorCategory: UInt32 = 1 << 2
    let scoreCategory: UInt32 = 1 << 3
    
    var score = 0
    var scoreLabelNode: SKLabelNode!
    var bestScoreLabelNode: SKLabelNode!
    let userDefaults: UserDefaults = UserDefaults.standard
    
    override func didMove(to view: SKView) {
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        physicsWorld.contactDelegate = self
        
        scrollNode = SKNode()
        addChild(scrollNode)
        
        meteorNode = SKNode()
        scrollNode.addChild(meteorNode)

        setupGround()
        setupBackground()
        setupMeteor()
        setupRocket()
        
        setupScoreLabel()
    }
    
    func setupGround() {
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = .nearest

        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 2
        
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5)
        
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
        
        // Repete a textura do chão para sempre
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))
        
        for i in 0..<needNumber {
            let sprite = SKSpriteNode(texture: groundTexture)
            
            sprite.position = CGPoint(
                x: groundTexture.size().width / 2 + groundTexture.size().width * CGFloat(i),
                y: groundTexture.size().height / 2
            )
            
            sprite.run(repeatScrollGround)

            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
            
                sprite.physicsBody?.categoryBitMask = groundCategory

            sprite.physicsBody?.isDynamic = false
            
            scrollNode.addChild(sprite)
        }
    }
    
    func setupBackground() {

        let backgroundTexture = SKTexture(imageNamed: "background")
        backgroundTexture.filteringMode = .nearest
        
        let needBackgroundNumber = Int(self.frame.size.width / backgroundTexture.size().width) + 2

        let moveBackground = SKAction.moveBy(x: -backgroundTexture.size().width, y: 0, duration: 15)

        let resetBackground = SKAction.moveBy(x: backgroundTexture.size().width, y: 0, duration: 0)

        let repeatScrollBackground = SKAction.repeatForever(SKAction.sequence([moveBackground, resetBackground]))

        for i in 0..<needBackgroundNumber {
            let sprite = SKSpriteNode(texture: backgroundTexture)
            sprite.zPosition = -100

            sprite.position = CGPoint(
                x: backgroundTexture.size().width / 2 + backgroundTexture.size().width * CGFloat(i),
                y: self.size.height - backgroundTexture.size().height / 2
            )

            sprite.run(repeatScrollBackground)

            scrollNode.addChild(sprite)
        }
    }
    
    func setupMeteor() {
        let meteorTexture = SKTexture(imageNamed: "meteor")
        meteorTexture.filteringMode = .nearest
        
        let movingDistance = CGFloat(self.frame.size.width + meteorTexture.size().width)
        
        let moveMeteor = SKAction.moveBy(x: -movingDistance, y: 0, duration: 4)
    
        let removeMeteor = SKAction.removeFromParent()
        
        let meteorAnimation = SKAction.sequence([moveMeteor, removeMeteor])
        
        let rocketSize = SKTexture(imageNamed: "foguetin").size()
        
        let slit_length = rocketSize.height * 5
        
        let random_y_range = rocketSize.height * 12

        let groundSize = SKTexture(imageNamed: "ground").size()
        let center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
        let under_meteor_lowest_y = center_y - slit_length / 2 - meteorTexture.size().height / 2 - random_y_range / 2
        
        let createMeteorAnimation = SKAction.run ({

            let meteor = SKNode()
            meteor.position = CGPoint(x: self.frame.size.width + meteorTexture.size().width / 2, y: 0)
            meteor.zPosition = -50
            
            let random_y = CGFloat.random(in: 0..<random_y_range)

            let under_meteor_y = under_meteor_lowest_y + random_y
            
            let under = SKSpriteNode(texture: meteorTexture)
            under.position = CGPoint(x: 0, y: under_meteor_y)
            
            under.physicsBody = SKPhysicsBody(rectangleOf: meteorTexture.size())
            under.physicsBody?.categoryBitMask = self.meteorCategory
            
            under.physicsBody?.isDynamic = false
            
            meteor.addChild(under)
            
            let upper = SKSpriteNode(texture: meteorTexture)
            upper.position = CGPoint(x: 0, y: under_meteor_y + meteorTexture.size().height + slit_length)
            
            upper.physicsBody = SKPhysicsBody(rectangleOf: meteorTexture.size())
            upper.physicsBody?.categoryBitMask = self.meteorCategory
        
            upper.physicsBody?.isDynamic = false
            
            meteor.addChild(upper)
            
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + rocketSize.width / 2, y: self.frame.height / 2)
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.isDynamic = false
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.contactTestBitMask = self.rocketCategory
            
            meteor.addChild(scoreNode)
            
            meteor.run(meteorAnimation)
            
            self.meteorNode.addChild(meteor)
        })
        
        let waitAnimation = SKAction.wait(forDuration: 2)
        
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createMeteorAnimation, waitAnimation]))
        
        meteorNode.run(repeatForeverAnimation)
    }
    
    func setupRocket() {
        
        let rocketTextureA = SKTexture(imageNamed: "foguetin")
        rocketTextureA.filteringMode = .linear
        let rocketTextureB = SKTexture(imageNamed: "foguetin")
        rocketTextureB.filteringMode = .linear

        let textureAnimation = SKAction.animate(with: [rocketTextureA, rocketTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(textureAnimation)
        
        rocket = SKSpriteNode(texture: rocketTextureA)
        rocket.position = CGPoint(x: self.frame.size.width * 0.2 , y: self.frame.size.height * 0.7)
        
        rocket.physicsBody = SKPhysicsBody(circleOfRadius: rocket.size.height / 2)
        
        rocket.physicsBody?.allowsRotation = false
        
        rocket.physicsBody?.categoryBitMask = rocketCategory
        rocket.physicsBody?.collisionBitMask = groundCategory | meteorCategory
        rocket.physicsBody?.contactTestBitMask = groundCategory | meteorCategory
        
        rocket.run(flap)
        
        addChild(rocket)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if scrollNode.speed > 0 {

            rocket.physicsBody?.velocity = CGVector.zero
            
        rocket.physicsBody?.applyImpulse((CGVector(dx: 0, dy: 10)))
        } else if rocket.speed == 0 {
            restart()
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {

        if scrollNode.speed <= 0 {
            return
        }
        
        //checa se passou do obstaculo
        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            
            //adiciona pontuação
            print("ScoreUp")
            score += 1
            scoreLabelNode.text = "Score:\(score)"

            // checa se a pontuacão atual é maior que o recorde, e salva
            var bestScore = userDefaults.integer(forKey: "BEST")
            if score > bestScore {
                bestScore = score
                bestScoreLabelNode.text = "Best Score:\(bestScore)"
                userDefaults.set(bestScore, forKey: "BEST")
                userDefaults.synchronize()
            }
            //situação se o jogador bateu
        } else {
            print("GameOver")
            
            scrollNode.speed = 0
            
            rocket.physicsBody?.collisionBitMask = groundCategory
            
            let roll = SKAction.rotate(byAngle: 0, duration: 1)
            rocket.run(roll, completion:{
                self.rocket.speed = 0
            })
        }
    }
    
    //Aqui é a função de recomeçar, onde será colocado a segue para tela pós jogos (tentar dnv, voltar pra nave)
    func restart() {
        // Zera a pontuação
        score = 0
        scoreLabelNode.text = "Score:\(score)"
        
        // Reposiciona o foguete
        rocket.position = CGPoint(x: self.frame.size.width * 0.2, y: self.frame.size.height * 0.7)
        rocket.physicsBody?.velocity = CGVector.zero
        rocket.physicsBody?.collisionBitMask = groundCategory | meteorCategory
        rocket.zPosition = 0
        
        meteorNode.removeAllChildren()
        
        rocket.speed = 1
        scrollNode.speed = 1
    }
    
    func setupScoreLabel() {
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.white
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        scoreLabelNode.zPosition = 100
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)
        
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.white
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        bestScoreLabelNode.zPosition = 100
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        let bestScore = userDefaults.integer(forKey: "BEST")
        bestScoreLabelNode.text = "BEST Score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
    }
}
