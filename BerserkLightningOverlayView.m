#import "BerserkLightningOverlayView.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>

@interface BerserkLightningOverlayView ()

@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, assign) BOOL hasLastPoint;
@property (nonatomic, assign) NSTimeInterval lastHapticTimestamp;
@property (nonatomic, strong) UIImpactFeedbackGenerator *lightHapticGenerator;
@property (nonatomic, strong) UIImpactFeedbackGenerator *mediumHapticGenerator;
@property (nonatomic, strong) NSTimer *ambientTimer;

@end

@implementation BerserkLightningOverlayView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        self.clipsToBounds = NO;
        self.layer.masksToBounds = NO;

        _hasLastPoint = NO;
        _lastHapticTimestamp = 0;

        _lightHapticGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
        [_lightHapticGenerator prepare];

        _mediumHapticGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
        [_mediumHapticGenerator prepare];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return nil;
}

#pragma mark - Ambient Background Lightning (Фоновые молнии каждые 3 сек)

- (void)startAmbientLightning {
    [self stopAmbientLightning];
    [self scheduleNextAmbientStrike];
}

- (void)scheduleNextAmbientStrike {
    [self.ambientTimer invalidate];
    // Фоновые раскаты молний каждые 3 секунды
    CGFloat delay = 3.0f;
    __weak typeof(self) weakSelf = self;
    self.ambientTimer = [NSTimer scheduledTimerWithTimeInterval:delay
                                                        repeats:NO
                                                          block:^(NSTimer * _Nonnull timer) {
        [weakSelf triggerAmbientStrike];
        [weakSelf scheduleNextAmbientStrike];
    }];
}

- (void)triggerTapStrikeAt:(CGPoint)tapPoint {
    CGFloat startX = tapPoint.x + ((((CGFloat)arc4random() / 0xFFFFFFFF) - 0.5f) * 60.0f);
    CGPoint skyPoint = CGPointMake(startX, -10.0f);
    [self generateDramaticAmbientStrikeFrom:skyPoint to:tapPoint];
    [self spawnSparksAtPoint:tapPoint count:8];
    [self triggerHapticFeedback];
}

- (void)stopAmbientLightning {
    [self.ambientTimer invalidate];
    self.ambientTimer = nil;
    [self clearLightnings];
}

- (void)triggerAmbientStrike {
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    if (w <= 0 || h <= 0) {
        w = 320.0f;
        h = 568.0f;
    }

    // Случайная начальная точка в верхней части неба
    CGFloat startX = 20.0f + (((CGFloat)arc4random() / 0xFFFFFFFF) * (w - 40.0f));
    CGFloat startY = -10.0f;
    CGPoint start = CGPointMake(startX, startY);

    // Конечная точка раската молнии (в нижней или центральной половине экрана)
    CGFloat endX = 20.0f + (((CGFloat)arc4random() / 0xFFFFFFFF) * (w - 40.0f));
    CGFloat endY = h * (0.45f + (((CGFloat)arc4random() / 0xFFFFFFFF) * 0.45f));
    CGPoint end = CGPointMake(endX, endY);

    [self generateDramaticAmbientStrikeFrom:start to:end];
}

- (void)generateDramaticAmbientStrikeFrom:(CGPoint)start to:(CGPoint)end {
    UIBezierPath *mainPath = [UIBezierPath bezierPath];
    [mainPath moveToPoint:start];
    [self buildFractalLightningPath:mainPath
                               from:start
                                 to:end
                              depth:0
                           maxDepth:5
                       displacement:26.0f];

    // 1. Первичная мощная вспышка (Halo + Core)
    CAShapeLayer *halo = [CAShapeLayer layer];
    halo.path = mainPath.CGPath;
    halo.strokeColor = [UIColor colorWithRed:0.98 green:0.02 blue:0.06 alpha:0.90].CGColor;
    halo.fillColor = [UIColor clearColor].CGColor;
    halo.lineWidth = 6.5f;
    halo.lineCap = kCALineCapRound;
    halo.lineJoin = kCALineJoinRound;
    halo.shadowColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.05 alpha:1.0].CGColor;
    halo.shadowRadius = 24.0f;
    halo.shadowOpacity = 1.0f;
    halo.shadowOffset = CGSizeZero;
    [self.layer addSublayer:halo];

    CAShapeLayer *core = [CAShapeLayer layer];
    core.path = mainPath.CGPath;
    core.strokeColor = [UIColor colorWithRed:1.0 green:0.85 blue:0.85 alpha:0.98].CGColor;
    core.fillColor = [UIColor clearColor].CGColor;
    core.lineWidth = 2.2f;
    core.lineCap = kCALineCapRound;
    core.lineJoin = kCALineJoinRound;
    [self.layer addSublayer:core];

    [self fadeAndRemoveLayer:halo duration:0.32f];
    [self fadeAndRemoveLayer:core duration:0.26f];

    [self spawnSparksAtPoint:end count:5];

    // Тактильный раскат
    [self.mediumHapticGenerator impactOccurred];
    [self.mediumHapticGenerator prepare];

    // 2. Двойной вторичный разряд через 60 мс (эффект реальной кинематографичной молнии)
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.06 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!weakSelf) return;
        CAShapeLayer *aftershock = [CAShapeLayer layer];
        aftershock.path = mainPath.CGPath;
        aftershock.strokeColor = [UIColor colorWithRed:1.0 green:0.25 blue:0.25 alpha:0.85].CGColor;
        aftershock.fillColor = [UIColor clearColor].CGColor;
        aftershock.lineWidth = 3.2f;
        aftershock.lineCap = kCALineCapRound;
        aftershock.shadowColor = [UIColor redColor].CGColor;
        aftershock.shadowRadius = 14.0f;
        aftershock.shadowOpacity = 0.9f;
        aftershock.shadowOffset = CGSizeZero;
        [weakSelf.layer addSublayer:aftershock];

        [weakSelf fadeAndRemoveLayer:aftershock duration:0.22f];
    });
}

