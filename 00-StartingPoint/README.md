## STARTING POINT (`00-StartingPoint`)

The MacOS and iOS/iPadOS variants will operate correctly as Bluetooth Peripherals ("Magic 8-Ball Answerers").

None of the applications will operate correctly as Bluetooth Centrals ("Question Askers").

We will add the Central functionality, and complete the "Magic 8-Ball" game.

In the first step, we will add the basic [CBCentralManagerDelegate](https://developer.apple.com/documentation/corebluetooth/cbcentralmanagerdelegate) callbacks, and establish our Core Bluetooth presence.

By the end of this step, the apps will still not operate completely, but we will be able to observe Core Bluetooth, operating "under the hood," through `print()` statements.

## NEXT STEP

Open the `01-CBCentralManagerDelegate.xcworkspace` alias in the parent directory, and follow the directions in the `README.md` file.