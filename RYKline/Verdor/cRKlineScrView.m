//
//  cRKlineScrView.m
//  RYKline
//
//  Created by Resory on 14/11/7.
//  Copyright (c) 2014年 Resory. All rights reserved.
//

#import "cRKlineScrView.h"

@import CoreText;

#define kDuration 3
#define kLineColor [UIColor colorWithRed:51/255.0 green:102/255.0f blue:184/255.0 alpha:1.0f]

@implementation cRKlineScrView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.contentMode = UIViewContentModeRedraw;
        
        _bezierKlinePath = [[UIBezierPath alloc] init];
        _bezierFramePath = [[UIBezierPath alloc] init];
        _bezierDotPath   = [[UIBezierPath alloc] init];
        
        _shapeKline = [[cRShapeView alloc] init];
        _shapeFrame = [[cRShapeView alloc] init];
        _shapeDot   = [[cRShapeView alloc] init];
        
        [self addSubview:_shapeFrame];
        [self addSubview:_shapeKline];
        [self addSubview:_shapeDot];
        
        _hideBgView = [[UIView alloc] init];
        _hideBgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_hideBgView];
        
        _hideView = [[UIView alloc] init];
        _hideView.backgroundColor = [UIColor whiteColor];
        
        _BottomLineView = [[UIView alloc] init];
        _BottomLineView.backgroundColor = [UIColor colorWithRed:127/255.0 green:127/255.0 blue:127/255.0 alpha:1.0];

    }
    return self;
}

- (void)awakeFromNib
{
    
}

- (void)drawRect:(CGRect)rect
{
    
}

- (void)setContentSize:(CGSize)contentSize
{
    [super setContentSize:contentSize];
    
    //遮盖底部view
    _hideBgView.frame = CGRectMake(0, self.frame.size.height - 20, contentSize.width, 20);
    //遮盖view
    _hideView.frame = CGRectMake(0, 0, _hideBgView.frame.size.width, _hideBgView.frame.size.height);
}

#pragma mark - 设置数据
//画房价走势
- (void)setKLineData:(NSArray *)kLineData
{
    _kLineData = kLineData;
    self.isDrawing = YES;
    
    // scrollview滚动
    [self scrollToTail];
    
    // 动态画竖线
    [self drawKlineBackGround];
    
    // 画K线图
    [self drawKline];
    
    // 画圆点
    [self drawDot];
}

// 设置K线底部日期
- (void)setKlineDate:(NSArray *)klineDate
{
    if(!_klineDate)
    {
        _klineDate = klineDate;
        
        for (int i = 0; i < _klineDate.count; i++)
        {
            NSValue *value = [_kLineData objectAtIndex:i];
            
            CGPoint point = [value CGPointValue];
            
            UILabel *dateLB = [[UILabel alloc] initWithFrame:CGRectMake(point.x - _klineWidthSpace/2.0, 0, _klineWidthSpace, 20)];
            
            dateLB.text = [_klineDate objectAtIndex:i];
            
            dateLB.textAlignment = NSTextAlignmentCenter;
            
            dateLB.textColor = [UIColor colorWithRed:127/255.0 green:127/255.0 blue:127/255.0 alpha:1.0];
            
            dateLB.font = [UIFont systemFontOfSize:10.0];
            
            dateLB.backgroundColor = [UIColor whiteColor];
            
            [_hideBgView addSubview:dateLB];
        }
        
        //底部遮住dateLB的view.
        [_hideBgView addSubview:_hideView];
    }
}

#pragma mark - 画框架

- (void)drawKlineBackGround
{
    // CAShapeLayer上加动画
    _shapeFrame.shapeLayer.fillColor = nil;
    _shapeFrame.shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    _shapeFrame.shapeLayer.lineWidth = 2.0;
    
    // 创建动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
    animation.fromValue = @0.0;
    animation.toValue = @1.0;
    animation.duration = kDuration ;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    
    // 把要画得路径加到CAShapeLayer上
    [self baseFramePath];
    
    // CAShapeLayer上加动画
    [_shapeFrame.shapeLayer addAnimation:animation forKey:NSStringFromSelector(@selector(strokeEnd))];
}

