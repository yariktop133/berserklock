#import <UIKit/UIKit.h>

@interface BerserkHomeWidgetView : UIView

/// Инициализация виджета рабочего стола
- (instancetype)initWithFrame:(CGRect)frame;

/// Запуск мониторинга батареи и анимаций виджета
- (void)startWidget;

/// Остановка для сохранения аккумулятора
- (void)stopWidget;

/// Обновление значений шкалы ярости/батареи
- (void)updateBatteryAndState;

@end
