
// DLog is almost a drop-in replacement for DLog to turn off logging for release build
// 
// add -DDEBUG to OTHER_CFLAGS in the build user defined settings
//
// Usage:
//
// DLog();
// DLog(@"here");
// DLog(@"value: %d", x);
// Unfortunately this doesn't work DLog(aStringVariable); you have to do this instead DLog(@"%@", aStringVariable);
//

#define SHOWLINENUMBER 1

#ifdef DEBUG

#if SHOWLINENUMBER

#define DLog(__FORMAT__, ...) NSLog((@"%s [Line %d] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#else

#define DLog(__FORMAT__, ...) NSLog(__FORMAT__, ##__VA_ARGS__)

#endif

#else

#define DLog(...) do {} while (0)

#endif
// ALog always displays output regardless of the DEBUG setting
#define ALog(__FORMAT__, ...) NSLog((@"%s [Line %d] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