#pragma mark - Touch & Swipe Handler

- (void)handleTouchAtPoint:(CGPoint)point isStart:(BOOL)isStart isEnd:(BOOL)isEnd {
    if (isStart) {
        self.lastPoint = point;
        self.hasLastPoint = YES;
        [self spawnSparksAtPoint:point count:4];
        return;
    }

    if (isEnd) {
        if (self.hasLastPoint) {
            CGFloat dist = hypotf(point.x - self.lastPoint.x, point.y - self.lastPoint.y);
            if (dist > 8.0f) {
                [self generateLightningFrom:self.lastPoint to:point];
            }
        }
        self.hasLastPoint = NO;
        return;
    }

    if (!self.hasLastPoint) {
        self.lastPoint = point;
        self.hasLastPoint = YES;
        return;
    }

    CGFloat distance = hypotf(point.x - self.lastPoint.x, point.y - self.lastPoint.y);
    if (distance >= 10.0f) {
        [self generateLightningFrom:self.lastPoint to:point];
        self.lastPoint = point;
    }
}

- (void)clearLightnings {
    self.hasLastPoint = NO;
    NSArray<CALayer *> *sublayers = [self.layer.sublayers copy];
    for (CALayer *layer in sublayers) {
        [layer removeAllAnimations];
        [layer removeFromSuperlayer];
    }
}

#pragma mark - Procedural Lightning Generator (Яркие укрупненные разряды)

- (void)generateLightningFrom:(CGPoint)start to:(CGPoint)end {
    UIBezierPath *mainPath = [UIBezierPath bezierPath];
    [mainPath moveToPoint:start];
    [self buildFractalLightningPath:mainPath
                               from:start
                                 to:end
                              depth:0
                           maxDepth:4
                       displacement:18.0f];

    // 1. Увеличенный багровый ореол (Halo)
    CAShapeLayer *haloLayer = [CAShapeLayer layer];
    haloLayer.path = mainPath.CGPath;
    haloLayer.strokeColor = [UIColor colorWithRed:0.98 green:0.02 blue:0.06 alpha:0.90].CGColor;
    haloLayer.fillColor = [UIColor clearColor].CGColor;
    haloLayer.lineWidth = 5.8f; // Увеличено с 3.6f
    haloLayer.lineCap = kCALineCapRound;
    haloLayer.lineJoin = kCALineJoinRound;
    haloLayer.shadowColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0].CGColor;
    haloLayer.shadowRadius = 20.0f; // Увеличено с 8.0f
    haloLayer.shadowOpacity = 1.0f;
    haloLayer.shadowOffset = CGSizeZero;
    [self.layer addSublayer:haloLayer];

    // 2. Горячий ослепительный сердечник (Core)
    CAShapeLayer *coreLayer = [CAShapeLayer layer];
    coreLayer.path = mainPath.CGPath;
    coreLayer.strokeColor = [UIColor colorWithRed:1.0 green:0.88 blue:0.88 alpha:0.98].CGColor;
    coreLayer.fillColor = [UIColor clearColor].CGColor;
    coreLayer.lineWidth = 1.8f;
    coreLayer.lineCap = kCALineCapRound;
    coreLayer.lineJoin = kCALineJoinRound;
    [self.layer addSublayer:coreLayer];

    [self fadeAndRemoveLayer:haloLayer duration:0.26f];
    [self fadeAndRemoveLayer:coreLayer duration:0.22f];

    [self spawnSparksAtPoint:end count:4];
    [self triggerHapticFeedback];
}

