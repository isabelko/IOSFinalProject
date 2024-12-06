//
//  StickFigureView.swift
//  FinalProject
//
//  Created by Isak Sabelko on 11/19/24.
//
//overlaps on top of the log climb view
import Foundation

import UIKit

class StickFigureView: UIView {
     
    private var joints: [UIView] = [] // Views for the stick figure's joints
    private var lines: [CAShapeLayer] = [] // Lines connecting the joints
    private var jointToLines: [UIView: [CAShapeLayer]] = [:] // Map each joint to its connected lines

    var jointColor: UIColor = .red {
        didSet {
            updateJointColors()
        }
    }

    var limbColor: UIColor = .black {
        didSet {
            updateLimbColors()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear // Transparent background
        setupStickFigure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStickFigure()
    }

    private func setupStickFigure() {
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height

        // Define joint positions: [Head, Neck, Left Elbow, Left Hand, Right Elbow, Right Hand, Torso, Left Knee, Left Foot, Right Knee, Right Foot]
        let jointPositions: [CGPoint] = [
            CGPoint(x: screenWidth / 2, y: screenHeight * 0.1),   // Head (centered horizontally, 10% down from top)
            CGPoint(x: screenWidth / 2, y: screenHeight * 0.15),  // Neck (centered horizontally, 15% down)
            CGPoint(x: screenWidth * 0.4, y: screenHeight * 0.2), // Left elbow (40% across, 20% down)
            CGPoint(x: screenWidth * 0.3, y: screenHeight * 0.25), // Left hand (30% across, 25% down)
            CGPoint(x: screenWidth * 0.6, y: screenHeight * 0.2), // Right elbow (60% across, 20% down)
            CGPoint(x: screenWidth * 0.7, y: screenHeight * 0.25), // Right hand (70% across, 25% down)
            CGPoint(x: screenWidth / 2, y: screenHeight * 0.35),  // Torso (centered horizontally, 35% down)
            CGPoint(x: screenWidth * 0.45, y: screenHeight * 0.5), // Left knee (45% across, 50% down)
            CGPoint(x: screenWidth * 0.4, y: screenHeight * 0.6),  // Left foot (40% across, 60% down)
            CGPoint(x: screenWidth * 0.55, y: screenHeight * 0.5), // Right knee (55% across, 50% down)
            CGPoint(x: screenWidth * 0.6, y: screenHeight * 0.6)   // Right foot (60% across, 60% down)
        ]

        // Define emojis for hands and feet
        let jointEmojis: [String?] = [
            "😀",       // Head
            nil,       // Neck
            nil,       // Left elbow
            "🖐️",      // Left hand
            nil,       // Right elbow
            "✋",       // Right hand
            nil,       // Torso
            nil,       // Left knee
            "🦶",      // Left foot
            nil,       // Right knee
            "🦶"       // Right foot
        ]

        // Create joints
        for (index, position) in jointPositions.enumerated() {
            let joint = createJoint(at: position, emoji: jointEmojis[index])
            joints.append(joint)
            addSubview(joint)
        }

        // Connect joints with lines
        connectJoints(from: joints[0], to: joints[1]) // Head to neck
        connectJoints(from: joints[1], to: joints[2]) // Neck to left elbow
        connectJoints(from: joints[2], to: joints[3]) // Left elbow to left hand
        connectJoints(from: joints[1], to: joints[4]) // Neck to right elbow
        connectJoints(from: joints[4], to: joints[5]) // Right elbow to right hand
        connectJoints(from: joints[1], to: joints[6]) // Neck to torso
        connectJoints(from: joints[6], to: joints[7]) // Torso to left knee
        connectJoints(from: joints[7], to: joints[8]) // Left knee to left foot
        connectJoints(from: joints[6], to: joints[9]) // Torso to right knee
        connectJoints(from: joints[9], to: joints[10]) // Right knee to right foot
    }


    private func createJoint(at position: CGPoint, emoji: String? = nil) -> UIView {
        let jointSize: CGFloat = 25 // Increased size to fit emojis better
        let joint: UIView

        if let emoji = emoji {
            // Create a UILabel for emoji-based joints
            let label = UILabel(frame: CGRect(x: position.x - jointSize / 2, y: position.y - jointSize / 2, width: jointSize, height: jointSize))
            label.text = emoji
            label.font = .systemFont(ofSize: jointSize - 5) // Ensure the font size fits within the label
            label.textAlignment = .center
            label.isUserInteractionEnabled = true
            joint = label
        } else {
            // Create a default circular joint
            joint = UIView(frame: CGRect(x: position.x - jointSize / 2, y: position.y - jointSize / 2, width: jointSize, height: jointSize))
            joint.backgroundColor = jointColor
            joint.layer.cornerRadius = jointSize / 2
        }

        joint.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))
        jointToLines[joint] = [] // Initialize the connected lines array

        return joint
    }

    private func connectJoints(from: UIView, to: UIView) {
        let line = CAShapeLayer() // Allows me to use UIbezierpath later for drawing and updating the line
        line.strokeColor = limbColor.cgColor
        line.lineWidth = 2
        layer.addSublayer(line)
        lines.append(line)

        // Add the line to the mappings for both joints
        jointToLines[from]?.append(line)
        jointToLines[to]?.append(line)

        updateLine(from: from, to: to, line: line)
    }

    private func updateLine(from: UIView, to: UIView, line: CAShapeLayer) {
        let fromPosition = convert(from.center, from: from.superview)
        let toPosition = convert(to.center, from: to.superview)
        
        // Create a new path for the line
        let path = UIBezierPath()
        path.move(to: fromPosition)
        path.addLine(to: toPosition)
        line.path = path.cgPath
    }


    private func updateJointColors() {
        for joint in joints {
            // Only update background color for non-emoji joints (not UILabels)
            if !(joint is UILabel) {
                joint.backgroundColor = jointColor
            }
        }
    }


    private func updateLimbColors() {
        for line in lines {
            line.strokeColor = limbColor.cgColor
        }
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let joint = gesture.view else { return }
        let translation = gesture.translation(in: self)
        
        // Calculate the new center
        var newCenter = CGPoint(x: joint.center.x + translation.x, y: joint.center.y + translation.y)
        
        // Restrict movement to bounds
        let jointRadius: CGFloat = joint.bounds.width / 2
        let allowedArea = CGRect(
            x: 0,
            y: 0,
            width: bounds.width,
            height: bounds.height
        )
        
        newCenter.x = max(allowedArea.minX + jointRadius, min(newCenter.x, allowedArea.maxX - jointRadius))
        newCenter.y = max(allowedArea.minY + jointRadius, min(newCenter.y, allowedArea.maxY - jointRadius))
        
        // Update joint position
        joint.center = newCenter
        gesture.setTranslation(.zero, in: self)

        // Update all lines connected to this joint
        if let connectedLines = jointToLines[joint] {
            for line in connectedLines {
                if let startJoint = joints.first(where: { jointToLines[$0]?.contains(line) == true && $0 != joint }) {
                    updateLine(from: startJoint, to: joint, line: line)
                }
            }
        }
    }
    
    private func updateAllLines() {
        for (joint, lines) in jointToLines {
            for line in lines {
                if let otherJoint = joints.first(where: { jointToLines[$0]?.contains(line) == true && $0 != joint }) {
                    updateLine(from: joint, to: otherJoint, line: line)
                }
            }
        }
    }


}



