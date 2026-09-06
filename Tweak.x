#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "BerserkClockView.h"
#import "BerserkLightningOverlayView.h"

// Ключи для ассоциированных объектов
static const void *kBerserkClockKey = &kBerserkClockKey;
static const void *kBerserkLightningKey = &kBerserkLightningKey;
static const void *kBerserkPanGestureKey = &kBerserkPanGestureKey;

static const void *kBerserkHomeLightningKey = &kBerserkHomeLightningKey;
static const void *kBerserkHomePanKey = &kBerserkHomePanKey;

// Делегат для одновременного распознавания жестов
@interface BerserkGestureDelegate : NSObject <UIGestureRecognizerDelegate>
+ (instancetype)sharedInstance;
@end

@implementation BerserkGestureDelegate
+ (instancetype)sharedInstance {
    static BerserkGestureDelegate *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BerserkGestureDelegate alloc] init];
    });
    return instance;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}
@end

// Предварительное объявление системных классов для Clang
@interface CSCoverSheetViewController : UIViewController
- (void)berserk_handlePan:(UIPanGestureRecognizer *)pan;
@end

@interface SBHomeScreenViewController : UIViewController
- (void)berserk_handleHomePan:(UIPanGestureRecognizer *)pan;
@end

@interface SBFLockScreenDateView : UIView
@end

@interface SBIconImageView : UIView
@end

@interface SBIconView : UIView
- (BOOL)isWidgetIcon;
@end

@interface SBIconLabelView : UIView
@end

@interface WGWidgetPlatterView : UIView
@end

@interface CCUIRoundButton : UIControl
@property (nonatomic, assign, getter=isSelected) BOOL selected;
@end

@interface CCUIContinuousSliderView : UIControl
@end

@interface CCUIContentModuleContainerView : UIView
@end

@interface UIKBRenderConfig : NSObject
- (BOOL)lightKeyboard;
@end

@interface UIKeyboardDockView : UIView
@end

@interface UIKBKeyView : UIView
@end

@interface TPRevealingRingView : UIView
@end

@interface TPNumberPadButton : UIControl
@end

@interface SBUIPasscodeLockViewBase : UIView
@end

@interface SBUILabel : UILabel
@end

#pragma mark - Hook CSCoverSheetViewController (Экран блокировки)

%hook CSCoverSheetViewController

