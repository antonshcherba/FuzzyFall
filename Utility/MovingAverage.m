
#import "MovingAverage.h"

@implementation MovingAverage

// init with default period
- (instancetype)init {
    self = [super init];
    if(self) {
        period = 10;
        window = [[NSMutableArray alloc] init];
        sum = 0.0;
    }
    return self;
}

// init with specified period
- (instancetype)initWithPeriod:(unsigned int)thePeriod {
    self = [super init];
    if(self) {
        period = thePeriod;
        window = [[NSMutableArray alloc] init];
        sum = 0.0;
    }
    return self;
}

// add a new number to the window
- (void)add:(double)val {
    sum += val;
    [window addObject:@(val)];
    if([window count] > period) {
        NSNumber *n = window[0];
        sum -= [n doubleValue];
        [window removeObjectAtIndex:0];
    }
}

// get the average value
- (double)avg {
    if([window count] == 0) {
        return 0; // technically the average is undefined
    }
    if ([window count] < period) {
        return 0;
    }
    return sum / [window count];
}

// set the period, resizes current window
- (void)setPeriod:(unsigned int)thePeriod {
    // make smaller?
    if(thePeriod < [window count]) {
        for(int i = 0; i < thePeriod; ++i) {
            NSNumber *n = window[0];
            sum -= [n doubleValue];
            [window removeObjectAtIndex:0];
        }
    }
    period = thePeriod;
}

// get the period (window size)
- (unsigned int)period {
    return period;
}

// clear the window and current sum
- (void)clear {
    [window removeAllObjects];
    sum = 0;
}

@end