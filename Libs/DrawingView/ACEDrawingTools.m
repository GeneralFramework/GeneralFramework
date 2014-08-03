/*
 * ACEDrawingView: https://github.com/acerbetti/ACEDrawingViewz
 */

#import "ACEDrawingTools.h"



//===================================================================================
//===================================================================================
//===================================================================================
//===================================================================================


@interface ExtSaveData : NSObject
{
    NSMutableArray          * _currAllDrawInfo;
}
@property (nonatomic, retain) NSMutableArray    * currAllDrawInfo;
+(id)sharedSaveData;
@end

static ExtSaveData  * saveData = nil;
@implementation ExtSaveData
@synthesize currAllDrawInfo = _currAllDrawInfo;
+(id)sharedSaveData{
    if (saveData == nil) {
        @synchronized(saveData){
            saveData = [[ExtSaveData alloc] init];
        }
    }
    return saveData;
}
- (id)init
{
    self = [super init];
    if (self) {
        _currAllDrawInfo = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    _currAllDrawInfo = nil;
}
@end
//===================================================================================
//===================================================================================
//===================================================================================
//===================================================================================

@interface FillModel :NSObject
{

}
@property (assign, nonatomic) CGPoint start;
@property (assign, nonatomic) CGPoint end;
@property (assign, nonatomic) CGRect rect;
@property (assign, nonatomic) CGPoint p1, p2, p3, p4, p5;

@property (assign, nonatomic) BOOL   isYuan;
@property (assign, nonatomic) BOOL   isXing;
@end

@implementation FillModel
@synthesize start, end, rect, isYuan, p1, p2, p3, p4, p5, isXing;
@end


//===================================================================================
//===================================================================================
//===================================================================================
//===================================================================================



CGPoint midPoint(CGPoint p1, CGPoint p2)
{
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}







#pragma mark - ACEDrawingPenTool

/*                                                        ACEDrawingPenTool  
    ===================================================================     */
@implementation ACEDrawingPenTool

@synthesize lineColor = _lineColor;
@synthesize lineAlpha = _lineAlpha;

-(id)initWithValueForRound:(BOOL)isValue
{
    self = [super init];
    if (self != nil) {
        if (YES){
            self.lineCapStyle = kCGLineCapRound;
            self.lineJoinStyle = kCGLineJoinRound;
        }else{
            self.lineCapStyle = kCGLineCapButt;
            self.lineJoinStyle = kCGLineJoinRound;
        }
        path = CGPathCreateMutable();
    }
    return self;
}


- (void)setInitialPoint:(CGPoint)firstPoint
{
    [self moveToPoint:firstPoint];
}

- (void)moveFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    [self addQuadCurveToPoint:midPoint(endPoint, startPoint) controlPoint:startPoint];
}

- (void)draw
{
    [self.lineColor setStroke];
    [self strokeWithBlendMode:kCGBlendModeNormal alpha:self.lineAlpha];

}

#if !ACE_HAS_ARC

- (void)dealloc
{
    CGPathRelease(path);
    self.lineColor = nil;
    [super dealloc];
}

#endif

@end
/*                                                                          ACEDrawingPenTool
    =====================================================================================  END */










#pragma mark - ACEDrawingEraserTool
/*                                                                    ACEDrawingEraserTool
 =====================================================================================  */
@implementation ACEDrawingEraserTool
- (void)draw{
    [self.lineColor setStroke];
    [self strokeWithBlendMode:kCGBlendModeClear alpha:self.lineAlpha];
}
@end
/*                                                                 ACEDrawingEraserTool
 =====================================================================================   END */











#pragma mark - ACEDrawingLineTool
/*                                                                 ACEDrawingLineTool
 =====================================================================================    */
@interface ACEDrawingLineTool ()
@property (nonatomic, assign) CGPoint firstPoint;
@property (nonatomic, assign) CGPoint lastPoint;
@end

#pragma mark -

@implementation ACEDrawingLineTool

@synthesize lineColor = _lineColor;
@synthesize lineAlpha = _lineAlpha;
@synthesize lineWidth = _lineWidth;

