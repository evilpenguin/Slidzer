//
//  PuzzleEngine.m
//  Slidzer
//
//  Created by James Emrich on 2/11/12.
//  Copyright (c) 2012 James Emrich. All rights reserved.
//

#import "PuzzleEngine.h"

@interface PuzzleEngine (Private)
    - (void) setTiles;
    - (BOOL) isTileAtPoint:(CGPoint)point;
    - (BOOL) isEmptyTile:(CGPoint)point;
    - (CGPoint) getTilesNewPointFromPoint:(CGPoint)point;
@end

@implementation PuzzleEngine

#pragma mark -
#pragma mark == PuzzleEngine ==

- (id) initEngine {
    if (self = [super init]) {
        tiles = [[NSMutableArray alloc] initWithCapacity:TILE_SIZE];
        
        [self setTiles]; 
    }
    return self;
}

#pragma mark -
#pragma mark == Private Methods ==

- (void) setTiles {
    [tiles removeAllObjects];
    
    int tileValue = 1;
    for (int i = 0; i < TILE_SIZE; i++) {
        NSMutableArray *tileColumns = [NSMutableArray arrayWithCapacity:TILE_SIZE];
        for (int j = 0; j < TILE_SIZE; j++) {
            if (tileValue == MAX_TILE_SIZE) [tileColumns addObject:[NSNumber numberWithInt:EMPTY_TILE]];
            else { 
                [tileColumns addObject:[NSNumber numberWithInt:tileValue]];
                tileValue++;
            }
            
        }
        [tiles addObject:tileColumns];
    } 
}

- (BOOL) isTileAtPoint:(CGPoint)point {
    BOOL isVisible  = (point.x > 0 && point.y > 0);
    BOOL isInColumn = (point.x <= TILE_SIZE && point.y <= TILE_SIZE);

    return (isVisible && isInColumn);
}

- (BOOL) isEmptyTile:(CGPoint)point {
    return ([self getTileFromPoint:point] == EMPTY_TILE);
}

- (CGPoint) getTilesNewPointFromPoint:(CGPoint)point {
    CGPoint newPoint = point;
    switch ([self getTileMoveDirection:point]) {
        case DirectionUp:
            newPoint = CGPointMake(point.x, point.y - 1);
            break;
        case DirectionRight:
            newPoint = CGPointMake(point.x + 1, point.y);
            break;
        case DirectionLeft:
            newPoint = CGPointMake(point.x - 1, point.y);
            break;
        case DirectionDown:
            newPoint = CGPointMake(point.x, point.y + 1);
            break;
        default:
            break;
    }
    return newPoint;
}

#pragma mark -
#pragma mark == Public Methods ==

- (void) resetTiles {
    [self setTiles];
}

- (void) replaceTileAtPoint:(CGPoint)oldPoint withPoint:(CGPoint)newPoint {
    int oldTile = [self getTileFromPoint:oldPoint];
    int newTile = [self getTileFromPoint:newPoint];
    
    [[tiles objectAtIndex:oldPoint.y-1] replaceObjectAtIndex:oldPoint.x-1 withObject:[NSNumber numberWithInt:newTile]];
    [[tiles objectAtIndex:newPoint.y-1] replaceObjectAtIndex:newPoint.x-1 withObject:[NSNumber numberWithInt:oldTile]];
    
}

- (int) getTileFromPoint:(CGPoint)point {    
    int column = point.y - 1;
    int tile = point.x - 1;
    
    if (column < [tiles count]) {
        if (tile < [[tiles objectAtIndex:column] count]) {
            return [[[tiles objectAtIndex:column] objectAtIndex:tile] intValue];
        }
    }
    return 0;
}

- (NSMutableArray *) getMovableTilesFromPoint:(CGPoint)point {
    NSMutableArray *columns = [NSMutableArray array];
    for (int i = point.y - 1; i > 0; i--) {
        TileDirection direction = [self getTileMoveDirection:CGPointMake(point.x, i)];
        if (direction == DirectionUp) { 
            for (int j = i; j < point.y; j++) {
                [columns addObject:[NSValue valueWithCGPoint:CGPointMake(point.x, j)]];
            }
            
        }
    }
    
    for (int i = point.x + 1; i < TILE_SIZE; i++) {
        TileDirection direction = [self getTileMoveDirection:CGPointMake(i, point.y)];
        if (direction == DirectionRight) { 
            for (int j = i; j > point.x; j--) {
                [columns addObject:[NSValue valueWithCGPoint:CGPointMake(j, point.y)]];
            }
            
        }
    }
    
    for (int i = point.x - 1; i > 0; i--) {
        TileDirection direction = [self getTileMoveDirection:CGPointMake(i, point.y)];
        if (direction == DirectionLeft) { 
            for (int j = i; j < point.x; j++) {
                [columns addObject:[NSValue valueWithCGPoint:CGPointMake(j, point.y)]];
            }
            
        }
    }
    
    for (int i = point.y + 1; i < TILE_SIZE; i++) {
        TileDirection direction = [self getTileMoveDirection:CGPointMake(point.x, i)];
        if (direction == DirectionDown) { 
            for (int j = i; j > point.y; j--) {
                [columns addObject:[NSValue valueWithCGPoint:CGPointMake(point.x, j)]];
            }
            
        }
    }
    [columns addObject:[NSValue valueWithCGPoint:CGPointMake(point.x, point.y)]];
    NSLog(@"PuzzleEngine columns: %@", columns);
    
    return columns;
}

- (TileDirection) getTileMoveDirection:(CGPoint)point {
    TileDirection direction = DirectionNone;
    
    if (canMoveInDirection(CGPointMake(point.x, point.y - 1))) direction = DirectionUp;
    if (canMoveInDirection(CGPointMake(point.x + 1, point.y))) direction = DirectionRight;
    if (canMoveInDirection(CGPointMake(point.x - 1, point.y))) direction = DirectionLeft;
    if (canMoveInDirection(CGPointMake(point.x, point.y + 1))) direction = DirectionDown;
    
    return direction;
}

- (TileDirection) getMovableDirectionFromArray:(NSMutableArray *)array {
    TileDirection direction = DirectionNone;
    for (NSValue *point in array) {
        TileDirection tempDirection = [self getTileMoveDirection:[point CGPointValue]];
        if (tempDirection != DirectionNone) direction = tempDirection;
    }
    return direction; 
}

- (BOOL) isValidMove:(CGPoint)point {
    return ([self getTileMoveDirection:point] != DirectionNone);
}

- (BOOL) isPuzzleFinished {
    int tileValue = 1;
    BOOL finished = YES;
    
    for (int i = 1; i < TILE_SIZE + 1; i++) {
        for (int j = 1; j < TILE_SIZE + 1; j++) {
            int tile = [self getTileFromPoint:CGPointMake(j, i)];

            if (tile == tileValue) tileValue++;
            else if (tileValue == MAX_TILE_SIZE) break;
            else  { 
                finished = NO;
                break;
            }
        }
    }
    return finished;
}

#pragma mark -
#pragma mark == Memory ==

- (void) dealloc {
    [tiles release];
    [super dealloc];
}

@end
