//
//  UIColorCategories.m

#import "UIColorCategories.h"


@implementation UIColor (Hex)

+(UIColor *)colorFromHex:(NSString *)hex withAlpha:(float)al
{
	return [UIColor colorWithRed:([UIColor hexToFloat:[hex substringWithRange:NSMakeRange(0, 2)]] / 255.0) 
						   green:([UIColor hexToFloat:[hex substringWithRange:NSMakeRange(2, 2)]] / 255.0) 
							blue:([UIColor hexToFloat:[hex substringWithRange:NSMakeRange(4, 2)]] / 255.0) 
						   alpha:al];
	
	
}

+(int)hexToFloat:(NSString *)hexVal
{
	NSString *hexVals = @"0123456789ABCDEF";
	NSString *sixteensChar = [hexVal substringWithRange:NSMakeRange(0, 1)];
	NSString *onesChar = [hexVal substringWithRange:NSMakeRange(1, 1)];
	NSString *testChar;
	int valAsInt = 0;
	for (int i = 0; i < [hexVals length]; i++) {
		testChar = [hexVals substringWithRange:NSMakeRange(i, 1)];
		if ([testChar isEqualToString:sixteensChar]) valAsInt += i * 16;
		if ([testChar isEqualToString:onesChar]) valAsInt += i;
	}
	return valAsInt;
}

@end
