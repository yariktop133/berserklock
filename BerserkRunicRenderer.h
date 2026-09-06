#import <UIKit/UIKit.h>

@interface BerserkRunicRenderer : NSObject

/// Отрисовка каноничного Клейма Жертвы (Brand of Sacrifice) в заданном прямоугольнике
+ (UIBezierPath *)canonicalBrandOfSacrificeInRect:(CGRect)rect;

/// Отрисовка одной рунической цифры (0-9) в заданном прямоугольнике
+ (UIBezierPath *)pathForDigit:(NSInteger)digit inRect:(CGRect)rect;

/// Отрисовка строки времени (например, "14:25") руническими символами
+ (UIBezierPath *)pathForTimeString:(NSString *)timeString inRect:(CGRect)rect;

@end