- (void)baseFramePath
{
    for (int i = 0; i < _kLineData.count; i++)
    {
        NSValue *value = [_kLineData objectAtIndex:i];
        
        CGPoint point = [value CGPointValue];
    
        [_bezierFramePath moveToPoint:CGPointMake(point.x, 0)];
        
        [_bezierFramePath addLineToPoint:CGPointMake(point.x, self.frame.size.height -20)];
    }
    
    _shapeFrame.shapeLayer.path = _bezierFramePath.CGPath;
    
}

#pragma mark - 画K线

- (void)drawKline
{
    // CAShapeLayer上加动画
    _shapeKline.shapeLayer.fillColor = [UIColor clearColor].CGColor;
    _shapeKline.shapeLayer.strokeColor = kLineColor.CGColor;
    
    // 创建动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
    animation.fromValue = @0.0;
    animation.toValue = @1.0;
    animation.duration = kDuration ;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    
    // 把要画得路径加到CAShapeLayer上
    [self klinePath];
    
    // CAShapeLayer上加动画
    [_shapeKline.shapeLayer addAnimation:animation forKey:NSStringFromSelector(@selector(strokeEnd))];
    
    NSLog(@"NSStringFromSelector = %@",NSStringFromSelector(@selector(strokeEnd)));
}

- (void)klinePath
{
    // K线路线
    for (int i = 0; i < _kLineData.count; i++)
    {
        NSValue *value = [_kLineData objectAtIndex:i];
        
        CGPoint point = [value CGPointValue];
        
        if(i == 0)
        {
            [_bezierKlinePath moveToPoint:CGPointMake(point.x, point.y)];
        }
        else
        {
            [_bezierKlinePath addLineToPoint:CGPointMake(point.x, point.y)];
        }
    }
    
    _shapeKline.shapeLayer.path = _bezierKlinePath.CGPath;
    
}

#pragma mark - 画圆点
- (void)drawDot
{
    // CAShapeLayer上加动画
    _shapeDot.shapeLayer.fillColor = [UIColor whiteColor].CGColor;
    _shapeDot.shapeLayer.strokeColor = kLineColor.CGColor;
    
    // 创建动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
    animation.fromValue = @0.0;
    animation.toValue = @1.0;
    animation.duration = kDuration ;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    
    // 把要画得路径加到CAShapeLayer上
    [self dotPath];
    
    // CAShapeLayer上加动画
    [_shapeDot.shapeLayer addAnimation:animation forKey:NSStringFromSelector(@selector(strokeEnd))];
}

- (void)dotPath
{
    for (int i = 0; i < _kLineData.count; i++)
    {
        NSValue *value = [_kLineData objectAtIndex:i];
        
        CGPoint point = [value CGPointValue];
        
        UIBezierPath *tempBezierPath = [UIBezierPath bezierPathWithArcCenter:point radius:4.0 startAngle:0 endAngle:2*M_PI clockwise:YES];
        
        [_bezierDotPath appendPath:tempBezierPath];
    }

    _shapeDot.shapeLayer.path = _bezierDotPath.CGPath;
}

#pragma mark - scrollView animation
- (void)scrollToTail
{
    _hideView.alpha = 1.0;
    
    [UIView animateWithDuration:3.0 animations:^{
        if(self.contentSize.width > 320)
        {
            //如果宽度大于320,则需要移动,移动位置到数据的一半
            self.contentOffset = CGPointMake(self.contentSize.width - 320, 0);
        }
        //移动遮盖
        CGRect frame = _hideView.frame;
        frame.origin.x = frame.origin.x + self.contentSize.width;
        _hideView.frame = frame;
        
    } completion:^(BOOL finished) {
        if(finished)
        {
            //恢复遮盖位置
            CGRect frame = _hideView.frame;
            frame.origin.x = 0;
            _hideView.frame = frame;
            _hideView.alpha = 0.0;
            
            [UIView animateWithDuration:0.5 animations:^{
                self.contentOffset = CGPointMake(0, 0);
            }];
            
            self.isDrawing = NO;
        }
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