- (void)setInitialPoint:(CGPoint)firstPoint
{    self.firstPoint = firstPoint;  }

- (void)moveFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{    self.lastPoint = endPoint; }

- (void)draw
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    // set the line properties
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetAlpha(context, self.lineAlpha);
    // draw the line
    CGContextMoveToPoint(context, self.firstPoint.x, self.firstPoint.y);
    CGContextAddLineToPoint(context, self.lastPoint.x, self.lastPoint.y);
    CGContextStrokePath(context);
}
#if !ACE_HAS_ARC
- (void)dealloc
{
    self.lineColor = nil;
    [super dealloc];
}
#endif
@end
/*                                                                 ACEDrawingLineTool
 =====================================================================================   END */













#pragma mark - ACEDrawingRectangleTool
/*                                                                 ACEDrawingRectangleTool
 =====================================================================================   */
@interface ACEDrawingRectangleTool ()
@property (nonatomic, assign) CGPoint firstPoint;
@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, assign) CGRect  rect;
@end

#pragma mark -

@implementation ACEDrawingRectangleTool

@synthesize lineColor = _lineColor;
@synthesize lineAlpha = _lineAlpha;
@synthesize lineWidth = _lineWidth;

- (id)init
{
    self = [super init];
    if (self) {
        if ([self  respondsToSelector:@selector(saveYuan)]) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveYuan) name:@"TOUCHEND" object:nil];
        }
    }
    return self;
}

- (void)setInitialPoint:(CGPoint)firstPoint
{
    self.firstPoint = firstPoint;
}

- (void)moveFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    self.lastPoint = endPoint;
}

- (void)draw
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the properties
    CGContextSetAlpha(context, self.lineAlpha);
    
    
    
    // draw the rectangle
    CGRect rectToFill = CGRectMake(self.firstPoint.x, self.firstPoint.y, self.lastPoint.x - self.firstPoint.x, self.lastPoint.y - self.firstPoint.y);
    self.rect = rectToFill;
    
    if (self.fill) {
        CGContextSetFillColorWithColor(context, self.lineColor.CGColor);
        CGContextFillRect(UIGraphicsGetCurrentContext(), rectToFill);
        
    } else {
        CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
        CGContextSetLineWidth(context, self.lineWidth);
        CGContextStrokeRect(UIGraphicsGetCurrentContext(), rectToFill);
    }
    //CGContextRelease(context);
}


-(void)saveYuan{

    BOOL isSave = YES;
    for (FillModel * m in [[ExtSaveData sharedSaveData] currAllDrawInfo]) {
        if (m.rect.origin.x == self.rect.origin.x && m.rect.origin.y == self.rect.origin.y) {
            isSave = NO;
            break;
        }else{
            isSave = YES;
        }
    }
    
    if (isSave) {
        FillModel * fill = [[FillModel alloc] init];
        fill.start = self.firstPoint;
        fill.end = self.lastPoint;
        fill.rect = self.rect;
        fill.isYuan = NO;
        //[[AppDelegate sharedAppDelegate].currAllDrawInfo addObject:fill];
        [[[ExtSaveData sharedSaveData] currAllDrawInfo] addObject:fill];
        
    }

}

#if !ACE_HAS_ARC

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TOUCHEND" object:nil];
    self.lineColor = nil;
    [super dealloc];
}

#endif

@end











#pragma mark - ACEDrawingEllipseTool

@interface ACEDrawingEllipseTool ()
@property (nonatomic, assign) CGPoint firstPoint;
@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, assign) CGRect  rect;
@end

#pragma mark -

@implementation ACEDrawingEllipseTool

@synthesize lineColor = _lineColor;
@synthesize lineAlpha = _lineAlpha;
@synthesize lineWidth = _lineWidth;

- (id)init
{
    self = [super init];
    if (self) {
        if ([self  respondsToSelector:@selector(saveRect)]) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveRect) name:@"TOUCHEND" object:nil];
        }
    }
    return self;
}

- (void)setInitialPoint:(CGPoint)firstPoint
{
    self.firstPoint = firstPoint;
}

- (void)moveFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    self.lastPoint = endPoint;
}