- (void)buildFractalLightningPath:(UIBezierPath *)path
                             from:(CGPoint)start
                               to:(CGPoint)end
                            depth:(int)depth
                         maxDepth:(int)maxDepth
                     displacement:(CGFloat)disp {
    if (depth >= maxDepth) {
        [path addLineToPoint:end];
        return;
    }

    CGFloat dx = end.x - start.x;
    CGFloat dy = end.y - start.y;
    CGFloat len = sqrtf(dx * dx + dy * dy);
    if (len < 1.0f) {
        [path addLineToPoint:end];
        return;
    }

    CGPoint mid = CGPointMake((start.x + end.x) * 0.5f, (start.y + end.y) * 0.5f);

    CGFloat nx = -dy / len;
    CGFloat ny = dx / len;

    CGFloat randVal = (((CGFloat)arc4random() / 0xFFFFFFFF) - 0.5f) * 2.0f;
    mid.x += nx * randVal * disp;
    mid.y += ny * randVal * disp;

    [self buildFractalLightningPath:path
                               from:start
                                 to:mid
                              depth:depth + 1
                           maxDepth:maxDepth
                       displacement:disp * 0.55f];

    [self buildFractalLightningPath:path
                               from:mid
                                 to:end
                              depth:depth + 1
                           maxDepth:maxDepth
                       displacement:disp * 0.55f];

    // Ответвления боковых разрядов (30% шанс)
    if (depth == 1 && ((arc4random() % 3) == 0)) {
        CGFloat branchAngle = (((CGFloat)arc4random() / 0xFFFFFFFF) - 0.5f) * 1.4f;
        CGFloat branchLen = len * 0.45f;
        CGFloat bx = mid.x + (cosf(branchAngle) * dx - sinf(branchAngle) * dy) * (branchLen / len);
        CGFloat by = mid.y + (sinf(branchAngle) * dx + cosf(branchAngle) * dy) * (branchLen / len);
        [self spawnBranchFrom:mid to:CGPointMake(bx, by)];
    }
}

- (void)spawnBranchFrom:(CGPoint)start to:(CGPoint)end {
    UIBezierPath *branchPath = [UIBezierPath bezierPath];
    [branchPath moveToPoint:start];
    [self buildFractalLightningPath:branchPath
                               from:start
                                 to:end
                              depth:0
                           maxDepth:2
                       displacement:10.0f];

    CAShapeLayer *branchLayer = [CAShapeLayer layer];
    branchLayer.path = branchPath.CGPath;
    branchLayer.strokeColor = [UIColor colorWithRed:0.98 green:0.1 blue:0.1 alpha:0.85].CGColor;
    branchLayer.fillColor = [UIColor clearColor].CGColor;
    branchLayer.lineWidth = 2.4f;
    branchLayer.lineCap = kCALineCapRound;
    branchLayer.shadowColor = [UIColor redColor].CGColor;
    branchLayer.shadowRadius = 8.0f;
    branchLayer.shadowOpacity = 0.9f;
    branchLayer.shadowOffset = CGSizeZero;
    [self.layer addSublayer:branchLayer];

    [self fadeAndRemoveLayer:branchLayer duration:0.18f];
}

#pragma mark - Particle Sparks

- (void)spawnSparksAtPoint:(CGPoint)point count:(int)count {
    for (int i = 0; i < count; i++) {
        CGFloat angle = ((CGFloat)arc4random() / 0xFFFFFFFF) * 2.0f * M_PI;
        CGFloat dist = 6.0f + (((CGFloat)arc4random() / 0xFFFFFFFF) * 16.0f);
        CGPoint endPoint = CGPointMake(point.x + cosf(angle) * dist, point.y + sinf(angle) * dist);

        CAShapeLayer *spark = [CAShapeLayer layer];
        spark.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-1.5f, -1.5f, 3.0f, 3.0f)].CGPath;
        spark.position = point;
        spark.fillColor = [UIColor colorWithRed:1.0 green:0.35 blue:0.35 alpha:0.95].CGColor;
        spark.shadowColor = [UIColor redColor].CGColor;
        spark.shadowRadius = 6.0f;
        spark.shadowOpacity = 1.0f;
        [self.layer addSublayer:spark];

        CABasicAnimation *posAnim = [CABasicAnimation animationWithKeyPath:@"position"];
        posAnim.fromValue = [NSValue valueWithCGPoint:point];
        posAnim.toValue = [NSValue valueWithCGPoint:endPoint];
        posAnim.duration = 0.20f;

        CABasicAnimation *fadeAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeAnim.fromValue = @(1.0f);
        fadeAnim.toValue = @(0.0f);
        fadeAnim.duration = 0.20f;

        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [spark removeFromSuperlayer];
        }];
        [spark addAnimation:posAnim forKey:@"pos"];
        [spark addAnimation:fadeAnim forKey:@"fade"];
        spark.opacity = 0.0f;
        [CATransaction commit];
    }
}

#pragma mark - Animation Helpers

- (void)fadeAndRemoveLayer:(CALayer *)targetLayer duration:(NSTimeInterval)duration {
    CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fade.fromValue = @(1.0f);
    fade.toValue = @(0.0f);
    fade.duration = duration;
    fade.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];

    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [targetLayer removeFromSuperlayer];
    }];
    [targetLayer addAnimation:fade forKey:@"fade"];
    targetLayer.opacity = 0.0f;
    [CATransaction commit];
}

#pragma mark - Haptic Feedback

- (void)triggerHapticFeedback {
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    if (now - self.lastHapticTimestamp > 0.09) {
        self.lastHapticTimestamp = now;
        [self.lightHapticGenerator impactOccurred];
        [self.lightHapticGenerator prepare];
    }
}

- (void)dealloc {
    [_ambientTimer invalidate];
    _ambientTimer = nil;
}

@end
