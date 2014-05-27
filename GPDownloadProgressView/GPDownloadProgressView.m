//Copyright (c) 2014 Gleb Pinigin
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.

#import "GPDownloadProgressView.h"

#define kArrowSizeRatio .12
#define kStopSizeRatio  .3
#define kTickWidthRatio .3

@interface GPDownloadProgressView() {
    CAShapeLayer *_progressBackgroundLayer;
    CAShapeLayer *_progressLayer;
    CAShapeLayer *_iconLayer;

    BOOL _isSpinning;
}

@end

@implementation GPDownloadProgressView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.backgroundColor = [UIColor clearColor];
    
    _lineWidth = fmaxf(self.frame.size.width * 0.025, 1.f);
    _tintColor = [UIColor colorWithRed:0.f green:122.f/255.f blue:1.f alpha:1.f];
    _tickColor = [UIColor whiteColor];
    
    _progressBackgroundLayer = [CAShapeLayer layer];
    _progressBackgroundLayer.strokeColor = _tintColor.CGColor;
    _progressBackgroundLayer.fillColor = self.backgroundColor.CGColor;
    _progressBackgroundLayer.lineCap = kCALineCapRound;
    _progressBackgroundLayer.lineWidth = _lineWidth;
    [self.layer addSublayer:_progressBackgroundLayer];
    
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.strokeColor = _tintColor.CGColor;
    _progressLayer.fillColor = nil;
    _progressLayer.lineCap = kCALineCapSquare;
    _progressLayer.lineWidth = _lineWidth * 2.0;
    [self.layer addSublayer:_progressLayer];
    
    _iconLayer = [CAShapeLayer layer];
    _iconLayer.strokeColor = _tintColor.CGColor;
    _iconLayer.fillColor = nil;
    _iconLayer.lineCap = kCALineCapButt;
    _iconLayer.lineWidth = _lineWidth;
    _iconLayer.fillRule = kCAFillRuleNonZero;
    [self.layer addSublayer:_iconLayer];
}

#pragma mark - 

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    // TODO handle enabled alpha = 1.f/0.7f
}

#pragma mark - properties

- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor;
    _progressBackgroundLayer.strokeColor = tintColor.CGColor;
    _progressLayer.strokeColor = tintColor.CGColor;
    _iconLayer.strokeColor = tintColor.CGColor;
}

- (void)setTickColor:(UIColor *)tickColor {
    _tickColor = tickColor;
}

- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = fmaxf(lineWidth, 1.f);

    _progressBackgroundLayer.lineWidth = _lineWidth;
    _progressLayer.lineWidth = _lineWidth * 2.0;
    _iconLayer.lineWidth = _lineWidth;
}

- (void)setProgress:(CGFloat)progress {
    if (progress > 1.0) progress = 1.0;

    if (_progress != progress) {
        _progress = progress;

        if (_progress == 1.0) {
            [self animateProgressBackgroundLayerFillColor];
        }

        if (_progress == 0.0) {
            _progressBackgroundLayer.fillColor = self.backgroundColor.CGColor;
        }

        [self setNeedsDisplay];
    }
}

- (void)setPaused:(BOOL)paused {
    if (paused == _paused)
        return;

    _paused = paused;
    [self setNeedsDisplay];
}

#pragma mark - layouting

- (void)layoutSubviews {
    [super layoutSubviews];

    // Make sure the layers cover the whole view
    _progressBackgroundLayer.frame = self.bounds;
    _progressLayer.frame = self.bounds;
    _iconLayer.frame = self.bounds;
}

#pragma mark - drawing

- (void)drawRect:(CGRect)rect {
    [self drawBackgroundCircle:_isSpinning];
    [self drawProgress];
    
    if ([self progress] == 1.0) {
        [self drawTick];
    } else if (([self progress] > 0) && [self progress] < 1.0) {
        if (_paused) {
            [self drawPlay];
        } else {
            [self drawStop];
        }
    } else {
        [self drawArrow];
    }
}

- (void)drawProgress {
    CGFloat startAngle = - (M_PI_2);
    CGFloat endAngle = startAngle + (2 * M_PI * self.progress);
    CGFloat radius = (self.bounds.size.width - 3 * _lineWidth) / 2.0;

    CGMutablePathRef progressPath = CGPathCreateMutable();
    CGPathAddArc(progressPath, NULL, CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds),
                 radius, startAngle, endAngle, NO);

    [_progressLayer setPath:progressPath];
    CGPathRelease(progressPath);
}

- (void) drawBackgroundCircle:(BOOL) partial {
    CGFloat startAngle = - (M_PI_2);

    CGFloat koef = partial? 1.8f: 2.f;
    CGFloat endAngle = (koef * M_PI) + startAngle;
    CGFloat radius = (self.bounds.size.width - _lineWidth)/2;

    CGMutablePathRef circlePath = CGPathCreateMutable();
    CGPathAddArc(circlePath, NULL, CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds),
                 radius, startAngle, endAngle, YES);

    _progressBackgroundLayer.path = circlePath;
    CGPathRelease(circlePath);
}

