#import "BerserkHomeWidgetView.h"
#import "BerserkRunicRenderer.h"
#import <QuartzCore/QuartzCore.h>

@interface BerserkHomeWidgetView ()

@property (nonatomic, strong) CAShapeLayer *brandLayer;
@property (nonatomic, strong) CAShapeLayer *brandGlowLayer;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *batteryTrack;
@property (nonatomic, strong) UIView *batteryFill;
@property (nonatomic, strong) UILabel *batteryPercentLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation BerserkHomeWidgetView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.06 green:0.06 blue:0.08 alpha:0.78];
        self.layer.cornerRadius = 14.0f;
        self.layer.borderWidth = 1.0f;
        self.layer.borderColor = [UIColor colorWithRed:0.80 green:0.12 blue:0.12 alpha:0.45].CGColor;
        self.layer.shadowColor = [UIColor colorWithRed:0.9 green:0.0 blue:0.0 alpha:0.6].CGColor;
        self.layer.shadowRadius = 8.0f;
        self.layer.shadowOpacity = 0.5f;
        self.layer.shadowOffset = CGSizeMake(0, 2);

        [UIDevice currentDevice].batteryMonitoringEnabled = YES;

        [self setupFormatters];
        [self setupSubviews];
        [self updateBatteryAndState];
    }
    return self;
}

- (void)setupFormatters {
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.locale = [NSLocale currentLocale];
    self.dateFormatter.dateFormat = @"d MMM";
}

- (void)setupSubviews {
    // 1. Миниатюрное пульсирующее Клеймо
    self.brandGlowLayer = [CAShapeLayer layer];
    self.brandGlowLayer.fillColor = [UIColor clearColor].CGColor;
    self.brandGlowLayer.strokeColor = [UIColor colorWithRed:0.95 green:0.05 blue:0.1 alpha:0.8].CGColor;
    self.brandGlowLayer.lineWidth = 3.0f;
    self.brandGlowLayer.lineCap = kCALineCapRound;
    self.brandGlowLayer.lineJoin = kCALineJoinRound;
    self.brandGlowLayer.shadowColor = [UIColor redColor].CGColor;
    self.brandGlowLayer.shadowRadius = 8.0f;
    self.brandGlowLayer.shadowOpacity = 0.9f;
    [self.layer addSublayer:self.brandGlowLayer];

    self.brandLayer = [CAShapeLayer layer];
    self.brandLayer.fillColor = [UIColor clearColor].CGColor;
    self.brandLayer.strokeColor = [UIColor colorWithRed:1.0 green:0.3 blue:0.3 alpha:1.0].CGColor;
    self.brandLayer.lineWidth = 1.6f;
    self.brandLayer.lineCap = kCALineCapRound;
    self.brandLayer.lineJoin = kCALineJoinRound;
    [self.layer addSublayer:self.brandLayer];

    // 2. Заголовок шкалы (Шкала Ярости / Rage Meter)
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:10.0f weight:UIFontWeightHeavy];
    self.titleLabel.textColor = [UIColor colorWithRed:0.90 green:0.35 blue:0.35 alpha:0.95];
    self.titleLabel.text = @"BERSERK RAGE";
    self.titleLabel.layer.shadowColor = [UIColor redColor].CGColor;
    self.titleLabel.layer.shadowRadius = 3.0f;
    self.titleLabel.layer.shadowOpacity = 0.5f;
    [self addSubview:self.titleLabel];

    // 3. Дорожка шкалы крови/батареи
    self.batteryTrack = [[UIView alloc] init];
    self.batteryTrack.backgroundColor = [UIColor colorWithRed:0.18 green:0.05 blue:0.05 alpha:0.8];
    self.batteryTrack.layer.cornerRadius = 4.0f;
    self.batteryTrack.layer.borderWidth = 0.8f;
    self.batteryTrack.layer.borderColor = [UIColor colorWithRed:0.5 green:0.1 blue:0.1 alpha:0.5].CGColor;
    self.batteryTrack.clipsToBounds = YES;
    [self addSubview:self.batteryTrack];

    // 4. Заливка шкалы крови
    self.batteryFill = [[UIView alloc] init];
    self.batteryFill.backgroundColor = [UIColor colorWithRed:0.95 green:0.10 blue:0.15 alpha:1.0];
    self.batteryFill.layer.shadowColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0].CGColor;
    self.batteryFill.layer.shadowRadius = 6.0f;
    self.batteryFill.layer.shadowOpacity = 0.9f;
    [self.batteryTrack addSubview:self.batteryFill];

    // 5. Проценты
    self.batteryPercentLabel = [[UILabel alloc] init];
    self.batteryPercentLabel.font = [UIFont systemFontOfSize:9.0f weight:UIFontWeightBold];
    self.batteryPercentLabel.textColor = [UIColor colorWithRed:1.0 green:0.85 blue:0.85 alpha:1.0];
    self.batteryPercentLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.batteryPercentLabel];

    // 6. Дата справа
    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.font = [UIFont systemFontOfSize:11.0f weight:UIFontWeightBold];
    self.dateLabel.textColor = [UIColor colorWithRed:0.85 green:0.40 blue:0.40 alpha:0.9];
    self.dateLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:self.dateLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat h = self.bounds.size.height;
    CGFloat w = self.bounds.size.width;

    // 1. Мини-клеймо слева
    CGFloat brandW = 20.0f;
    CGFloat brandH = 28.0f;
    CGFloat brandX = 14.0f;
    CGFloat brandY = (h - brandH) * 0.5f;
    CGRect brandRect = CGRectMake(brandX, brandY, brandW, brandH);

    UIBezierPath *bPath = [BerserkRunicRenderer canonicalBrandOfSacrificeInRect:brandRect];
    self.brandGlowLayer.path = bPath.CGPath;
    self.brandLayer.path = bPath.CGPath;

    // 2. Блок контента в центре
    CGFloat contentX = brandX + brandW + 12.0f;
    CGFloat dateW = 55.0f;
    CGFloat trackW = w - contentX - dateW - 14.0f;
    if (trackW < 80.0f) trackW = 80.0f;

    self.titleLabel.frame = CGRectMake(contentX, 10.0f, trackW, 12.0f);

    CGFloat trackH = 8.0f;
    CGFloat trackY = 25.0f;
    self.batteryTrack.frame = CGRectMake(contentX, trackY, trackW, trackH);

    self.batteryPercentLabel.frame = CGRectMake(contentX + trackW + 6.0f, trackY - 2.0f, 35.0f, 12.0f);

    self.dateLabel.frame = CGRectMake(w - dateW - 12.0f, (h - 16.0f) * 0.5f, dateW, 16.0f);

    [self updateBatteryFillAnimated:NO];
}

