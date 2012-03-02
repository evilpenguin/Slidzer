//
//  SLImage.h
//  Slidzer
//
//  Created by iPhone 4 on 2/11/12.
//  Copyright (c) 2012 NakedProductions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SLImage : UIImage {
    
}

- (UIImage *)resizedImageWithSize:(CGSize)size;
- (UIImage *)cropImageFromFrame:(CGRect)frame;
@end
