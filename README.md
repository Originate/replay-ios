# Replay.IO iOS Framework

Building this project will produce `ReplayIO.framework`, which can then be distributed and integrated into third-party iOS projects.

## How to build the framework

The project settings and configurations needed to create the framework were taken from this handy [iOS Framework tutorial](https://github.com/jverkoey/iOS-Framework). One additional setting missed by the tutorial is ensuring that **Build Active Architectures=*No***.

When you're ready to distribute the framework:

* Select the Framework target
* Build the project
* Expand the Products folder in the project navigator
* Right click *libReplayIO.a* 
* Click *Show in Finder*
* The resulting *ReplayIO.framework* file is the finished product

## Configuration

The API endpoints and configuration strings are defined and stored in the `ReplayConfig` class. Originally, a .plist file was used to store these, but when building frameworks, non-code resources are omitted.

### Adding/modifying endpoint definitions

API endpoints are defined in the `ReplayConfig.endpoints`. To add an endpoint, simply add its definition here. The definition must follow this format:

```
@"Endpoint name": @{kPath  : @"relative-path-to-resource",
                    kMethod: @"HTTP method: POST, GET, etc...",
                    kJSON  : @{the JSON structure that the server requires}}
```

Within the dictionary for `kJSON`, mark the primary data parameter with `kContent`.

#### Example

The "Events" endpoint is defined:

```
POST /events
{
  data:      <the primary parameter of this API call>
  replayKey: <ReplayIO API key>
  clientId:  <UUID created by SDK, persists across all uses of the app>
  sessionId: <UUID created by SDK, persists for a single use of the app>
}
```

This definition is added to `self.endpoints`:

```obj-c
@"Events": @{kPath  : @"events",
             kMethod: @"POST",
             kJSON  : @{@"data"   : kContent,
                        kReplayKey: @"",
                        kClientId : @"",
                        kSessionId: @""}
```

Note how `kContent` marks the primary data value of this call. When an instance of `ReplayEndpoint` is created, the value marked with `kContent` will be replaced with the actual data to be sent.

The other values are left as empty strings, and using `+ [ReplayAPIManager mapLocalKeyFromServerKey:]`, `kReplayKey`, `kClientId`, and `kSessionId`'s values are automatically mapped to properties of the ReplayAPIManager.

Finally, to use the endpoint:

```obj-c
ReplayEndpoint* endpoint= [ReplayEndpoint initWithEndpointName:@"Events" data:data];
[endpoint callWithCompletionHandler:...];
```

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
NSDictionary* eventDictionary = @{@"key": @"value"};
[ReplayIO trackEvent:eventDictionary];
```

### Debugging

```obj-c
[ReplayIO setDebugMode:YES];
```