- (void)viewDidLoad {
    %orig;

    UIView *parentView = self.view;

    // 1. Оверлей молний на экране блокировки
    BerserkLightningOverlayView *overlay = [[BerserkLightningOverlayView alloc] initWithFrame:parentView.bounds];
    overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [parentView addSubview:overlay];
    objc_setAssociatedObject(self, kBerserkLightningKey, overlay, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    // 2. Жест свайпа по экрану блокировки
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(berserk_handlePan:)];
    pan.cancelsTouchesInView = NO;
    pan.delaysTouchesBegan = NO;
    pan.delaysTouchesEnded = NO;
    pan.delegate = [BerserkGestureDelegate sharedInstance];
    [parentView addGestureRecognizer:pan];
    objc_setAssociatedObject(self, kBerserkPanGestureKey, pan, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    // 3. Часы в стиле Берсерка (каноничное Клеймо + рунические цифры)
    CGFloat screenW = parentView.bounds.size.width > 0 ? parentView.bounds.size.width : 320.0f;
    CGRect clockFrame = CGRectMake(0, 36.0f, screenW, 230.0f);
    BerserkClockView *clockView = [[BerserkClockView alloc] initWithFrame:clockFrame];
    clockView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [parentView addSubview:clockView];
    objc_setAssociatedObject(self, kBerserkClockKey, clockView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    BerserkClockView *clockView = (BerserkClockView *)objc_getAssociatedObject(self, kBerserkClockKey);
    if (clockView) {
        [clockView startClock];
    }

    BerserkLightningOverlayView *overlay = (BerserkLightningOverlayView *)objc_getAssociatedObject(self, kBerserkLightningKey);
    if (overlay) {
        [overlay startAmbientLightning];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    %orig;
    BerserkClockView *clockView = (BerserkClockView *)objc_getAssociatedObject(self, kBerserkClockKey);
    if (clockView) {
        [clockView stopClock];
    }

    BerserkLightningOverlayView *overlay = (BerserkLightningOverlayView *)objc_getAssociatedObject(self, kBerserkLightningKey);
    if (overlay) {
        [overlay stopAmbientLightning];
        [overlay clearLightnings];
    }
}

- (void)viewDidLayoutSubviews {
    %orig;
    BerserkClockView *clockView = (BerserkClockView *)objc_getAssociatedObject(self, kBerserkClockKey);
    if (clockView) {
        clockView.frame = CGRectMake(0, 36.0f, self.view.bounds.size.width, 230.0f);
        [clockView updateLayoutForBounds:clockView.bounds];
    }

    BerserkLightningOverlayView *overlay = (BerserkLightningOverlayView *)objc_getAssociatedObject(self, kBerserkLightningKey);
    if (overlay) {
        overlay.frame = self.view.bounds;
    }
}

%new
- (void)berserk_handlePan:(UIPanGestureRecognizer *)pan {
    BerserkLightningOverlayView *overlay = (BerserkLightningOverlayView *)objc_getAssociatedObject(self, kBerserkLightningKey);
    if (!overlay) return;

    CGPoint point = [pan locationInView:self.view];

    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            [overlay handleTouchAtPoint:point isStart:YES isEnd:NO];
            break;
        case UIGestureRecognizerStateChanged:
            [overlay handleTouchAtPoint:point isStart:NO isEnd:NO];
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [overlay handleTouchAtPoint:point isStart:NO isEnd:YES];
            break;
        default:
            break;
    }
}

%end

#pragma mark - Hook SBHomeScreenViewController (Рабочий стол SpringBoard)

%hook SBHomeScreenViewController

- (void)viewDidLoad {
    %orig;

    UIView *homeView = self.view;

    // 1. Оверлей молний на рабочем столе
    BerserkLightningOverlayView *homeOverlay = [[BerserkLightningOverlayView alloc] initWithFrame:homeView.bounds];
    homeOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [homeView addSubview:homeOverlay];
    objc_setAssociatedObject(self, kBerserkHomeLightningKey, homeOverlay, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    // 2. Свайпы по рабочему столу
    UIPanGestureRecognizer *homePan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(berserk_handleHomePan:)];
    homePan.cancelsTouchesInView = NO;
    homePan.delaysTouchesBegan = NO;
    homePan.delaysTouchesEnded = NO;
    homePan.delegate = [BerserkGestureDelegate sharedInstance];
    [homeView addGestureRecognizer:homePan];
    objc_setAssociatedObject(self, kBerserkHomePanKey, homePan, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    BerserkLightningOverlayView *homeOverlay = (BerserkLightningOverlayView *)objc_getAssociatedObject(self, kBerserkHomeLightningKey);
    if (homeOverlay) {
        [homeOverlay startAmbientLightning];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    %orig;
    BerserkLightningOverlayView *homeOverlay = (BerserkLightningOverlayView *)objc_getAssociatedObject(self, kBerserkHomeLightningKey);
    if (homeOverlay) {
        [homeOverlay stopAmbientLightning];
        [homeOverlay clearLightnings];
    }
}

- (void)viewDidLayoutSubviews {
    %orig;
    BerserkLightningOverlayView *homeOverlay = (BerserkLightningOverlayView *)objc_getAssociatedObject(self, kBerserkHomeLightningKey);
    if (homeOverlay) {
        homeOverlay.frame = self.view.bounds;
    }
}

%new
- (void)berserk_handleHomePan:(UIPanGestureRecognizer *)pan {
    BerserkLightningOverlayView *homeOverlay = (BerserkLightningOverlayView *)objc_getAssociatedObject(self, kBerserkHomeLightningKey);
    if (!homeOverlay) return;

    CGPoint point = [pan locationInView:self.view];

    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            [homeOverlay handleTouchAtPoint:point isStart:YES isEnd:NO];
            break;
        case UIGestureRecognizerStateChanged:
            [homeOverlay handleTouchAtPoint:point isStart:NO isEnd:NO];
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [homeOverlay handleTouchAtPoint:point isStart:NO isEnd:YES];
            break;
        default:
            break;
    }
}

%end

#pragma mark - Hook Экран ввода пароля (Passcode Screen: кнопки, кольца, цифры)

%hook TPRevealingRingView

- (void)layoutSubviews {
    %orig;
    // Кольца кнопок пароля из кованой стали с неоновым багровым свечением
    self.layer.borderWidth = 1.4f;
    self.layer.borderColor = [UIColor colorWithRed:0.90 green:0.08 blue:0.12 alpha:0.80].CGColor;
    self.layer.shadowColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.9].CGColor;
    self.layer.shadowRadius = 8.0f;
    self.layer.shadowOpacity = 0.7f;
    self.layer.shadowOffset = CGSizeZero;
}

%end

%hook TPNumberPadButton

- (void)layoutSubviews {
    %orig;

    // Цифры на клавиатуре пароля: насыщенный кровавый цвет и свечение
    UILabel *numberLabel = nil;
    @try {
        numberLabel = [self valueForKey:@"_numberLabel"];
    } @catch (NSException *e) {}

    if (numberLabel && [numberLabel isKindOfClass:[UILabel class]]) {
        numberLabel.textColor = [UIColor colorWithRed:0.98 green:0.18 blue:0.18 alpha:1.0];
        numberLabel.layer.shadowColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.9].CGColor;
        numberLabel.layer.shadowRadius = 6.0f;
        numberLabel.layer.shadowOpacity = 0.85f;
        numberLabel.layer.shadowOffset = CGSizeZero;
    }

    // Буквы под цифрами (ABC, DEF...)
    UILabel *letterLabel = nil;
    @try {
        letterLabel = [self valueForKey:@"_letterLabel"];
    } @catch (NSException *e) {}

    if (letterLabel && [letterLabel isKindOfClass:[UILabel class]]) {
        letterLabel.textColor = [UIColor colorWithRed:0.75 green:0.35 blue:0.35 alpha:0.75];
    }
}

%end

%hook SBUIPasscodeLockViewBase

- (void)layoutSubviews {
    %orig;

    // Заголовки ввода пароля ("Введите код-пароль", "Неверный пароль")
    UILabel *statusTitle = nil;
    @try {
        statusTitle = [self valueForKey:@"_statusTitleView"];
    } @catch (NSException *e) {}

    if (statusTitle && [statusTitle isKindOfClass:[UILabel class]]) {
        statusTitle.textColor = [UIColor colorWithRed:0.95 green:0.20 blue:0.20 alpha:1.0];
        statusTitle.layer.shadowColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.9].CGColor;
        statusTitle.layer.shadowRadius = 8.0f;
        statusTitle.layer.shadowOpacity = 0.85f;
        statusTitle.layer.shadowOffset = CGSizeZero;
    }
}

