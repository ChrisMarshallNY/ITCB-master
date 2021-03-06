![Bluetooth 8-Ball Icon](img/trySwiftWorldITCB.png)

# A QUICK INTRODUCTION TO CORE BLUETOOTH

Welcome to [try! Swift World](https://tryswift.co/world)!

This is a ***VERY*** quick introduction to Core Bluetooth.

We only have a couple of hours, so the lesson will be highly constrained. It has been carefully designed to give a good idea of how to access the most useful parts of Core Bluetooth, and "prime the pump" for further exploration.

## THIS LESSON IS A "KEEPER"

The lesson has been designed as a "legacy." Once we're done, you will have a codebase of exceedingly well-documented Swift code at your disposal, so you can further explore Core Bluetooth.

The code is accompanied by extensive Markdown README files that walk through each exercise, in great detail.

In your explorations, you'll discover that what we discuss today "barely scratches the surface." The codebase will have complete implementation of **BOTH** a Central implementation (what we will cover), *and* a Peripheral implementation (what we don't cover, but pretty cool).

It will also have complete, App-Store-ready applications for [Mac OS X](https://apple.com/macos), [iOS](https://apple.com/ios)/[iPadOS](https://apple.com/ipados), [tvOS](https://apple.com/tvos), and [WatchOS](https://apple.com/watchos). Each app will implement a common Bluetooth "SDK" framework.

It is our hope that this codebase can provide great utility in your own endeavors.

*"A ship in harbor is safe, but that is not what ships are built for."*

– John A. Shedd

Go forth, and explore. Bluetooth is an enormous topic, and promises great adventures.

## MAGIC 8-BALL GAME

The application that we will use as a learning platform will be a Bluetooth expression of the famous [Mattel Magic 8-Ball toy](https://en.wikipedia.org/wiki/Magic_8-Ball).

In order to understand the game completely, view [the `README.md` file](https://github.com/ChrisMarshallNY/ITCB-master/blob/master/03-Final-CompleteImplementation/README.md) in [the `Final-CompleteImplementation` directory](https://github.com/ChrisMarshallNY/ITCB-master/tree/master/03-Final-CompleteImplementation). That file will have a detailed "walkthrough" of the app.

At the start, we will have 4 applications that already function, but not completely. The goal of this exercise is to "fill in the blanks," and get the apps working properly.

As we do this, we'll strive to understand what is happening at each step.

## SDK VS. APPS

The Magic 8-Ball game has been designed as a cross-platform "SDK," that abstracts Core Bluetooth, along with four relatively independent apps that will be focused on each of the Apple platforms: [Mac OS X](https://apple.com/macos), [iOS](https://apple.com/ios)/[iPadOS](https://apple.com/ipados), [tvOS](https://apple.com/tvos), and [WatchOS](https://apple.com/watchos).

The apps are fully operational, and at "release quality." They are not "casual samples." They could (arguably) be submitted to the Apple App Store right now.

Each app imports its own expression of [the Cocoa Application Layer](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/OSX_Technology_Overview/CocoaApplicationLayer/CocoaApplicationLayer.html), and is a fairly simple "basic" application that relies on [Interface Builder](https://developer.apple.com/xcode/interface-builder/). They are each aimed at the current major revision of the operating system to which they are targeted.

Thse versions are:

- [Mac OS X](https://apple.com/macos): 10.15 (Catalina), or above
- [iOS](https://apple.com/ios)/[iPadOS](https://apple.com/ipados): 13.0, or above
- [tvOS](https://apple.com/tvos): 13.0, or above
- [WatchOS](https://apple.com/watchos): 6.0, or above

They all share the same SDK, which has four variants, one for each platform. The SDK code is completely cross-platform, with one exception: ***Only Mac OS and iOS/iPadOS support "Peripheral Mode,"** so Watch and TV will not have this functionality.*

We will work with one single SDK file throughout the entire exercise, [`SDK-src/src/internal/ITCB_SDK_Central_internal_Callbacks.swift`](https://github.com/ChrisMarshallNY/ITCB-master/blob/master/00-StartingPoint/SDK-src/src/internal/ITCB_SDK_Central_internal_Callbacks.swift); filling it in as we proceed.

All other files and directories will be left alone.

## REQUIREMENTS TO START

- We should each have the latest version of Xcode, installed and ready to go.
- We should each have two Apple devices that we can access with Xcode, and run in debug mode *(one of them can be the Mac on which we are developing)*.
- These devices should be [registered](https://help.apple.com/developer-account/#/dev40df0d9fa) and prepared for debugging. We will run all our code on-device.
- We should all have Apple Developer accounts. **THEY NO LONGER NEED TO BE PAID ACCOUNTS (ADP).** Apple now [allows free accounts to run on-device](https://help.apple.com/xcode/mac/current/#/dev60b6fbbc7).

> ***NOTE:*** *We will need to have at least one device that can act as a Peripheral. Since we are working on a Mac, we already have that. This means that the other device can be an iPhone, iPod, iPad, Watch or AppleTV, as long as the device is recent enough to support the current operating system. We can use another Mac, but two-machine debugging can be a bit complex. We're probably best off having an iOS device as our other target (This also allows us to switch the roles of the devices).*

## PHASES

#### The lesson will proceed in two major phases, which will have "sub-steps." These major phases can be found in these directories:

- [`00-StartingPoint`](https://github.com/ChrisMarshallNY/ITCB-master/tree/master/00-StartingPoint)

This directory contains the "bald" starting point. No code has been added.
It walks through the process of adding [CBCentralManagerDelegate](https://developer.apple.com/documentation/corebluetooth/cbcentralmanagerdelegate) callbacks, and starting the process by discovering devices, and initiating connections.
    
- [`01-SecondStep`](https://github.com/ChrisMarshallNY/ITCB-master/tree/master/01-SecondStep)

This directory starts at the completion of the previous phase, and walks through the process of adding support for [CBPeripheralDelegate](https://developer.apple.com/documentation/corebluetooth/cbperipheraldelegate) callbacks, which is where the lions' share of functionality exists.
    
#### These directories will contain the complete, running applications:
    
- [`02-FinishedLesson`](https://github.com/ChrisMarshallNY/ITCB-master/tree/master/02-FinishedLesson)

This directory just contains the final implementation, including the Peripheral delegate callbacks. It is sparse, and not LINTed.
    
- [`03-Final-CompleteImplementation`](https://github.com/ChrisMarshallNY/ITCB-master/tree/master/03-Final-CompleteImplementation)

This directory is a "ship-ready" implementation of the project, with full source code documentation and LINTing.
    
## LET'S GET STARTED

### OPEN THE MAIN WORKSPACE

It's likely that you have already done so, but, if not, open the [`TheOneRing.xcworkspace` Xcode workspace file](https://github.com/ChrisMarshallNY/ITCB-master/tree/master/TheOneRing.xcworkspace). All work in this class will be done from this workspace.

### IDEAL CONFIGURATION

The ideal configuration for the lesson, is to use the Mac as the Central (question asker), and install the `03-Final-Bluetooth 8-Ball On iOS (App)` scheme *(explained below)* onto an iOS/iPadOS device (an iPod, iPhone, or iPad). You would then use the iOS device as a "test target," while developing the Mac application. This is the configuration that I will use during the class.

![The Ideal Setup](img/Setup.png)

### SCHEMES

At the top, in the Scheme Menu, you will see that there are sixteen (16) schemes that will implement the app for each operating system, at each phase of the lesson *(**NOTE:** The displayed order is likely to be different from the order below)*:

**These implement the first lesson (Part 1):**

- "`00-StartingPoint-Bluetooth 8-Ball On Mac (App)`"
- "`00-StartingPoint-Bluetooth 8-Ball On iOS (App)`"
- "`00-StartingPoint-Bluetooth 8-Ball On Watch (App)`"
- "`00-StartingPoint-Bluetooth 8-Ball On TV (App)`"

**These implement the second lesson (Part 2):**

- "`01-SecondStep-Bluetooth 8-Ball On Mac (App)`"
- "`01-SecondStep-Bluetooth 8-Ball On iOS (App)`"
- "`01-SecondStep-Bluetooth 8-Ball On Watch (App)`"
- "`01-SecondStep-Bluetooth 8-Ball On TV (App)`"

**These implement the completed apps, but with debug symbols and console strings:**

- "`02-FinishedLesson-Bluetooth 8-Ball On Mac (App)`"
- "`02-FinishedLesson-Bluetooth 8-Ball On iOS (App)`"
- "`02-FinishedLesson-Bluetooth 8-Ball On Watch (App)`"
- "`02-FinishedLesson-Bluetooth 8-Ball On TV (App)`"

**These implement the completed apps, as if they were to be released to the App Store:**

- "`03-Final-Bluetooth 8-Ball On Mac (App)`"
- "`03-Final-Bluetooth 8-Ball On iOS (App)`"
- "`03-Final-Bluetooth 8-Ball On Watch (App)`"
- "`03-Final-Bluetooth 8-Ball On TV (App)`"

Each of these will build the app (and the SDK) for the indicated platform.

If you were to look at the schemes in the Scheme Manager, you would see additional schemes to build the SDKs, but those are not displayed, as they are actually incorporated into the app  build schemes.

> ***The simulator won't support Core Bluetooth, so you should choose [an actual device](xcdevice://showDevicesWindow) as the target for each scheme. Also, be aware that iOS/iPadOS and MacOS are the only operating systems that support Peripheral Mode.***

The "`00-StartingPoint`" schemes will run, but the Central Mode won't work. Peripheral Mode will work fine (on Mac and iOS). You can use this to test as we proceed.

The "`01-SecondStep`" schemes will run, but the Central Mode still won't work. However, at this point, running the app, and locating a Peripheral will result in some debug prints in the Debugger Console.

The "`02-FinishedLesson`" schemes will run properly, but you will also see debug strings in the Console.

The "`03-Final`" schemes will run properly, without debug strings.

### QUICK VERIFICATION RUN

Select the "`00-StartingPoint-Bluetooth 8-Ball On Mac (App)`" scheme, and choose "`My Mac`" as the target. Build and run, just to make sure that all is good. There should be no errors, and you should get the Mode Selection Screen on the Mac.

![Mode Selection Screen for Mac](img/ModeSelectionScreen.png)

If you click on the "PERIPHERAL" button, the app will start waiting for a connection.

If you click on the "CENTRAL" button, you will get a blank screen, which is to be expected, at this point.

### WORKING FILE

If you are reading this in the "`TheOneRing.xcworkspace`" file, then it's easy. Simply look at the Project Navigator pane on the left side of the screen, and choose [the "`00-StartingPoint/ITCB_SDK_Central_internal_Callbacks.swift`" source file](https://github.com/ChrisMarshallNY/ITCB-master/blob/master/00-StartingPoint/SDK-src/src/internal/ITCB_SDK_Central_internal_Callbacks.swift):

![The Source File We'll be Modifying](img/FileLocation.png)

This is an alias to the actual file that we'll be working on in the project.

![The Actual Location of the Source File We'll be Modifying](img/AliasTarget.png)

Next, go to the [the `00-StartingPoint/README.md` file](https://github.com/ChrisMarshallNY/ITCB-master/blob/master/00-StartingPoint/README.md).

![The Next README File](img/NextREADME.png)

## REFERENCES

- [try! Swift World](https://tryswift.co/world)
- [My GitHub ID](https://github.com/ChrisMarshallNY)
- [My Email (chris@riftvalleysoftware.com)](mailto:chris@riftvalleysoftware.com)
- [This is a Downloadable ZIP File, With the Entire Lesson](https://github.com/ChrisMarshallNY/ITCB-master/blob/master/spec/ITCB.zip) *(**WARNING:** Big File -About 34MB)*
- [The Git Repo for This Entire Exercise](https://github.com/ChrisMarshallNY/ITCB-master)
- [The Git Repo Location of the Presentations](https://github.com/ChrisMarshallNY/ITCB-master/tree/master/Presentations) *([Apple Keynote](https://www.apple.com/keynote/) files)*
- [The Git Repo Location for the First Phase](https://github.com/ChrisMarshallNY/ITCB-master/tree/master/00-StartingPoint)
- [The Git Repo Location for the Second Phase](https://github.com/ChrisMarshallNY/ITCB-master/tree/master/01-SecondStep)
- [The Git Repo Location for the Finished Lesson](https://github.com/ChrisMarshallNY/ITCB-master/tree/master/02-FinishedLesson)
- [The Git Repo Location for the "Ship-Ready" Apps](https://github.com/ChrisMarshallNY/ITCB-master/tree/master/03-Final-CompleteImplementation)
- [This is a GitHub Gist, with the Snippets for the First Phase](https://gist.github.com/ChrisMarshallNY/d287be6dbcc88627178058bdee348d32)
- [This is a GitHub Gist, with the Snippets for the Second Phase](https://gist.github.com/ChrisMarshallNY/80f3370d407f9b5f848077e5f2061894)
- [The "Genesis" of This Lesson: A Series That Walks Through Development of a Core Bluetooth App](https://littlegreenviper.com/series/bluetooth/)
- [A "Sequel" to That Series](https://littlegreenviper.com/series/bluetooth-2/)
- [The "Blue Van Clef" App](https://riftvalleysoftware.com/work/ios-apps/bluevanclef/)
- [The Source Repo for the Blue Van Clef iOS App](https://github.com/RiftValleySoftware/BlueVanClef)
- [The Source Repo for the BlueThoth Bluetooth SDK Project (Used by Blue Van Clef)](https://github.com/RiftValleySoftware/RVS_BlueThoth)
- [The Source Documentation for the Blue Van Clef iOS App](https://riftvalleysoftware.github.io/BlueVanClef/)
- [The Apple Core Bluetooth Reference](https://developer.apple.com/documentation/corebluetooth)
- [The Apple Core Bluetooth Programming Guide](https://developer.apple.com/library/archive/documentation/NetworkingInternetWeb/Conceptual/CoreBluetooth_concepts/AboutCoreBluetooth/Introduction.html#//apple_ref/doc/uid/TP40013257)
- [Apple WWDC 2017 "What's New In Core Bluetooth" Session (Video)](https://developer.apple.com/videos/play/wwdc2017/712/)
- [Apple WWDC 2019 "What's New In Core Bluetooth" Session (Video)](https://developer.apple.com/videos/play/wwdc2019/901/)
- [The Main Bluetooth Site](https://www.bluetooth.com/)
- [Bluetooth Core Specifications](https://www.bluetooth.com/specifications/bluetooth-core-specification/)
- [The Official Bluetooth Name Story](https://www.bluetooth.com/about-us/bluetooth-origin/)
- [An Intel Story About Jim Kardach, and His Name for Bluetooth](https://newsroom.intel.com/editorials/the-man-who-named-bluetooth/#gs.7shvhe)
