//
//  ViewController.m
//  SafeCollections
//
//  Created by 冯 传祥 on 15/12/5.
//  Copyright © 2015年 冯 传祥. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    [self testSafe];
    [self testKeyValue];
}


- (void)testSafe {
    //Array
    NSArray *array  = @[@1, @2];
    
    NSLog(@"index==== %@", array[2]);
    
    NSMutableArray *muArray = [[NSMutableArray alloc] initWithObjects:@"1", nil];
    NSLog(@"****");
    NSLog(@"=======muarray %@", muArray[2]);
    
    [muArray replaceObjectAtIndex:3 withObject:@""];
    [muArray replaceObjectAtIndex:0 withObject:nil];
    [muArray insertObject:@2 atIndex:2];
    
    
    //Dict
    NSMutableDictionary *muDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"obj", @"key", nil];
    
    [muDict setObject:nil forKey:@"1"];
    [muDict setObject:@"1" forKey:nil];
}

- (void)testKeyValue {
    
    Person *xiaoming = [[Person alloc] init];
    [xiaoming setValue:@"xiaoming" forKey:@"name"];
    NSLog(@"name %@", xiaoming.name);
    [xiaoming setValue:nil forKey:@"name"];
    [xiaoming setValue:nil forKey:@"array"];
    //    [xiaoming setValue:nil forKey:@"person1"];
    [xiaoming setValue:@"aa" forKey:@"age"];
    //    [xiaoming setValue:nil forKey:@"age"];
    //    [xiaoming setNilValueForKey:@"age"];
    NSLog(@"name %@ age %ld", xiaoming.name, xiaoming.age);
    
    //    [xiaoming setValue:@"xiaoming" forKey:@"person1"];
    [xiaoming valueForKey:@"person1"];
    [xiaoming valueForKey:@"age1"];
}


@end