- (void)updateBatteryFillAnimated:(BOOL)animated {
    float rawLevel = [UIDevice currentDevice].batteryLevel;
    float level = (rawLevel < 0.0f) ? 1.0f : rawLevel; // Fallback если не инициализирован
    int percent = (int)(level * 100.0f);

    self.batteryPercentLabel.text = [NSString stringWithFormat:@"%d%%", percent];

    CGFloat trackW = self.batteryTrack.bounds.size.width;
    CGFloat trackH = self.batteryTrack.bounds.size.height;
    CGFloat fillW = trackW * level;
    if (fillW < 2.0f) fillW = 2.0f;

    void (^updateBlock)(void) = ^{
        self.batteryFill.frame = CGRectMake(0, 0, fillW, trackH);
    };

    if (animated) {
        [UIView animateWithDuration:0.35 animations:updateBlock];
    } else {
        updateBlock();
    }
}

- (void)updateBatteryAndState {
    [self updateBatteryFillAnimated:YES];
    self.dateLabel.text = [[self.dateFormatter stringFromDate:[NSDate date]] uppercaseString];
}

#pragma mark - Lifecycle

- (void)startWidget {
    [self updateBatteryAndState];

    // Пульсация мини-клейма
    CABasicAnimation *pulse = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    pulse.fromValue = @(0.35f);
    pulse.toValue = @(1.0f);
    pulse.duration = 1.2f;
    pulse.autoreverses = YES;
    pulse.repeatCount = HUGE_VALF;
    [self.brandGlowLayer addAnimation:pulse forKey:@"miniPulse"];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBatteryAndState)
                                                 name:UIDeviceBatteryLevelDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBatteryAndState)
                                                 name:UIDeviceBatteryStateDidChangeNotification
                                               object:nil];
}

- (void)stopWidget {
    [self.brandGlowLayer removeAnimationForKey:@"miniPulse"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