- (void)draw
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the properties
    CGContextSetAlpha(context, self.lineAlpha);
    
    // draw the ellipse
    CGRect rectToFill = CGRectMake(self.firstPoint.x, self.firstPoint.y, self.lastPoint.x - self.firstPoint.x, self.lastPoint.y - self.firstPoint.y);
    self.rect = rectToFill;
    
    if (self.fill) {
        CGContextSetFillColorWithColor(context, self.lineColor.CGColor);
        CGContextFillEllipseInRect(UIGraphicsGetCurrentContext(), rectToFill);
        
    } else {
        CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
        CGContextSetLineWidth(context, self.lineWidth);
        CGContextStrokeEllipseInRect(UIGraphicsGetCurrentContext(), rectToFill);
    }
    //CGContextRelease(context);

}

-(void)saveRect{
    
    BOOL isSave = YES;
    for (FillModel * m in [[ExtSaveData sharedSaveData] currAllDrawInfo]) {
        if (m.rect.origin.x == self.rect.origin.x && m.rect.origin.y == self.rect.origin.y) {
            isSave = NO;
            break;
        }else{
            isSave = YES;
        }
    }
    
    if (isSave) {
        FillModel * fill = [[FillModel alloc] init];
        fill.start = self.firstPoint;
        fill.end = self.lastPoint;
        fill.rect = self.rect;
        fill.isYuan = YES;
        //[[AppDelegate sharedAppDelegate].currAllDrawInfo addObject:fill];
        [[[ExtSaveData sharedSaveData] currAllDrawInfo] addObject:fill];
    }
    
}

#if !ACE_HAS_ARC

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TOUCHEND" object:nil];
    self.lineColor = nil;
    [super dealloc];
}

#endif

@end


#pragma mark - ACEDrawing image...
@interface ACEDrawingImageTool ()

@property (nonatomic, assign) CGPoint firstPoint;
@property (nonatomic, assign) CGPoint lastPoint;

@end

@implementation ACEDrawingImageTool

@synthesize lineColor = _lineColor;
@synthesize lineAlpha = _lineAlpha;
@synthesize lineWidth = _lineWidth;
@synthesize image;

- (void)setInitialPoint:(CGPoint)firstPoint
{
    self.firstPoint = firstPoint;
    self.userInteractionEnabled = YES;
   
}

- (void)moveFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    self.lastPoint = endPoint;
    
}

-(void)draw{
    [image drawInRect:CGRectMake(self.firstPoint.x - (image.size.width / 2),
                                 self.firstPoint.y - (image.size.height / 2),
                                 image.size.width, image.size.height)];
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{

    NSLog(@"end.....");
    
}



- (void)dealloc
{
    self.lineColor = nil;
    self.image = nil;
}

@end


@interface ACEDrawingBianXing ()

@property (nonatomic, assign) CGPoint firstPoint;
@property (nonatomic, assign) CGPoint lastPoint;
@end


@implementation ACEDrawingBianXing

@synthesize lineAlpha = _lineAlpha;
@synthesize lineColor = _lineColor;
@synthesize lineWidth = _lineWidth;

- (void)setInitialPoint:(CGPoint)firstPoint
{
    self.firstPoint = firstPoint;
    self.userInteractionEnabled = YES;
    
}

- (void)moveFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    self.lastPoint = endPoint;
    
}
-(void)draw{
//    CGRect rect = self.frame;
//    CGFloat centerX = rect.size.width / 2;
//    	CGFloat centerY = rect.size.height / 2;
//    	CGFloat r0 = self.radius * sin(18 * th)/cos(36 * th); /*计算小圆半径r0 */
//    	CGFloat x1[5]={0},y1[5]={0},x2[5]={0},y2[5]={0};
//    	for (int i = 0; i < 5; i ++)
//        	{
//            	x1[i] = centerX + self.radius * cos((90 + i * 72) * th); /* 计算出大圆上的五个平均分布点的坐标*/
//            	y1[i]=centerY - self.radius * sin((90 + i * 72) * th);
//            	x2[i]=centerX + r0 * cos((54 + i * 72) * th); /* 计算出小圆上的五个平均分布点的坐标*/
//            	y2[i]=centerY - r0 * sin((54 + i * 72) * th);
//            	}
//    	CGContextRef context = UIGraphicsGetCurrentContext();
//    	CGMutablePathRef startPath = CGPathCreateMutable();
//    	CGPathMoveToPoint(startPath, NULL, x1[0], y1[0]);
//    	for (int i = 1; i < 5; i ++) {
//        	CGPathAddLineToPoint(startPath, NULL, x2[i], y2[i]);
//        	CGPathAddLineToPoint(startPath, NULL, x1[i], y1[i]);
//        	}
//    	CGPathAddLineToPoint(startPath, NULL, x2[0], y2[0]);
//    	CGPathCloseSubpath(startPath);
//    	CGContextAddPath(context, startPath);
//    	CGContextSetFillColorWithColor(context, self.startColor.CGColor);
//    	CGContextSetStrokeColorWithColor(context, self.boundsColor.CGColor);
//    	CGContextStrokePath(context);
//    	CGRect range = CGRectMake(x1[1], 0, (x1[4] - x1[1]) * self.value , y1[2]);
//    	CGContextAddPath(context, startPath);
//    	CGContextClip(context);
//    	CGContextFillRect(context, range);
//    	CFRelease(startPath);
//    	}
}

