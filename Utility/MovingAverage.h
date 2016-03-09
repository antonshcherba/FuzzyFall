
#import <Foundation/Foundation.h>

@interface MovingAverage : NSObject {
    unsigned int period;
    NSMutableArray *window;
    double sum;
}
- (instancetype)initWithPeriod:(unsigned int)thePeriod;
- (void)add:(double)val;
- (double)avg;
@end