%end

%hook SBUILabel

- (void)layoutSubviews {
    %orig;
    if (self.text.length > 0) {
        self.textColor = [UIColor colorWithRed:0.95 green:0.25 blue:0.25 alpha:1.0];
        self.layer.shadowColor = [UIColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:0.7].CGColor;
        self.layer.shadowRadius = 4.0f;
        self.layer.shadowOpacity = 0.6f;
        self.layer.shadowOffset = CGSizeZero;
    }
}

%end

#pragma mark - Hook Системная типографика (Названия иконок на рабочем столе)

%hook SBIconView

- (void)layoutSubviews {
    %orig;

    // Стилизация виджетов
    if ([self respondsToSelector:@selector(isWidgetIcon)] && [self isWidgetIcon]) {
        self.layer.cornerRadius = 18.0f;
        self.layer.borderWidth = 1.6f;
        self.layer.borderColor = [UIColor colorWithRed:0.90 green:0.10 blue:0.15 alpha:0.85].CGColor;
        self.layer.shadowColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.85].CGColor;
        self.layer.shadowRadius = 10.0f;
        self.layer.shadowOpacity = 0.55f;
        self.layer.shadowOffset = CGSizeZero;
    }

    // Стилизация подписей иконок
    UIView *labelView = nil;
    @try {
        labelView = [self valueForKey:@"_labelView"];
    } @catch (NSException *e) {}

    if (labelView) {
        labelView.layer.shadowColor = [UIColor colorWithRed:0.85 green:0.0 blue:0.0 alpha:0.8].CGColor;
        labelView.layer.shadowRadius = 3.5f;
        labelView.layer.shadowOpacity = 0.75f;
        labelView.layer.shadowOffset = CGSizeZero;
    }
}

%end

%hook SBIconLabelView

- (void)layoutSubviews {
    %orig;
    self.layer.shadowColor = [UIColor colorWithRed:0.9 green:0.0 blue:0.0 alpha:0.8].CGColor;
    self.layer.shadowRadius = 3.0f;
    self.layer.shadowOpacity = 0.7f;
    self.layer.shadowOffset = CGSizeZero;
}

%end

#pragma mark - Hook SBIconImageView (Стилизация ВСЕХ иконок)

%hook SBIconImageView

