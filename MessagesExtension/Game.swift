//
//  Game.swift
//  TicTacToe-Messages
//
//  Created by Andrew H on 6/20/16.
//  Copyright © 2016 Andrew H. All rights reserved.
//

import UIKit
import Messages


// Enum escapsulating the possible states for an occupied position on the board.
// Unoccupied positions are nil.
//
// @todo rename this to something that makes more sense given that I use it
// literally everywhere, even if not directly referring to a position on the
// board
enum PositionState: String {
    case X
    case O
}

// Represents game state and much of the logic
struct Game {
    var board: [PositionState?] // count: 9. Having a 1D array as opposed to 2D simplifies enumerations given the simplicity of the game
    var session: MSSession
    
    init?(message: MSMessage?) {
        guard let messageURL = message?.url else { return nil }
        guard let urlComponents = NSURLComponents(url: messageURL, resolvingAgainstBaseURL: false), queryItems = urlComponents.queryItems else { return nil }
        
        // Initialize the board from the queryComponents
        
        if queryItems.count != 9 { return nil }
        
        board = queryItems.map({
            guard let value = $0.value else { return nil }
            return PositionState(rawValue: value)
        })
        
        session = message?.session ?? MSSession()
    }
    
    init() {
        print("New Game created.")
        board = [PositionState?](repeating: nil, count: 9)
        session = MSSession()
    }
    
    var queryItems: [URLQueryItem] {
        var items = [URLQueryItem] ()
        for (index, position) in board.enumerated() {
            let value = position != nil ? position!.rawValue : "U"
            items.append(URLQueryItem(name: "\(index)", value: value))
        }
        return items
    }
    
    var occupiedCount: Int {
        var count = 0
        for pos in board {
            if pos != nil {
                count += 1
            }
        }
        return count
    }
    
    
    var playerTurn: PositionState {
        return occupiedCount % 2 == 0 ? .X : .O
    }
    
    var winner: PositionState? {
        return rowWin ?? colWin ?? diagWin
    }
    
    private var rowWin: PositionState? {
        for i in [0, 3, 6] {
            if board[i] != nil && board[i] == board[i+1] && board[i+1] == board[i+2] {
                return board[i]
            }
        }
        return nil
    }
    
    private var colWin: PositionState? {
        for i in 0...2 {
            if board[i] != nil && board[i] == board[i+3] && board[i+3] == board[i+6] {
                return board[i]
            }
        }
        return nil
    }
    
    private var diagWin: PositionState? {
        // Upper left -> Lower right
        if board[0] != nil && board[0] == board[4] && board[4] == board[8] {
            return board[0]
        }
        
        // Upper right -> Lower left
        if board[2] != nil && board[2] == board[4] && board[4] == board[6] {
            return board[2]
        }
        return nil
    }
    
}
