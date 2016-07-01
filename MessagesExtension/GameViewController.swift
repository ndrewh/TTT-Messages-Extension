//
//  GameViewController.swift
//  TicTacToe-Messages
//
//  Created by Andrew H on 6/20/16.
//  Copyright © 2016 Andrew H. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    // Storyboard Outlets
    @IBOutlet var board: [UILabel]! // 0 1 2
                                    // 3 4 5
                                    // 6 7 8
    @IBOutlet var topLabel: UILabel!
    
    // State
    var game: Game!
    var allowMove = true
    weak var delegate: GameViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the board labels to represent game state
        for (index, position) in game.board.enumerated() {
            let label = board[index]
            label.tag = index // use the UIView 'tag' property to easily identify a label's position
            label.text = position?.rawValue ?? ""
            configureLabel(label: label)
        }
        
        allowMove = (game.winner == nil && game.occupiedCount < 9)
        topLabel.text = allowMove ? "It's your turn! You are \(game.playerTurn.rawValue)." : "Game over."

        //let rekt = CGRect(x: (self.view.bounds.width - squareSize) / 2.0, y: (self.view.bounds.height - squareSize) / 2.0, width: squareSize, height: squareSize)
    }
    
    private func configureLabel(label: UILabel) {
        let ge = UITapGestureRecognizer(target: self, action: #selector(GameViewController.boardTapped))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(ge)
    }
    
    func boardTapped(ge: UIGestureRecognizer) {
        let selectedPosState = game.board[ge.view!.tag]
        if allowMove && selectedPosState == nil {
            allowMove = false
            
            // Make the play
            let thisPlayer = game.playerTurn
            game.board[ge.view!.tag] = thisPlayer
            (ge.view as! UILabel).text = thisPlayer.rawValue
            
            let winner = game.winner
            if winner != nil {
                // Tell the user the great news!
                let alert = UIAlertController(title: "Congratulations!", message: "You won the game!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok!", style: .default, handler: { action in
                    // Finally, tell the delegate
                    self.delegate?.playMade(using: self, in: self.game, with: winner, screenshot: self.screenshotBoard())
                }))
                present(alert, animated: true, completion: nil)
            } else {
                // Tell the delegate immediately
                delegate?.playMade(using: self, in: game, with: winner, screenshot: screenshotBoard())
            }
        }
    }
    
    
    // @todo Fix this so that it only captures the portion of the view which holds the board (remove the topLabel.isHidden hack)
    func screenshotBoard() -> UIImage? {
        let squareSize = min(self.view.bounds.height, self.view.bounds.width)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: squareSize, height: squareSize), true, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        topLabel.isHidden = true
        self.view.drawHierarchy(in: CGRect(x: 0, y: 0, width: squareSize, height: squareSize), afterScreenUpdates: true)
        topLabel.isHidden = false
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    static let storyboardIdentifier = "GameViewController"

}

protocol GameViewControllerDelegate: class {
    // Tells the delegate that a play was made.
    // I'm not yet a big fan of the Swift 3 method naming conventions. I feel like there's two labels for everything
    func playMade(using gameViewController:GameViewController, in game: Game, with winner: PositionState?, screenshot: UIImage?)
}
