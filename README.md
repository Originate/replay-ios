# Replay.IO iOS Framework

Building this project will produce `ReplayIO.framework`, which can then be distributed and integrated into third-party iOS projects.

## How to build the framework

The project settings and configurations needed to create the framework were taken from this handy [iOS Framework tutorial](https://github.com/jverkoey/iOS-Framework). One additional setting missed by the tutorial is ensuring that **Build Active Architectures** = *No*.

When you're ready to distribute the framework:

* Select the Framework target
* Build the project
* Expand the Products folder in the project navigator
* Right click *libReplayIO.a* 
* Click *Show in Finder*
* The resulting *ReplayIO.framework* file is the finished product

## Documentation for framework users

The framework lives as a singleton in your app. For convenience, all instance methods have class method counterparts, so there's no need to first obtain the global instance `[ReplayIO sharedTracker]`.

### Installation

1. Add *ReplayIO.framework* to your project
2. Import the header file
 
	```#import <ReplayIO/ReplayIO.h>```

3. Initialize the tracker

	```[ReplayIO trackWithAPIKey:@"Your API Key"];```
	
### Tracking Events

```
NSDictionary* eventDictionary = @{@"key": @"value"};
[ReplayIO trackEvent:eventDictionary];
```

### Debugging

```
[ReplayIO setDebugMode:YES];
```