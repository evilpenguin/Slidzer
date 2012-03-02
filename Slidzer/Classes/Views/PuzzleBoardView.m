//
//  PuzzleBoardView.m
//  Slidzer
//
//  Created by James Emrich on 2/11/12.
//  Copyright (c) 2012 James Emrich. All rights reserved.
//

#import "PuzzleBoardView.h"

@interface PuzzleBoardView (Private)
    - (void) setTileWithAndHeight;
    - (void) resetValues;
    - (void) createTileImages;
    - (void) shuffleTiles;
    - (void) drawPuzzle;
    - (void) moveTileWithPoint:(CGPoint)point direction:(TileDirection)moveDirection finish:(BOOL)finish animation:(BOOL)animation;
    - (UIImage *) cropImageFromFrame:(CGRect)frame;
    - (UIImageView *) getTileImageAtPoint:(CGPoint)point;
    - (float) getXTransformFromPoint:(CGPoint)point;
    - (float) getYTransformFromPoint:(CGPoint)point;
@end

@implementation PuzzleBoardView
@synthesize delegate;

#pragma mark -
#pragma mark == PuzzleBoardView

- (id) initWithFrame:(CGRect)frame image:(id)image {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor        = [UIColor darkGrayColor];
        self.clipsToBounds          = YES;
        self.userInteractionEnabled = NO;
        self.layer.borderColor      = [[UIColor lightGrayColor] CGColor];
        self.layer.borderWidth      = 2.0f;
        self.delegate               = nil;
        boardImage                  = [image retain];
        engine                      = [[PuzzleEngine alloc] initEngine];
        tiles                       = [[NSMutableArray alloc] initWithCapacity:16];
        
        [self setTileWithAndHeight];
        [self resetValues];
        
        fullImage = [[UIImageView alloc] initWithImage:image];
        fullImage.frame = self.bounds;
        fullImage.alpha = 1.0f;
        [self addSubview:fullImage];
        
        UIPanGestureRecognizer *dragGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragging:)];
        [dragGesture setMaximumNumberOfTouches:1];
        [dragGesture setMinimumNumberOfTouches:1];
        [self addGestureRecognizer:dragGesture];
        [dragGesture release];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [tapGesture setNumberOfTapsRequired:1];
        [self addGestureRecognizer:tapGesture];
        [tapGesture release];
    }    
    return self;
}

- (void) drawRect:(CGRect)rect {
    NSString *developer = @"James D. Emrich ( EvilPenguin )";
    CGSize developerSize = [developer sizeWithFont:[UIFont boldSystemFontOfSize:14.0f]];
    
    [[UIColor purpleColor] set];
    [developer drawAtPoint:CGPointMake(self.frame.size.width/2.0f - developerSize.width/2.0f, (self.frame.size.height/2.0 - developerSize.height/2.0f) + 30.0f) 
                  withFont:[UIFont boldSystemFontOfSize:14.0f]];
    
    [super drawRect:rect];
}

#pragma mark -
#pragma mark == Private Methods ==

- (void) setTileWithAndHeight {
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0f);
    CGImageRef sourceImage = CGImageCreateCopy(boardImage.CGImage);
    UIImage *newImage = [UIImage imageWithCGImage:sourceImage scale:0.0f orientation:boardImage.imageOrientation];
    [newImage drawInRect:CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height)];
    CGImageRelease(sourceImage);
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    tileWidth = newImage.size.width/BOARD_SIZE;
    tileHeight = newImage.size.height/BOARD_SIZE;
}

- (void) resetValues {
    isMovingTile        = NO;
    steps               = 0;
    draggingDirection   = DirectionNil;
    
    if (draggingTiles != nil) { 
        [draggingTiles release];
        draggingTiles = nil;
    }
}

