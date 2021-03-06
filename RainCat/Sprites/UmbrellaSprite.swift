//
//  UmbrellaSprite.swift
//  RainCat
//
//  Created by Marc Vandehey on 8/30/16.
//  Copyright © 2016 Thirteen23. All rights reserved.
//

import Foundation
import SpriteKit

public class UmbrellaSprite : SKSpriteNode, Palettable {
  private var umbrellaTop : SKSpriteNode!
  private var umbrellaBottom : SKSpriteNode!

  private var destination : CGPoint!
  private var easing : CGFloat = 0.1
  public var minimumHeight : CGFloat = 0

  private var isPingPong = false

  public static func newInstance(palette : ColorPalette, pingPong : Bool = false) -> UmbrellaSprite {
    let umbrella = UmbrellaSprite()

    umbrella.isPingPong = pingPong

    let top = SKSpriteNode(imageNamed: "umbrellaTop")
    let bottom = SKSpriteNode(imageNamed: "umbrellaBottom")

    if pingPong {
      top.physicsBody = SKPhysicsBody(texture: top.texture!, size: top.size)
    } else {
      let path = UIBezierPath()
      path.move(to: CGPoint(x: -top.size.width / 2, y: -top.size.height / 2))
      path.addLine(to: CGPoint(x: 0, y: top.size.height / 2))
      path.addLine(to: CGPoint(x: top.size.width / 2, y: -top.size.height / 2))
      path.addLine(to: CGPoint(x: top.size.width / 2 - 10, y: -top.size.height / 2))
      path.addLine(to: CGPoint(x: 0, y: top.size.height / 2 - 10))
      path.addLine(to: CGPoint(x: -top.size.width / 2 + 10, y: -top.size.height / 2))
      path.close()

      top.physicsBody = SKPhysicsBody(edgeLoopFrom: path.cgPath)
    }
    top.physicsBody?.isDynamic = false
    top.physicsBody?.categoryBitMask = UmbrellaCategory
    top.physicsBody?.contactTestBitMask = RainDropCategory
    top.physicsBody?.restitution = 0.9

    top.zPosition = 4
    bottom.zPosition = 2

    top.colorBlendFactor = 1
    bottom.colorBlendFactor = 1

    top.color = palette.umbrellaTopColor
    bottom.color = palette.umbrellaBottomColor

    top.position.y = (top.size.height + bottom.size.height) / 2

    bottom.position.x -= bottom.size.width / 4

    umbrella.addChild(top)
    umbrella.addChild(bottom)

    umbrella.umbrellaTop = top
    umbrella.umbrellaBottom = bottom

    return umbrella
  }

  public func updatePosition(point : CGPoint) {
    position = point
    destination = point
  }

  public func setDestination(destination : CGPoint) {
    self.destination = destination

    if destination.y < minimumHeight {
      self.destination.y = minimumHeight
    }

    let distance = Distance(p1: self.destination, p2: self.position)

    if isPingPong {
      easing = 0.3
    } else {
      if distance > UIScreen.main.bounds.width / 2 {
        easing = 0.04
      } else if distance > UIScreen.main.bounds.width / 4 {
        easing = 0.1
      } else {
        easing = 0.15
      }

      if self.destination.y == minimumHeight && position.y <= (minimumHeight + 5) {
        easing = max(easing / 2, 0.04)
      }
    }
  }

  public func update(deltaTime : TimeInterval) {
    let distance = sqrt(pow((destination.x - position.x), 2) + pow((destination.y - position.y), 2))

    if(distance > 1) {
      let directionX = (destination.x - position.x)
      let directionY = (destination.y - position.y)

      position.x += directionX * easing
      position.y += directionY * easing
    } else {
      position = destination;
    }
  }

  public func getVelocity() -> CGVector {
    return CGVector(dx: destination.x - position.x, dy: destination.y - position.y)
  }

  public func getHeight() -> CGFloat {
    return umbrellaTop.size.height + umbrellaBottom.size.height
  }

  public func updatePalette(palette: ColorPalette) {
    umbrellaTop.run(ColorAction().colorTransitionAction(fromColor: umbrellaTop.color, toColor: palette.umbrellaTopColor, duration: colorChangeDuration))
    umbrellaBottom.run(ColorAction().colorTransitionAction(fromColor: umbrellaBottom.color, toColor: palette.umbrellaBottomColor, duration: colorChangeDuration))
  }
}
