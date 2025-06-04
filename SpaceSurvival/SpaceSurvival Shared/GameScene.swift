//
//  GameScene.swift
//  SpaceSurvival iOS
//

import SpriteKit

final class GameScene: SKScene {
    
    // MARK: - Nós principais
    private var player: SKSpriteNode!
    private var enemies: [SKSpriteNode] = []
    private var bullets: [SKSpriteNode] = []
    private var pickups: [SKSpriteNode] = []
    
    // MARK: - HUD
    private var heartNodes: [SKSpriteNode] = []
    private var timeLabel: SKLabelNode!
    private var scoreLabel: SKLabelNode!
    private var gameOverLabel: SKLabelNode?
    
    // MARK: - Estado do jogo
    private var lives = 3 {
        didSet {
            lives = min(max(lives, 0), 3)
            updateHearts()
        }
    }
    private var score = 0 {
        didSet {
            scoreLabel.text = " \(score)"
        }
    }
    private var startTime: TimeInterval = 0
    
    // MARK: - Constantes
    private let playerSpeed: CGFloat           = 400
    private let bulletSpeed: CGFloat           = 300
    private let bulletInterval: TimeInterval   = 0.5
    
    private let baseEnemySpeed: CGFloat        = 150
    private var spawnInterval: TimeInterval    = 1.0
    private let spawnDecrease: TimeInterval    = 0.02
    private let spawnMin: TimeInterval         = 0.35
    
    // Controlo de tempo
    private var lastSpawn:       TimeInterval = 0
    private var lastUpdate:      TimeInterval = 0
    private var lastSecondCount: TimeInterval = 0
    private var lastBulletSpawn: TimeInterval = 0
    
    // MARK: - Setup
    override func didMove(to view: SKView) {
        setupScene()
        startGame()
    }
    
    private func setupScene() {
        anchorPoint = CGPoint(x: 0.5, y: 0.5) // (0,0) no centro
        
        // Fundo
        let bg = SKSpriteNode(imageNamed: "background")
        bg.zPosition = -1
        bg.position  = .zero
        bg.size      = size
        addChild(bg)
        
        // Jogador
        let texPlayer = SKTexture(imageNamed: "spaceship_green")
        player = SKSpriteNode(texture: texPlayer)
        rescale(node: player, desiredWidthRatio: 0.12)
        player.position = CGPoint(x: 0, y: -size.height * 0.4)
        addChild(player)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = false
        player.physicsBody?.categoryBitMask = 1
        player.physicsBody?.collisionBitMask = 0
        
        physicsWorld.contactDelegate = self
        
        // Câmera + HUD
        let cam = SKCameraNode()
        camera = cam
        addChild(cam)
        
        let hudYOffset: CGFloat = 80
        
        // Hearts (vidas) à esquerda
        for i in 0..<3 {
            let heart = SKSpriteNode(imageNamed: "heart")
            rescale(node: heart, desiredWidthRatio: 0.06)
            let xPos = -size.width/2 + 20 + CGFloat(i) * (heart.size.width + 10)
            heart.position = CGPoint(x: xPos, y: size.height/2 - hudYOffset)
            heart.zPosition = 5
            cam.addChild(heart)
            heartNodes.append(heart)
        }
        
        // Time (cronômetro) ao centro
        timeLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        timeLabel.fontSize  = 22
        timeLabel.fontColor = .white
        timeLabel.text      = " 0 s"
        timeLabel.position  = CGPoint(x: 0, y: size.height/2 - hudYOffset)
        timeLabel.zPosition = 5
        cam.addChild(timeLabel)
        
        // Score à direita
        scoreLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        scoreLabel.fontSize  = 22
        scoreLabel.fontColor = .white
        scoreLabel.text      = " 0"
        scoreLabel.position  = CGPoint(x: size.width/2 - 100, y: size.height/2 - hudYOffset)
        scoreLabel.zPosition = 5
        cam.addChild(scoreLabel)
    }
    
    private func startGame() {
        // Reinicia estado
        lives           = 3
        score           = 0
        spawnInterval   = 1.0
        startTime       = CACurrentMediaTime()
        lastUpdate      = startTime
        lastSpawn       = startTime
        lastSecondCount = startTime
        lastBulletSpawn = startTime
        
        // Remove gameOverLabel, se existir
        gameOverLabel?.removeFromParent()
        gameOverLabel = nil
        
        // Remove todos os inimigos, balas e pickups
        for e in enemies { e.removeFromParent() }
        for b in bullets { b.removeFromParent() }
        for p in pickups { p.removeFromParent() }
        enemies.removeAll()
        bullets.removeAll()
        pickups.removeAll()
        
        // Atualiza HUD
        updateHearts()
        timeLabel.text = " 0 s"
        scoreLabel.text = " 0"
        
        isPaused = false
    }
    
