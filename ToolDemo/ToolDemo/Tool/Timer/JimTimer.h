//
//  JimTimer.h
//  ProjectTemplate3
//
//  Created by luogq on 2020/8/18.
//  Copyright © 2020 jim. All rights reserved.
//  定时器默认60秒

#import <Foundation/Foundation.h>

/** 定时器改变 */
typedef void (^JimTimerChangeBlock)(int interval);
/** 定时器结束 */
typedef void (^JimTimerEndBlock)(void);

// 倒计时时间，可自定义
static NSUInteger kMaxCountDownTime = 60;

NS_ASSUME_NONNULL_BEGIN

@interface JimTimer : NSObject

/** 定时器最大时间,默认kMaxCountDownTime，设置0也默认kMaxCountDownTime */
@property (nonatomic, assign) NSUInteger maxTimeCount;
/** 定时器改变 */
@property (nonatomic, copy) JimTimerChangeBlock changeBlock;
/** 定时器结束 */
@property (nonatomic, copy) JimTimerEndBlock endBlock;

/** 开始定时器 */
- (void)startTimer;
/** 取消定时器 */
- (void)cancelTimer;

- (void)setKey:(NSString *)key;
- (NSString *)key;

@end


#pragma mark -- JimTimerManager
/** 定时器改变 key:定时器的标识，interval:剩余时间 */
typedef void (^JimTimerManagerChangeBlock)(NSString *key, int interval);
/** 定时器结束 key:定时器的标识 */
typedef void (^JimTimerManagerEndBlock)(NSString *key);

/** 定时器改变 objcet:(JimTimerManagerNotificationModel *) */
#define kJimTimerManagerChangeNotificationKey @"kJimTimerManagerChangeNotificationKey"
/** 定时器结束 objcet:(JimTimerManagerNotificationModel *) */
#define kJimTimerManagerEndNotificationKey @"kJimTimerManagerEndNotificationKey"

@interface JimTimerManager : NSObject

+ (instancetype)manager;

#pragma mark -- block形式的定时器
/**
 * 开始定时器，默认kMaxCountDownTime
 *
 * @param changeBlock 定时器改变
 * @param endBlock 定时器结束
 * @return 返回唯一标识，用来取消定时器的
 */
+ (NSString *)startTimerWithChangeBlock:(JimTimerManagerChangeBlock)changeBlock
                               endBlock:(JimTimerManagerEndBlock)endBlock;
/**
 * 开始定时器
 *
 * @param changeBlock 定时器改变
 * @param endBlock 定时器结束
 * @param maxTimeCount 定时器最大时间
 * @return 返回唯一标识，用来取消定时器的
 */
+ (NSString *)startTimerWithChangeBlock:(JimTimerManagerChangeBlock)changeBlock
                               endBlock:(JimTimerManagerEndBlock)endBlock
                           maxTimeCount:(NSUInteger)maxTimeCount;
/**
 * 开始定时器
 *
 * @param timer 定时器
 * @return 返回唯一标识，用来取消定时器的
 */
+ (NSString *)startTimerWithTimer:(JimTimer *)timer;

#pragma mark -- 通知形式的定时器
/**
 * 开始定时器，默认kMaxCountDownTime,通知的形式
 *
 * @return 返回唯一标识，用来取消定时器的
 */
+ (NSString *)startTimer;
/**
 * 开始定时器，默认kMaxCountDownTime,通知的形式
 *
 * @param key 自定义key
 */
+ (JimTimer *)startTimerWithKey:(nullable NSString *)key;
/**
 * 开始定时器，通知的形式
 *
 * @param maxTimeCount 定时器最大时间
 * @param key 自定义key
 */
+ (JimTimer *)startTimerWithKey:(nullable NSString *)key maxTimeCount:(NSUInteger)maxTimeCount;

#pragma mark -- 其它
/** 取消定时器 */
+ (void)cancelTimerWithKey:(NSString *)key;

/** 添加通知 kJimTimerManagerChangeNotificationKey和kJimTimerManagerEndNotificationKey,通知的object是JimTimerManagerNotificationModel */
+ (void)addNotWithTarget:(id)target sel:(SEL)sel;

@end


#pragma mark -- JimTimerManagerNotificationModel
/** 监听返回的对象 */
@interface JimTimerManagerNotificationModel : NSObject

/** 标识 */
@property (nonatomic, copy) NSString *key;
/** 剩余多少时间,等于0表示结束 */
@property (nonatomic, assign) NSUInteger interval;

@end

NS_ASSUME_NONNULL_END
