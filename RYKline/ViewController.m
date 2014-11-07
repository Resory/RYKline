//
//  ViewController.m
//  RYKline
//
//  Created by Resory on 14/11/7.
//  Copyright (c) 2014年 Resory. All rights reserved.
//

#import "ViewController.h"
#import "cRKlineScrView.h"

// K线间隔宽度
#define KLINEWIDTHSPACE 50

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *pathPointArr;         //K线点位置数组
@property (nonatomic, strong) NSMutableArray *dateArr;              //点对应的日期
@property (nonatomic, strong) NSMutableArray *scaleArr;             //刻度日期
@property (nonatomic, assign) CGFloat         klineToLeftWidth;     //K线图距离左边距离,左边留给价格显示
@property (nonatomic, assign) NSInteger       klineHeightspace;     //价格刻度间距
@property (nonatomic, assign) NSInteger       maxHeightPrice;       //最高值价格
@property (nonatomic, assign) NSInteger       minHeightPrice;       //最低值价格
@property (nonatomic, assign) BOOL            DrawOneTime;          //底部和侧边栏只画一次.
@property (nonatomic, strong) cRKlineScrView *klineSrc;             //K线图
@property (nonatomic, strong) NSDictionary   *dicFromService;       //模拟服务器返回数据
@property (nonatomic, assign) BOOL           isDrawing;             //K线图正在画的时候，不能绘画

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //初始化视图
    [self configureUI];
    //模拟服务器返回数据
    [self getDataSuccess];
    
}

