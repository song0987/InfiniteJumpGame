import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var paddle: SKSpriteNode!
    private var ball: SKSpriteNode!
    private var bricks = [SKSpriteNode]()
    private var scoreLabel: SKLabelNode!
    private var score = 0
    private var isGameRunning = true
    
    private var hitBrickSound: SKAction {
        SKAction.playSoundFileNamed("brick.caf", waitForCompletion: false)
    }
    private var hitPaddleSound: SKAction {
        SKAction.playSoundFileNamed("paddle.caf", waitForCompletion: false)
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        setupGame()
    }
    
    func setupGame() {
        isGameRunning = true
        score = 0
        
        bricks.forEach { $0.removeFromParent() }
        bricks.removeAll()
        
        paddle = SKSpriteNode(color: .white, size: CGSize(width: 100, height: 16))
        paddle.position = CGPoint(x: size.width/2, y: 60)
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.size)
        paddle.physicsBody?.isDynamic = false
        paddle.physicsBody?.restitution = 1.0
        paddle.physicsBody?.friction = 0
        paddle.physicsBody?.categoryBitMask = 1
        paddle.physicsBody?.contactTestBitMask = 2
        addChild(paddle)
        
        ball = SKSpriteNode(color: .red, size: CGSize(width:16, height:16))
        ball.position = CGPoint(x: size.width/2, y: 120)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 8)
        ball.physicsBody?.restitution = 1.0
        ball.physicsBody?.friction = 0
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.angularDamping = 0
        ball.physicsBody?.categoryBitMask = 2
        ball.physicsBody?.contactTestBitMask = 1 | 3
        ball.physicsBody?.velocity = CGVector(dx: 160, dy: 160)
        addChild(ball)
        
        createBricks()
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: 60, y: size.height - 30)
        scoreLabel.fontColor = .white
        scoreLabel.fontSize = 18
        addChild(scoreLabel)
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: size.height))
        path.addLine(to: CGPoint(x: size.width, y: size.height))
        path.addLine(to: CGPoint(x: size.width, y: 0))
        let borderBody = SKPhysicsBody(edgeChainFrom: path)
        borderBody.friction = 0
        self.physicsBody = borderBody
    }
    
    func createBricks() {
        let brickW: CGFloat = 70
        let brickH: CGFloat = 24
        let startY = size.height - 80
        
        for row in 0..<4 {
            for col in 0..<6 {
                let brick = SKSpriteNode(color: .systemGreen, size: CGSize(width: brickW, height: brickH))
                let x = brickW * CGFloat(col) + 40
                let y = startY - CGFloat(row) * (brickH + 8)
                brick.position = CGPoint(x:x, y:y)
                brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size)
                brick.physicsBody?.isDynamic = false
                brick.physicsBody?.restitution = 1.0
                brick.physicsBody?.categoryBitMask = 3
                addChild(brick)
                bricks.append(brick)
            }
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard isGameRunning else { return }
        let location = event.location(in: self)
        var newX = location.x
        if newX < paddle.size.width/2 {
            newX = paddle.size.width/2
        }
        if newX > size.width - paddle.size.width/2 {
            newX = size.width - paddle.size.width/2
        }
        paddle.position.x = newX
    }
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 49, !isGameRunning {
            ball.removeFromParent()
            paddle.removeFromParent()
            scoreLabel.removeFromParent()
            setupGame()
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard isGameRunning else { return }
        let a = contact.bodyA
        let b = contact.bodyB
        
        if a.categoryBitMask == 3 || b.categoryBitMask == 3 {
            run(hitBrickSound)
            var brickBody: SKPhysicsBody?
            if a.categoryBitMask == 3 { brickBody = a }
            else { brickBody = b }
            
            if let brick = brickBody?.node as? SKSpriteNode {
                brick.removeFromParent()
                bricks.removeAll{$0 == brick}
                score += 10
                scoreLabel.text = "Score: \(score)"
                
                if bricks.isEmpty {
                    scoreLabel.text = "YOU WIN! Press Space"
                    ball.physicsBody?.velocity = .zero
                    isGameRunning = false
                }
            }
        }
        
        if (a.categoryBitMask == 1 && b.categoryBitMask == 2) || (a.categoryBitMask == 2 && b.categoryBitMask == 1) {
            run(hitPaddleSound)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard isGameRunning else { return }
        if ball.position.y < -30 {
            scoreLabel.text = "GAME OVER! Press Space"
            ball.physicsBody?.velocity = .zero
            isGameRunning = false
        }
    }
}
