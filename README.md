![Bluetooth 8-Ball Icon](icon.png)

# INTRODUCTION TO CORE BLUETOOTH

Welcome to try! Swift World!

This is a ***VERY*** quick introduction to Core Bluetooth.

We only have a couple of hours, so the lesson will be highly constrained, and has been carefully designed to give a good idea of how to access the most useful parts of Core Bluetooth, and "prime the pump" for further exploration.

## MAGIC 8-BALL GAME

The application that we will use as a learning platform will be a Bluetooth expression of the famous [Mattel Magic 8-Ball toy](https://en.wikipedia.org/wiki/Magic_8-Ball).

In order to understand the game completely, view the `README.md` file in the `Final-CompleteImplementation` directory, available in this directory. That file will have a detailed "walkthrough" of the app.

At the start, we will have 4 applications that already function, but not completely. The goal of this exercise is to "fill in the blanks," and get the apps working properly.

As we do this, we'll strive to understand what is happening at each step.

## SDK VS. APPS

The Magic 8-Ball game has been designed as a cross-platform "SDK," that abstracts Core Bluetooth, and four relatively independent apps that will be focused on each of the Apple platforms: [Mac OS X](https://apple.com/macos), [iOS](https://apple.com/ios)/[iPadOS](https://apple.com/ipados), [tvOS](https://apple.com/tvos), and [WatchOS](https://apple.com/watchos).

The apps are fully operational, and at "release quality." They are not "casual samples." They could (arguably) be submitted to the Apple App Store right now.

Each app imports its own expression of [the Cocoa Application Layer](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/OSX_Technology_Overview/CocoaApplicationLayer/CocoaApplicationLayer.html), and is a fairly simple "basic" application that relies on [Interface Builder](https://developer.apple.com/xcode/interface-builder/). They are each aimed at the current major revision of the operating system to which they are targeted.

They all share the same SDK, which has four variants, one for each platform. The SDK code is completely cross-platform, with one exception: Only Mac OS and iOS/iPadOS support "Peripheral Mode," so Watch and TV will not have this functionality.

We will work with one single SDK file throughout the entire exercise, `SDK-src/src/internal/ITCB_SDK_Central_internal_Callbacks.swift`; filling it in as we proceed.

All other files and directories will be left alone.

## REQUIREMENTS TO START

Two Apple devices that we can access with Xcode, and run in debug mode.

We will need to have at least one device that can act as a Peripheral. Since we are working on a Mac, we already have that. This means that the other device can be an iPhone, iPod, iPad, Watch or AppleTV, as long as the device is recent enough to support the current operating system. We can use another Mac, but double-Mac debugging can be a bit complex. We're probably best off having an iOS device as our other target (This also allows us to switch the roles of the devices).

## STEPS

The lesson will proceed in two major steps, which will have "sub-steps." These major steps can be found in four directories:

- `00-StartingPoint`
    This directory contains the "bald" starting point. No code has been added.
    It walks through the process of adding [CBCentralManagerDelegate](https://developer.apple.com/documentation/corebluetooth/cbcentralmanagerdelegate) callbacks, and starting the process by discovering devices and their Services and Peripherals.
    
- `01-CBCentralManagerDelegate`
    This directory starts at the completion of the previous step, and walks through the process of adding support for [CBPeripheralDelegate](https://developer.apple.com/documentation/corebluetooth/cbperipheraldelegate) callbacks, which is where the lions' share of functionality exists.
    
- `02-CBPeripheralDelegate`
    This directory just contains the final implementation, including the Peripheral delegate callbacks.
    
- `Final-CompleteImplementation`
    This directory is a "ship-ready" implementation of the project, with full source code documentation and LINTing.