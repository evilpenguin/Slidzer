//
//  PuzzleEngine.h
//  Slidzer
//
//  Created by James Emrich on 2/11/12.
//  Copyright (c) 2012 James Emrich. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    DirectionNil   = -1,
    DirectionNone  = 0,
    DirectionUp    = 1,
    DirectionRight = 2,
    DirectionLeft  = 3,
    DirectionDown  = 4
} TileDirection;

#define EMPTY_TILE                      0
#define TILE_SIZE                       4 
#define MAX_TILE_SIZE                   (TILE_SIZE * TILE_SIZE)
#define canMoveInDirection(direction)   ([self isTileAtPoint:direction] && [self isEmptyTile:direction])

@interface PuzzleEngine : NSObject {
    NSMutableArray  *tiles;
}

- (id) initEngine;
- (void) resetTiles;
- (void) replaceTileAtPoint:(CGPoint)oldPoint withPoint:(CGPoint)newPoint;
- (int) getTileFromPoint:(CGPoint)point;
- (NSMutableArray *) getMovableTilesFromPoint:(CGPoint)point;
- (TileDirection) getTileMoveDirection:(CGPoint)point;
- (TileDirection) getMovableDirectionFromArray:(NSMutableArray *)array;
- (BOOL) isValidMove:(CGPoint)point;
- (BOOL) isPuzzleFinished;
@end
