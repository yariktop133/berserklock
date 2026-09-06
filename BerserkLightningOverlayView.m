#import "BerserkLightningOverlayView.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>

@interface BerserkLightningOverlayView ()

@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, assign) BOOL hasLastPoint;
@property (nonatomic, assign) NSTimeInterval lastHapticTimestamp;
@property (nonatomic, strong) UIImpactFeedbackGenerator *hapticGenerator;

@end

@implementation BerserkLightningOverlayView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO; // Пропускает тачи сквозь оверлей
        self.clipsToBounds = NO;
        self.layer.masksToBounds = NO;

        _hasLastPoint = NO;
        _lastHapticTimestamp = 0;

        _hapticGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
        [_hapticGenerator prepare];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    // Гарантируем, что оверлей прозрачен для всей системы тачей iOS
    return nil;
}

#pragma mark - Public Touch & Swipe Handler

- (void)handleTouchAtPoint:(CGPoint)point isStart:(BOOL)isStart isEnd:(BOOL)isEnd {
    if (isStart) {
        self.lastPoint = point;
        self.hasLastPoint = YES;
        [self spawnSparksAtPoint:point count:3];
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
    // Порог минимального сдвига для генерации молнии (предотвращает спам разрядами)
    if (distance >= 12.0f) {
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

#pragma mark - Procedural Lightning Generator

- (void)generateLightningFrom:(CGPoint)start to:(CGPoint)end {
    UIBezierPath *mainPath = [UIBezierPath bezierPath];
    [mainPath moveToPoint:start];
    [self buildFractalLightningPath:mainPath
                               from:start
                                 to:end
                              depth:0
                           maxDepth:4
                       displacement:16.0f];

    // 1. Внешнее багрово-кровавое свечение (Halo)
    CAShapeLayer *haloLayer = [CAShapeLayer layer];
    haloLayer.path = mainPath.CGPath;
    haloLayer.strokeColor = [UIColor colorWithRed:0.95 green:0.02 blue:0.08 alpha:0.85].CGColor;
    haloLayer.fillColor = [UIColor clearColor].CGColor;
    haloLayer.lineWidth = 3.6f;
    haloLayer.lineCap = kCALineCapRound;
    haloLayer.lineJoin = kCALineJoinRound;
    haloLayer.shadowColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.1 alpha:1.0].CGColor;
    haloLayer.shadowRadius = 8.0f;
    haloLayer.shadowOpacity = 1.0f;
    haloLayer.shadowOffset = CGSizeZero;
    [self.layer addSublayer:haloLayer];

    // 2. Внутренний горячий сердечник разряда (Core)
    CAShapeLayer *coreLayer = [CAShapeLayer layer];
    coreLayer.path = mainPath.CGPath;
    coreLayer.strokeColor = [UIColor colorWithRed:1.0 green:0.80 blue:0.80 alpha:0.95].CGColor;
    coreLayer.fillColor = [UIColor clearColor].CGColor;
    coreLayer.lineWidth = 1.2f;
    coreLayer.lineCap = kCALineCapRound;
    coreLayer.lineJoin = kCALineJoinRound;
    [self.layer addSublayer:coreLayer];

    // Анимация затухания и удаление слоев
    [self fadeAndRemoveLayer:haloLayer duration:0.24f];
    [self fadeAndRemoveLayer:coreLayer duration:0.20f];

    // Искры на конце дуги
    [self spawnSparksAtPoint:end count:2];

    // Тактильный отклик Taptic Engine
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

    // Нормаль перпендикуляра (-dy / len, dx / len)
    CGFloat nx = -dy / len;
    CGFloat ny = dx / len;

    // Случайное смещение
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

    // Вероятность 25% ответвления боковой мини-молнии
    if (depth == 1 && ((arc4random() % 4) == 0)) {
        CGFloat branchAngle = (((CGFloat)arc4random() / 0xFFFFFFFF) - 0.5f) * 1.3f;
        CGFloat branchLen = len * 0.40f;
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
                       displacement:8.0f];

    CAShapeLayer *branchLayer = [CAShapeLayer layer];
    branchLayer.path = branchPath.CGPath;
    branchLayer.strokeColor = [UIColor colorWithRed:0.95 green:0.1 blue:0.1 alpha:0.75].CGColor;
    branchLayer.fillColor = [UIColor clearColor].CGColor;
    branchLayer.lineWidth = 1.6f;
    branchLayer.lineCap = kCALineCapRound;
    branchLayer.shadowColor = [UIColor redColor].CGColor;
    branchLayer.shadowRadius = 5.0f;
    branchLayer.shadowOpacity = 0.8f;
    branchLayer.shadowOffset = CGSizeZero;
    [self.layer addSublayer:branchLayer];

    [self fadeAndRemoveLayer:branchLayer duration:0.16f];
}

#pragma mark - Particle Sparks

- (void)spawnSparksAtPoint:(CGPoint)point count:(int)count {
    for (int i = 0; i < count; i++) {
        CGFloat angle = ((CGFloat)arc4random() / 0xFFFFFFFF) * 2.0f * M_PI;
        CGFloat dist = 5.0f + (((CGFloat)arc4random() / 0xFFFFFFFF) * 12.0f);
        CGPoint endPoint = CGPointMake(point.x + cosf(angle) * dist, point.y + sinf(angle) * dist);

        CAShapeLayer *spark = [CAShapeLayer layer];
        spark.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-1.5f, -1.5f, 3.0f, 3.0f)].CGPath;
        spark.position = point;
        spark.fillColor = [UIColor colorWithRed:1.0 green:0.3 blue:0.3 alpha:0.9].CGColor;
        spark.shadowColor = [UIColor redColor].CGColor;
        spark.shadowRadius = 4.0f;
        spark.shadowOpacity = 0.9f;
        [self.layer addSublayer:spark];

        // Анимация полета искры
        CABasicAnimation *posAnim = [CABasicAnimation animationWithKeyPath:@"position"];
        posAnim.fromValue = [NSValue valueWithCGPoint:point];
        posAnim.toValue = [NSValue valueWithCGPoint:endPoint];
        posAnim.duration = 0.18f;

        CABasicAnimation *fadeAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeAnim.fromValue = @(1.0f);
        fadeAnim.toValue = @(0.0f);
        fadeAnim.duration = 0.18f;

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
    // Ограничение частоты виброотклика (не чаще 1 раза в 110 мс)
    if (now - self.lastHapticTimestamp > 0.11) {
        self.lastHapticTimestamp = now;
        [self.hapticGenerator impactOccurred];
        [self.hapticGenerator prepare];
    }
}

@end
