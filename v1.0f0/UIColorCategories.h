//Extension categories to UIColor

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

//Create a UIColor from an inputed hex string and alpha value
+(UIColor *)colorFromHex:(NSString *)hex withAlpha:(float)al;

//convenience method to convert a two digit hex value to
//its float value (from 0 to 1)
+(int)hexToFloat:(NSString *)hexVal;

@end
