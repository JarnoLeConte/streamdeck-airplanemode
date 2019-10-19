//==============================================================================
/**
@file       AirplaneModeStreamDeckPlugin.h

@brief      A Stream Deck plugin to enable Airplane Mode on your Mac

@copyright  Original work (c) 2018, Corsair Memory, Inc.
            Modified work (c) 2019, Jarno Le Conté
            This source code is licensed under the MIT-style license found in the LICENSE file.
**/
//==============================================================================

#import <Foundation/Foundation.h>
#import "ESDEventsProtocol.h"

@class ESDConnectionManager;


NS_ASSUME_NONNULL_BEGIN

@interface AirplaneModeStreamDeckPlugin : NSObject <ESDEventsProtocol>

@property (weak) ESDConnectionManager *connectionManager;

- (void)keyDownForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID;
- (void)keyUpForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID;
- (void)willAppearForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID;
- (void)willDisappearForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID;

- (void)deviceDidConnect:(NSString *)deviceID withDeviceInfo:(NSDictionary *)deviceInfo;
- (void)deviceDidDisconnect:(NSString *)deviceID;

- (void)applicationDidLaunch:(NSDictionary *)applicationInfo;
- (void)applicationDidTerminate:(NSDictionary *)applicationInfo;

@end

NS_ASSUME_NONNULL_END

