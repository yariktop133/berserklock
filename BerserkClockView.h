#import <UIKit/UIKit.h>

@interface BerserkClockView : UIView

/// Инициализация представления часов Берсерка
- (instancetype)initWithFrame:(CGRect)frame;

/// Запуск таймера обновления времени и анимаций (вызывается при пробуждении экрана)
- (void)startClock;

/// Остановка таймера и анимаций для сохранения заряда аккумулятора (при выключении экрана)
- (void)stopClock;

/// Принудительное обновление времени и даты
- (void)updateTime;

/// Обновление разметки компонентов под размеры экрана
- (void)updateLayoutForBounds:(CGRect)bounds;

@end