- (void) createTileImages {
    [tiles removeAllObjects];
    for (int i = 0; i < BOARD_SIZE; i++) {
        for (int j = 0; j < BOARD_SIZE; j++) {
            CGRect frame = CGRectMake(tileWidth * i, tileHeight * j, tileWidth, tileHeight);
            UIImage *tileImage = [self cropImageFromFrame:frame]; 
            UIImageView *tileImageView          = [[UIImageView alloc] initWithImage:tileImage];
            tileImageView.frame                 = frame;
            tileImageView.layer.borderColor     = [[UIColor lightGrayColor] CGColor];
            tileImageView.layer.borderWidth     = 1.0f;
            [tiles addObject:tileImageView];
            [tileImageView release];
        }
    }
}

- (void) shuffleTiles {
    NSMutableArray *shuffledArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < SHUFFLE_TIMES; i++) {
        [shuffledArray removeAllObjects];
        
        for (int j = 1; j < BOARD_SIZE + 1; j++) {
            for (int k = 1; k < BOARD_SIZE + 1; k++) {
                if ([engine isValidMove:CGPointMake(k, j)]) {
                    [shuffledArray addObject:[NSValue valueWithCGPoint:CGPointMake(k, j)]];
                }
            }
        }
        
        if ([shuffledArray count] > 0) {
            int pick = arc4random() % [shuffledArray count];
            CGPoint moveThisTile = [[shuffledArray objectAtIndex:pick] CGPointValue];            
            [self moveTileWithPoint:moveThisTile direction:DirectionNil finish:NO animation:NO];
        }
    }
    [shuffledArray release];
}

- (void) drawPuzzle {
    for (int i = 1; i < BOARD_SIZE + 1; i++) {
        for (int j = 1; j < BOARD_SIZE + 1; j++) {
            int tilePoint = [engine getTileFromPoint:CGPointMake(j, i)];
            if (tilePoint == 0) continue;
            
            UIImageView *tileImageView = [tiles objectAtIndex:tilePoint - 1];
            
            CGRect frame = CGRectMake(tileWidth * (i - 1), tileHeight * (j - 1), tileWidth, tileHeight);
            tileImageView.frame = frame;
            
            [self addSubview:tileImageView];
            [self sendSubviewToBack:tileImageView];
        }
    }
}


- (void) moveTileWithPoint:(CGPoint)point direction:(TileDirection)moveDirection finish:(BOOL)finish animation:(BOOL)animation {    
    moveDirection = (moveDirection == DirectionNil ? [engine getTileMoveDirection:point] : moveDirection);
    
    UIImageView *imageView = [self getTileImageAtPoint:point];
    int x = point.x;
    int y = point.y;
     
    switch (moveDirection) {
        case DirectionNone: 
            break;
        case DirectionUp:
            x = point.x;
            y = point.y - 1;
            break;
        case DirectionRight:
            x = point.x + 1;
            y = point.y ;
            break;
        case DirectionLeft:
            x = point.x - 1;
            y = point.y ;
            break;
        case DirectionDown:
            x = point.x;
            y = point.y + 1;
            break;
        default:
            break;
    }
    [engine replaceTileAtPoint:point withPoint:CGPointMake(x, y)];
    NSLog(@"PuzzleBoardView moveTileWithPoint: x(%f -> %i) y(%f -> %i)", point.x, x, point.y, y);
    
    if (animation) {
        [UIView animateWithDuration:0.3f 
                              delay:0.0 
                            options:UIViewAnimationCurveEaseOut 
                         animations:^ {
                             imageView.frame = CGRectMake((x - 1) * tileWidth, (y - 1) * tileHeight, imageView.frame.size.width, imageView.frame.size.height);
                         } 
                         completion:^ (BOOL finished) { 
                             isMovingTile           = NO;
                             imageView.transform    = CGAffineTransformIdentity;
                             imageView.frame        = CGRectMake((x - 1) * tileWidth, (y - 1) * tileHeight, imageView.frame.size.width, imageView.frame.size.height);
                             
                             if (finish) {
                                 if (moveDirection != DirectionNone) {
                                     steps = steps + 1;

                                     if (self.delegate != nil) {
                                         if ([self.delegate respondsToSelector:@selector(puzzleBoard:stepCount:)]) {
                                             [self.delegate puzzleBoard:self stepCount:steps];
                                         }
                                     }
                                     
                                     if ([engine isPuzzleFinished]) {
                                         [self setUserInteractionEnabled:NO];
                                         
                                         if (self.delegate != nil) {
                                             if ([self.delegate respondsToSelector:@selector(puzzleBoardFinished:)]) {
                                                 [self.delegate puzzleBoardFinished:self];
                                             }
                                         }
                                     }
                                 }
                             }
                             
                         }
         ];
    }
    else {
        isMovingTile           = NO;
        imageView.transform    = CGAffineTransformIdentity;
        imageView.frame        = CGRectMake((x - 1) * tileWidth, (y - 1) * tileHeight, imageView.frame.size.width, imageView.frame.size.height);
        
        if (finish) {
            if (moveDirection != DirectionNone) {
                steps = steps + 1;
                
                if (self.delegate != nil) {
                    if ([self.delegate respondsToSelector:@selector(puzzleBoard:stepCount:)]) {
                        [self.delegate puzzleBoard:self stepCount:steps];
                    }
                }
                
                if ([engine isPuzzleFinished]) {
                    [self setUserInteractionEnabled:NO];
                    
                    if (self.delegate != nil) {
                        if ([self.delegate respondsToSelector:@selector(puzzleBoardFinished:)]) {
                            [self.delegate puzzleBoardFinished:self];
                        }
                    }
                }
            }
        }
    }
}

