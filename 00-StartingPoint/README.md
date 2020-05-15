## STARTING POINT (`00-StartingPoint`)

The MacOS and iOS/iPadOS variants will operate correctly as Bluetooth Peripherals ("Magic 8-Ball Answerers").

None of the applications will operate correctly as Bluetooth Centrals ("Question Askers").

We will add the Central functionality, and complete the "Magic 8-Ball" game.

In the first step, we will add the basic [`CBCentralManagerDelegate`](https://developer.apple.com/documentation/corebluetooth/cbcentralmanagerdelegate) callbacks, and establish our Core Bluetooth presence.

By the end of this step, the apps will still not operate completely, but we will be able to observe Core Bluetooth, operating "under the hood," through `print()` statements.

## FIRST, LET'S SEE WHAT WE HAVE

If you haven't already, open the `ITCB.xcworkspace` workspace with Xcode, and use the Project navigator to select the `ITCB/src/Shared/internal/ITCB_SDK_Central_internal_Callbacks.swift` file.

This will be all that you'll see (***NOTE:*** *We are removing comments, in order to keep these examples smaller*):

    import CoreBluetooth

    internal let _static_ITCB_SDK_8BallServiceUUID = CBUUID(string: "8E38140A-27BE-4090-8955-4FC4B5698D1E")
    internal let _static_ITCB_SDK_8BallService_Question_UUID = CBUUID(string: "BDD37D7A-F66A-47B9-A49C-FE29FD235A77")
    internal let _static_ITCB_SDK_8BallService_Answer_UUID = CBUUID(string: "349A0D7B-6215-4E2C-A095-AF078D737445")

    extension ITCB_SDK_Device_Peripheral {
        func sendQuestion(_ question: String) { }
    }


These are the bare minimum to allow the SDK to compile and operate in Peripheral Mode for the apps.

Those three UUIDs are the unique identifiers that we are using to denote the special Service and the two Characteristics that we use for our "magic 8-ball" game. They were generated using this technique:

Simply start Terminal, and enter "[`uuidgen`](https://www.freebsd.org/cgi/man.cgi?query=uuidgen&sektion=1&manpath=freebsd-release-ports)", followed by a carriage return.

    $ uuidgen
    8E38140A-27BE-4090-8955-4FC4B5698D1E
    
You can also use a UUID-generator Web site, [like this one](https://www.uuidgenerator.net/).

This code:

    extension ITCB_SDK_Device_Peripheral {
        func sendQuestion(_ question: String) { }
    }

Simply gives us just enough code to satisfy the requirement of the [`ITCB_Device_Peripheral_Protocol` protocol](https://github.com/LittleGreenViper/ITCB/blob/e911848003141b8d5f5a0702285b1c84d7ef16b5/00-StartingPoint/SDK-src/src/public/ITCB_SDK_Protocol.swift#L212)

That [`sendQuestion(_:)`](https://github.com/LittleGreenViper/ITCB/blob/e911848003141b8d5f5a0702285b1c84d7ef16b5/00-StartingPoint/SDK-src/src/internal/ITCB_SDK_Central_internal_Callbacks.swift#L35) method is required.

For the moment, we are leaving it empty, but it won't stay that way.

## ON TO CODING

Now, we will start to add code. While we do that, I'll explain what is happening, step-by-step.

### We Will Be Implementing the [`CBCentralManagerDelegate`](https://developer.apple.com/documentation/corebluetooth/cbcentralmanagerdelegate) Protocol

This means that we'll be doing a couple of things:

1. We will create a computed override of a [stored property](https://github.com/LittleGreenViper/ITCB/blob/e911848003141b8d5f5a0702285b1c84d7ef16b5/00-StartingPoint/SDK-src/src/public/ITCB_SDK.swift#L104) that stores an instance of [`CBCentralManager`](https://developer.apple.com/documentation/corebluetooth/cbcentralmanager), and assign it to the superclass stored property (already prepared for it).

    That property is "typeless," so it will need to be cast, in order to be useful in the future.

    It is typeless, so that it can store either an instance of [`CBCentralManager`](https://developer.apple.com/documentation/corebluetooth/cbcentralmanager) or [`CBPeripheralManager`](https://developer.apple.com/documentation/corebluetooth/cbperipheralmanager), dependent upon the mode the SDK has been set to.
    
    It should also be noted that this is a **strong** reference. This is important. The `CB`*`XXX`*`Manager` instance needs to be kept around, after instantiation.

2. We will create an extension of the [`ITCB_SDK_Central`](https://github.com/LittleGreenViper/ITCB/blob/e911848003141b8d5f5a0702285b1c84d7ef16b5/00-StartingPoint/SDK-src/src/public/ITCB_SDK.swift#L130) class, adding conformance to the [`CBCentralManagerDelegate`](https://developer.apple.com/documentation/corebluetooth/cbcentralmanagerdelegate) protocol.

    What this means, is that the [`ITCB_SDK_Central`](https://github.com/LittleGreenViper/ITCB/blob/e911848003141b8d5f5a0702285b1c84d7ef16b5/00-StartingPoint/SDK-src/src/public/ITCB_SDK.swift#L130) class will be set up to "catch" messages from our instance of [`CBCentralManager`](https://developer.apple.com/documentation/corebluetooth/cbcentralmanager), and act on them.

## NEXT STEP

Open the `01-CBCentralManagerDelegate` directory in the parent directory, open the `ITCB.xcworkspace` workspace with Xcode, and follow the steps in the `README.md` file.