    // MARK: - Spawning
    private func spawnEnemyOrPickup() {
        let rand = CGFloat.random(in: 0...1)
        if lives == 2 && rand < 0.20 {
            spawnPickup()
            return
        }
        if lives == 1 && rand < 0.40 {
            spawnPickup()
            return
        }
        spawnEnemy()
    }
    
    private func spawnEnemy() {
        let r = CGFloat.random(in: 0...1)
        let spriteName: String
        let hp: Int
        let speed: CGFloat
        
        if r < 0.15 {
            spriteName = "spaceship_3"   // precisa de 3 tiros, mais lento
            hp = 3
            speed = baseEnemySpeed * 0.5
        } else if r < 0.40 {
            spriteName = "spaceship_2"   // precisa de 2 tiros, velocidade média
            hp = 2
            speed = baseEnemySpeed * 0.75
        } else {
            spriteName = "spaceship_1"   // precisa de 1 tiro, velocidade normal
            hp = 1
            speed = baseEnemySpeed
        }
        
        let texEnemy = SKTexture(imageNamed: spriteName)
        let enemy    = SKSpriteNode(texture: texEnemy)
        rescale(node: enemy, desiredWidthRatio: 0.10)
        
        let halfW = size.width / 2
        let xPos  = CGFloat.random(in: -halfW ... halfW)
        enemy.position = CGPoint(x: xPos, y: size.height/2 + enemy.size.height)
        enemy.zRotation = .pi
        
        enemy.userData = ["hp": hp, "speed": speed]
        
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.isDynamic = true
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.categoryBitMask = 2
        enemy.physicsBody?.contactTestBitMask = 1 | 4
        enemy.physicsBody?.collisionBitMask = 0 // não empurra outros
        
        addChild(enemy)
        enemies.append(enemy)
    }
    
    private func spawnPickup() {
        let pickup = SKSpriteNode(imageNamed: "heart")
        rescale(node: pickup, desiredWidthRatio: 0.06)
        
        let halfW = size.width / 2
        let xPos  = CGFloat.random(in: -halfW ... halfW)
        pickup.position = CGPoint(x: xPos, y: size.height/2 + pickup.size.height)
        // NÃO gira: zRotation removido
        
        pickup.physicsBody = SKPhysicsBody(rectangleOf: pickup.size)
        pickup.physicsBody?.isDynamic = true
        pickup.physicsBody?.affectedByGravity = false
        pickup.physicsBody?.categoryBitMask = 8
        pickup.physicsBody?.contactTestBitMask = 1
        pickup.physicsBody?.collisionBitMask = 0
        
        addChild(pickup)
        pickups.append(pickup)
    }
    
    private func spawnBullet() {
        let texBullet = SKTexture(imageNamed: "bullet")
        let bullet    = SKSpriteNode(texture: texBullet)
        rescale(node: bullet, desiredWidthRatio: 0.03)
        
        bullet.position = CGPoint(
            x: player.position.x,
            y: player.position.y + player.size.height/2 + bullet.size.height/2
        )
        bullet.zRotation = 0
        
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.categoryBitMask = 4
        bullet.physicsBody?.contactTestBitMask = 2
        bullet.physicsBody?.collisionBitMask = 0
        
        addChild(bullet)
        bullets.append(bullet)
    }
    
    // MARK: - Update loop
    override func update(_ currentTime: TimeInterval) {
        if isPaused { return }
        let dt = currentTime - lastUpdate
        lastUpdate = currentTime
        
        // 1) Cronômetro e ponto por segundo
        let elapsed = currentTime - startTime
        if currentTime - lastSecondCount >= 1.0 {
            lastSecondCount += 1.0
            score += 1
        }
        timeLabel.text = " \(Int(elapsed)) s"
        
        // 2) Spawn de inimigos/pickups
        if currentTime - lastSpawn > spawnInterval {
            spawnEnemyOrPickup()
            lastSpawn      = currentTime
            spawnInterval  = max(spawnMin, spawnInterval - spawnDecrease)
        }
        
        // 3) Spawn de balas automáticas
        if currentTime - lastBulletSpawn > bulletInterval {
            spawnBullet()
            lastBulletSpawn = currentTime
        }
        
        // 4) Move inimigos para baixo
        for enemy in enemies {
            if let speed = enemy.userData?["speed"] as? CGFloat {
                enemy.position.y -= speed * CGFloat(dt)
            }
        }
        
        // 5) Move balas para cima
        for bullet in bullets {
            bullet.position.y += bulletSpeed * CGFloat(dt)
        }
        
        // 6) Move pickups para baixo
        for pickup in pickups {
            pickup.position.y -= baseEnemySpeed * CGFloat(dt)
        }
        
        // 7) Limpa inimigos fora do ecrã (+5 pontos)
        enemies.removeAll { e in
            if e.position.y < -size.height/2 - e.size.height {
                e.removeFromParent()
                score += 5
                return true
            }
            return false
        }
        
        // 8) Limpa balas fora do ecrã
        bullets.removeAll { b in
            if b.position.y > size.height/2 + b.size.height {
                b.removeFromParent()
                return true
            }
            return false
        }
        
        // 9) Limpa pickups fora do ecrã
        pickups.removeAll { p in
            if p.position.y < -size.height/2 - p.size.height {
                p.removeFromParent()
                return true
            }
            return false
        }
    }
    
