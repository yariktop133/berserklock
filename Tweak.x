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

// Предварительное объявление классов для Clang
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

    // 2. Свайпы по рабочему столу (между страницами иконок)
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

#pragma mark - Hook SBIconImageView (Стилизация ВСЕХ иконок рабочего стола)

%hook SBIconImageView

- (void)layoutSubviews {
    %orig;
    // Каждая иконка рабочего стола получает стальную окантовку и багровое свечение
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

#pragma mark - Hook WGWidgetPlatterView / SBIconView (Стилизация ВСЕХ виджетов рабочего стола)

%hook WGWidgetPlatterView

- (void)layoutSubviews {
    %orig;
    // Обсидиановый фон и кровавая окантовка для всех виджетов
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

%hook SBIconView

- (void)layoutSubviews {
    %orig;
    if ([self respondsToSelector:@selector(isWidgetIcon)] && [self isWidgetIcon]) {
        self.layer.cornerRadius = 18.0f;
        self.layer.borderWidth = 1.6f;
        self.layer.borderColor = [UIColor colorWithRed:0.90 green:0.10 blue:0.15 alpha:0.85].CGColor;
        self.layer.shadowColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.85].CGColor;
        self.layer.shadowRadius = 10.0f;
        self.layer.shadowOpacity = 0.55f;
        self.layer.shadowOffset = CGSizeZero;
    }
}

%end

#pragma mark - Hook Пункт управления (Control Center — Wi-Fi, фонарик, ползунки)

%hook CCUIRoundButton

- (void)layoutSubviews {
    %orig;
    self.layer.borderWidth = 1.2f;

    if (self.selected) {
        // Активный тумблер: пылающий кроваво-красный цвет с багровым неоном
        self.layer.borderColor = [UIColor colorWithRed:1.0 green:0.20 blue:0.20 alpha:1.0].CGColor;
        self.layer.shadowColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0].CGColor;
        self.layer.shadowRadius = 10.0f;
        self.layer.shadowOpacity = 0.9f;
        self.layer.shadowOffset = CGSizeZero;
        [self setBackgroundColor:[UIColor colorWithRed:0.92 green:0.08 blue:0.12 alpha:1.0]];
    } else {
        // Выключенный тумблер: вороненая сталь с легким алым кантом
        self.layer.borderColor = [UIColor colorWithRed:0.65 green:0.08 blue:0.12 alpha:0.5].CGColor;
        self.layer.shadowOpacity = 0.0f;
        [self setBackgroundColor:[UIColor colorWithRed:0.10 green:0.08 blue:0.10 alpha:0.85]];
    }
}

%end

%hook CCUIContinuousSliderView

- (void)layoutSubviews {
    %orig;
    // Слайдеры яркости и громкости
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

#pragma mark - Hook Системная клавиатура в стиле Berserk

%hook UIKBRenderConfig

- (BOOL)lightKeyboard {
    // Принудительно глубокая темная тема для клавиатуры во всей системе
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

#pragma mark - Hook SBFLockScreenDateView (Скрытие стоковых часов iOS 15)

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
