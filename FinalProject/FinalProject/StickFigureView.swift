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
     
    private var joints: [UIView] = [] //views for the stick figure's joints
    private var lines: [CAShapeLayer] = [] //connect joints with lines
    private var jointToLines: [UIView: [CAShapeLayer]] = [:] //create a map for each of the joints and lines

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
        backgroundColor = .clear //clear to overlay
        setupStickFigure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStickFigure()
    }

    private func setupStickFigure() {
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height

        //joint positions
        let jointPositions: [CGPoint] = [
            CGPoint(x: screenWidth / 2, y: screenHeight * 0.1),     //head
            CGPoint(x: screenWidth / 2, y: screenHeight * 0.15),    //neck
            CGPoint(x: screenWidth * 0.4, y: screenHeight * 0.2),   //left elbow
            CGPoint(x: screenWidth * 0.3, y: screenHeight * 0.25),  //left hand
            CGPoint(x: screenWidth * 0.6, y: screenHeight * 0.2),   //right elbow
            CGPoint(x: screenWidth * 0.7, y: screenHeight * 0.25),  //right hand
            CGPoint(x: screenWidth / 2, y: screenHeight * 0.35),    //torso
            CGPoint(x: screenWidth * 0.45, y: screenHeight * 0.5),  //left knee
            CGPoint(x: screenWidth * 0.4, y: screenHeight * 0.6),   //left foot
            CGPoint(x: screenWidth * 0.55, y: screenHeight * 0.5),  //right knee
            CGPoint(x: screenWidth * 0.6, y: screenHeight * 0.6)    //right foot
        ]

        //define emojis for hands and feet also can change other joints if wanting to
        //same order as above
        let jointEmojis: [String?] = [
            "😀",
            nil,
            nil,
            "🖐️",
            nil,
            "✋",
            nil,
            nil,
            "🦶",
            nil,
            "🦶"
        ]

        //create the joints
        for (index, position) in jointPositions.enumerated() {
            let joint = createJoint(at: position, emoji: jointEmojis[index])
            joints.append(joint)
            addSubview(joint)
        }

        //connect the joints with lines
        connectJoints(from: joints[0], to: joints[1])   //head to neck
        connectJoints(from: joints[1], to: joints[2])   //neck to left elbow
        connectJoints(from: joints[2], to: joints[3])   //left elbow to left hand
        connectJoints(from: joints[1], to: joints[4])   //neck to right elbow
        connectJoints(from: joints[4], to: joints[5])   //right elbow to right hand
        connectJoints(from: joints[1], to: joints[6])   //neck to torso
        connectJoints(from: joints[6], to: joints[7])   //torso to left knee
        connectJoints(from: joints[7], to: joints[8])   //left knee to left foot
        connectJoints(from: joints[6], to: joints[9])   //torso to right knee
        connectJoints(from: joints[9], to: joints[10])  //right knee to right foot
    }


    private func createJoint(at position: CGPoint, emoji: String? = nil) -> UIView {
        let jointSize: CGFloat = 25 //emojis cutting off so makes size larger to now cut off
        let joint: UIView

        if let emoji = emoji {
            //UILabel for emoji-based joints
            let label = UILabel(frame: CGRect(x: position.x - jointSize / 2, y: position.y - jointSize / 2, width: jointSize, height: jointSize))
            label.text = emoji
            label.font = .systemFont(ofSize: jointSize - 5)
            label.textAlignment = .center
            label.isUserInteractionEnabled = true
            joint = label
        } else {
            //default circle joint if no emoji
            joint = UIView(frame: CGRect(x: position.x - jointSize / 2, y: position.y - jointSize / 2, width: jointSize, height: jointSize))
            joint.backgroundColor = jointColor
            joint.layer.cornerRadius = jointSize / 2
        }

        joint.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))
        jointToLines[joint] = []

        return joint
    }

    private func connectJoints(from: UIView, to: UIView) {
        let line = CAShapeLayer() //allows me to use UIbezierpath later for drawing and updating the line
        line.strokeColor = limbColor.cgColor
        line.lineWidth = 2
        layer.addSublayer(line)
        lines.append(line)

        //add the lines to the mappings for joints
        jointToLines[from]?.append(line)
        jointToLines[to]?.append(line)

        updateLine(from: from, to: to, line: line)
    }

    private func updateLine(from: UIView, to: UIView, line: CAShapeLayer) {
        let fromPosition = convert(from.center, from: from.superview)
        let toPosition = convert(to.center, from: to.superview)
        
        //update path for the line
        let path = UIBezierPath()
        path.move(to: fromPosition)
        path.addLine(to: toPosition)
        line.path = path.cgPath
    }


    private func updateJointColors() {
        for joint in joints {
            //update background color for non-emoji joints
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
        
        var newCenter = CGPoint(x: joint.center.x + translation.x, y: joint.center.y + translation.y)
        
        //keep moves within area, dont lose them in unaccesable area
        let jointRadius: CGFloat = joint.bounds.width / 2
        let allowedArea = CGRect(
            x: 0,
            y: 0,
            width: bounds.width,
            height: bounds.height
        )
        
        newCenter.x = max(allowedArea.minX + jointRadius, min(newCenter.x, allowedArea.maxX - jointRadius))
        newCenter.y = max(allowedArea.minY + jointRadius, min(newCenter.y, allowedArea.maxY - jointRadius))
        
        //update position of joints
        joint.center = newCenter
        gesture.setTranslation(.zero, in: self)

        //update all lines connected to this joint
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



