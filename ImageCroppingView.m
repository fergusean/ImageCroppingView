//
//  CroppingImageView.m
//  CroppingImageView
//
//  Copyright (c) 2013 Signal24, Inc. All rights reserved.
//

#import "ImageCroppingView.h"

@implementation ImageCroppingView

- (id)init {
    self = [super init];
    
    _cropRect = CGRectMake(15, 15, 150, 150);
    
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = YES;
        
    return self;
}

- (void)attachToView:(UIView *)view {
    self.frame = CGRectMake(view.frame.origin.x - 15, view.frame.origin.y - 15, view.bounds.size.width + 30, view.bounds.size.height + 30);
    
    _attachedView = view;
    
    [view.superview insertSubview:self aboveSubview:view];
}

- (void)detachFromView {
    _attachedView = nil;
    [self removeFromSuperview];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    CGPoint location = [touch locationInView:_attachedView];
    
    CGPoint topLeft = CGPointMake(_cropRect.origin.x, _cropRect.origin.y);
    CGPoint topRight = CGPointMake(_cropRect.origin.x + _cropRect.size.width, _cropRect.origin.y);
    CGPoint bottomLeft = CGPointMake(_cropRect.origin.x, _cropRect.origin.y + _cropRect.size.height);
    CGPoint bottomRight = CGPointMake(_cropRect.origin.x + _cropRect.size.width, _cropRect.origin.y + _cropRect.size.height);
    
    // top left
    if (location.x > topLeft.x - 15 && location.x < topLeft.x + 15 && location.y > topLeft.y - 15 && location.y < topLeft.y + 15) {
        _touchType = 1;
    }
    
    // top right
    else if (location.x > topRight.x - 15 && location.x < topRight.x + 15 && location.y > topRight.y - 15 && location.y < topRight.y + 15) {
        _touchType = 2;
    }
    
    // bottom left
    else if (location.x > bottomLeft.x - 15 && location.x < bottomLeft.x + 15 && location.y > bottomLeft.y - 15 && location.y < bottomLeft.y + 15) {
        _touchType = 3;
    }
    
    // bottom right
    else if (location.x > bottomRight.x - 15 && location.x < bottomRight.x + 15 && location.y > bottomRight.y - 15 && location.y < bottomRight.y + 15) {
        _touchType = 4;
    }
    
    // drag
    else if (location.x > topLeft.x && location.x < topRight.x && location.y > topLeft.y && location.y < bottomLeft.y) {
        _touchType = 5;
        _touchStartOffset = CGPointMake(location.x - topLeft.x, location.y - topLeft.y);
    }
    
    // outside the box
    else {
        return;
    }
    
    _touch = touch;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![touches containsObject:_touch])
        return;
    
    CGPoint previousLocation = [_touch previousLocationInView:_attachedView];
    
    CGPoint location = [_touch locationInView:_attachedView];
    
    CGPoint offset = CGPointMake(location.x - previousLocation.x, location.y - previousLocation.y);
    
    CGPoint topLeft = CGPointMake(_cropRect.origin.x, _cropRect.origin.y);
    CGPoint topRight = CGPointMake(_cropRect.origin.x + _cropRect.size.width, _cropRect.origin.y);
    CGPoint bottomLeft = CGPointMake(_cropRect.origin.x, _cropRect.origin.y + _cropRect.size.height);
    CGPoint bottomRight = CGPointMake(_cropRect.origin.x + _cropRect.size.width, _cropRect.origin.y + _cropRect.size.height);
    
    CGRect newRect = _cropRect;
    
    // top left
    if (_touchType == 1) {
        if (!(offset.x > 0 && location.x < 0) &&
            !(offset.x < 0 && location.x > topLeft.x)) {
            newRect.origin.x = MAX(0, newRect.origin.x + offset.x);
            newRect.size.width += _cropRect.origin.x - newRect.origin.x;
        }
        if (!(offset.y > 0 && location.y < 0) &&
            !(offset.y < 0 && location.y > topLeft.y)) {
            newRect.origin.y = MAX(0, newRect.origin.y + offset.y);
            newRect.size.height += _cropRect.origin.y - newRect.origin.y;
        }
    }
    
    // top right
    else if (_touchType == 2) {
        if (!(offset.x < 0 && location.x > _attachedView.bounds.size.width) &&
            !(offset.x > 0 && location.x < topRight.x) &&
            topRight.x + offset.x <= _attachedView.bounds.size.width) {
            newRect.size.width += offset.x;
        }
        if (!(offset.y > 0 && location.y < 0) &&
            !(offset.y < 0 && location.y > topRight.y)) {
            newRect.origin.y = MAX(0, newRect.origin.y + offset.y);
            newRect.size.height += _cropRect.origin.y - newRect.origin.y;
        }
    }
    
    // bottom left
    else if (_touchType == 3) {
        if (!(offset.x > 0 && location.x < 0) &&
            !(offset.x < 0 && location.x > bottomLeft.x)) {
            newRect.origin.x = MAX(0, newRect.origin.x + offset.x);
            newRect.size.width += _cropRect.origin.x - newRect.origin.x;
        }
        if (!(offset.y < 0 && location.y > _attachedView.bounds.size.height) &&
            !(offset.y > 0 && location.y < bottomLeft.y) &&
            bottomLeft.y + offset.y <= _attachedView.bounds.size.height) {
            newRect.size.height += offset.y;
        }
    }
    
    // bottom right
    else if (_touchType == 4) {
        if (!(offset.x < 0 && location.x > _attachedView.bounds.size.width) &&
            !(offset.x > 0 && location.x < bottomRight.x) &&
            bottomRight.x + offset.x <= _attachedView.bounds.size.width) {
            newRect.size.width += offset.x;
        }
        if (!(offset.y < 0 && location.y > _attachedView.bounds.size.height) &&
            !(offset.y > 0 && location.y < bottomRight.y) &&
            bottomRight.y + offset.y <= _attachedView.bounds.size.height) {
            newRect.size.height += offset.y;
        }
    }
    
    // drag
    else {
        newRect.origin.x = MIN(MAX(0, location.x - _touchStartOffset.x), _attachedView.bounds.size.width - newRect.size.width);
        newRect.origin.y = MIN(MAX(0, location.y - _touchStartOffset.y), _attachedView.bounds.size.height - newRect.size.height);
        _cropRect = newRect;
        [self setNeedsDisplay];
        return;
    }
    
    if (self.ratio != 0) {
        if (ABS(offset.y) > ABS(offset.x)) {
            newRect.size.height = newRect.size.width / self.ratio;
        } else {
            newRect.size.width = newRect.size.height * self.ratio;
        }
        
        if (_touchType == 1) {
            newRect.origin.x = _cropRect.origin.x + (_cropRect.size.width - newRect.size.width);
            newRect.origin.y = _cropRect.origin.y + (_cropRect.size.height - newRect.size.height);
        } else if (_touchType == 2) {
            newRect.origin.y = _cropRect.origin.y + (_cropRect.size.height - newRect.size.height);
        } else if (_touchType == 3) {
            newRect.origin.x = _cropRect.origin.x + (_cropRect.size.width - newRect.size.width);
        }
        
        if (newRect.origin.y < 0)
            return;
        if (newRect.origin.x < 0)
            return;
        
        if (newRect.origin.y + newRect.size.height > _attachedView.bounds.size.height)
            return;
        if (newRect.origin.x + newRect.size.width > _attachedView.bounds.size.width)
            return;
        
        if (newRect.size.width < self.minWidth || newRect.size.height < self.minHeight)
            return;
    }
    
    else {
        if (newRect.size.width < self.minWidth) {
            newRect.origin.x = _cropRect.origin.x;
            newRect.size.width = _cropRect.size.width;
        }
        
        if (newRect.size.height < self.minHeight) {
            newRect.origin.y = _cropRect.origin.y;
            newRect.size.height = _cropRect.size.height;
        }
    }
    
    _cropRect = newRect;
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([touches containsObject:_touch])
        _touch = nil;
}

