![Icon](../img/icon.png)

# [The Apps](https://github.com/LittleGreenViper/TheBasicsOfCoreBluetooth/tree/master/Apps-src)

The apps are "Ship-quality" apps, written to the standards of any apps destined to be sold/distributed through the various Apple App Stores. They are localizable and carefully designed.

They are not "super-advanced" apps, though. They don't use [SwiftUI](https://developer.apple.com/documentation/swiftui), for example; instead, sticking with the traditional [Interface Builder](https://developer.apple.com/xcode/interface-builder/).

They aren't the star of the show, and the lesson doesn't deal with them at all, except to mention the need for some plist values and a sandbox setting.

## The Way They Work

The apps implement a rather simple "game," based on the famous [Mattel Magic 8-Ball Toy](https://en.wikipedia.org/wiki/Magic_8-Ball).

It requires two devices (at least), with one acting as a "Central" (the "question-asker"), and the other[s] acting as a "Peripheral" (the "question-answerers").

There will only be one Central, but there can be more than one Peripheral.

Only iOS/iPadOS and MacOS support Peripheral Mode, so those are the only app variants that can act as "question-answerers."

***NOTE:** The following example images are from the iOS app, on an iPad and an iPhone.*

## The Initial Mode Selection Screen (iOS and MacOS apps Only)

![The Initial Mode Selection Screen](../img/Figure-1.png)

*Figure 1: The Initial Mode Selection Screen*

In this screen, the user is presented with two image buttons: "CENTRAL", and "PERIPHERAL".

They each represent an operating mode for the app.

This screen is only shown at startup, and "commits" the user to that mode, thereafter. In order to change modes, the user needs to exit the application, and restart.

## The Central Mode Screen

In Central Mode (which is also the only mode for tvOS and watchOS), the app acts as a "question-asking" app. The user is presented with a list of nearby Peripheral Mode devices in a simple, vertical table.

![The Central Mode Screen](../img/Figure-2.png)

*Figure 2: The Central Mode Screen*

## The Device Information Screen

Once a user selects one of the Peripherals, they are taken to a simple screen, with just a text entry field.

They use this field to "ask a question" of the Peripheral. It should be a "yes/no" question.

![Asking A Question In the Device Information Screen](../img/Figure-3.png)

*Figure 3: Asking a Question*

The Peripheral will automatically return an answer, randomly selected from [the 20 standard answers](https://en.wikipedia.org/wiki/Magic_8-Ball#Possible_answers).

![Getting the Answer In the Device Information Screen](../img/Figure-4.png)

*Figure 4: Getting the Answer*

***NOTE:** In the Watch variant of the app, there is no room to enter a question, so one of 20 random questions is selected to be sent.*

## The Peripheral Mode Screen

In Peripheral Mode *(Again, only for iOS/iPadOS and MacOS)*, the user doesn't do anything. The app reacts automatically to questions from the Central.

![The Peripheral Mode Screen](../img/Figure-5.png)

*Figure 5: Waiting for a Question*

Once a question is asked of a Peripheral, it is reported in an alert.

![The Peripheral Mode Screen Reports An Answer](../img/Figure-6.png)

*Figure 6: Reporting an Answer*

***NOTE** The alert needs to be dismissed by the user, so there is "a bit" of user interaction in Peripheral Mode.*