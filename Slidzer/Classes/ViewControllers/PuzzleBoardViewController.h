//
//  PuzzleBoardViewController.h
//  Slidzer
//
//  Created by James Emrich on 2/11/12.
//  Copyright (c) 2012 James Emrich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PuzzleBoardView.h"

typedef enum {
    StartType = 0,
    StopType  = 1
} ButtonTypes;

@interface PuzzleBoardViewController : UIViewController <PuzzleBoardViewDelegate> {
    UIButton        *startButton;
    UILabel         *finishedLabel;
    UILabel         *stepsLabel;
    PuzzleBoardView *boardView;
}

- (id) initWithFrame:(CGRect)frame;
@end
