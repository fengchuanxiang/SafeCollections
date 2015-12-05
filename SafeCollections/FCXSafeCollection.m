//
//  FCXSafeCollection.m
//  Array
//
//  Created by 冯 传祥 on 15/10/16.
//  Copyright © 2015年 冯 传祥. All rights reserved.
//

#import "FCXSafeCollection.h"
#import <objc/runtime.h>

#if DEBUG
    #define FCXSCLOG(...) fcxSafeCollectionLog(__VA_ARGS__)
#else
    #define FCXSCLOG(...)
#endif


void fcxSafeCollectionLog(NSString *fmt, ...) NS_FORMAT_FUNCTION(1, 2);

void fcxSafeCollectionLog(NSString *fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    NSString *content = [[NSString alloc] initWithFormat:fmt arguments:ap];
    NSLog(@"***Terminating app due to uncaught exception\n");
    NSLog(@"***reason:-%@", content);
    va_end(ap);
    
    NSLog(@"*** First throw call stack:\n%@", [NSThread callStackSymbols]);
}



#pragma mark - NSArray

@interface NSArray (Safte)

@end

@implementation NSArray (Safte)

- (id)fcx_safeObjectAtIndex:(NSUInteger)index {
    
    if (self.count > index) {
        return [self fcx_safeObjectAtIndex:index];
    }else {
        
        FCXSCLOG(@"[%@ %@] index %lu beyond bounds [0 .. %lu]",
                          NSStringFromClass([self class]),
                          NSStringFromSelector(_cmd),
                          (unsigned long)index,
                          MAX((unsigned long)self.count - 1, 0));
        return nil;
    }
}

@end


//**************************************************************

#pragma mark - NSMutableArray

@interface NSMutableArray (Safte)

@end

@implementation NSMutableArray (Safte)

- (id)fcx_safeObjectAtIndex:(NSUInteger)index {

    if (self.count > index) {
        return [self fcx_safeObjectAtIndex:index];
    }else {
        
        FCXSCLOG(@"[%@ %@] index %lu beyond bounds [0 .. %lu]",
                          NSStringFromClass([self class]),
                          NSStringFromSelector(_cmd),
                          (unsigned long)index,
                          MAX((unsigned long)self.count - 1, 0));
        return nil;
    }
}

