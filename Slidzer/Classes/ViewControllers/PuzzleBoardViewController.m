//
//  PuzzleBoardViewController.m
//  Slidzer
//
//  Created by James Emrich on 2/11/12.
//  Copyright (c) 2012 James Emrich. All rights reserved.
//

#import "PuzzleBoardViewController.h"

@interface PuzzleBoardViewController (Private)
    - (void) start:(id)sender;
    - (void) shakePuzzleBoardView;
@end

@implementation PuzzleBoardViewController

#pragma mark -
#pragma mark == PuzzleBoardViewController

- (id) initWithFrame:(CGRect)frame {
    if (self = [super init]) {
        self.view.frame                 = frame;
        self.view.backgroundColor       = [UIColor scrollViewTexturedBackgroundColor];
        self.view.autoresizingMask      = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.view.autoresizesSubviews   = YES;
        
        boardView = [[PuzzleBoardView alloc] initWithFrame:CGRectMake((frame.size.width - 270.0f)/2.0f, -270.0f, 270.0f, 270.0f) image:[UIImage imageNamed:@"UIE_Slider_Puzzle--globe.jpg"]];
        boardView.delegate = self;
        [self.view addSubview:boardView];
        
        finishedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 3.0f, self.view.frame.size.width, 20.0f)];
        finishedLabel.backgroundColor = [UIColor clearColor];
        finishedLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        finishedLabel.textColor = [UIColor blackColor];
        finishedLabel.textAlignment = UITextAlignmentCenter;
        finishedLabel.alpha = 0.0f;
        [self.view addSubview:finishedLabel];
        
        stepsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 20.0f)];
        [stepsLabel setCenter:CGPointMake(self.view.frame.size.width/2.0f, (boardView.frame.size.height + 25.0f + stepsLabel.frame.size.height/2.0f))];
        stepsLabel.backgroundColor = [UIColor clearColor];
        stepsLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        stepsLabel.text = @"0 Steps";
        stepsLabel.textColor = [UIColor blackColor];
        stepsLabel.textAlignment = UITextAlignmentCenter;
        stepsLabel.alpha = 0.0f;
        [self.view addSubview:stepsLabel];

        startButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [startButton setFrame:CGRectMake(0.0f, 0.0f, 100.0f, 30.0f)];
        [startButton setCenter:CGPointMake(self.view.frame.size.width/2.0f, (self.view.frame.size.height + startButton.frame.size.height/2.0f))];
        [startButton setTitle:@"Start Game" forState:UIControlStateNormal];
        [startButton setTag:StartType];
        [startButton addTarget:self action:@selector(start:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:startButton];
                
        [UIView animateWithDuration:0.5f
                              delay:0.0 
                            options:UIViewAnimationOptionAllowUserInteraction 
                         animations:^ { 
                             boardView.frame = CGRectMake((frame.size.width - 270.0f)/2.0f, 25.0f, 270.0f, 270.0f);
                             [startButton setCenter:CGPointMake(self.view.frame.size.width/2.0f, (self.view.frame.size.height - startButton.frame.size.height/2.0f) - 50.0f)];
                         }
                         completion:^(BOOL finished) { }
         ];
    }
    return self;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

#pragma mark -
#pragma mark == Private Methods ==

- (void) start:(id)sender {
    switch (startButton.tag) {
        case StartType:
            [boardView playGame];
            
            stepsLabel.text = @"0 Steps";
            [startButton setTitle:@"Reset Game" forState:UIControlStateNormal];
            [startButton setTag:StopType];
            
            [UIView animateWithDuration:0.5f 
                             animations:^{ 
                                 finishedLabel.alpha = 0.0f; 
                                 stepsLabel.alpha = 1.0f;
                             }
             ];
            break;
        case StopType:
            [boardView stopGame];
            
            stepsLabel.text = @"0 Steps";
            [startButton setTitle:@"Start Game" forState:UIControlStateNormal];
            [startButton setTag:StartType];
            
            [UIView animateWithDuration:0.5f 
                             animations:^{ 
                                 finishedLabel.alpha = 0.0f; 
                             }];
        default:
            break;
    }
    
}

- (void) shakePuzzleBoardView {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.05f];
    [animation setRepeatCount:8];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:CGPointMake(boardView.center.x - 5.0f, boardView.center.y)]];
    [animation setToValue:[NSValue valueWithCGPoint:CGPointMake(boardView.center.x + 5.0f, boardView.center.y)]];
    [boardView.layer addAnimation:animation forKey:@"position"];
}

#pragma mark -
#pragma mark == PuzzleBoardViewDelegate ==

- (void) puzzleBoardFinished:(id)board {
    [boardView stopGame];
    
    [startButton setTitle:@"Start Game" forState:UIControlStateNormal];
    [startButton setTag:StartType];
    [startButton setEnabled:NO];
    
    [UIView animateWithDuration:0.5f 
                     animations:^{ 
                         finishedLabel.alpha = 1.0f; 
                         stepsLabel.alpha = 0.0f;
                     }
                     completion:^ (BOOL finished) {
                         [self shakePuzzleBoardView];
                         [startButton setEnabled:YES];
                     }
     ];
}

- (void) puzzleBoard:(id)board stepCount:(int)count {
    NSLog(@"PuzzleBoardViewController StepCount: %i", count); 
    stepsLabel.text = [NSString stringWithFormat:@"%i Steps", count];
    finishedLabel.text = [NSString stringWithFormat:@"Slidzer Puzzle Completed in %i steps!!!", count];
}

#pragma -
#pragma mark == Memory ==

- (void) dealloc {
    boardView.delegate = nil;
    [boardView release];
    startButton = nil;
    [finishedLabel release];
    [stepsLabel release];
    [super dealloc];
}

@end
