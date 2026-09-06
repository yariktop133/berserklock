#import "BerserkClockView.h"
#import <QuartzCore/QuartzCore.h>

@interface BerserkClockView ()

@property (nonatomic, strong) UILabel *timeLabel;
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
        self.userInteractionEnabled = NO; // Пропускаем нажатия сквозь часы

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
    // Локализованный формат: "ПОНЕДЕЛЬНИК, 6 СЕНТЯБРЯ"
    self.dateFormatter.locale = [NSLocale currentLocale];
    self.dateFormatter.dateFormat = @"EEEE, d MMMM";
}

- (void)setupSubviews {
    // 1. Отрисовка Клейма Жертвы (Brand of Sacrifice)
    self.brandGlowLayer = [CAShapeLayer layer];
    self.brandGlowLayer.fillColor = [UIColor clearColor].CGColor;
    self.brandGlowLayer.strokeColor = [UIColor colorWithRed:0.95 green:0.05 blue:0.1 alpha:0.75].CGColor;
    self.brandGlowLayer.lineWidth = 5.0f;
    self.brandGlowLayer.lineCap = kCALineCapRound;
    self.brandGlowLayer.lineJoin = kCALineJoinRound;
    self.brandGlowLayer.shadowColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.1 alpha:1.0].CGColor;
    self.brandGlowLayer.shadowRadius = 14.0f;
    self.brandGlowLayer.shadowOpacity = 0.95f;
    self.brandGlowLayer.shadowOffset = CGSizeZero;
    [self.layer addSublayer:self.brandGlowLayer];

    self.brandLayer = [CAShapeLayer layer];
    self.brandLayer.fillColor = [UIColor clearColor].CGColor;
    self.brandLayer.strokeColor = [UIColor colorWithRed:1.0 green:0.25 blue:0.25 alpha:1.0].CGColor;
    self.brandLayer.lineWidth = 2.4f;
    self.brandLayer.lineCap = kCALineCapRound;
    self.brandLayer.lineJoin = kCALineJoinRound;
    [self.layer addSublayer:self.brandLayer];

    // 2. Цифровое время
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.font = [UIFont monospacedDigitSystemFontOfSize:58.0f weight:UIFontWeightMedium];
    self.timeLabel.textColor = [UIColor colorWithRed:0.98 green:0.15 blue:0.15 alpha:1.0];
    self.timeLabel.layer.shadowColor = [UIColor colorWithRed:0.9 green:0.0 blue:0.0 alpha:0.9].CGColor;
    self.timeLabel.layer.shadowRadius = 10.0f;
    self.timeLabel.layer.shadowOpacity = 0.85f;
    self.timeLabel.layer.shadowOffset = CGSizeZero;
    [self addSubview:self.timeLabel];

    // 3. Дата
    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.textAlignment = NSTextAlignmentCenter;
    self.dateLabel.font = [UIFont systemFontOfSize:12.5f weight:UIFontWeightBold];
    self.dateLabel.textColor = [UIColor colorWithRed:0.85 green:0.45 blue:0.45 alpha:0.9];
    self.dateLabel.layer.shadowColor = [UIColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:0.7].CGColor;
    self.dateLabel.layer.shadowRadius = 5.0f;
    self.dateLabel.layer.shadowOpacity = 0.7f;
    self.dateLabel.layer.shadowOffset = CGSizeZero;
    [self addSubview:self.dateLabel];

    // 4. Тематическая подпись Берсерка (эстетика Затмения)
    self.quoteLabel = [[UILabel alloc] init];
    self.quoteLabel.textAlignment = NSTextAlignmentCenter;
    self.quoteLabel.font = [UIFont systemFontOfSize:9.5f weight:UIFontWeightHeavy];
    self.quoteLabel.textColor = [UIColor colorWithRed:0.70 green:0.20 blue:0.20 alpha:0.75];
    self.quoteLabel.text = @"― STRUGGLE, CONTEND, WRIGGLE ―";
    self.quoteLabel.layer.shadowColor = [UIColor colorWithRed:0.6 green:0.0 blue:0.0 alpha:0.6].CGColor;
    self.quoteLabel.layer.shadowRadius = 3.0f;
    self.quoteLabel.layer.shadowOpacity = 0.5f;
    self.quoteLabel.layer.shadowOffset = CGSizeZero;
    [self addSubview:self.quoteLabel];
}

#pragma mark - Geometry & Brand Path

