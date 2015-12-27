# SafeCollections
##解决NSArray、NSMutableArray、NSDictionary、NSMutableDictionary引起的闪退
使用了MethodSwizzle解决项目中经常遇到的数组越界、字典键值对为空操作等闪退问题，
在Debug模式会在控制台输出相应的错误原因，并且不会导致程序闪退
```objc
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

```

##解决KeyValue引起的程序闪退
```objc
//当对一个非类对象属性设置nil时，就会执行setNilValueForKey:方法,setNilValueForKey:方法的默认实现,是产生一个NSInvalidArgumentException的异常,但是你可以重写这个方法.
- (void)setNilValueForKey:(NSString *)key {
    
    FCXSCLOG(@"[%@ %@]: could not set nil as the value for the key %@.", NSStringFromClass([self class]), NSStringFromSelector(_cmd), key);
}

//如果没有对应的访问器方法(setter方法),如果接受者的类的+accessInstanceVariablesDirectly方法返回YES,那么就查找这个接受者的与key相匹配的实例变量(匹配模式为_<key>,_is<Key>,<key>,is<Key>):比如:key为age,只要属性存在_age,_isAge,age,isAge中的其中一个就认为匹配上了,如果找到这样的一个实例变量,并且的类型是一个对象指针类型,首先released对象上的旧值,然后把传入的新值retain后的传入的值赋值该成员变量,如果方法的参数类型是NSNumber或NSValue的对应的基本类型,先把它转换为基本数据类,再执行方法,传入转换后的数据.
//+ (BOOL)accessInstanceVariablesDirectly {
//    return YES;
//}

//对于数据模型中缺少的、不能与任何键配对的属性的时候，系统会自动调用setValue:forUndefinedKey:这个方法，该方法默认的实现会引发一个NSUndefinedKeyExceptiony异常,但是我们可以重写setValue:forUndefinedKey:方法让程序在运行过程中不引发任何异常信息且正常工作
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    FCXSCLOG(@"[%@ %@]: this class is not key value coding-compliant for the key %@.", NSStringFromClass([self class]), NSStringFromSelector(_cmd), key);
}

//通过valueForKey获取对象属性值的方法时，如果代码中的key值不存在，系统会自动调用valueForUndefinedKey:这个方法，该方法默认的实现会引发一个NSUndefinedKeyExceptiony异常,但是我们可以重写valueForUndefinedKey:方法让程序在运行过程中不引发任何异常信息且正常工作
/**
 *  通过valueForKey获取对象属性值的方法时，如果代码中的key值不存在，系统会自动调用valueForUndefinedKey:这个方法，该方法默认的实现会引发一个NSUndefinedKeyExceptiony异常,但是我们可以重写valueForUndefinedKey:方法让程序在运行过程中不引发任何异常信息且正常工作
 *
 *  @return nil
 *
 *  @notice 虽然这步可以返回nil不闪退，但是后续操作依然可能有问题
 */
- (id)valueForUndefinedKey:(NSString *)key {
    
    FCXSCLOG(@"[%@ %@]: this class is not key value coding-compliant for the key %@.", NSStringFromClass([self class]), NSStringFromSelector(_cmd), key);
    return nil;
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

```