@end



@interface ACEDrawingDengJiao ()

@property (nonatomic, assign) CGPoint firstPoint;
@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, assign) CGPoint p1, p2, p3, p4, p5;
@end


@implementation ACEDrawingDengJiao

@synthesize lineAlpha = _lineAlpha;
@synthesize lineColor = _lineColor;
@synthesize lineWidth = _lineWidth;

- (id)init
{
    self = [super init];
    if (self) {
        if ([self  respondsToSelector:@selector(saveDengBian)]) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveDengBian) name:@"TOUCHEND" object:nil];
        }
    }
    return self;
}

- (void)setInitialPoint:(CGPoint)firstPoint
{
    self.firstPoint = firstPoint;
    self.userInteractionEnabled = YES;
    
}

- (void)moveFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    self.lastPoint = endPoint;
    
}
-(void)draw{

    CGPoint centerPt = {self.firstPoint.x, self.firstPoint.y};
    CGFloat radius = self.firstPoint.x - self.lastPoint.x;
    
    #define degree2Radian(d) (M_PI * d/180)
    
    // 数学比较挫，硬算了5个点  -_-
    CGPoint pt1 = {centerPt.x, centerPt.y - radius};
    CGPoint pt2 = {self.firstPoint.x + radius * sin(degree2Radian(72)),
    self.firstPoint.y - radius * cos(degree2Radian(72))};
    CGPoint pt3 = {centerPt.x + radius * sin(degree2Radian(36)),
        centerPt.y + radius * cos(degree2Radian(36))};
    CGPoint pt4 = {centerPt.x - radius * sin(degree2Radian(36)),
        centerPt.y + radius * cos(degree2Radian(36))};
    CGPoint pt5 = {centerPt.x - radius * sin(degree2Radian(72)),
    centerPt.y - radius * cos(degree2Radian(72))};
    CGPoint points[] = {pt1, pt2, pt3, pt4, pt5};
    self.p1 = points[0]; self.p2 = points[1]; self.p3 = points[2];self.p4 = points[3]; self.p5 = points[4];
   
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    //CGContextSetFillColorWithColor(context, fillColor);
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetLineCap(context, kCGLineCapButt);
    CGContextAddLines(context, points, sizeof(points)/sizeof(CGPoint));
    CGContextClosePath(context);
    CGContextStrokePath(context);
    
    //[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(saveDengBian:) userInfo:nil repeats:NO];
    //NSLog(@"self.p1 = %f,%f  \n self.p2 = %f,%f \n self.p3 = %f, %f \n self.p4 = %f, %f \n self.p5 = %f, %f",
    //self.p1.x,self.p1.y,self.p2.x,self.p2.y, self.p3.x,self.p3.y,self.p4.x,self.p4.y,self.p5.x,self.p5.y);
    
}

