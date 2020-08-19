//
//  JimTimer.m
//  ProjectTemplate3
//
//  Created by luogq on 2020/8/18.
//  Copyright © 2020 jim. All rights reserved.
//

#import "JimTimer.h"

#define kJimWeakObj(obj) __weak typeof(obj) weak##obj = obj

@interface JimTimer () {
    /** 定时器的标识 */
    NSString *_key;
}

/** 定时器 */
@property (nonatomic, strong) dispatch_source_t source;

@end

@implementation JimTimer

#pragma mark -- life cycle
- (instancetype)init {
    if (self = [super init]) {
        _maxTimeCount = kMaxCountDownTime;
    }
    return self;
}

#pragma mark -- public
- (void)startTimer {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    self.source = source;
    
    dispatch_source_set_timer(source, dispatch_walltime(NULL, 0), NSEC_PER_SEC, 0);
    NSDate *endTime = [NSDate dateWithTimeIntervalSinceNow:self.maxTimeCount];
    dispatch_source_set_event_handler(source, ^{
        int interval = [endTime timeIntervalSinceNow];
        if (interval <= 0) { // 结束定时器
            dispatch_source_cancel(source);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.endBlock) {
                    self.endBlock();
                }
            });
        }else { // 倒计时
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.changeBlock) {
                    self.changeBlock(interval);
                }
            });
        }
    });
    
    dispatch_resume(source);
}
- (void)cancelTimer {
    dispatch_source_cancel(self.source);
    self.source = nil;
}

#pragma mark -- Getter & Setter
- (void)setMaxTimeCount:(NSUInteger)maxTimeCount {
    _maxTimeCount = maxTimeCount == 0 ? kMaxCountDownTime : maxTimeCount;
}
- (void)setKey:(NSString *)key {
    if ([key isKindOfClass:[NSString class]]) {
        _key = key;
    }
}
- (NSString *)key {
    if (!_key) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyyMMddHHmmssSSS";
        _key = [dateFormatter stringFromDate:[NSDate date]];
    }
    return _key;
}

@end



#pragma mark -- JimTimerManager
@interface JimTimerManager ()

/** 保存定时器 key:时间戳, value:JimTimer */
@property (nonatomic, strong) NSMutableDictionary<NSString *, JimTimer *> *timerDic;

@end

@implementation JimTimerManager

static JimTimerManager *__manager;

#pragma mark -- public
+ (instancetype)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __manager = [JimTimerManager new];
    });
    
    return __manager;
}

#pragma mark -- block形式的定时器
+ (NSString *)startTimerWithChangeBlock:(JimTimerManagerChangeBlock)changeBlock
                               endBlock:(JimTimerManagerEndBlock)endBlock {
    return [self startTimerWithChangeBlock:changeBlock
                                  endBlock:endBlock
                              maxTimeCount:0];
}
+ (NSString *)startTimerWithChangeBlock:(JimTimerManagerChangeBlock)changeBlock
                               endBlock:(JimTimerManagerEndBlock)endBlock
                           maxTimeCount:(NSUInteger)maxTimeCount {
    JimTimer *timer = [JimTimer new];
    kJimWeakObj(timer);
    timer.changeBlock = ^(int interval) {
        if (changeBlock) {
            changeBlock(weaktimer.key, interval);
        }
    };
    timer.endBlock = ^{
        [self cancelTimerWithKey:weaktimer.key];
        
        if (endBlock) {
            endBlock(weaktimer.key);
        }
    };
    timer.maxTimeCount = maxTimeCount;
    
    return [self startTimerWithTimer:timer];
}
+ (NSString *)startTimerWithTimer:(JimTimer *)timer {
    if (!([timer isKindOfClass:[JimTimer class]] &&
          [timer.key isKindOfClass:[NSString class]])) {
        return nil;
    }
    if ([[JimTimerManager manager].timerDic.allKeys containsObject:timer.key]) {
        return timer.key;
    }
    
    [timer startTimer];
    
    [JimTimerManager manager].timerDic[timer.key] = timer;
    return timer.key;
}

#pragma mark -- 通知形式的定时器
+ (NSString *)startTimer {
    return [self startTimerWithKey:nil].key;
}
+ (JimTimer *)startTimerWithKey:(nullable NSString *)key {
    return [self startTimerWithKey:key maxTimeCount:kMaxCountDownTime];
}
+ (JimTimer *)startTimerWithKey:(NSString *)key maxTimeCount:(NSUInteger)maxTimeCount {
    JimTimer *timer = nil;
    if ([key isKindOfClass:[NSString class]]) {
        timer = [JimTimerManager manager].timerDic[key];
    }
    if (timer) {
        return timer;
    }
    
    timer = [JimTimer new];
    
    timer.maxTimeCount = maxTimeCount;
    if ([key isKindOfClass:[NSString class]]) {
        timer.key = key;
    }
    
    kJimWeakObj(timer);
    timer.changeBlock = ^(int interval) {
        JimTimerManagerNotificationModel *model = [JimTimerManagerNotificationModel new];
        model.interval = interval;
        model.key = weaktimer.key;
        [[NSNotificationCenter defaultCenter] postNotificationName:kJimTimerManagerChangeNotificationKey object:model];
    };
    timer.endBlock = ^{
        [self cancelTimerWithKey:weaktimer.key];
        
        JimTimerManagerNotificationModel *model = [JimTimerManagerNotificationModel new];
        model.interval = 0;
        model.key = weaktimer.key;
        [[NSNotificationCenter defaultCenter] postNotificationName:kJimTimerManagerEndNotificationKey object:model];
    };
    
    [timer startTimer];
    
    [JimTimerManager manager].timerDic[timer.key] = timer;
    
    return timer;
}

#pragma mark -- 其它
+ (void)cancelTimerWithKey:(NSString *)key {
    if ([key isKindOfClass:[NSString class]]) {
        JimTimer *timer = [JimTimerManager manager].timerDic[key];
        if (timer) {
            [timer cancelTimer];
            [[JimTimerManager manager].timerDic removeObjectForKey:key];
        }
    }
}

+ (void)addNotWithTarget:(id)target sel:(SEL)sel {
    [[NSNotificationCenter defaultCenter] addObserver:target selector:sel name:kJimTimerManagerChangeNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:target selector:sel name:kJimTimerManagerEndNotificationKey object:nil];
}

#pragma mark -- Getter & Setter
- (NSMutableDictionary<NSString *, JimTimer *> *)timerDic {
    if (!_timerDic) {
        _timerDic = [[NSMutableDictionary alloc] init];
    }
    return _timerDic;
}

@end


#pragma mark -- JimTimerManagerNotificationModel
@implementation JimTimerManagerNotificationModel

@end
