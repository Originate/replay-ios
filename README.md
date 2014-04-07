# Replay.IO iOS Framework

Building this project will produce `ReplayIO.framework`, which can then be distributed and integrated into third-party iOS projects.

## Documentation for framework developers

### How to build the framework

The project settings and configurations needed to create the framework were taken from this handy [iOS Framework tutorial](https://github.com/jverkoey/iOS-Framework). One additional setting missed by the tutorial is ensuring that **Build Active Architectures=*No***.

When you're ready to distribute the framework:

* Select the Framework target
* Build the project
* Expand the Products folder in the project navigator
* Right click *libReplayIO.a*, then click *Show in Finder*
* The resulting *ReplayIO.framework* file is the finished product

### ReplaySesssionManager

All calls to `[ReplaySessionManager sessionUUID]` should return the same UUID until `[ReplaySessionManager endSession]` is called. 

A session ends when the app is sent to the background. Upon restoration, a new session UUID is generated, and stored in `NSUserDefaults`. The ReplayIO class registers itself for listening to app delegate notifications. 

### ReplayAPIManager

This class manages the endpoints. For each endpoint, there should be a corresponding `- (NSURLRequest *)requestFor<Endpoint>...` method that returns an NSURLRequest that's ready to be fired off.

### ReplayQueue

This class queues the URL requests created by ReplayAPIManager.

Possible features:

* Batch dispatching
* Request rate limiting
* Store requests when internet connection is unavailable

### Tests

We have tests, write and use them! Haven't been able to automatically run tests before building.

## Documentation for framework users

The framework lives as a singleton in your app. For convenience, all instance methods have class method counterparts, so there's no need to first obtain the global instance `[ReplayIO sharedTracker]`.

### Installation

1. Add *ReplayIO.framework* to your project
2. Import the header file
 
	```#import <ReplayIO/ReplayIO.h>```

3. Initialize the tracker

	```[ReplayIO trackWithAPIKey:@"Your API Key"];```
	
### Tracking Events

```obj-c
[ReplayIO trackEvent:@"Event name" withProperties:@{@"key": @"value"}];
```

### Set Alias

```obj-c
[ReplayIO updateAlias:@"Custom alias"];
```

### Debugging

```obj-c
[ReplayIO setDebugMode:YES];
```

### Enable/disable

```obj-c
[ReplayIO enable];
[ReplayIO disable];
```