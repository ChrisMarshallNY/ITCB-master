![Bluetooth 8-Ball Icon](icon.png)

# INTRODUCTION TO CORE BLUETOOTH

Welcome to try! Swift World!

This is a ***VERY*** quick introduction to Core Bluetooth.

We only have a couple of hours, so the lesson will be highly constrained. It has been carefully designed to give a good idea of how to access the most useful parts of Core Bluetooth, and "prime the pump" for further exploration.

## THIS LESSON IS A "KEEPER"

The lesson has been designed as a "legacy." Once we're done, you will have a codebase of exceedingly well-documented Swift code at your disposal, so you can further explore Core Bluetooth.

In your explorations, you'll discover that what we discuss today "barely scratches the surface." The codebase will have complete implementation of **BOTH** a Central implementation (what we will cover), *and* a Peripheral implementation.

It will also have complete, App-Store-ready applications for MacOS, iOS/iPadOS, WatchOS and tvOS. Each app will implement a common Bluetooth "SDK" framework.

It is our hope that this codebase can provide great utility in your own endeavors.

*"A ship in harbor is safe, but that is not what ships are built for."*
- John A. Shedd

Go forth, and explore. Bluetooth is an enormous topic, and promises great adventures.

## MAGIC 8-BALL GAME

The application that we will use as a learning platform will be a Bluetooth expression of the famous [Mattel Magic 8-Ball toy](https://en.wikipedia.org/wiki/Magic_8-Ball).

In order to understand the game completely, view the `README.md` file in the `Final-CompleteImplementation` directory. That file will have a detailed "walkthrough" of the app.

At the start, we will have 4 applications that already function, but not completely. The goal of this exercise is to "fill in the blanks," and get the apps working properly.

As we do this, we'll strive to understand what is happening at each step.

## SDK VS. APPS

The Magic 8-Ball game has been designed as a cross-platform "SDK," that abstracts Core Bluetooth, and four relatively independent apps that will be focused on each of the Apple platforms: [Mac OS X](https://apple.com/macos), [iOS](https://apple.com/ios)/[iPadOS](https://apple.com/ipados), [tvOS](https://apple.com/tvos), and [WatchOS](https://apple.com/watchos).

The apps are fully operational, and at "release quality." They are not "casual samples." They could (arguably) be submitted to the Apple App Store right now.

Each app imports its own expression of [the Cocoa Application Layer](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/OSX_Technology_Overview/CocoaApplicationLayer/CocoaApplicationLayer.html), and is a fairly simple "basic" application that relies on [Interface Builder](https://developer.apple.com/xcode/interface-builder/). They are each aimed at the current major revision of the operating system to which they are targeted.

Thse versions are:

- [Mac OS X](https://apple.com/macos): 10.15 (Catalina), or above
- [iOS](https://apple.com/ios)/[iPadOS](https://apple.com/ipados): 13.0, or above
- [tvOS](https://apple.com/tvos): 13.0, or above
- [WatchOS](https://apple.com/watchos): 6.0, or above

They all share the same SDK, which has four variants, one for each platform. The SDK code is completely cross-platform, with one exception: Only Mac OS and iOS/iPadOS support "Peripheral Mode," so Watch and TV will not have this functionality.

We will work with one single SDK file throughout the entire exercise, [`SDK-src/src/internal/ITCB_SDK_Central_internal_Callbacks.swift`](https://github.com/LittleGreenViper/ITCB/blob/00-StartingPoint/SDK-src/src/internal/ITCB_SDK_Central_internal_Callbacks.swift); filling it in as we proceed.

All other files and directories will be left alone.

## REQUIREMENTS TO START

We should each have two Apple devices that we can access with Xcode, and run in debug mode.

We will need to have at least one device that can act as a Peripheral. Since we are working on a Mac, we already have that. This means that the other device can be an iPhone, iPod, iPad, Watch or AppleTV, as long as the device is recent enough to support the current operating system. We can use another Mac, but double-Mac debugging can be a bit complex. We're probably best off having an iOS device as our other target (This also allows us to switch the roles of the devices).

## STEPS

The lesson will proceed in two major steps, which will have "sub-steps." These major steps can be found in these directories:

- `00-StartingPoint`
    This directory contains the "bald" starting point. No code has been added.
    It walks through the process of adding [CBCentralManagerDelegate](https://developer.apple.com/documentation/corebluetooth/cbcentralmanagerdelegate) callbacks, and starting the process by discovering devices and their Services and Peripherals.
    
- `01-SecondStep`
    This directory starts at the completion of the previous step, and walks through the process of adding support for [CBPeripheralDelegate](https://developer.apple.com/documentation/corebluetooth/cbperipheraldelegate) callbacks, which is where the lions' share of functionality exists.
    
These directories will contain the complete, running applications:
    
- `02-FinishedLesson`
    This directory just contains the final implementation, including the Peripheral delegate callbacks. It is sparse, and not LINTed.
    
- `Final-CompleteImplementation`
    This directory is a "ship-ready" implementation of the project, with full source code documentation and LINTing.
    
## LET'S GET STARTED

To begin, simply open the `00-StartingPoint` directory, open the `ITCB.xcworkspace` workspace with Xcode, and follow the steps in the `README.md` file.