-(void)saveDengBian{
    
    BOOL isSave = YES;
    for (FillModel * m in [[ExtSaveData sharedSaveData] currAllDrawInfo]) {
        if (m.p1.x == self.p1.x) {
            isSave = NO;
            break;
        }else{
            isSave = YES;
        }
    }
        
    if (isSave) {
        FillModel * fill = [[FillModel alloc] init];
        fill.isXing = YES;
        fill.p1 = self.p1;
        fill.p2 = self.p2;
        fill.p3 = self.p3;
        fill.p4 = self.p4;
        fill.p5 = self.p5;
        //[[AppDelegate sharedAppDelegate].currAllDrawInfo addObject:fill];
        [[[ExtSaveData sharedSaveData] currAllDrawInfo] addObject:fill];
    }

}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TOUCHEND" object:nil];
}

@end




@interface ACEDrawingFill ()

@property (nonatomic, assign) CGPoint firstPoint;
@property (nonatomic, assign) CGPoint lastPoint;

@end

@implementation ACEDrawingFill
@synthesize lineAlpha = _lineAlpha;
@synthesize lineColor = _lineColor;
@synthesize lineWidth = _lineWidth;

-(void)setInitialPoint:(CGPoint)firstPoint{

    self.firstPoint = firstPoint;
    
}
-(void)moveFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint{

    self.lastPoint = endPoint;
}
-(void)draw{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (FillModel * m in [[ExtSaveData sharedSaveData] currAllDrawInfo]) {
        if (m.isXing) {
            /*
            if (self.firstPoint.x > m.p1.x && self.firstPoint.y > m.p1.y && self.lastPoint.x < m.p2.x && self.lastPoint.y < m.p2.y) {
                
                CGContextMoveToPoint(context, m.p1.x, m.p1.y);
                
               
                CGContextAddLineToPoint(context, m.p2.x, m.p2.y);
                CGContextAddLineToPoint(context, m.p3.x , m.p3.y);
                
                // 关闭并终止当前路径的子路径，并在当前点和子路径的起点之间追加一条线
                CGContextClosePath(context);
        
                //CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
                CGContextSetFillColorWithColor(context, self.lineColor.CGColor);
                CGContextSetLineWidth(context, self.lineWidth);
                
                CGContextFillPath(context);
            }
             */
            
            if (self.lastPoint.x > m.p3.x &&
                self.lastPoint.x < m.p2.x &&
                self.lastPoint.y < m.p2.y &&
                self.lastPoint.y > m.p1.y) {
                
                CGContextMoveToPoint(context, m.p1.x, m.p1.y);
                
                
                CGContextAddLineToPoint(context, m.p2.x, m.p2.y);
                CGContextAddLineToPoint(context, m.p3.x , m.p3.y);
                
                // 关闭并终止当前路径的子路径，并在当前点和子路径的起点之间追加一条线
                CGContextClosePath(context);
                
                //CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
                CGContextSetFillColorWithColor(context, self.lineColor.CGColor);
                CGContextSetLineWidth(context, self.lineWidth);
                
                CGContextFillPath(context);
            }else if (self.lastPoint.x < m.p3.x &&
                      self.lastPoint.x > m.p2.x &&
                      self.lastPoint.y < m.p2.y &&
                      self.lastPoint.y > m.p1.y){

                CGContextMoveToPoint(context, m.p1.x, m.p1.y);
                CGContextAddLineToPoint(context, m.p3.x, m.p3.y);
                CGContextAddLineToPoint(context, m.p2.x, m.p2.y);

                // 关闭并终止当前路径的子路径，并在当前点和子路径的起点之间追加一条线
                CGContextClosePath(context);
                
                //CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
                CGContextSetFillColorWithColor(context, self.lineColor.CGColor);
                CGContextSetLineWidth(context, self.lineWidth);
                
                CGContextFillPath(context);

                
            }
        }else{
            if (self.firstPoint.x > m.start.x && self.firstPoint.y > m.start.y){
                if(self.lastPoint.x < m.end.x && self.lastPoint.y < m.end.y){
                
                    if (m.isYuan) {
                        CGContextSetFillColorWithColor(context, self.lineColor.CGColor);
                        CGContextFillEllipseInRect(UIGraphicsGetCurrentContext(), m.rect);
                    }else{
                        CGContextSetFillColorWithColor(context, self.lineColor.CGColor);
                        CGContextFillRect(UIGraphicsGetCurrentContext(), m.rect);
                    }//else
                }
            }//if
        }//else
    }// for
}// draw
@end



