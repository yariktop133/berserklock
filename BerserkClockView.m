#import "BerserkClockView.h"
#import "BerserkRunicRenderer.h"
#import <QuartzCore/QuartzCore.h>

@interface BerserkClockView ()

@property (nonatomic, strong) CAShapeLayer *timeGlowLayer;
@property (nonatomic, strong) CAShapeLayer *timeLayer;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *quoteLabel;
@property (nonatomic, strong) CAShapeLayer *brandGlowLayer;
@property (nonatomic, strong) CAShapeLayer *brandLayer;
@property (nonatomic, strong) NSTimer *clockTimer;
@property (nonatomic, strong) NSDateFormatter *timeFormatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation BerserkClockView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;

        [self setupFormatters];
        [self setupSubviews];
        [self updateTime];
    }
    return self;
}

- (void)setupFormatters {
    self.timeFormatter = [[NSDateFormatter alloc] init];
    self.timeFormatter.dateFormat = @"HH:mm";

    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.locale = [NSLocale currentLocale];
    self.dateFormatter.dateFormat = @"EEEE, d MMMM";
}

- (void)setupSubviews {
    // 1. Каноничное Клеймо Жертвы (Brand of Sacrifice)
    self.brandGlowLayer = [CAShapeLayer layer];
    self.brandGlowLayer.fillColor = [UIColor clearColor].CGColor;
    self.brandGlowLayer.strokeColor = [UIColor colorWithRed:0.95 green:0.02 blue:0.08 alpha:0.85].CGColor;
    self.brandGlowLayer.lineWidth = 5.2f;
    self.brandGlowLayer.lineCap = kCALineCapRound;
    self.brandGlowLayer.lineJoin = kCALineJoinRound;
    self.brandGlowLayer.shadowColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0].CGColor;
    self.brandGlowLayer.shadowRadius = 18.0f;
    self.brandGlowLayer.shadowOpacity = 1.0f;
    self.brandGlowLayer.shadowOffset = CGSizeZero;
    [self.layer addSublayer:self.brandGlowLayer];

    self.brandLayer = [CAShapeLayer layer];
    self.brandLayer.fillColor = [UIColor clearColor].CGColor;
    self.brandLayer.strokeColor = [UIColor colorWithRed:1.0 green:0.35 blue:0.35 alpha:1.0].CGColor;
    self.brandLayer.lineWidth = 2.4f;
    self.brandLayer.lineCap = kCALineCapRound;
    self.brandLayer.lineJoin = kCALineJoinRound;
    [self.layer addSublayer:self.brandLayer];

    // 2. Рунические цифры времени в стиле Берсерка
    self.timeGlowLayer = [CAShapeLayer layer];
    self.timeGlowLayer.fillColor = [UIColor clearColor].CGColor;
    self.timeGlowLayer.strokeColor = [UIColor colorWithRed:0.95 green:0.05 blue:0.08 alpha:0.80].CGColor;
    self.timeGlowLayer.lineWidth = 4.8f;
    self.timeGlowLayer.lineCap = kCALineCapRound;
    self.timeGlowLayer.lineJoin = kCALineJoinRound;
    self.timeGlowLayer.shadowColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0].CGColor;
    self.timeGlowLayer.shadowRadius = 14.0f;
    self.timeGlowLayer.shadowOpacity = 0.95f;
    self.timeGlowLayer.shadowOffset = CGSizeZero;
    [self.layer addSublayer:self.timeGlowLayer];

    self.timeLayer = [CAShapeLayer layer];
    self.timeLayer.fillColor = [UIColor clearColor].CGColor;
    self.timeLayer.strokeColor = [UIColor colorWithRed:1.0 green:0.55 blue:0.55 alpha:1.0].CGColor;
    self.timeLayer.lineWidth = 2.2f;
    self.timeLayer.lineCap = kCALineCapRound;
    self.timeLayer.lineJoin = kCALineJoinRound;
    [self.layer addSublayer:self.timeLayer];

    // 3. Дата
    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.textAlignment = NSTextAlignmentCenter;
    self.dateLabel.font = [UIFont systemFontOfSize:12.5f weight:UIFontWeightBold];
    self.dateLabel.textColor = [UIColor colorWithRed:0.90 green:0.40 blue:0.40 alpha:0.95];
    self.dateLabel.layer.shadowColor = [UIColor colorWithRed:0.9 green:0.0 blue:0.0 alpha:0.8].CGColor;
    self.dateLabel.layer.shadowRadius = 6.0f;
    self.dateLabel.layer.shadowOpacity = 0.8f;
    self.dateLabel.layer.shadowOffset = CGSizeZero;
    [self addSubview:self.dateLabel];

    // 4. Подпись Затмения
    self.quoteLabel = [[UILabel alloc] init];
    self.quoteLabel.textAlignment = NSTextAlignmentCenter;
    self.quoteLabel.font = [UIFont systemFontOfSize:9.5f weight:UIFontWeightHeavy];
    self.quoteLabel.textColor = [UIColor colorWithRed:0.75 green:0.18 blue:0.18 alpha:0.85];
    self.quoteLabel.text = @"― STRUGGLE, CONTEND, WRIGGLE ―";
    self.quoteLabel.layer.shadowColor = [UIColor colorWithRed:0.7 green:0.0 blue:0.0 alpha:0.7].CGColor;
    self.quoteLabel.layer.shadowRadius = 4.0f;
    self.quoteLabel.layer.shadowOpacity = 0.6f;
    self.quoteLabel.layer.shadowOffset = CGSizeZero;
    [self addSubview:self.quoteLabel];
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateLayoutForBounds:self.bounds];
}

