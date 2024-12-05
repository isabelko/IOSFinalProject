//
//  StickFigureView.swift
//  FinalProject
//
//  Created by Isak Sabelko on 12/4/24.
//

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
        // Define joint positions: [Head, Neck, Left Elbow, Left Hand, Right Elbow, Right Hand, Torso, Left Knee, Left Foot, Right Knee, Right Foot]
        let jointPositions: [CGPoint] = [
            CGPoint(x: 100, y: 100),  // Head
            CGPoint(x: 100, y: 150),  // Neck
            CGPoint(x: 80, y: 175),   // Left elbow
            CGPoint(x: 60, y: 200),   // Left hand
            CGPoint(x: 120, y: 175),  // Right elbow
            CGPoint(x: 140, y: 200),  // Right hand
            CGPoint(x: 100, y: 250),  // Torso
            CGPoint(x: 90, y: 275),   // Left knee
            CGPoint(x: 80, y: 300),   // Left foot
            CGPoint(x: 110, y: 275),  // Right knee
            CGPoint(x: 120, y: 300)   // Right foot
        ]

        // Create joints
        for position in jointPositions {
            let joint = createJoint(at: position)
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

    private func createJoint(at position: CGPoint) -> UIView {
        let joint = UIView(frame: CGRect(x: position.x - 10, y: position.y - 10, width: 20, height: 20))
        joint.backgroundColor = jointColor
        joint.layer.cornerRadius = 10
        joint.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))
        jointToLines[joint] = [] // Initialize an empty array for connected lines
        return joint
    }

    private func connectJoints(from: UIView, to: UIView) {
        let line = CAShapeLayer()
        line.strokeColor = limbColor.cgColor
        line.lineWidth = 2
        line.lineCap = .round
        layer.addSublayer(line)
        lines.append(line)

        // Add the line to the mappings for both joints
        jointToLines[from]?.append(line)
        jointToLines[to]?.append(line)

        updateLine(from: from, to: to, line: line)
    }

    private func updateLine(from: UIView, to: UIView, line: CAShapeLayer) {
        let path = UIBezierPath()
        path.move(to: convert(from.center, from: from.superview))
        path.addLine(to: convert(to.center, from: to.superview))
        line.path = path.cgPath
    }

    private func updateJointColors() {
        for joint in joints {
            joint.backgroundColor = jointColor
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
        
        // Define custom movement bounds
        let jointRadius: CGFloat = joint.bounds.width / 2
        let allowedArea = CGRect(
            x: 0,
            y: 0,
            width: bounds.width,
            height: bounds.height // Extend downward by 100 points
        )
        
        // Restrict movement to the custom bounds
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


}