- (void)configureUI
{
    _klineSrc = [[cRKlineScrView alloc] initWithFrame:CGRectMake(50, 20, 320, 200)];
    _klineSrc.backgroundColor = [UIColor colorWithRed:0.9647 green:0.9647 blue:0.9647 alpha:1.0];
    _klineSrc.klineWidthSpace = KLINEWIDTHSPACE;
    _klineSrc.bounces = NO;
    _klineSrc.showsHorizontalScrollIndicator = YES;
    [self.view addSubview:_klineSrc];
    
    // 添加观察者,如果k线图正在绘画中,则不会激活绘画
    [_klineSrc addObserver:self forKeyPath:@"isDrawing" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

//从服务器获得数据.
- (void)getDataSuccess
{
    _DrawOneTime = YES;
    _isDrawing = NO;
    
    NSMutableDictionary *dicFromService = [[NSMutableDictionary alloc] init];
    
    NSArray *k_data = @[
                        @{@"date":@"2013-05",@"price":@"20000"},
                        @{@"date":@"2013-06",@"price":@"20000"},
                        @{@"date":@"2013-07",@"price":@"20000"},
                        @{@"date":@"2013-08",@"price":@"20600"},
                        @{@"date":@"2013-09",@"price":@"26000"},
                        @{@"date":@"2013-10",@"price":@"19000"},
                        @{@"date":@"2013-11",@"price":@"18500"},
                        @{@"date":@"2013-12",@"price":@"18000"},
                        @{@"date":@"2014-01",@"price":@"18000"},
                        @{@"date":@"2014-02",@"price":@"18000"},
                        @{@"date":@"2014-03",@"price":@"19500"},
                        @{@"date":@"2014-04",@"price":@"19500"},
                        @{@"date":@"2014-05",@"price":@"19000"},
                        @{@"date":@"2014-06",@"price":@"19000"},
                        ];
    
    [dicFromService setObject:k_data forKey:@"k_data"];
    [dicFromService setObject:@"26000" forKey:@"max"];
    [dicFromService setObject:@"18000" forKey:@"min"];
    
    // 获得数据后,根据自身情况分析..
    [self configureKlineData:dicFromService];
}

- (IBAction)drawItAction:(id)sender
{
    if(!_isDrawing)
    {
        [self showKline];
    }
}

- (void)configureKlineData:(NSDictionary *)dic
{
    if (dic && !_pathPointArr) {
        _pathPointArr = [[NSMutableArray alloc] init];
        _dateArr = [[NSMutableArray alloc] init];
        _scaleArr = [[NSMutableArray alloc] init];
        
        NSArray *k_data = [dic objectForKey:@"k_data"];
        // 最高值
        _maxHeightPrice = [[dic objectForKey:@"max"] intValue];
        // 最低值
        _minHeightPrice = [[dic objectForKey:@"min"] intValue];
        // 刻度
        _klineHeightspace = (_maxHeightPrice - _minHeightPrice) / 4;
        if(_klineHeightspace == 0)
        {
            //最高价和最低价是一样时,手动重置最高值和最低值
            _klineHeightspace = 1000;
            _minHeightPrice = _minHeightPrice - 2000;
            _maxHeightPrice = _maxHeightPrice + 2000;
        }
        // K线图距离左边距离,左边留给价格显示
        _klineToLeftWidth = 0;
        // 加入数据
        [_scaleArr addObject:[NSString stringWithFormat:@"%ld",_minHeightPrice]];
        [_scaleArr addObject:[NSString stringWithFormat:@"%ld",_minHeightPrice + _klineHeightspace*1]];
        [_scaleArr addObject:[NSString stringWithFormat:@"%ld",_minHeightPrice + _klineHeightspace*2]];
        [_scaleArr addObject:[NSString stringWithFormat:@"%ld",_minHeightPrice + _klineHeightspace*3]];
        [_scaleArr addObject:[NSString stringWithFormat:@"%ld",_maxHeightPrice]];
        
        // 价格点 月份右滚递增加
        NSMutableArray *priceArr = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < k_data.count; i++)
        {
            // 获得日期数据
            NSDictionary *tempDic = [k_data objectAtIndex:i];
            [_dateArr addObject:[tempDic objectForKey:@"date"]];
            
            // 获得K线坐标位置
            [priceArr addObject:[tempDic objectForKey:@"price"]];
            CGFloat price = [[tempDic objectForKey:@"price"] floatValue];
            
            // K线图区域高度
            CGFloat klineAreaHeight = _klineSrc.frame.size.height - 60;
            
            //注意不要顶头，顶底
            CGFloat offSetX = _klineSrc.klineWidthSpace * (i+1) + _klineToLeftWidth;
            CGFloat offsetY = (klineAreaHeight*(price - _minHeightPrice))/(_maxHeightPrice - _minHeightPrice + 0.0);
            offsetY = (klineAreaHeight - offsetY) +20;
            
            CGPoint pointInScrollView = CGPointMake(offSetX, offsetY);
            NSValue *value = [NSValue valueWithCGPoint:pointInScrollView];
            [_pathPointArr addObject:value];
        }
    }
    
}

- (void)showKline
{
    //清空数据
    [_klineSrc.bezierFramePath removeAllPoints];
    [_klineSrc.bezierKlinePath removeAllPoints];
    [_klineSrc.bezierDotPath removeAllPoints];
    [_klineSrc setNeedsDisplay];
    
    //K线图宽度
    _klineSrc.contentSize = CGSizeMake(MAX(_klineSrc.klineWidthSpace * (_pathPointArr.count + 2) + _klineToLeftWidth, _klineSrc.frame.size.width),_klineSrc.frame.size.height);
    
    //K线点位置数组(CGPoint)
    _klineSrc.kLineData = _pathPointArr;
    
    //点对应的日期
    _klineSrc.klineDate = _dateArr;
    
    //侧边价格栏&底边线
    [self KlinePriceColumn];
}

- (void)KlinePriceColumn
{
    if(_DrawOneTime)
    {
        _DrawOneTime = NO;
        
        CGFloat klineAreaHeight = _klineSrc.frame.size.height - 60;
        
        for (NSInteger i = 0 ; i < _scaleArr.count ; i++)
        {
            // 价格
            NSString *price = [_scaleArr objectAtIndex:i];
            CGFloat offsetY = (klineAreaHeight*(price.integerValue - _minHeightPrice))/(_maxHeightPrice - _minHeightPrice + 0.0);
            offsetY = (klineAreaHeight - offsetY) + 20 + 10;
            UILabel *priceLB = [[UILabel alloc] initWithFrame:CGRectMake(0, offsetY /*+ 33*/, KLINEWIDTHSPACE, 20)];
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
            NSNumber *priceNumer = [formatter numberFromString:price];
            priceLB.text = [formatter stringFromNumber:priceNumer];
            priceLB.textColor = [UIColor colorWithRed:127/255.0 green:127/255.0 blue:127/255.0 alpha:1.0];
            priceLB.textAlignment = NSTextAlignmentCenter;
            priceLB.font = [UIFont systemFontOfSize:11.0];
            priceLB.backgroundColor = [UIColor clearColor];
            [self.view addSubview:priceLB];
            
            // 刻度
            UIView *scale = [[UIView alloc] initWithFrame:CGRectMake(KLINEWIDTHSPACE, offsetY + 10 /*+ 33*/, 5, 1)];
            scale.backgroundColor = [UIColor lightGrayColor];
            [self.view addSubview:scale];
        }
        
        //左边线
        UIView *leftLine = [[UIView alloc] initWithFrame:CGRectMake(50, 20 /*+ 33*/, 1, _klineSrc.frame.size.height - 20)];
        leftLine.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:leftLine];
        
        //底边线
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(50, _klineSrc.frame.size.height /*+ 33*/, 320 - 50, 1)];
        bottomLine.backgroundColor = [UIColor lightGrayColor];
        
        [self.view addSubview:bottomLine];
    }
}

#pragma mark Observer Function
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"isDrawing"])
    {
        _isDrawing = _klineSrc.isDrawing;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated....
}

@end