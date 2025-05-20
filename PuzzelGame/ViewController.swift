//
//  ViewController.swift
//  PuzzelGame
//
//  Created by Meet Budheliya on 20/05/25.
//

import UIKit

class PuzzleViewController: UIViewController {

    var originalImage: UIImage!
    let gridSize = 3
    var pieceSize: CGSize = .zero
    var pieces: [UIImageView] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        originalImage = UIImage(named: "IMG_2028")
        setupPuzzle()
    }

    func setupPuzzle() {
        guard let image = originalImage else { return }
        
        let imageWidth = view.bounds.size.width
        let imageHeight = view.bounds.size.height
        let scale = UIScreen.main.scale
        
        pieceSize = CGSize(width: imageWidth / CGFloat(gridSize),
                           height: imageHeight / CGFloat(gridSize))
        
        // Create pieces
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let x = CGFloat(col) * pieceSize.width
                let y = CGFloat(row) * pieceSize.height
                let rect = CGRect(x: x * scale, y: y * scale,
                                  width: pieceSize.width * scale,
                                  height: pieceSize.height * scale)
                
                if let cgImage = image.cgImage?.cropping(to: rect) {
                    let pieceImage = UIImage(cgImage: cgImage, scale: scale, orientation: .up)
                    let pieceView = UIImageView(image: pieceImage)
                    pieceView.frame = CGRect(x: CGFloat.random(in: 0...300),
                                             y: CGFloat.random(in: 400...700),
                                             width: pieceSize.width,
                                             height: pieceSize.height)
                    pieceView.isUserInteractionEnabled = true
                    pieceView.tag = row * gridSize + col
                    let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
                    pieceView.addGestureRecognizer(pan)
                    view.addSubview(pieceView)
                    pieces.append(pieceView)
                }
            }
        }
    }

    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let piece = gesture.view else { return }
        let translation = gesture.translation(in: view)
        piece.center = CGPoint(x: piece.center.x + translation.x,
                               y: piece.center.y + translation.y)
        gesture.setTranslation(.zero, in: view)

        if gesture.state == .ended {
            let correctRow = piece.tag / gridSize
            let correctCol = piece.tag % gridSize
            let targetX = CGFloat(correctCol) * pieceSize.width
            let targetY = CGFloat(correctRow) * pieceSize.height
            
            let distance = hypot(piece.frame.origin.x - targetX, piece.frame.origin.y - targetY)
            
            if distance < 20 {
                UIView.animate(withDuration: 0.2) {
                    piece.frame.origin = CGPoint(x: targetX, y: targetY)
                }
                piece.isUserInteractionEnabled = false
                checkCompletion()
            }
        }
    }

    func checkCompletion() {
        let completed = pieces.allSatisfy { piece in
            let row = piece.tag / gridSize
            let col = piece.tag % gridSize
            let correctFrame = CGRect(x: CGFloat(col) * pieceSize.width,
                                      y: CGFloat(row) * pieceSize.height,
                                      width: pieceSize.width,
                                      height: pieceSize.height)
            return piece.frame.origin == correctFrame.origin
        }
        
        if completed {
            let alert = UIAlertController(title: "🎉 Puzzle Completed!", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}