- (void)layoutSubviews {
    %orig;
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 14.0f;
    self.layer.borderWidth = 1.4f;
    self.layer.borderColor = [UIColor colorWithRed:0.85 green:0.08 blue:0.12 alpha:0.75].CGColor;
    self.layer.shadowColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.8].CGColor;
    self.layer.shadowRadius = 5.0f;
    self.layer.shadowOpacity = 0.6f;
    self.layer.shadowOffset = CGSizeZero;
}

%end

#pragma mark - Hook WGWidgetPlatterView (Виджеты)

%hook WGWidgetPlatterView

- (void)layoutSubviews {
    %orig;
    self.layer.cornerRadius = 18.0f;
    self.layer.borderWidth = 1.6f;
    self.layer.borderColor = [UIColor colorWithRed:0.90 green:0.10 blue:0.15 alpha:0.85].CGColor;
    self.layer.shadowColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.85].CGColor;
    self.layer.shadowRadius = 10.0f;
    self.layer.shadowOpacity = 0.55f;
    self.layer.shadowOffset = CGSizeZero;
    self.backgroundColor = [UIColor colorWithRed:0.08 green:0.06 blue:0.08 alpha:0.90];
}

%end

#pragma mark - Hook Пункт управления (Control Center)

%hook CCUIRoundButton

- (void)layoutSubviews {
    %orig;
    self.layer.borderWidth = 1.2f;

    if (self.selected) {
        self.layer.borderColor = [UIColor colorWithRed:1.0 green:0.20 blue:0.20 alpha:1.0].CGColor;
        self.layer.shadowColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0].CGColor;
        self.layer.shadowRadius = 10.0f;
        self.layer.shadowOpacity = 0.9f;
        self.layer.shadowOffset = CGSizeZero;
        [self setBackgroundColor:[UIColor colorWithRed:0.92 green:0.08 blue:0.12 alpha:1.0]];
    } else {
        self.layer.borderColor = [UIColor colorWithRed:0.65 green:0.08 blue:0.12 alpha:0.5].CGColor;
        self.layer.shadowOpacity = 0.0f;
        [self setBackgroundColor:[UIColor colorWithRed:0.10 green:0.08 blue:0.10 alpha:0.85]];
    }
}

%end

%hook CCUIContinuousSliderView

- (void)layoutSubviews {
    %orig;
    self.layer.cornerRadius = 16.0f;
    self.layer.borderWidth = 1.4f;
    self.layer.borderColor = [UIColor colorWithRed:0.85 green:0.10 blue:0.15 alpha:0.75].CGColor;
    self.layer.shadowColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.8].CGColor;
    self.layer.shadowRadius = 8.0f;
    self.layer.shadowOpacity = 0.5f;

    UIView *valueIndicator = nil;
    @try {
        valueIndicator = [self valueForKey:@"_valueIndicator"];
    } @catch (NSException *e) {}

    if (valueIndicator) {
        valueIndicator.backgroundColor = [UIColor colorWithRed:0.95 green:0.12 blue:0.16 alpha:0.95];
    }
}

%end

%hook CCUIContentModuleContainerView

- (void)layoutSubviews {
    %orig;
    self.layer.cornerRadius = 18.0f;
    self.layer.borderWidth = 1.4f;
    self.layer.borderColor = [UIColor colorWithRed:0.8 green:0.08 blue:0.12 alpha:0.5].CGColor;
}

%end

#pragma mark - Hook Системная клавиатура

%hook UIKBRenderConfig

- (BOOL)lightKeyboard {
    return NO;
}

- (void)setLightKeyboard:(BOOL)light {
    %orig(NO);
}

%end

%hook UIKeyboardDockView

- (void)layoutSubviews {
    %orig;
    self.backgroundColor = [UIColor colorWithRed:0.08 green:0.06 blue:0.08 alpha:0.95];
}

%end

%hook UIKBKeyView

- (void)layoutSubviews {
    %orig;
    self.layer.cornerRadius = 6.0f;
    self.layer.borderWidth = 0.8f;
    self.layer.borderColor = [UIColor colorWithRed:0.75 green:0.10 blue:0.15 alpha:0.45].CGColor;
}

%end

#pragma mark - Hook SBFLockScreenDateView (Скрытие стоковых часов)

%hook SBFLockScreenDateView

- (void)didMoveToWindow {
    %orig;
    self.hidden = YES;
    self.alpha = 0.0f;
}

- (void)layoutSubviews {
    %orig;
    self.hidden = YES;
    self.alpha = 0.0f;
}

- (void)setAlpha:(CGFloat)alpha {
    %orig(0.0f);
}

- (void)setHidden:(BOOL)hidden {
    %orig(YES);
}

%end
