//
//  PuzzleBoardView.h
//  Slidzer
//
//  Created by James Emrich on 2/11/12.
//  Copyright (c) 2012 James Emrich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PuzzleEngine.h"

#define SHUFFLE_TIMES   125 
#define BOARD_SIZE      4 

@protocol PuzzleBoardViewDelegate <NSObject>
    @required
    - (void) puzzleBoardFinished:(id)board;
    - (void) puzzleBoard:(id)board stepCount:(int)count;
@end

@interface PuzzleBoardView : UIView {
    NSMutableArray  *tiles;
    NSMutableArray  *draggingTiles;
    UIImage         *boardImage;
    UIImageView     *fullImage;
    PuzzleEngine    *engine;
    TileDirection   draggingDirection;
    float           tileWidth;
    float           tileHeight;
    int             steps;
    BOOL            isMovingTile;
}
@property (nonatomic, assign) id <PuzzleBoardViewDelegate> delegate;

- (id) initWithFrame:(CGRect)frame image:(id)image;
- (void) playGame;
- (void) stopGame;
@end
