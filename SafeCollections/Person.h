//
//  Person.h
//  SafeCollections
//
//  Created by 冯 传祥 on 15/12/27.
//  Copyright © 2015年 冯 传祥. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, unsafe_unretained) NSInteger age;
@property (nonatomic, strong) NSArray *array;
@property (nonatomic, strong) Person *person;



@end
