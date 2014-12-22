# Replay for iOS

## Quick Start

In order to integrate Replay you’ll need to download the .framework from [link goes here]. Once downloaded, drag and drop it into your Xcode project (and make sure you’re linking against it). Also link against SystemConfiguration.framework Replay is dependant on SQLite for persisting events when the network is not reachable, so you will need to link against libsqlite3.dylib as well.

Once you’ve linked against Replay and SQLite your project should build again. In order to use Replay you’ll need to supply us your API key through the -trackWithAPIKey: method. Call that on the +sharedTracker and you’ll be ready to track events.

You can track events through the -trackEvent:distinctId:properties: method that takes the name of the event (e.g. @“User Login”), a unique identifier for the session/user (e.g. the current user’s user ID), and a dictionary of any additional information you’d like to associate with this event.

You can also use the -updateTraitsWithDistinctId:properties: method to set user-level information you need to collect.

## In Depth

### Interface

Replay’s SDK exposes one class, ReplayIO. ReplayIO has a +sharedTracker and the following properties and instance methods:

#### debugMode

debugMode (getter: isDebugMode) lets you run the tracker in debug mode. Once the tracker is in debug mode we will log additional information about events we receive to the console.

#### -trackWithAPIKey:

This method lets you set the API key associated with your Replay project.

#### -trackEvent:distinctId:properties:

This method lets you track events for a given user when the tracker is enabled.

#### -updateTraitsWithDistinctId:properties: 

This method lets you set user specific information.

#### -enable/-disable

This method enables the Replay tracker. When enabled, Replay will send requests to our API. If disabled Replay will ignore calls to -trackEvent:distinctId:properties: and updateTraitsWithDistinctId:properties:.

### Dispatch

When enabled, Replay queues up network operations as soon as either -trackEvent:distinctId:properties: or updateTraitsWithDistinctId:properties: are called. If Replay does not have network access it will serialize the request to disk and send them once network access is restored. 
