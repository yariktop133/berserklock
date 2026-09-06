#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "BerserkClockView.h"
#import "BerserkLightningOverlayView.h"
#import "BerserkHomeWidgetView.h"

// Ключи для ассоциированных объектов
static const void *kBerserkClockKey = &kBerserkClockKey;
static const void *kBerserkLightningKey = &kBerserkLightningKey;
static const void *kBerserkPanGestureKey = &kBerserkPanGestureKey;

static const void *kBerserkHomeLightningKey = &kBerserkHomeLightningKey;
static const void *kBerserkHomeWidgetKey = &kBerserkHomeWidgetKey;
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

// Предварительное объявление классов SpringBoard для Clang
@interface CSCoverSheetViewController : UIViewController
- (void)berserk_handlePan:(UIPanGestureRecognizer *)pan;
@end

@interface SBHomeScreenViewController : UIViewController
- (void)berserk_handleHomePan:(UIPanGestureRecognizer *)pan;
@end

@interface SBFLockScreenDateView : UIView
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

    // 3. Виджет рабочего стола (Шкала Ярости / Батарея + мини-Клеймо)
    CGFloat widgetW = homeView.bounds.size.width - 24.0f;
    if (widgetW <= 0) widgetW = 296.0f;
    CGRect widgetFrame = CGRectMake(12.0f, 28.0f, widgetW, 46.0f);
    BerserkHomeWidgetView *widget = [[BerserkHomeWidgetView alloc] initWithFrame:widgetFrame];
    widget.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [homeView addSubview:widget];
    objc_setAssociatedObject(self, kBerserkHomeWidgetKey, widget, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    BerserkLightningOverlayView *homeOverlay = (BerserkLightningOverlayView *)objc_getAssociatedObject(self, kBerserkHomeLightningKey);
    if (homeOverlay) {
        [homeOverlay startAmbientLightning];
    }

    BerserkHomeWidgetView *widget = (BerserkHomeWidgetView *)objc_getAssociatedObject(self, kBerserkHomeWidgetKey);
    if (widget) {
        [widget startWidget];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    %orig;
    BerserkLightningOverlayView *homeOverlay = (BerserkLightningOverlayView *)objc_getAssociatedObject(self, kBerserkHomeLightningKey);
    if (homeOverlay) {
        [homeOverlay stopAmbientLightning];
        [homeOverlay clearLightnings];
    }

    BerserkHomeWidgetView *widget = (BerserkHomeWidgetView *)objc_getAssociatedObject(self, kBerserkHomeWidgetKey);
    if (widget) {
        [widget stopWidget];
    }
}

- (void)viewDidLayoutSubviews {
    %orig;
    BerserkLightningOverlayView *homeOverlay = (BerserkLightningOverlayView *)objc_getAssociatedObject(self, kBerserkHomeLightningKey);
    if (homeOverlay) {
        homeOverlay.frame = self.view.bounds;
    }

    BerserkHomeWidgetView *widget = (BerserkHomeWidgetView *)objc_getAssociatedObject(self, kBerserkHomeWidgetKey);
    if (widget) {
        widget.frame = CGRectMake(12.0f, 28.0f, self.view.bounds.size.width - 24.0f, 46.0f);
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
