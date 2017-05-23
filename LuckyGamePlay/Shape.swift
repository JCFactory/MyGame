//
//  Shape.swift
//  LuckyGamePlay
//
//  Created by Jacqueline on 23.05.17.
//  Copyright © 2017 Jackys Code Factory. All rights reserved.
//

import SpriteKit

//the number of total shape varieties
let NumOrientations: UInt32 = 4

//shape indexes

let FirstBlockIdx = 0
let SecondBlockIdx = 1
let ThirdBlockIdx = 2
let FourthBlockIdx = 3

enum Orientation: Int, CustomStringConvertible{
    
    case Zero = 0, Ninety, OneEighty, TwoSeventy
    
    var description: String{
        switch self{
        case .Zero:
            return "0"
        
        case .Ninety:
            return "90"

        case .OneEighty:
            return "180"

        case .TwoSeventy:
            return "270"
        }
    }
    
    static func random() -> Orientation{
        return Orientation (rawValue:Int(arc4random_uniform(NumOrientations)))!
    }
    
    //#1
    static func rotate(orientation:Orientation, clockwise: Bool) -> Orientation{
        
        var rotated = orientation.rawValue + (clockwise ?1 : -1)
        
        if rotated > Orientation.TwoSeventy.rawValue{
            rotated = Orientation.Zero.rawValue
            
        }else if rotated < 0 {
            rotated = Orientation.TwoSeventy.rawValue
        }
        return Orientation(rawValue:rotated)!
        }
        
    }

class Shape: Hashable, CustomStringConvertible{
    
    //the color of the shape
    
    let color: BlockColor
    
    //the blocks comprising the shape
    
    var blocks = Array<Block>()
    
    //the current orientation of the blocks
    
    var orientation: Orientation
    
    //the column, row representint the shape's anchor point
    
    var column, row:Int
    
    //Required overrides
    
    //#2
    //subclasses must override this property
    var blockRowColumnPositions: [Orientation:Array<(columnDiff:Int, rowDiff: Int)>]{
        return [:]
    }
    
    //#3
    //subclasses must override this property
    var bottomBlocksForOrientations: [Orientation: Array<Block>]{
        return[:]
    }
    
    //#4
    var bottomBlocks:Array<Block>{
        guard let bottomBlocks = bottomBlocksForOrientations[orientation] else{
            return[]
        }
        return bottomBlocks
    }
    
    //Hashable
    var hashValue:Int{
        //#5
        return blocks.reduce(0){$0.hashValue ^ $1.hashValue}
        
    }
    
    //CustomStringConvertible
    var description:String {
        return "\(color) block facing \(orientation): \(blocks[FirstBlockIdx]), \(blocks[SecondBlockIdx]), \(blocks[ThirdBlockIdx]), \(blocks[FourthBlockIdx])"
    }
    
    init(column:Int, row:Int, color:BlockColor, orientation:Orientation){
        self.color=color
        self.column=column
        self.row=row
        self.orientation=orientation
        initializeBlocks()
    }
    
    convenience init(column:Int, row:Int){
        self.init(column:column, row:row, color:BlockColor.random(), orientation:Orientation.random())
        
    }
    
    //#7
    final func initializeBlocks() {
        guard let blockRowColumnTranslations = blockRowColumnPositions[orientation] else {
            return
        }
    
        //#8
        blocks = blockRowColumnTranslations.map{ (diff) -> Block in
            return Block(column: column+diff.columnDiff, row: row+diff.rowDiff, color: color)
        }
    }

    final func rotateBlocks(orientation:Orientation){
        guard let blockRowColumnTranslation:Array<(columnDiff:Int, rowDiff:Int)>=blockRowColumnPositions[orientation]
            else{
                return
        }
        for(idx, diff) in blockRowColumnTranslation.enumerated(){
            blocks[idx].column = column + diff.columnDiff
            
            blocks[idx].row = row + diff.rowDiff
        }
    }
    
    final func lowerShapeByOneRow(){
        shiftBy(columns: 0, rows:1)
    }
    
    final func shiftBy(columns: Int, rows:Int){
        self.column += columns
        self.row += rows
        for block in blocks {
            block.column += columns
            block.row += rows
        }
    }
    
    final func moveTo(column:Int, row:Int){
        self.column=column
        self.row=row
        rotateBlocks(orientation)
    }
    
    final class func random(startingColumn:Int, startingRow: Int) -> Shape{
        switch Int(arc4random_uniform(NumShapeTypes)){
            case 0:
                return SquareShape(column:startingColumn, row:startingRow)
            case 1:
                return LineShape(column:startingColumn, row:startingRow)
            case 2:
                return TShape(column:startingColumn, row:startingRow)
            case 3:
                return LShape(column:startingColumn, row:startingRow)
            case 4:
                return JShape(column:startingColumn, row:startingRow)
            case 5:
                return SShape(column:startingColumn, row:startingRow)
            default:
                return ZShape(column:startingColumn, row:startingRow)
            
        }
        
    
    }
    
}
    
     func ==(lhs: Shape, rhs: Shape) -> Bool {
        return lhs.row == rhs.row && lhs.column == rhs.column
}


    
    
    
    
    
    
    
    
    
    
    
    
    
    
    