    // MARK: - Controlo tátil (movimento lateral)
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else { return }
        let loc      = t.location(in: self)
        let targetX  = loc.x.clamped(to: -size.width/2 ... size.width/2)
        let dist     = abs(targetX - player.position.x)
        let duration = TimeInterval(dist / playerSpeed)
        
        player.removeAllActions()
        player.run(SKAction.moveTo(x: targetX, duration: duration))
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isPaused, gameOverLabel != nil {
            // Se estiver em Game Over, reinicia ao tocar
            startGame()
        } else {
            touchesMoved(touches, with: event)
        }
    }
    
    // MARK: - Utilitário de escala
    private func rescale(node: SKSpriteNode, desiredWidthRatio r: CGFloat) {
        let desired = size.width * r
        let scale   = desired / node.size.width
        node.setScale(scale)
    }
}

// MARK: - Colisão
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let aMask = contact.bodyA.categoryBitMask
        let bMask = contact.bodyB.categoryBitMask
        let combined = aMask | bMask
        
        // 1 = player, 2 = enemy, 4 = bullet, 8 = pickup
        if combined == 3 {
            // Player (1) × Enemy (2)
            if let enemyNode = (aMask == 2 ? contact.bodyA.node : contact.bodyB.node) as? SKSpriteNode {
                handleEnemyHit(enemyNode)
            }
        }
        else if combined == 6 {
            // Bullet (4) × Enemy (2)
            if
                let enemyNode  = (aMask == 2 ? contact.bodyA.node : contact.bodyB.node) as? SKSpriteNode,
                let bulletNode = (aMask == 4 ? contact.bodyA.node : contact.bodyB.node) as? SKSpriteNode
            {
                handleBulletHit(enemyNode, bulletNode)
            }
        }
        else if combined == 9 {
            // Player (1) × Pickup (8)
            if let pickupNode = (aMask == 8 ? contact.bodyA.node : contact.bodyB.node) as? SKSpriteNode {
                handlePickup(pickupNode)
            }
        }
    }
    
    private func handleEnemyHit(_ enemy: SKSpriteNode) {
        if var hp = enemy.userData?["hp"] as? Int {
            hp -= 1
            if hp > 0 {
                enemy.userData?["hp"] = hp
            } else {
                enemy.removeFromParent()
                if let idx = enemies.firstIndex(of: enemy) {
                    enemies.remove(at: idx)
                }
                score += 5
            }
        }
        lives -= 1
        if lives <= 0 {
            showGameOver()
        }
    }
    
    private func handleBulletHit(_ enemy: SKSpriteNode, _ bullet: SKSpriteNode) {
        bullet.removeFromParent()
        if let bIdx = bullets.firstIndex(of: bullet) {
            bullets.remove(at: bIdx)
        }
        
        if var hp = enemy.userData?["hp"] as? Int {
            hp -= 1
            if hp > 0 {
                enemy.userData?["hp"] = hp
            } else {
                enemy.removeFromParent()
                if let eIdx = enemies.firstIndex(of: enemy) {
                    enemies.remove(at: eIdx)
                }
                score += 5
            }
        }
    }
    
    private func handlePickup(_ pickup: SKSpriteNode) {
        pickup.removeFromParent()
        if let idx = pickups.firstIndex(of: pickup) {
            pickups.remove(at: idx)
        }
        lives += 1
    }
    
    private func showGameOver() {
        isPaused = true
        let lbl = SKLabelNode(text: "GAME OVER")
        lbl.fontName = "Arial-BoldMT"
        lbl.fontSize = 48
        lbl.fontColor = .red
        lbl.zPosition = 10
        lbl.position = .zero
        camera?.addChild(lbl)
        gameOverLabel = lbl
    }
}

// MARK: - Extensão para limitar valores
private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

// MARK: - Atualização de corações (vidas)
private extension GameScene {
    func updateHearts() {
        // Remove corações antigos
        for heart in heartNodes {
            heart.removeFromParent()
        }
        heartNodes.removeAll()
        
        // Desenha novo conjunto conforme lives
        for i in 0..<lives {
            let heart = SKSpriteNode(imageNamed: "heart")
            rescale(node: heart, desiredWidthRatio: 0.06)
            let xPos = -size.width/2 + 20 + CGFloat(i) * (heart.size.width + 10)
            heart.position = CGPoint(x: xPos, y: size.height/2 - 80)
            heart.zPosition = 5
            camera?.addChild(heart)
            heartNodes.append(heart)
        }
    }
}
