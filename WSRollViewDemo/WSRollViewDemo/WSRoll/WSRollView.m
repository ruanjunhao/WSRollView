//
//  WSRollView.m
//  WSRollImageView
//
//  Created by iMac on 16/11/29.
//  Copyright © 2016年 zws. All rights reserved.
//

#import "WSRollView.h"
#import "UIImageView+WebCache.h"


typedef enum {
    RollDirectionUpDown,//上下移动
    RollDirectionLeftRight,//左右移动
} RollDirection;



@interface WSRollView ()

@property(nonatomic,strong)UIImage *rollImage;//滚动图片
@property(nonatomic,strong)UIImageView *rollImageView;//滚动图片View
@property(nonatomic,strong)NSTimer *rollTimer;//滚动视图计时器

@property(nonatomic,assign)RollDirection direction;//滚动方向


@end


@implementation WSRollView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.timeInterval = 0.05;
        self.rollSpace = 1.0;
    }
    
    return self;
}


- (void)startRoll {
    _rollImageView  = [[UIImageView alloc]init];
    
    if (self.image != nil && self.rollImageURL ==nil) { //如果有本地图片  没有网络图片地址
        
        _rollImage = self.image;
        [self addRollImageAndTimer];
    }else{
        //如果有网络图片地址
        [self downLoaderImageWithUrlString:_rollImageURL];
        
    }

    
}

-(void)addRollImageAndTimer{
    
    //图片
    if (_rollImage !=nil && _rollImage.size.width/_rollImage.size.height<self.frame.size.width/self.frame.size.height) {
        //本地图片的宽高比(100*568)<视图的宽高比(320*568)，进行上下滚动
        
        _rollImageView.frame = CGRectMake(0, 0,self.frame.size.width, _rollImage.size.width/_rollImage.size.height *self.frame.size.width);
        
        _rollImageView.image = _rollImage;
        self.clipsToBounds = YES;//截掉超过父视图大小的_rollImageView
        [self addSubview:_rollImageView];
        
        self.direction = RollDirectionUpDown;//上下
        self.rollTimer =[NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(rollImageAction) userInfo:nil repeats:YES];
        [self.rollTimer fire];

        
    }else if(_rollImage !=nil && _rollImage.size.width/_rollImage.size.height>self.frame.size.width/self.frame.size.height){
        
        //本地图片的宽高比(500*568)>视图的宽高比(320*568)，进行左右滚动

        _rollImageView.frame  = CGRectMake(0, 0,_rollImage.size.width/_rollImage.size.height * self.frame.size.height, self.frame.size.height);
        
        _rollImageView.image = _rollImage;
        self.clipsToBounds = YES;//截掉超过父视图大小的_rollImageView
        [self addSubview:_rollImageView];
        
        self.direction = RollDirectionLeftRight;//左右

        self.rollTimer =[NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(rollImageAction) userInfo:nil repeats:YES];
        
        
        [self.rollTimer fire];
    }
    else {
        
        NSLog(@"Error:没有图片或者图片宽高比和视图相同");
    }
    
    
    
}

float rollX = 0.0;
float rollY = 0.0;
bool isReverse = NO;//是否反向翻滚
-(void)rollImageAction {
    
    switch (self.direction) {
        case RollDirectionUpDown:
        {
            if (rollY-self.rollSpace >(self.frame.size.height-self.frame.size.width* _rollImage.size.height/_rollImage.size.width) &&!isReverse) {
                
                rollY = rollY-self.rollSpace;
                _rollImageView.frame = CGRectMake(0, rollY,self.frame.size.width, self.frame.size.width*_rollImage.size.height/_rollImage.size.width);
                
            }else{
                
                isReverse = YES;
            }
            
            if (rollY+self.rollSpace < 0 &&isReverse) {
                
                rollY = rollY +self.rollSpace;
                _rollImageView.frame = CGRectMake(0, rollY, self.frame.size.width, self.frame.size.width* _rollImage.size.height/_rollImage.size.width);
                
            }else{
                isReverse = NO;
            }

        }
            break;
        
        case RollDirectionLeftRight:
        {
            if (rollX-self.rollSpace >(self.frame.size.width-self.frame.size.height* _rollImage.size.width/_rollImage.size.height) &&!isReverse) {
                
                rollX = rollX-self.rollSpace;
                _rollImageView.frame = CGRectMake(rollX, 0,self.frame.size.height* _rollImage.size.width/_rollImage.size.height, self.frame.size.height);
                
            }else{
                
                isReverse = YES;
            }
            
            if (rollX+self.rollSpace < 0 &&isReverse) {
                
                rollX = rollX +self.rollSpace;
                
                _rollImageView.frame = CGRectMake(rollX, 0,self.frame.size.height* _rollImage.size.width/_rollImage.size.height, self.frame.size.height);
                
            }else{
                isReverse = NO;
            }

        }
            break;
            
        default:
            break;
    }
    
    
}

-(void)downLoaderImageWithUrlString:(nonnull NSString *)string{
    
    __weak typeof(self)weakSelf = self;
    
    [_rollImageView sd_setImageWithURL:[NSURL URLWithString:string] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        weakSelf.rollImage = image;
        [weakSelf addRollImageAndTimer];

    }];
}

-(void)dealloc{
    
    if (self.rollTimer != nil) {
        [self.rollTimer invalidate];
        self.rollTimer = nil;
    }
}
@end