- (UIImage *) cropImageFromFrame:(CGRect)frame {
    CGRect destFrame = CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height);
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGRect sourceFrame = CGRectMake(frame.origin.x * scale, frame.origin.y * scale, frame.size.width * scale, frame.size.height * scale);
    
    UIGraphicsBeginImageContextWithOptions(destFrame.size, NO, 0.0f);
    CGImageRef sourceImage = CGImageCreateWithImageInRect(boardImage.CGImage, sourceFrame);
    UIImage *newImage = [UIImage imageWithCGImage:sourceImage scale:0.0f orientation:boardImage.imageOrientation];
    [newImage drawInRect:destFrame];
    CGImageRelease(sourceImage);
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImageView *) getTileImageAtPoint:(CGPoint)point {
    UIImageView *tile = nil;
    for (UIImageView *tileImageView in tiles) {
        int x = (tileImageView.center.x / tileWidth) + 1;
        int y = (tileImageView.center.y / tileHeight) + 1;
        
        if (point.x == x && point.y == y) { 
            tile = tileImageView;
            break;
        }
    }
    return tile;
}

- (float) getXTransformFromPoint:(CGPoint)point withDirection:(TileDirection)direction {
    switch (direction) {
        case DirectionNone:             return 0.0f;
        case DirectionRight:
            if (point.x > tileWidth)    return tileWidth;
            else if (point.x < 0)       return 0.0f;
            else                        return point.x;
        case DirectionLeft:
            if (point.x < -tileWidth)   return -tileWidth;
            else if (point.x > 0)       return 0.0f;
            else                        return point.x;
        default:                        break;
    } 
    return 0.0f;
}

- (float) getYTransformFromPoint:(CGPoint)point withDirection:(TileDirection)direction {
    switch (direction) {
        case DirectionNone:             return 0.0f;
        case DirectionUp:
            if (point.y < -tileHeight)  return -tileHeight;
            else if (point.y > 0)       return 0.0f;
            else                        return point.y;
        case DirectionDown:
            if (point.y > tileHeight)   return tileHeight;
            else if (point.y < 0)       return 0.0f;
            else                        return point.y;
            break;
        default:                        break;
    }
    return 0.0f;
}

#pragma mark -
#pragma mark == Public Methods ==