- (void) drawTick {
    CGFloat radius = MIN(self.frame.size.width, self.frame.size.height)/2;
    
    /*
     First draw a tick that looks like this:
     
     A---F
     |   |
     |   E-------D
     |           |
     B-----------C
     
     (Remember: (0,0) is top left)
     */
    UIBezierPath *tickPath = [UIBezierPath bezierPath];
    CGFloat tickWidth = radius * kTickWidthRatio;
    [tickPath moveToPoint:CGPointMake(0, 0)];                            // A
    [tickPath addLineToPoint:CGPointMake(0, tickWidth * 2)];             // B
    [tickPath addLineToPoint:CGPointMake(tickWidth * 3, tickWidth * 2)]; // C
    [tickPath addLineToPoint:CGPointMake(tickWidth * 3, tickWidth)];     // D
    [tickPath addLineToPoint:CGPointMake(tickWidth, tickWidth)];         // E
    [tickPath addLineToPoint:CGPointMake(tickWidth, 0)];                 // F
    [tickPath closePath];
    
    // Now rotate it through -45 degrees...
    [tickPath applyTransform:CGAffineTransformMakeRotation(-M_PI_4)];
    
    // ...and move it into the right place.
    [tickPath applyTransform:CGAffineTransformMakeTranslation(radius * .46, 1.02 * radius)];
    
    [_iconLayer setPath:tickPath.CGPath];
    [_iconLayer setFillColor:self.tickColor.CGColor];
    [_progressBackgroundLayer setFillColor:_progressLayer.strokeColor];
}

- (void) drawStop {
    CGFloat radius = (self.bounds.size.width)/2;
    CGFloat ratio = kStopSizeRatio;
    CGFloat sideSize = self.bounds.size.width * ratio;
    
    UIBezierPath *stopPath = [UIBezierPath bezierPath];
    [stopPath moveToPoint:CGPointMake(0, 0)];
    [stopPath addLineToPoint:CGPointMake(sideSize, 0.0)];
    [stopPath addLineToPoint:CGPointMake(sideSize, sideSize)];
    [stopPath addLineToPoint:CGPointMake(0.0, sideSize)];
    [stopPath closePath];
    
    // ...and move it into the right place.
    [stopPath applyTransform:CGAffineTransformMakeTranslation(radius * (1-ratio), radius* (1-ratio))];
    
    [_iconLayer setPath:stopPath.CGPath];
    [_iconLayer setStrokeColor:_progressLayer.strokeColor];
    [_iconLayer setFillColor:self.tintColor.CGColor];
}

- (void)drawPlay {
    CGFloat radius = (self.bounds.size.width)/2;
    CGFloat ratio = kStopSizeRatio;
    CGFloat sideSize = self.bounds.size.width * ratio;

    UIBezierPath *stopPath = [UIBezierPath bezierPath];
    [stopPath moveToPoint:CGPointMake(0, 0)];
    [stopPath addLineToPoint:CGPointMake(sideSize, sideSize / 2.f)];
    [stopPath addLineToPoint:CGPointMake(0.0, sideSize)];
    [stopPath closePath];

    // ...and move it into the right place.
    [stopPath applyTransform:CGAffineTransformMakeTranslation(radius * (1-ratio), radius* (1-ratio))];

    [_iconLayer setPath:stopPath.CGPath];
    [_iconLayer setStrokeColor:_progressLayer.strokeColor];
    [_iconLayer setFillColor:self.tintColor.CGColor];
}

- (void) drawArrow {
    CGFloat radius = (self.bounds.size.width)/2;
    CGFloat ratio = kArrowSizeRatio;
    CGFloat segmentSize = self.bounds.size.width * ratio;

    // Draw icon
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0.0, 0.0)];
    [path addLineToPoint:CGPointMake(segmentSize * 2.0, 0.0)];
    [path addLineToPoint:CGPointMake(segmentSize * 2.0, segmentSize)];
    [path addLineToPoint:CGPointMake(segmentSize * 3.0, segmentSize)];
    [path addLineToPoint:CGPointMake(segmentSize, segmentSize * 3.3)];
    [path addLineToPoint:CGPointMake(-segmentSize, segmentSize)];
    [path addLineToPoint:CGPointMake(0.0, segmentSize)];
    [path addLineToPoint:CGPointMake(0.0, 0.0)];
    [path closePath];

    [path applyTransform:CGAffineTransformMakeTranslation(-segmentSize /2.0, -segmentSize / 1.2)];
    [path applyTransform:CGAffineTransformMakeTranslation(radius * (1-ratio), radius* (1-ratio))];
    _iconLayer.path = path.CGPath;
    _iconLayer.fillColor = nil;
}

#pragma mark - initial animation

- (void) animateProgressBackgroundLayerFillColor {
    CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"fillColor"];
    
    colorAnimation.duration = .5;
    colorAnimation.repeatCount = 1.0;
    colorAnimation.removedOnCompletion = NO;
    
    colorAnimation.fromValue = (__bridge id) _progressBackgroundLayer.backgroundColor;
    colorAnimation.toValue = (__bridge id) _progressLayer.strokeColor;
    
    colorAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    [_progressBackgroundLayer addAnimation:colorAnimation forKey:@"colorAnimation"];
}

- (void) startAnimating {
    _isSpinning = YES;
    [self drawBackgroundCircle:YES];
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    rotationAnimation.duration = 1;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    [_progressBackgroundLayer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void) stopAnimating {
    [self drawBackgroundCircle:NO];
    
    [_progressBackgroundLayer removeAllAnimations];
    _isSpinning = NO;
}

@end
