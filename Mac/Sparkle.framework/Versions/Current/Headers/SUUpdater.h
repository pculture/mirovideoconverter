//  MiroVideoConverter -- a super simple way to convert almost any video to MP4, 
//  Ogg Theora, or a specific phone or iPod.
//
//  Copyright 2010 Participatory Culture Foundation
//
//  This file is part of MiroVideoConverter.
//
//  MiroVideoConverter is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  MiroVideoConverter is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with MiroVideoConverter.  If not, see http://www.gnu.org/licenses/.

//
//  SUUpdater.h
//  Sparkle
//
//  Created by Andy Matuschak on 1/4/06.
//  Copyright 2006 Andy Matuschak. All rights reserved.
//

#ifndef SUUPDATER_H
#define SUUPDATER_H

#import <Sparkle/SUVersionComparisonProtocol.h>

@class SUUpdateDriver, SUAppcastItem, SUHost, SUAppcast;
@interface SUUpdater : NSObject {
	NSTimer *checkTimer;
	SUUpdateDriver *driver;
	
	SUHost *host;
	IBOutlet id delegate;
}

+ (SUUpdater *)sharedUpdater;
+ (SUUpdater *)updaterForBundle:(NSBundle *)bundle;
- (NSBundle *)hostBundle;

- (void)setDelegate:(id)delegate;
- delegate;

- (void)setAutomaticallyChecksForUpdates:(BOOL)automaticallyChecks;
- (BOOL)automaticallyChecksForUpdates;

- (void)setUpdateCheckInterval:(NSTimeInterval)interval;
- (NSTimeInterval)updateCheckInterval;

- (void)setFeedURL:(NSURL *)feedURL;
- (NSURL *)feedURL;

- (void)setSendsSystemProfile:(BOOL)sendsSystemProfile;
- (BOOL)sendsSystemProfile;

- (void)setAutomaticallyDownloadsUpdates:(BOOL)automaticallyDownloadsUpdates;
- (BOOL)automaticallyDownloadsUpdates;

// This IBAction is meant for a main menu item. Hook up any menu item to this action,
// and Sparkle will check for updates and report back its findings verbosely.
- (IBAction)checkForUpdates:sender;

// This kicks off an update meant to be programmatically initiated. That is, it will display no UI unless it actually finds an update,
// in which case it proceeds as usual. If the fully automated updating is turned on, however, this will invoke that behavior, and if an
// update is found, it will be downloaded and prepped for installation.
- (void)checkForUpdatesInBackground;

// Date of last update check. Returns null if no check has been performed.
- (NSDate*)lastUpdateCheckDate;

// This begins a "probing" check for updates which will not actually offer to update to that version. The delegate methods, though,
// (up to updater:didFindValidUpdate: and updaterDidNotFindUpdate:), are called, so you can use that information in your UI.
- (void)checkForUpdateInformation;

// Call this to appropriately schedule or cancel the update checking timer according to the preferences for time interval and automatic checks. This call does not change the date of the next check, but only the internal NSTimer.
- (void)resetUpdateCycle;

- (BOOL)updateInProgress;
@end

@interface NSObject (SUUpdaterDelegateInformalProtocol)
// This method allows you to add extra parameters to the appcast URL, potentially based on whether or not Sparkle will also be sending along the system profile. This method should return an array of dictionaries with keys: "key", "value", "displayKey", "displayValue", the latter two being specifically for display to the user.
- (NSArray *)feedParametersForUpdater:(SUUpdater *)updater sendingSystemProfile:(BOOL)sendingProfile;

// Use this to override the default behavior for Sparkle prompting the user about automatic update checks.
- (BOOL)updaterShouldPromptForPermissionToCheckForUpdates:(SUUpdater *)bundle;

// Implement this if you want to do some special handling with the appcast once it finishes loading.
- (void)updater:(SUUpdater *)updater didFinishLoadingAppcast:(SUAppcast *)appcast;

// If you're using special logic or extensions in your appcast, implement this to use your own logic for finding
// a valid update, if any, in the given appcast.
- (SUAppcastItem *)bestValidUpdateInAppcast:(SUAppcast *)appcast forUpdater:(SUUpdater *)bundle;

// Sent when a valid update is found by the update driver.
- (void)updater:(SUUpdater *)updater didFindValidUpdate:(SUAppcastItem *)update;

// Sent when a valid update is not found.
- (void)updaterDidNotFindUpdate:(SUUpdater *)update;

// Sent immediately before installing the specified update.
- (void)updater:(SUUpdater *)updater willInstallUpdate:(SUAppcastItem *)update;

// Return YES to delay the relaunch until you do some processing; invoke the given NSInvocation to continue.
- (BOOL)updater:(SUUpdater *)updater shouldPostponeRelaunchForUpdate:(SUAppcastItem *)update untilInvoking:(NSInvocation *)invocation;

// Called immediately before relaunching.
- (void)updaterWillRelaunchApplication:(SUUpdater *)updater;

// This method allows you to provide a custom version comparator.
// If you don't implement this method or return nil, the standard version comparator will be used.
- (id <SUVersionComparison>)versionComparatorForUpdater:(SUUpdater *)updater;

// Returns the path which is used to relaunch the client after the update is installed. By default, the path of the host bundle.
- (NSString *)pathToRelaunchForUpdater:(SUUpdater *)updater;

@end

// Define some minimum intervals to avoid DOS-like checking attacks. These are in seconds.
#ifdef DEBUG
#define SU_MIN_CHECK_INTERVAL 60
#else
#define SU_MIN_CHECK_INTERVAL 60*60
#endif

#ifdef DEBUG
#define SU_DEFAULT_CHECK_INTERVAL 60
#else
#define SU_DEFAULT_CHECK_INTERVAL 60*60*24
#endif

#endif
