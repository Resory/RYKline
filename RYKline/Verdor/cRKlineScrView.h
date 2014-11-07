//
//  cRKlineScrView.h
//  RYKline
//
//  Created by Resory on 14/11/7.
//  Copyright (c) 2014年 Resory. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cRShapeView.h"

@interface cRKlineScrView : UIScrollView
{
    cRShapeView *pathShapeView;
}
@property (nonatomic, strong) UIBezierPath *bezierKlinePath;
@property (nonatomic, strong) UIBezierPath *bezierFramePath;
@property (nonatomic, strong) UIBezierPath *bezierDotPath;
@property (nonatomic, strong) cRShapeView  *shapeKline;
@property (nonatomic, strong) cRShapeView  *shapeFrame;
@property (nonatomic, strong) cRShapeView  *shapeDot;
@property (nonatomic, strong) NSArray      *kLineData;
@property (nonatomic, strong) NSArray      *klineDate;
@property (nonatomic, assign) CGFloat       klineWidthSpace;

@property (nonatomic, strong) UIView       *hideView;
@property (nonatomic, strong) UIView       *hideBgView;
@property (nonatomic, strong) UIView       *BottomLineView;
@property (nonatomic, assign) BOOL          isDrawing;

@end