- (void) playGame {
    [self resetValues];
    [self createTileImages];
    [self drawPuzzle];
    [self shuffleTiles];
    
    [self bringSubviewToFront:fullImage];
    [UIView animateWithDuration:0.5f 
                          delay:0.0f 
                        options:UIViewAnimationOptionAllowUserInteraction 
                     animations:^ { fullImage.alpha = 0.0f; } 
                     completion:^(BOOL finished) { [self setUserInteractionEnabled:YES]; }
     ];    
}

- (void) stopGame {
    [engine resetTiles];
    
    [self bringSubviewToFront:fullImage];
    [UIView animateWithDuration:0.5f 
                          delay:0.0f 
                        options:UIViewAnimationOptionAllowUserInteraction 
                     animations:^ { 
                         fullImage.alpha = 1.0f;
                     } 
                     completion:^(BOOL finished) {
                         [self setUserInteractionEnabled:NO];
                         
                         NSMutableArray *subviews = [NSMutableArray arrayWithArray:self.subviews];
                         [subviews removeObject:fullImage]; 
                         [subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                     }
     ];
}

#pragma mark -
#pragma mark == Gestures ==

- (void) dragging:(UIPanGestureRecognizer *)sender {  
    CGPoint dragPoint   = [sender locationInView:self];
    int dragX           = (dragPoint.x / tileWidth) + 1;
    int dragY           = (dragPoint.y / tileHeight) + 1;
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            if (!isMovingTile) {
                isMovingTile        = YES;
                draggingTiles       = [[engine getMovableTilesFromPoint:CGPointMake(dragX, dragY)] retain];
                draggingDirection   = [engine getMovableDirectionFromArray:draggingTiles];
            }
            break;
        case UIGestureRecognizerStateChanged:
            if (draggingTiles != nil) {
                for (NSValue *point in draggingTiles) {
                    UIImageView *tile = [self getTileImageAtPoint:[point CGPointValue]]; 
                    float x = [self getXTransformFromPoint:[sender translationInView:self] withDirection:draggingDirection];
                    float y = [self getYTransformFromPoint:[sender translationInView:self] withDirection:draggingDirection];
                    [tile setTransform:CGAffineTransformMakeTranslation(x, y)];
                }
            }            
            break;
        case UIGestureRecognizerStateEnded:
            if (draggingTiles != nil) {
                for (NSValue *point in draggingTiles) {
                    UIImageView *tile = [self getTileImageAtPoint:[point CGPointValue]];
                    
                    TileDirection direction = DirectionNone;
                    if (tile.transform.ty < -tileHeight/2) direction     = DirectionUp;
                    else if (tile.transform.tx > tileWidth/2) direction  = DirectionRight;
                    else if (tile.transform.tx < -tileWidth/2) direction = DirectionLeft;
                    else if (tile.transform.ty > tileHeight/2) direction = DirectionDown;
                    
                    [self moveTileWithPoint:[point CGPointValue] direction:direction finish:YES animation:YES];
                }
                
                [draggingTiles release];
                draggingTiles = nil;  
            } 
            isMovingTile = NO;
            break;
        default:
            break;
    }
}

- (void) tap:(UITapGestureRecognizer *)sender {
    if (!isMovingTile) {
        isMovingTile = YES;
        
        CGPoint tapPoint    = [sender locationInView:self];
        int tapX            = (tapPoint.x / tileWidth) + 1;
        int tapY            = (tapPoint.y / tileHeight) + 1;
        
        NSMutableArray *columns = [engine getMovableTilesFromPoint:CGPointMake(tapX, tapY)];
        for (NSValue *point in columns) {
            [self moveTileWithPoint:[point CGPointValue] direction:DirectionNil finish:YES animation:YES];
        }
    }
}

#pragma mark -
#pragma mark == Memory ==

- (void) dealloc {
    if (draggingTiles != nil) [draggingTiles release];
    self.delegate = nil;
    [boardImage release];
    [engine release];
    [fullImage release];
    [tiles release];
    [super dealloc];
}

@end