- (void)updateLayoutForBounds:(CGRect)bounds {
    CGFloat totalWidth = bounds.size.width;
    if (totalWidth <= 0) totalWidth = 320.0f;

    // 1. Каноничное Клеймо Жертвы
    CGFloat brandW = 44.0f;
    CGFloat brandH = 62.0f;
    CGFloat brandX = (totalWidth - brandW) / 2.0f;
    CGFloat brandY = 8.0f;
    CGRect brandRect = CGRectMake(brandX, brandY, brandW, brandH);

    UIBezierPath *brandPath = [BerserkRunicRenderer canonicalBrandOfSacrificeInRect:brandRect];
    self.brandGlowLayer.path = brandPath.CGPath;
    self.brandLayer.path = brandPath.CGPath;

    // 2. Рунические часы
    CGFloat timeW = totalWidth * 0.72f;
    if (timeW > 250.0f) timeW = 250.0f;
    CGFloat timeH = 54.0f;
    CGFloat timeX = (totalWidth - timeW) / 2.0f;
    CGFloat timeY = brandY + brandH + 6.0f;
    CGRect timeRect = CGRectMake(timeX, timeY, timeW, timeH);

    NSString *timeStr = [self.timeFormatter stringFromDate:[NSDate date]];
    UIBezierPath *timePath = [BerserkRunicRenderer pathForTimeString:timeStr inRect:timeRect];
    self.timeGlowLayer.path = timePath.CGPath;
    self.timeLayer.path = timePath.CGPath;

    // 3. Дата
    CGFloat dateY = timeY + timeH + 6.0f;
    self.dateLabel.frame = CGRectMake(10.0f, dateY, totalWidth - 20.0f, 18.0f);

    // 4. Подпись Затмения
    CGFloat quoteY = dateY + 20.0f;
    self.quoteLabel.frame = CGRectMake(10.0f, quoteY, totalWidth - 20.0f, 14.0f);
}

#pragma mark - Animations

- (void)startPulseAnimation {
    [self.brandGlowLayer removeAnimationForKey:@"brandPulse"];
    [self.timeGlowLayer removeAnimationForKey:@"timePulse"];

    // Зловещая пульсация (сердцебиение Затмения)
    CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    opacityAnim.fromValue = @(0.45f);
    opacityAnim.toValue = @(1.0f);

    CABasicAnimation *radiusAnim = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
    radiusAnim.fromValue = @(8.0f);
    radiusAnim.toValue = @(22.0f);

    CABasicAnimation *colorAnim = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
    colorAnim.fromValue = (id)[UIColor colorWithRed:0.75 green:0.0 blue:0.0 alpha:0.7].CGColor;
    colorAnim.toValue = (id)[UIColor colorWithRed:1.0 green:0.1 blue:0.1 alpha:1.0].CGColor;

    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[opacityAnim, radiusAnim, colorAnim];
    group.duration = 1.35f;
    group.autoreverses = YES;
    group.repeatCount = HUGE_VALF;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

    [self.brandGlowLayer addAnimation:group forKey:@"brandPulse"];
    [self.timeGlowLayer addAnimation:group forKey:@"timePulse"];
}

- (void)stopPulseAnimation {
    [self.brandGlowLayer removeAnimationForKey:@"brandPulse"];
    [self.timeGlowLayer removeAnimationForKey:@"timePulse"];
}

#pragma mark - Lifecycle & Timer

- (void)startClock {
    [self updateTime];
    [self startPulseAnimation];

    [self.clockTimer invalidate];
    self.clockTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                       target:self
                                                     selector:@selector(updateTime)
                                                     userInfo:nil
                                                      repeats:YES];
}

- (void)stopClock {
    [self.clockTimer invalidate];
    self.clockTimer = nil;
    [self stopPulseAnimation];
}

- (void)updateTime {
    NSDate *now = [NSDate date];
    NSString *timeStr = [self.timeFormatter stringFromDate:now];

    CGFloat totalWidth = self.bounds.size.width;
    if (totalWidth <= 0) totalWidth = 320.0f;
    CGFloat timeW = totalWidth * 0.72f;
    if (timeW > 250.0f) timeW = 250.0f;
    CGFloat timeH = 54.0f;
    CGFloat timeX = (totalWidth - timeW) / 2.0f;
    CGFloat timeY = 8.0f + 62.0f + 6.0f;
    CGRect timeRect = CGRectMake(timeX, timeY, timeW, timeH);

    UIBezierPath *timePath = [BerserkRunicRenderer pathForTimeString:timeStr inRect:timeRect];
    self.timeGlowLayer.path = timePath.CGPath;
    self.timeLayer.path = timePath.CGPath;

    self.dateLabel.text = [[self.dateFormatter stringFromDate:now] uppercaseString];
}

- (void)dealloc {
    [_clockTimer invalidate];
    _clockTimer = nil;
}

@end
