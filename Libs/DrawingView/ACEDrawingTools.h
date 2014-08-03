/*
 
    这个类来自  ACEDrawingView: https://github.com/acerbetti/ACEDrawingView
    本人只是在原有的基础上添加了一些额外的功能。
    本人邮箱：YinHanMsn@sina.com
 */

#import <Foundation/Foundation.h>


#if __has_feature(objc_arc)
#define ACE_HAS_ARC 1
#define ACE_RETAIN(exp) (exp)
#define ACE_RELEASE(exp)
#define ACE_AUTORELEASE(exp) (exp)
#else
#define ACE_HAS_ARC 0
#define ACE_RETAIN(exp) [(exp) retain]
#define ACE_RELEASE(exp) [(exp) release]
#define ACE_AUTORELEASE(exp) [(exp) autorelease]
#endif








//创建一个delegate
@protocol ACEDrawingTool <NSObject>
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, assign) CGFloat lineAlpha;
@property (nonatomic, assign) CGFloat lineWidth;

- (void)setInitialPoint:(CGPoint)firstPoint;
- (void)moveFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint;
- (void)draw;

@end





#pragma mark - 这个是画笔
@interface ACEDrawingPenTool : UIBezierPath<ACEDrawingTool>
{
    CGMutablePathRef path;
}
// YES代表是圆笔头， NO是方笔头
-(id)initWithValueForRound:(BOOL)isValue;
@end
//====================================================



#pragma mark - 这个是橡皮
@interface ACEDrawingEraserTool : ACEDrawingPenTool
@end
//====================================================



#pragma mark - 这个是直线
@interface ACEDrawingLineTool : NSObject<ACEDrawingTool>
@end
//====================================================



#pragma mark - 这个是方块
@interface ACEDrawingRectangleTool : NSObject<ACEDrawingTool>
@property (nonatomic, assign) BOOL fill;
@end
//====================================================



#pragma mark - 这个是画圆圈
@interface ACEDrawingEllipseTool : NSObject<ACEDrawingTool>
@property (nonatomic, assign) BOOL fill;
@end
//====================================================


#pragma mark - 这个是画图片
@interface ACEDrawingImageTool : UIImageView <ACEDrawingTool>
@property (nonatomic, strong) UIImage * image;
@end
//====================================================



#pragma mark - 这个是画三角形
@interface ACEDrawingSanJiao : NSObject<ACEDrawingTool>
@property (nonatomic, assign) BOOL fill;
@end
//====================================================




#pragma mark - 这个是变形
@interface ACEDrawingBianXing : UIView <ACEDrawingTool>
@end
//====================================================


#pragma mark - 这个是画五角形 ★
@interface ACEDrawingDengJiao : UIView <ACEDrawingTool>
@property (nonatomic, assign) BOOL    fill;
@end
//====================================================



#pragma mark - 是否填充
@interface ACEDrawingFill : NSObject <ACEDrawingTool>
@end
//====================================================