- (void)drawRect:(CGRect)rect {
    CGFloat y = _cropRect.origin.y;
    CGFloat x = _cropRect.origin.x;
    CGFloat w = _attachedView.bounds.size.width;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.0 alpha:0.75].CGColor);
    
    CGContextFillRect(context, CGRectMake(15, 15, w, y));
    CGContextFillRect(context, CGRectMake(15, y + _cropRect.size.height + 15, w, self.bounds.size.height - y + _cropRect.size.height));
    
    CGContextFillRect(context, CGRectMake(15, y + 15, x, _cropRect.size.height));
    CGContextFillRect(context, CGRectMake(x + _cropRect.size.width + 15, y + 15, self.bounds.size.width - x + _cropRect.size.width, _cropRect.size.height));
    
    CGFloat dashes[] = { 2, 2 };
    CGContextSetStrokeColorWithColor(context,[UIColor whiteColor].CGColor);
    CGContextSetLineDash(context, 0.0, dashes, 2);
    CGContextStrokeRect(context, CGRectMake(_cropRect.origin.x + 15, _cropRect.origin.y + 15, _cropRect.size.width, _cropRect.size.height));
    
    CGPoint lines[4];
    
    lines[0] = CGPointMake(x + (_cropRect.size.width / 2) + 15, y + 15);
    lines[1] = CGPointMake(x + (_cropRect.size.width / 2) + 15, y + (_cropRect.size.height) + 15);
    
    lines[2] = CGPointMake(x + 15, y + (_cropRect.size.height / 2) + 15);
    lines[3] = CGPointMake(x + _cropRect.size.width + 15, y + (_cropRect.size.height / 2) + 15);
    
    CGContextStrokeLineSegments(context, lines, 4);
    
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 0.9);
    CGContextFillEllipseInRect(context, CGRectMake(_cropRect.origin.x, _cropRect.origin.y, 30, 30));
    CGContextFillEllipseInRect(context, CGRectMake(_cropRect.origin.x + _cropRect.size.width, _cropRect.origin.y, 30, 30));
    CGContextFillEllipseInRect(context, CGRectMake(_cropRect.origin.x, _cropRect.origin.y + _cropRect.size.height, 30, 30));
    CGContextFillEllipseInRect(context, CGRectMake(_cropRect.origin.x + _cropRect.size.width, _cropRect.origin.y + _cropRect.size.height, 30, 30));
    
    CGContextRestoreGState(context);
}

@end