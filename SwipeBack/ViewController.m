#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
{
    CAShapeLayer* shapeLayer;
    CAShapeLayer* arrowLayer;
    CGFloat controlX;
    CGFloat posY;
    CGFloat dir;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIScreenEdgePanGestureRecognizer* r = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(onRightPanGesture:)];
    r.edges = UIRectEdgeRight;
    [self.view addGestureRecognizer:r];
    
    UIScreenEdgePanGestureRecognizer* l = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(onLeftPanGesture:)];
    l.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:l];
}

- (void)remoteLayer {
    if (shapeLayer != nil) {
        [shapeLayer removeFromSuperlayer];
        shapeLayer = nil;
    }
    if (arrowLayer != nil) {
        [arrowLayer removeFromSuperlayer];
        arrowLayer = nil;
    }
}

- (void)createLayer {
    if (shapeLayer == nil) {
        shapeLayer = [CAShapeLayer layer];
        shapeLayer.strokeColor = [UIColor blackColor].CGColor;
        [self.view.layer addSublayer:shapeLayer];
    }
    if (arrowLayer == nil) {
        arrowLayer = [CAShapeLayer layer];
        arrowLayer.strokeColor = [UIColor whiteColor].CGColor;
        arrowLayer.lineWidth = 2;
        [self.view.layer addSublayer:arrowLayer];
    }
}

// https://github.com/ChenTianSaber/SlideBack
- (void)updateLayer {
    if (shapeLayer == nil || arrowLayer == nil)
        return;
    
    float screenWidth = self.view.bounds.size.width;
    float w = 30;
    float h = 200;
    float y = posY - h / 2;

    if (controlX > 50)
        controlX = 50;
    
    float x1 = screenWidth - screenWidth * dir;

    UIBezierPath* spath = [UIBezierPath new];
    [spath moveToPoint:CGPointMake(x1, y + w)];
    [spath addQuadCurveToPoint:CGPointMake(fabs(x1 - controlX / 3), y + h * 3 / 8)
                 controlPoint:CGPointMake(x1, y + h / 4)];
    [spath addQuadCurveToPoint:CGPointMake(fabs(x1 - controlX / 3), y + h * 5 / 8)
                 controlPoint:CGPointMake(fabs(x1 - controlX * 5 / 8), y + h / 2)];
    [spath addQuadCurveToPoint:CGPointMake(x1, y + h - 40)
                 controlPoint:CGPointMake(x1, y + h * 3 / 4)];
    shapeLayer.path = spath.CGPath;
    
    float x2 = fabs(screenWidth - screenWidth * dir - controlX / 6);

    UIBezierPath* apath = [UIBezierPath new];
    if (controlX > 35) {
        [apath moveToPoint:CGPointMake(x2 + 5 * (controlX / (screenWidth / 4)), y + h * 15.3 / 32)];
        [apath addLineToPoint:CGPointMake(x2, y + h * 16 / 32)];
        [apath moveToPoint:CGPointMake(x2, y + h * 16 / 32)];
        [apath addLineToPoint:CGPointMake(x2 + 5 * (controlX / (screenWidth / 4)), y + h * 16.7 / 32)];
    }
    arrowLayer.path = apath.CGPath;
}

- (void)sendEvent {
    if (controlX > 35) {
        NSLog(@"Trigger swipe back event !!!");
    }
}

- (void)handlePanGesture:(UIGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        posY = [gesture locationInView:self.view].y;
        [self createLayer];
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        [self remoteLayer];
        [self sendEvent];
    } else if (gesture.state == UIGestureRecognizerStateCancelled) {
        [self remoteLayer];
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        [self updateLayer];
    }
}

- (void)onLeftPanGesture:(UIGestureRecognizer *)gesture {
    dir = 1;
    controlX = pow([gesture locationInView:self.view].x, 0.85);
    [self handlePanGesture:gesture];
}

- (void)onRightPanGesture:(UIGestureRecognizer *)gesture {
    dir = 0;
    controlX = pow(self.view.bounds.size.width - [gesture locationInView:self.view].x, 0.85);
    [self handlePanGesture:gesture];
}

@end

