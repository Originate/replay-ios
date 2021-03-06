# Replay.IO iOS Framework

Building this project will produce `ReplayIO.framework`, which can then be distributed and integrated into third-party iOS projects.

## Documentation for framework developers

### Notes

Since ReplayIO includes dependencies, there may be conflicts if the host app is also dependent on the same things we are. Instead of forcing the clients of our SDK to include further dependencies, we rename any symbols that might conflict.

You can rename symbols at compile time by adding a flag to the “Other C Flags” section of the Build Settings for the project.

Ex.

`-D[Existing Symbol]=[New Symbol Name]`

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

This class queues the URL requests created by ReplayAPIManager. All requests to be sent out are enqueued by ReplayQueue and dequeued according to the `dispatchInterval`.

| t < 0           | t = 0              | t > 0          |
|-----------------|--------------------|----------------|
| Manual dispatch | Immediate dispatch | Timer dispatch |

The dequeue method will attempt to send off all requests in the queue synchronously. When connectivity problems prevent a request from succeeding, the dequeueing will stop.

A [popular third-party fork](https://github.com/tonymillion/Reachability) of Apple's Reachability class is used to detect changes to internet availability. When Reachability notifies the ReplayQueue that "there is internet," ReplayQueue will reattempt to dequeue all pending requests.

When the parent app is sent to the background, ReplayIO will persist all pending requests to disk, and requests will be requeued when the app is restored.

Possible TODOs:

* Batch dispatching (send multiple requests in a single HTTP request, requires server support)
* Request rate limiting

### Tests

We have tests, write and use them! Xcode 5 seems to have [removed](http://stackoverflow.com/questions/20605509/how-do-i-automatically-perform-unit-tests-on-each-build-and-run-action-in-xcod) the option to automatically test after building.

## Documentation for framework users

The framework lives as a singleton in your app. For convenience, all instance methods have class method counterparts, so there's no need to first obtain the global instance `[ReplayIO sharedTracker]`.

### Installation

1. Add *ReplayIO.framework* to your project
2. Add the following under the "Link Binary With Libraries" section of "Build Phases"
    * SystemConfiguration.framework
    * libsqlite3.dylib
3. Import the header file
 
	```#import <ReplayIO/ReplayIO.h>```

4. Initialize the tracker

	```[[ReplayIO sharedTracker] trackWithAPIKey:@"Your API Key"];```
	
### Tracking Events

```obj-c
[[ReplayIO sharedTracker] trackEvent:@"Event name"
          distinctId:@"A distinct string that identifies the user"
          properties:@{@"key": @"value"}];
```

### Set Traits

```obj-c
[[ReplayIO sharedTracker] updateTraitsWithDistinctId:@"A distinct string that identifies the user"
                          properties:@{@"key": @"value"}];
```

### Debugging

```obj-c
[[ReplayIO sharedTracker] setDebugMode:YES];
```

### Enable/disable

```obj-c
[[ReplayIO sharedTracker] enable];
[[ReplayIO sharedTracker] disable];
```

