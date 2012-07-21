//
//  DrawPatternLockView.m
//  AndroidLock
//
//  Created by Purnama Santo on 11/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DrawPatternLockView.h"
#define kDotViewsInitCapacity 10

@implementation DrawPatternLockView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _trackdedPoint = CGPointZero;
    }
    
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    NSLog(@"drawrect...");
    
    if (_trackdedPoint.x == 0 && _trackdedPoint.y == 0)
        return;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 10.0);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = {0, 0, 1, 1};//{0.5, 0.5, 0.5, 0.8};
    CGColorRef color = CGColorCreate(colorspace, components);
    CGContextSetStrokeColorWithColor(context, color);
    
    CGPoint from;
    UIView *lastDot;
    NSLog(@"dotViews retainCount:%d",[_dotViews retainCount]);
    for (UIView *dotView in _dotViews) {
        from = dotView.center;
        NSLog(@"drwaing dotview: %@", dotView);
        NSLog(@"\tdrawing from: %f, %f", from.x, from.y);
        
        if (!lastDot)
            CGContextMoveToPoint(context, from.x, from.y);
        else
            CGContextAddLineToPoint(context, from.x, from.y);
        
        lastDot = dotView;
    }
    
    CGPoint pt = _trackdedPoint;
    NSLog(@"\t to: %f, %f", pt.x, pt.y);
    CGContextAddLineToPoint(context, pt.x, pt.y);
    
    CGContextStrokePath(context);
    CGColorSpaceRelease(colorspace);
    CGColorRelease(color);
    
     _trackdedPoint = CGPointZero;
}


- (void)clearDotViews {
    [_dotViews removeAllObjects];
    [_dotViews release];
    _dotViews = nil;
}


- (void)addDotView:(UIView *)view {
    if (!_dotViews)
        _dotViews = [[NSMutableArray alloc]initWithCapacity:kDotViewsInitCapacity];
    
    [_dotViews addObject:view];
}


- (void)drawLineFromLastDotTo:(CGPoint)pt {
    _trackdedPoint = pt;
    [self setNeedsDisplay];
}


@end