@interface ACEDrawingSanJiao ()

@property (nonatomic, assign) CGPoint firstPoint;
@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, assign) CGPoint p1, p2, p3, p4, p5;

@end

@implementation ACEDrawingSanJiao
@synthesize lineAlpha = _lineAlpha;
@synthesize lineColor = _lineColor;
@synthesize lineWidth = _lineWidth;
- (id)init
{
    self = [super init];
    if (self) {
        if ([self  respondsToSelector:@selector(saveSan)]) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveSan) name:@"TOUCHEND" object:nil];
        }
    }
    return self;
}

-(void)setInitialPoint:(CGPoint)firstPoint{
    
    self.firstPoint = firstPoint;
    
}
-(void)moveFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint{
    
    self.lastPoint = endPoint;
    
    NSLog(@"\nself.firstPoint.x = %f, y = %f,  \n self.lastPoint.x = %f, y = %f ",self.firstPoint.x, self.firstPoint.y, self.lastPoint.x,self.lastPoint.y);
    
}
-(void)draw{
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // set the properties
    CGContextSetAlpha(ctx, self.lineAlpha);
    
    
    
    // draw the ellipse
    //CGRect rectToFill = CGRectMake(self.firstPoint.x, self.firstPoint.y, self.lastPoint.x - self.firstPoint.x, self.lastPoint.y - self.firstPoint.y);
    if (self.fill) {
    
        
    
    }else{
    
        
        // 获取当前图形，视图推入堆栈的图形，相当于你所要绘制图形的图纸
        
        // 创建一个新的空图形路径。
        CGContextBeginPath(ctx);
        
        /**
         *  @brief 在指定点开始一个新的子路径 参数按顺序说明
         *
         *  @param c 当前图形
         *  @param x 指定点的x坐标值
         *  @param y 指定点的y坐标值
         *
         */
       
        self.p1 = self.firstPoint;
        self.p2 = self.lastPoint;
        float f = self.lastPoint.x - ((self.lastPoint.x - self.firstPoint.x) * 2);
        self.p3 = CGPointMake(f, self.lastPoint.y);
        
        CGContextMoveToPoint(ctx, self.p1.x, self.p1.y);
        
        /**
         *  @brief 在当前点追加直线段，参数说明与上面一样
         */
        CGContextAddLineToPoint(ctx, self.p2.x, self.p2.y);
        CGContextAddLineToPoint(ctx, self.p3.x , self.p3.y);
        
        // 关闭并终止当前路径的子路径，并在当前点和子路径的起点之间追加一条线
        CGContextClosePath(ctx);
        
        // 设置当前视图填充色
        //CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
        
        CGContextSetStrokeColorWithColor(ctx, self.lineColor.CGColor);
        CGContextSetLineWidth(ctx, self.lineWidth);

        // 绘制当前路径区域
        CGContextStrokePath(ctx);
        //CGContextRelease(ctx);
        //CGContextFillPath(ctx);
    }
    
}// draw

-(void)saveSan{
    
    BOOL isSave = YES;
    for (FillModel * m in [[ExtSaveData sharedSaveData] currAllDrawInfo]) {
        if (m.p1.x == self.p1.x) {
            isSave = NO;
            break;
        }else{
            isSave = YES;
        }
    }
    
    if (isSave) {
        FillModel * fill = [[FillModel alloc] init];
        fill.isXing = YES;
        fill.p1 = self.p1;
        fill.p2 = self.p2;
        fill.p3 = self.p3;
        //[[AppDelegate sharedAppDelegate].currAllDrawInfo addObject:fill];
        [[[ExtSaveData sharedSaveData] currAllDrawInfo] addObject:fill];
    }
    
}




- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TOUCHEND" object:nil];
}
@end

