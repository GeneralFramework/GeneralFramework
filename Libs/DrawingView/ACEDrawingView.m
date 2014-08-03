/*
 * ACEDrawingView: https://github.com/acerbetti/ACEDrawingView
 *
 * Copyright (c) 2013 Stefano Acerbetti
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "ACEDrawingView.h"
#import "ACEDrawingTools.h"
#import <QuartzCore/QuartzCore.h>

#define kDefaultLineColor       [UIColor blackColor]
#define kDefaultLineWidth       10.0f;
#define kDefaultLineAlpha       1.0f
#define Drawing                 @"drawing"
// experimental code
#define PARTIAL_REDRAW          0

@interface ACEDrawingView (){

    CGPoint currentPoint;
    CGPoint previousPoint1;
    CGPoint previousPoint2;


}
@property (nonatomic, strong) NSMutableArray *pathArray;
@property (nonatomic, strong) NSMutableArray *bufferArray;
//@property (nonatomic, strong) UIImage *image;
@end

#pragma mark -

@implementation ACEDrawingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configure];
    }
    return self;
}
- (void)setIsImgFill:(BOOL)isImgFill
{
    _isImgFill = isImgFill;
    if (isImgFill) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(drawing:) name:Drawing object:nil];
    }
}
- (void)configure
{
    // init the private arrays
    self.pathArray = [NSMutableArray array];
    self.bufferArray = [NSMutableArray array];
    
    // set the default values for the public properties
    self.lineColor = kDefaultLineColor;
    self.lineWidth = kDefaultLineWidth;
    self.lineAlpha = kDefaultLineAlpha;
    
    // set the transparent background
    self.backgroundColor = [UIColor clearColor];
}


#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
#if PARTIAL_REDRAW
    // TODO: draw only the updated part of the image
    [self drawPath];
#else
    [self.image drawInRect:self.bounds];
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    if (!self.isClear) {
        
        if (![self.currentTool isKindOfClass:[ACEDrawingImageTool class]]&&self.currentTool != nil) {
            if (!self.isImgFill) {
                if ([self.delegate respondsToSelector:@selector(drawingView:Context:UsingTool:)]) {
                    [self.delegate drawingView:self Context:currentContext UsingTool:self.currentTool];
                }
            }
            [self.currentTool draw];
            
        }
        self.isClear = NO;
    }


   #endif
}

- (void)updateCacheImage:(BOOL)redraw
{
    // init a context
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    if (redraw) {
        // erase the previous image
        self.image = nil;
        
        // I need to redraw all the lines
        for (id<ACEDrawingTool> tool in self.pathArray) {
            [tool draw];
        }

    } else {
        // set the draw point
        [self.image drawAtPoint:CGPointZero];
        if (![self.currentTool isKindOfClass:[ACEDrawingImageTool class]]&&self.currentTool!= nil) {
            if (!self.isImgFill) {
                
                if ([self.delegate respondsToSelector:@selector(drawingView:Context:UsingTool:)]) {
                    [self.delegate drawingView:self Context:currentContext UsingTool:self.currentTool];
                }
            }
            [self.currentTool draw];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TOUCHEND" object:nil];
            
        }

    }

    // store the image
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (id<ACEDrawingTool>)toolWithCurrentSettings
{
    switch (self.drawTool) {
     
        case ACEDrawingToolTypePen:
        {
            return ACE_AUTORELEASE([[ACEDrawingPenTool alloc] initWithValueForRound:YES]);
        }
            
        case ACEDrawingFangBi:
        {
            return ACE_AUTORELEASE([[ACEDrawingPenTool alloc] initWithValueForRound:NO]);
        }
        case ACEDrawingToolTypeLine:
        {
            return ACE_AUTORELEASE([ACEDrawingLineTool new]);
        }
        case ACEDrawingSanJiaos:{
        
             ACEDrawingSanJiao * tool = [[ACEDrawingSanJiao alloc] init];
            return tool;
        }
            
        case ACEDrawingToolTypeRectagleStroke:
        {
            ACEDrawingRectangleTool *tool = [[ACEDrawingRectangleTool alloc] init];
            tool.fill = NO;
            return tool ;
        }
            
        case ACEDrawingToolTypeRectagleFill:
        {
            ACEDrawingRectangleTool *tool = ACE_AUTORELEASE([ACEDrawingRectangleTool new]);
            tool.fill = YES;
            return tool;
        }
            
        case ACEDrawingToolTypeEllipseStroke:
        {
            ACEDrawingEllipseTool *tool = [[ACEDrawingEllipseTool alloc] init];
            tool.fill = NO;
            return tool ;
        }
            
        case ACEDrawingToolTypeEllipseFill:
        {
            ACEDrawingEllipseTool *tool = ACE_AUTORELEASE([ACEDrawingEllipseTool new]);
            tool.fill = YES;
            return tool;
        }
            
        case ACEDrawingToolTypeImages:
        {
            ACEDrawingImageTool * tool = ACE_AUTORELEASE([ACEDrawingImageTool new]);
            tool.userInteractionEnabled = YES;
            tool.image = self.selectImage.image;
            return tool;
        }
        case ACEDrawingDengJiaos:{
        
            ACEDrawingDengJiao * tool = [[ACEDrawingDengJiao alloc] init];
            return tool ;
        }
            
        case ACEDrawingFills:{
        
            ACEDrawingFill * tool = ACE_AUTORELEASE([ACEDrawingFill new]);
            return tool;
        }
            
            
        case ACEDrawingToolTypeEraser:
        {
            return ACE_AUTORELEASE([[ACEDrawingEraserTool alloc] initWithValueForRound:YES]);
        }
            
        default:{
        
        }
    }
    return nil;
}

#pragma mark - Touch Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    // init the bezier path
    self.currentTool = [self toolWithCurrentSettings];
    self.currentTool.lineWidth = self.lineWidth;
    self.currentTool.lineColor = self.lineColor;
    self.currentTool.lineAlpha = self.lineAlpha;
    [self.pathArray addObject:self.currentTool];
    
    // add the first touch
    UITouch *touch = [touches anyObject];
    previousPoint1 = [touch previousLocationInView:self];
    currentPoint = [touch locationInView:self];
    [self.currentTool setInitialPoint:currentPoint];
    
    
    // call the delegate
    if ([self.delegate respondsToSelector:@selector(drawingView:willBeginDrawUsingTool:)]) {
        [self.delegate drawingView:self willBeginDrawUsingTool:self.currentTool];
    }
    if (![self.currentTool isKindOfClass:[ACEDrawingImageTool class]]){
        [self touchesMoved:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    // save all the touches in the path
    UITouch *touch = [touches anyObject];
    
    // add the current point to the path
    CGPoint currentLocation = [touch locationInView:self];
    CGPoint previousLocation = [touch previousLocationInView:self];
    [self.currentTool moveFromPoint:previousLocation toPoint:currentLocation];
    
#if PARTIAL_REDRAW
    // calculate the dirty rect
    CGFloat minX = fmin(previousLocation.x, currentLocation.x) - self.lineWidth * 0.5;
    CGFloat minY = fmin(previousLocation.y, currentLocation.y) - self.lineWidth * 0.5;
    CGFloat maxX = fmax(previousLocation.x, currentLocation.x) + self.lineWidth * 0.5;
    CGFloat maxY = fmax(previousLocation.y, currentLocation.y) + self.lineWidth * 0.5;
    [self setNeedsDisplayInRect:CGRectMake(minX, minY, (maxX - minX), (maxY - minY))];
#else
    [self setNeedsDisplay];
#endif
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // make sure a point is recorded
    //[self touchesMoved:touches withEvent:event];
    
    // update the image
    [self updateCacheImage:NO];
    
    
    // call the delegate
    if ([self.delegate respondsToSelector:@selector(drawingView:didEndDrawUsingTool:)]) {
        [self.delegate drawingView:self didEndDrawUsingTool:self.currentTool];
    }
    // clear the current tool
    self.currentTool = nil;
    
    // clear the redo queue
    [self.bufferArray removeAllObjects];
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // make sure a point is recorded
    [self touchesEnded:touches withEvent:event];
}


#pragma mark - Actions

- (void)clear
{
    [self.bufferArray removeAllObjects];
    [self.pathArray removeAllObjects];
    [self updateCacheImage:YES];
    //self.isClear = YES;
    [self setNeedsDisplay];
}


#pragma mark - Undo / Redo

- (NSUInteger)undoSteps
{
    return self.bufferArray.count;
}

- (BOOL)canUndo
{
    return self.pathArray.count > 0;
}

- (void)undoLatestStep
{
    if ([self canUndo]) {
        id<ACEDrawingTool>tool = [self.pathArray lastObject];
        [self.bufferArray addObject:tool];
        [self.pathArray removeLastObject];
        [self updateCacheImage:YES];
        [self setNeedsDisplay];
    }
}

- (BOOL)canRedo
{
    return self.bufferArray.count > 0;
}

- (void)redoLatestStep
{
    if ([self canRedo]) {
        id<ACEDrawingTool>tool = [self.bufferArray lastObject];
        [self.pathArray addObject:tool];
        [self.bufferArray removeLastObject];
        [self updateCacheImage:YES];
        [self setNeedsDisplay];
    }
}


#pragma mark - Ext ...


- (UIColor*) getPixelColorAtLocation:(CGPoint)point {
    
    UIColor* color = nil;
    CGImageRef inImage = self.selectImage.image.CGImage;
    // Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
    if (cgctx == NULL) { return nil; /* error */ }
    
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(cgctx, rect, inImage);
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    unsigned char* data = CGBitmapContextGetData (cgctx);
    if (data != NULL) {
        //offset locates the pixel in the data from x,y.
        //4 for 4 bytes of data per pixel, w is width of one row of data.
        @try {
            int offset = 4*((w*round(point.y))+round(point.x));
            NSLog(@"offset: %d", offset);
            int alpha =  data[offset];
            int red = data[offset+1];
            int green = data[offset+2];
            int blue = data[offset+3];
            NSLog(@"offset: %i colors: RGB A %i %i %i  %i",offset,red,green,blue,alpha);
            color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
        }
        @catch (NSException * e) {
            NSLog(@"%@",[e reason]);
        }
        @finally {
            
        }
        
    }
    
    // When finished, release the context
    CGContextRelease(cgctx);
    // Free image data memory for the context
    if (data) { free(data); }
    
    return color ;
}



- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage {
    
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    return context;
}

- (void)drawing:(NSNotification *)notification
{
        
    
}



#if !ACE_HAS_ARC

- (void)dealloc
{
    self.pathArray = nil;
    self.bufferArray = nil;
    self.currentTool = nil;
    self.image = nil;
    [super dealloc];
}

#endif

@end