+ (UIBezierPath *)brandOfSacrificePathInRect:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat w = rect.size.width;
    CGFloat h = rect.size.height;
    CGFloat ox = rect.origin.x;
    CGFloat oy = rect.origin.y;

    CGFloat sx = w / 100.0f;
    CGFloat sy = h / 140.0f;

    #define P(px, py) CGPointMake(ox + (px) * sx, oy + (py) * sy)

    // 1. Центральный вертикальный стержень
    [path moveToPoint:P(50, 10)];
    [path addLineToPoint:P(50, 130)];

    // 2. Левый изогнутый рог / дуга
    [path moveToPoint:P(50, 16)];
    [path addCurveToPoint:P(22, 44)
            controlPoint1:P(32, 10)
            controlPoint2:P(20, 24)];
    [path addCurveToPoint:P(50, 60)
            controlPoint1:P(24, 58)
            controlPoint2:P(38, 60)];

    // 3. Правый изогнутый рог / дуга
    [path moveToPoint:P(50, 16)];
    [path addCurveToPoint:P(78, 44)
            controlPoint1:P(68, 10)
            controlPoint2:P(80, 24)];
    [path addCurveToPoint:P(50, 60)
            controlPoint1:P(76, 58)
            controlPoint2:P(62, 60)];

    // 4. Центральное диагональное перекрестие (рунический узел)
    [path moveToPoint:P(25, 42)];
    [path addLineToPoint:P(75, 88)];

    [path moveToPoint:P(75, 42)];
    [path addLineToPoint:P(25, 88)];

    // 5. Нижние расходящиеся зубцы
    [path moveToPoint:P(50, 88)];
    [path addLineToPoint:P(28, 122)];

    [path moveToPoint:P(50, 88)];
    [path addLineToPoint:P(72, 122)];

    #undef P
    return path;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateLayoutForBounds:self.bounds];
}

- (void)updateLayoutForBounds:(CGRect)bounds {
    CGFloat totalWidth = bounds.size.width;
    
    // Клеймо сверху по центру
    CGFloat brandW = 42.0f;
    CGFloat brandH = 58.0f;
    CGFloat brandX = (totalWidth - brandW) / 2.0f;
    CGFloat brandY = 12.0f;
    CGRect brandRect = CGRectMake(brandX, brandY, brandW, brandH);

    UIBezierPath *brandPath = [BerserkClockView brandOfSacrificePathInRect:brandRect];
    self.brandGlowLayer.path = brandPath.CGPath;
    self.brandLayer.path = brandPath.CGPath;

    // Цифровые часы
    CGFloat timeY = brandY + brandH + 4.0f;
    self.timeLabel.frame = CGRectMake(10.0f, timeY, totalWidth - 20.0f, 62.0f);

    // Дата
    CGFloat dateY = timeY + 62.0f + 2.0f;
    self.dateLabel.frame = CGRectMake(10.0f, dateY, totalWidth - 20.0f, 18.0f);

    // Подпись Затмения
    CGFloat quoteY = dateY + 20.0f;
    self.quoteLabel.frame = CGRectMake(10.0f, quoteY, totalWidth - 20.0f, 14.0f);
}

#pragma mark - Animations

- (void)startPulseAnimation {
    [self.brandGlowLayer removeAnimationForKey:@"brandPulse"];

    // Зловещая пульсация Клейма (эффект биения сердца Затмения)
    CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    opacityAnim.fromValue = @(0.40f);
    opacityAnim.toValue = @(1.0f);

    CABasicAnimation *radiusAnim = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
    radiusAnim.fromValue = @(6.0f);
    radiusAnim.toValue = @(18.0f);

    CABasicAnimation *colorAnim = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
    colorAnim.fromValue = (id)[UIColor colorWithRed:0.7 green:0.0 blue:0.0 alpha:0.7].CGColor;
    colorAnim.toValue = (id)[UIColor colorWithRed:1.0 green:0.1 blue:0.1 alpha:1.0].CGColor;

    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[opacityAnim, radiusAnim, colorAnim];
    group.duration = 1.4f;
    group.autoreverses = YES;
    group.repeatCount = HUGE_VALF;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

    [self.brandGlowLayer addAnimation:group forKey:@"brandPulse"];
}

- (void)stopPulseAnimation {
    [self.brandGlowLayer removeAnimationForKey:@"brandPulse"];
}

#pragma mark - Lifecycle & Timer

- (void)startClock {
    [self updateTime];
    [self startPulseAnimation];

    [self.clockTimer invalidate];
    // Обновление каждую секунду для точности
    self.clockTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                       target:self
                                                     selector:@selector(updateTime)
                                                     userInfo:nil
                                                      repeats:YES];
}

- (void)stopClock {
    [self.clockTimer invalidate];
    self.clockTimer = nil;
    [self.stopPulseAnimation];
}

- (void)updateTime {
    NSDate *now = [NSDate date];
    self.timeLabel.text = [self.timeFormatter stringFromDate:now];
    self.dateLabel.text = [[self.dateFormatter stringFromDate:now] uppercaseString];
}

- (void)dealloc {
    [_clockTimer invalidate];
    _clockTimer = nil;
}

@end
