//==============================================================================
/**
@file       AirplaneModeStreamDeckPlugin.m

@brief      A Stream Deck plugin to enable Airplane Mode on your Mac

@copyright  Original work (c) 2018, Corsair Memory, Inc.
            Modified work (c) 2019, Jarno Le Conté
            This source code is licensed under the MIT-style license found in the LICENSE file.
**/
//==============================================================================

#import "AirplaneModeStreamDeckPlugin.h"

#import "ESDSDKDefines.h"
#import "ESDConnectionManager.h"
#import "ESDUtilities.h"
#import <AppKit/AppKit.h>


// MARK: - Utility methods

//
// Utility function to get the fullpath of an resource in the bundle
//
static NSString * GetResourcePath(NSString *inFilename)
{
	NSString *outPath = nil;
	
	if([inFilename length] > 0)
	{
		NSString * bundlePath = [ESDUtilities pluginPath];
		if(bundlePath != nil)
		{
			outPath = [bundlePath stringByAppendingPathComponent:inFilename];
		}
	}
	
	return outPath;
}


// MARK: - AirplaneModeStreamDeckPlugin

@interface AirplaneModeStreamDeckPlugin ()

// Tells us if plugin is initialized
@property (assign) BOOL initialized;

// Tells us if airplane mode is enabled
@property (assign) BOOL airplaneModeEnabled;

// The list of visible contexts
@property (strong) NSMutableArray *knownContexts;

@end


@implementation AirplaneModeStreamDeckPlugin



// MARK: - Setup the instance variables if needed

- (void)setupIfNeeded
{
	// Initialize the first time
	if(_initialized == FALSE)
	{
        // Create the array of known contexts
		_knownContexts = [[NSMutableArray alloc] init];
        
        // Check if airplane mode is already enabled at launch
        [self airplaneModeStatusCheck];
        
        _initialized = TRUE;
	}
}

// MARK: - Action handlers

- (void) airplaneModeStatusCheck
{
    // Check if airplane mode is current enabled on your Mac
    // and render all action buttond with the corresponding state.
    NSURL* url = [NSURL fileURLWithPath:GetResourcePath(@"scripts/airplaneModeStatus.scpt")];
    
    NSDictionary *errors = nil;
    NSAppleScript* appleScript = [[NSAppleScript alloc] initWithContentsOfURL:url error:&errors];
    if(appleScript != nil)
    {
        NSAppleEventDescriptor* result = [appleScript executeAndReturnError:&errors];
        NSString* location = [result stringValue];
        if (([location isEqualToString:@"Airplane mode"] && !_airplaneModeEnabled) ||
            ([location isNotEqualTo:@"Airplane mode"] && _airplaneModeEnabled)) {
            [self toggleAirplaneModeStatus];
        }
    }
}

- (void)toggleAirplaneModeStatus
{
    _airplaneModeEnabled = !_airplaneModeEnabled;
    
    if(_airplaneModeEnabled)
    {
        // Turn on airplane mode (block internet activity)
        NSURL* url = [NSURL fileURLWithPath:GetResourcePath(@"scripts/airplaneModeOn.scpt")];
        
        NSDictionary *errors = nil;
        NSAppleScript* appleScript = [[NSAppleScript alloc] initWithContentsOfURL:url error:&errors];
        if(appleScript != nil)
        {
            [appleScript executeAndReturnError:&errors];
        }
    }
    else
    {
        // Turn off airplane mode (allow internet activity)
        NSURL* url = [NSURL fileURLWithPath:GetResourcePath(@"scripts/airplaneModeOff.scpt")];
       
        NSDictionary *errors = nil;
        NSAppleScript* appleScript = [[NSAppleScript alloc] initWithContentsOfURL:url error:&errors];
        if(appleScript != nil)
        {
            [appleScript executeAndReturnError:&errors];
        }
    }
    
    [self refreshAirplaneModeStatus];
}

// MARK: - Refresh all actions

- (void)refreshAirplaneModeStatus
{
	// Update each known context with the new value
	for(NSString *context in self.knownContexts)
	{
		if(_airplaneModeEnabled)
		{
            [self.connectionManager setState:[NSNumber numberWithInt:1] forContext:context];
		}
		else
		{
            [self.connectionManager setState:[NSNumber numberWithInt:0] forContext:context];
		}
	}
}


// MARK: - Events handler


- (void)keyDownForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
    // Nothing to do
}

- (void)keyUpForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
	[self toggleAirplaneModeStatus];
}

- (void)willAppearForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
	// Set up the instance variables if needed
	[self setupIfNeeded];
	
	// Add the context to the list of known contexts
	[self.knownContexts addObject:context];
	
	// Explicitely refresh action
	[self refreshAirplaneModeStatus];
}

- (void)willDisappearForAction:(NSString *)action withContext:(id)context withPayload:(NSDictionary *)payload forDevice:(NSString *)deviceID
{
	// Remove the context from the list of known contexts
	[self.knownContexts removeObject:context];
}

- (void)deviceDidConnect:(NSString *)deviceID withDeviceInfo:(NSDictionary *)deviceInfo
{
	// Nothing to do
}

- (void)deviceDidDisconnect:(NSString *)deviceID
{
	// Nothing to do
}

- (void)applicationDidLaunch:(NSDictionary *)applicationInfo
{
	// Nothing to do
}

- (void)applicationDidTerminate:(NSDictionary *)applicationInfo
{
	// Nothing to do
}

@end
