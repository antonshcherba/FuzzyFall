//
//  FuzzySolver.m
//  FuzzFalliOSSwift
//
//  Created by Admin on 28/11/15.
//  Copyright © 2015 Anton Shcherba. All rights reserved.
//

#import "FuzzySolver.h"
#import "FuzzyFall-Swift.h"
#import "MovingAverage.h"
#include "Headers.h"
#import <notify.h>
#import <notify_keys.h>

//struct Wrapper {
//public:
//    fl::InputVariable InputVariable;
//    Wrapper() : InputVariable() {};
//    
//
//};

@interface FuzzySolver () {
    fl::InputVariable *accel;
    fl::InputVariable *pitch;
    fl::OutputVariable* action;
    fl::Engine *engine;
    fl::RuleBlock *ruleblock;
    MovingAverage *movingAverage;
    
}

@end

@implementation FuzzySolver

int window = 20;

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        movingAverage = [[MovingAverage alloc] initWithPeriod:window];
        engine = new fl::Engine("detector");

        accel = new fl::InputVariable();
        accel->setName("Accel");
        accel->setEnabled(true);
        accel->setRange(0.000, 8.000);
        accel->addTerm(new fl::Trapezoid("HIGH", 0.5, 0.6, 7.0, 8.0));
        accel->addTerm(new fl::Triangle("LOW", 0.0, 0.0,0.6));
        engine->addInputVariable(accel);

        pitch = new fl::InputVariable();
        pitch->setName("Pitch");
        pitch->setEnabled(true);
        pitch->setRange(-3.000, 3.000);
        pitch->addTerm(new fl::Trapezoid("BIG", 0.6, 0.8, 1.2, 1.3));
        pitch->addTerm(new fl::Trapezoid("SMALL", -3.0, -3.0, 0.5, 0.9));
        engine->addInputVariable(pitch);
        
        action = new fl::OutputVariable;
        action->setName("Action");
        action->setRange(0.000, 1.000);
        action->setDefaultValue(fl::nan);
        action->addTerm(new fl::Triangle("FALL", 0.6, 1.0, 1.0));
        action->addTerm(new fl::Triangle("NONFALL", 0.0, 0.0, 0.5));
        engine->addOutputVariable(action);
        
        ruleblock = new fl::RuleBlock;
        ruleblock->addRule(fl::Rule::parse("if Accel is HIGH and Pitch is BIG then Action is FALL", engine));
        ruleblock->addRule(fl::Rule::parse("if Accel is LOW and Pitch is SMALL then Action is NONFALL", engine));
        engine->addRuleBlock(ruleblock);
        
        engine->configure("Minimum", "Maximum", "Minimum", "Maximum", "Centroid");
    }
    return self;
}

-(BOOL) solve: (id) data {

    Measure *measure = (Measure*)data;
    BOOL result = false;
    
    try {
        accel->setInputValue(measure.avgAccel);
        pitch->setInputValue(measure.pitchDiff);
        
        engine->process();
        fl::Accumulated *ac = action->fuzzyOutput();
        if (ac->membership(1) >= 0.1) {
            result = true;
//            printf("\t%f\t %s\n\n",action->getOutputValue(), action->fuzzyOutputValue().c_str());
        }
        printf("\t%f\t %s\n",action->getOutputValue(), action->fuzzyOutputValue().c_str());
        

    } catch (...) {
        result = false;
        NSLog(@"Catch Error");
    }
    
    return result;
}

//-(NSMutableArray*) pitchDiff: (NSMutableArray*) array WithWindow:(int) window  {
//    NSMutableArray *result = [[NSMutableArray alloc]initWithArray:array copyItems:true];
//    
//    for (int index = 0; index < window; index++) {
//        [result replaceObjectAtIndex:index withObject:@(0.0)];
//    }
//    
//    for (int index = array.count - window; index < array.count; index++) {
//        [result replaceObjectAtIndex:index withObject:@(0.0)];
//    }
//    
//    for (int index = window; index < array.count - window; index++) {
//       NSNumber *tmp = @(((NSNumber*)array[index+window]).doubleValue -
//                        ((NSNumber*)array[index-window]).doubleValue);
//        [result replaceObjectAtIndex:index withObject:tmp];
//    }
//    
//    return result;
//}

@end
