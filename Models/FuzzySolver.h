//
//  FuzzySolver.h
//  FuzzFalliOSSwift
//
//  Created by Admin on 28/11/15.
//  Copyright © 2015 Anton Shcherba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <CoreMotion/CoreMotion.h>
#import <CorePlot/CorePlot-CocoaTouch.h>
#import <CoreLocation/CoreLocation.h>

@interface FuzzySolver : NSObject
//-(NSMutableArray*) solve: (NSArray*) data;
-(BOOL) solve: (id) data;
@end