- (void)fcx_safeAddObject:(id)anObject {
    
    if (anObject) {
        [self fcx_safeAddObject:anObject];
    }else {
        FCXSCLOG(@"[%@ %@], nil object. object cannot be nil", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    }
}

- (void)fcx_safeReplaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {

    if (index >= self.count) {
        FCXSCLOG(@"[%@ %@] index %lu beyond bounds [0 .. %lu].",
                NSStringFromClass([self class]),
                NSStringFromSelector(_cmd),
                (unsigned long)index,
                MAX((unsigned long)self.count - 1, 0));
        return;
    }else if (!anObject) {
        FCXSCLOG(@"[%@ %@] nil object. object cannot be nil", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return;

    }
    [self fcx_safeReplaceObjectAtIndex:index withObject:anObject];
}

- (void)fcx_safeInsertObject:(id)anObject atIndex:(NSUInteger)index {

    if (index > self.count)
    {
        FCXSCLOG(@"[%@ %@] index %lu beyond bounds [0...%lu].",
                NSStringFromClass([self class]),
                NSStringFromSelector(_cmd),
                (unsigned long)index,
                MAX((unsigned long)self.count - 1, 0));
        return;
    }
    
    if (!anObject)
    {
        FCXSCLOG(@"[%@ %@] nil object. object cannot be nil", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return;
    }
    
    [self fcx_safeInsertObject:anObject atIndex:index];
}

@end


//**************************************************************

#pragma mark - NSDictionary

@interface NSDictionary (Safte)

@end

@implementation NSDictionary (Safte)


+ (instancetype)fcx_safeDictionaryWithObjects:(const id  _Nonnull __unsafe_unretained *)objects forKeys:(const id<NSCopying>  _Nonnull __unsafe_unretained *)keys count:(NSUInteger)cnt {

    id validObjects[cnt];
    id<NSCopying> validKeys[cnt];
    NSUInteger count = 0;
    for (NSUInteger i = 0; i < cnt; i++)
    {
        if (objects[i] && keys[i])
        {
            validObjects[count] = objects[i];
            validKeys[count] = keys[i];
            count ++;
        }
        else
        {
            FCXSCLOG(@"[%@ %@] NIL object or key at index{%lu}.",
                    NSStringFromClass(self),
                    NSStringFromSelector(_cmd),
                    (unsigned long)i);
        }
    }
    
    return [self fcx_safeDictionaryWithObjects:validObjects forKeys:validKeys count:count];
}


@end


//**************************************************************

#pragma mark - NSMuatbleDictionary

@interface NSMutableDictionary (Safte)

@end

@implementation NSMutableDictionary (Safte)

- (void)fcx_safeSetObject:(id)anObject forKey:(id<NSCopying>)aKey {
    
    if (!aKey)
    {
        FCXSCLOG(@"[%@ %@] nil key. key cannot be nil", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return;
    }
    if (!anObject)
    {
        FCXSCLOG(@"[%@ %@] nil object. object cannot be nil", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return;
    }
    [self fcx_safeSetObject:anObject forKey:aKey];
}

@end

//**************************************************************

@implementation FCXSafeCollection

+ (void)load {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

//        NSArray
        [self swizzleInstanceMethodWithClass:NSClassFromString(@"__NSArrayI") originalSelector:@selector(objectAtIndex:) swizzledMethod:@selector(fcx_safeObjectAtIndex:)];
        
//        NSMutableArray
        [self swizzleInstanceMethodWithClass:NSClassFromString(@"__NSArrayM") originalSelector:@selector(objectAtIndex:) swizzledMethod:@selector(fcx_safeObjectAtIndex:)];
//        [self swizzleInstanceMethodWithClass:NSClassFromString(@"__NSArrayM") originalSelector:@selector(addObject:) swizzledMethod:@selector(fcx_safeAddObject:)];
        [self swizzleInstanceMethodWithClass:NSClassFromString(@"__NSArrayM") originalSelector:@selector(replaceObjectAtIndex:withObject:) swizzledMethod:@selector(fcx_safeReplaceObjectAtIndex:withObject:)];
        [self swizzleInstanceMethodWithClass:NSClassFromString(@"__NSArrayM") originalSelector:@selector(insertObject:atIndex:) swizzledMethod:@selector(fcx_safeInsertObject:atIndex:)];

//        NSDictionary
//        [self swizzleClassMethodWithClass:[NSDictionary class] originalSelector:@selector(dictionaryWithObjects:forKeys:count:) swizzledMethod:@selector(fcx_safeDictionaryWithObjects:forKeys:count:)];
        
//        NSMutableDictionary
        [self swizzleInstanceMethodWithClass:NSClassFromString(@"__NSDictionaryM") originalSelector:@selector(setObject:forKey:) swizzledMethod:@selector(fcx_safeSetObject:forKey:)];
        
    });
}

+ (void)swizzleInstanceMethodWithClass:(Class)class
                      originalSelector:(SEL)originalSelector
                        swizzledMethod:(SEL)swizzledSelector {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

    if (class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
        
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }else {
    
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (void)swizzleClassMethodWithClass:(Class)class
                   originalSelector:(SEL)originalSelector
                     swizzledMethod:(SEL)swizzledSelector {

    Method originalMethod = class_getClassMethod(class, originalSelector);
    Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
    
//    if (class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
//        
//        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
//    }else {
//        
        method_exchangeImplementations(originalMethod, swizzledMethod);
//    }
}

@end
