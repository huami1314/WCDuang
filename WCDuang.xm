#import <Foundation/Foundation.h>

@interface MMContext : NSObject
+ (instancetype)currentContext;
- (NSString *)userName;
@end

@interface CMessageWrap : NSObject
@property (nonatomic, assign) int m_uiMessageType;
@property (nonatomic, copy) NSString *m_nsFromUsr;
@property (nonatomic, assign) unsigned int m_uiStatus;
- (int)yoType;
@end

@interface WCWatchNativeMgr : NSObject
- (void)displaySignalMessageWithDelay:(CMessageWrap *)msg;
@end

%hook WCWatchNativeMgr

- (void)OnMsgNotAddDBNotify:(NSString *)chatName MsgWrap:(CMessageWrap *)msg {
    BOOL shouldDisplay = NO;

    if (msg && msg.m_uiMessageType == 63) {
        MMContext *context = [%c(MMContext) currentContext];
        NSString *me = [context userName];
        BOOL fromSelf = [msg.m_nsFromUsr isEqualToString:me];
        BOOL alreadyRead = (msg.m_uiStatus == 4);
        BOOL isReplyYo = ([msg yoType] == 1);
        
        // 如果想连“对方回复小信号”的打勾动画也显示，把 !isReplyYo 去掉。
        shouldDisplay = !fromSelf && !alreadyRead && !isReplyYo;
    }

    %orig;

    if (shouldDisplay) {
        CMessageWrap *hold = msg;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self displaySignalMessageWithDelay:hold];
        });
    }
}

%end