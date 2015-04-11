//
//  CroppingImageView.h
//  CroppingImageView
//
//  Copyright (c) 2013 Signal24, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class ImageCroppingViewLayerDelegate;

@interface ImageCroppingView : UIView {
    UIView *_attachedView;
    CGRect _cropRect;
    UITouch *_touch;
    NSInteger _touchType;
    CGPoint _touchStartOffset;
}

@property (nonatomic) CGRect cropRect;
@property (nonatomic) CGFloat minWidth;
@property (nonatomic) CGFloat minHeight;
@property (nonatomic) CGFloat ratio;

- (void)attachToView:(UIView *)view;
- (void)detachFromView;

@end