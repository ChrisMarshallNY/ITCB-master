## CREATING A CENTRAL MANAGER/DELEGATE (`00-StartingPoint`)

At this point, none of the applications will operate correctly as Bluetooth Centrals ("Question Askers"), but the MacOS and iOS/iPadOS variants will operate correctly as Bluetooth Peripherals ("Magic 8-Ball Answerers").

In this exercise, we'll add the Central functionality to all the apps, and complete the "Magic 8-Ball" game. We'll do this by completing the SDK, which is common to all the apps.

In the first step, we'll create the [`CBCentralManager`](https://developer.apple.com/documentation/corebluetooth/cbcentralmanager) instance.

In the second step, we'll add the basic [`CBCentralManagerDelegate`](https://developer.apple.com/documentation/corebluetooth/cbcentralmanagerdelegate) callbacks, and establish our Core Bluetooth presence.

By the end of this exercise, the apps will still not operate completely, but we'll be able to observe Core Bluetooth operating "under the hood," through `print()` statements.

## FIRST, LET'S SEE WHAT WE HAVE

If you haven't already done so, open the `ITCB.xcworkspace` workspace with Xcode, and use the Project navigator to select the `ITCB/src/Shared/internal/ITCB_SDK_Central_internal_Callbacks.swift` file.

The following code is all that you'll see (***NOTE:*** *We are removing comments, in order to keep these examples smaller*):

    import CoreBluetooth

    internal let _static_ITCB_SDK_8BallServiceUUID = CBUUID(string: "8E38140A-27BE-4090-8955-4FC4B5698D1E")
    internal let _static_ITCB_SDK_8BallService_Question_UUID = CBUUID(string: "BDD37D7A-F66A-47B9-A49C-FE29FD235A77")
    internal let _static_ITCB_SDK_8BallService_Answer_UUID = CBUUID(string: "349A0D7B-6215-4E2C-A095-AF078D737445")

    extension ITCB_SDK_Device_Peripheral {
        func sendQuestion(_ question: String) { }
    }


This is the bare minimum to allow the SDK to compile and operate in Peripheral Mode for the apps.

Those three [`CBUUID`](https://developer.apple.com/documentation/corebluetooth/cbuuid)s are the unique identifiers that we are using to denote the special Service and the two Characteristics that we use for our "magic 8-ball" game. They were generated using the following technique:

### Command Line

Simply start Terminal, and enter "[`uuidgen`](https://www.freebsd.org/cgi/man.cgi?query=uuidgen&sektion=1&manpath=freebsd-release-ports)", followed by a carriage return.

    $ uuidgen
    8E38140A-27BE-4090-8955-4FC4B5698D1E

[`uuidgen`](https://www.freebsd.org/cgi/man.cgi?query=uuidgen&sektion=1&manpath=freebsd-release-ports) is a built-in UUID generator, and we can use it to create unique identifiers for our attributes. The devices, themselves, will already have their own UUIDs.

### UUID-Generator Web Site

You can also use a UUID-generator Web site, [like this one](https://www.uuidgenerator.net/).

### The Empty [`sendQuestion(_:)`]() Method

This code:

    extension ITCB_SDK_Device_Peripheral {
        func sendQuestion(_ question: String) { }
    }

simply gives us just enough code to satisfy the requirement of the [`ITCB_Device_Peripheral_Protocol` protocol]() (that [`sendQuestion(_:)`]() method is required).

For the moment, we're leaving [`sendQuestion(_:)`]() empty, but it won't stay that way.

## ON TO CODING

Now, we'll start to add code. While we do that, we'll examine what is happening, step-by-step.

### We'll Be Implementing the [`CBCentralManagerDelegate`](https://developer.apple.com/documentation/corebluetooth/cbcentralmanagerdelegate) Protocol

This means that we'll be doing a couple of things:

1. We'll create a computed override of a [stored property]() that stores an instance of [`CBCentralManager`](https://developer.apple.com/documentation/corebluetooth/cbcentralmanager), and assign it to the superclass stored property (already prepared for it).

2. We'll create an extension of the [`ITCB_SDK_Central`]() class, adding several methods to provide conformance to the [`CBCentralManagerDelegate`](https://developer.apple.com/documentation/corebluetooth/cbcentralmanagerdelegate) protocol.

    What this means, is that the [`ITCB_SDK_Central`]() class will be set up to "catch" messages from our instance of [`CBCentralManager`](https://developer.apple.com/documentation/corebluetooth/cbcentralmanager), and act on them.

### STEP ONE: Instantiating the [`CBCentralManager`](https://developer.apple.com/documentation/corebluetooth/cbcentralmanager)

The first thing that we'll do, is add the following code, just below the static variables:

    extension ITCB_SDK_Central {
        override var _managerInstance: Any! {
            get {
                if super._managerInstance == nil {
                    super._managerInstance = CBCentralManager(delegate: self, queue: nil)
                }
            
                return super._managerInstance
            }
        
            set {
                super._managerInstance = newValue
            }
        }
    }

What this does, is override the stored property [`_managerInstance`]() with [a computed property](https://docs.swift.org/swift-book/LanguageGuide/Properties.html#ID259), so we intercept access to the stored property.

That property is "typeless," so it will need to be cast, in order to be useful in the future.

It is typeless, so that it can store either an instance of [`CBCentralManager`](https://developer.apple.com/documentation/corebluetooth/cbcentralmanager) or [`CBPeripheralManager`](https://developer.apple.com/documentation/corebluetooth/cbperipheralmanager), dependent upon the mode the SDK has been set to. It is *completely* typeless, as opposed to being an instance of [`CBManager`](https://developer.apple.com/documentation/corebluetooth/cbmanager), because I wanted to avoid referencing the Core Bluetooth module in the two "public" files (note that they both just import [`Foundation`](https://developer.apple.com/documentation/foundation)). I like my SDKs to hide as much stuff as possible.

It should also be noted that this is a **strong** reference. This is important. The `CB`*`XXX`*`Manager` instance needs to be kept around, after instantiation.

Our getter method will check the superclass instance of `_managerInstance` before returning it. If that instance is `nil`, then we'll actually instantiate an instance of [`CBCentralManager`](https://developer.apple.com/documentation/corebluetooth/cbcentralmanager), setting our class as the delegate, and using the Main Thread (by leaving the second argument as `nil`). We then assign this to the superclass property before returning the superclass property (which now has the new instance).

The setter is a simple straight-up passthrough.

***NOTE:*** *At this point, the build will be broken. The compiler will complain with a weird error like "Expression type 'CBCentralManager' is ambiguous without more context". This is because our main class is not [yet] conformant to [`CBCentralManagerDelegate`](https://developer.apple.com/documentation/corebluetooth/cbcentralmanagerdelegate). We'll fix that in just a minute.*

### STEP TWO: Adding [`CBCentralManagerDelegate`](https://developer.apple.com/documentation/corebluetooth/cbcentralmanagerdelegate) Conformance

Below the code we just added, we should now add this code:

    extension ITCB_SDK_Central: CBCentralManagerDelegate {
        public func centralManagerDidUpdateState(_ centralManager: CBCentralManager) { }
    }


Nothing will change, but the compiler will stop complaining.

That [`CBCentralManagerDelegate.centralManagerDidUpdateState(_:)`](https://developer.apple.com/documentation/corebluetooth/cbcentralmanagerdelegate/1518888-centralmanagerdidupdatestate) method is the only required method for [`CBCentralManagerDelegate`](https://developer.apple.com/documentation/corebluetooth/cbcentralmanagerdelegate) conformance. We added an empty "placeholder" method there (for now), in order to satisfy the conformance requirement.


#### Examining the State

It should be noted at this point that it's *really important* to not make any assumptions about the state of the Bluetooth subsystem, or any of the devices.

We should not proceed until Core Bluetooth reports that it is ready to go. It does this by setting the [`CBCentralManager.state`](https://developer.apple.com/documentation/corebluetooth/cbmanager/1648600-state) property to [`.poweredOn`](https://developer.apple.com/documentation/corebluetooth/cbmanagerstate/poweredon).

In our app, we'll assume that scanning is enabled at startup. What this means to us, is that when the Bluetooth subsystem is ready, we can immediately start scanning for peripherals.

We'll add the following code inside the empty [`CBCentralManagerDelegate.centralManagerDidUpdateState(_:)`](https://developer.apple.com/documentation/corebluetooth/cbcentralmanagerdelegate/1518888-centralmanagerdidupdatestate) method body:

    public func centralManagerDidUpdateState(_ centralManager: CBCentralManager) {
        if centralManager.state == .poweredOn {
            print("Scanning for Peripherals")
            centralManager.scanForPeripherals(withServices: [_static_ITCB_SDK_8BallServiceUUID], options: nil)
        }
    }

What we just did, was tell the app that, upon the Bluetooth system becoming powered-up and ready (the [`.poweredOn`](https://developer.apple.com/documentation/corebluetooth/cbmanagerstate/poweredon) state), we are to immediately begin scanning for Peripherals.

Note the [`_static_ITCB_SDK_8BallServiceUUID`]() that we send into the [`CBCentralManager.scanForPeripherals(withServices:,options:)`](https://developer.apple.com/documentation/corebluetooth/cbcentralmanager/1518986-scanforperipherals) method. That tells the Central to filter advertisements from Peripherals, and only pay attention to ones that claim that they provide the "Magic 8-Ball" Service. You can scan for multiple Services, here, with the filtering done on an "OR" basis (a device that advertises any one of the Services will result in a "hit").

In our app, we are only interested in the one custom Service that we created to run the magic 8-ball functionality. This ensures that only "Magic 8-Ball" Peripherals will be found.

***NOTE:*** *In any given tech environment, there may be dozens of devices that are advertising. This helps us to ignore the "noise floor" of all those advertising devices, and concentrate on just the ones that interest us.*

#### Responding to A Device Discovery

before we proceed further, we'll need to add two more static constants, just below the static variables at the top of the file:

    internal let _static_ITCB_SDK_RSSI_Min = -60
    internal let _static_ITCB_SDK_RSSI_Max = -20

These define a signal strength "window," describing a range of signal strength that we will consider valid for connection. The lower bound is -60dBm, and the upper bound is -20dBm.

Now that we are scanning for devices, we need to be able to react to their discovery, so we'll now add the following callback inside the extension we just made, and just after the [`CBCentralManagerDelegate.centralManagerDidUpdateState(_:)`](https://developer.apple.com/documentation/corebluetooth/cbcentralmanagerdelegate/1518888-centralmanagerdidupdatestate) method:

    public func centralManager(_ centralManager: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        if  !devices.contains(where: { $0.uuid == peripheral.identifier.uuidString }),
            let peripheralName = peripheral.name,
            !peripheralName.isEmpty,
            (_static_ITCB_SDK_RSSI_Min..._static_ITCB_SDK_RSSI_Max).contains(rssi.intValue) {
            print("Peripheral Discovered: \(peripheralName), RSSI: \(rssi)")
            devices.append(ITCB_SDK_Device_Peripheral(peripheral, owner: self))
            print("Connecting to \(peripheralName).")
            centralManager.connect(peripheral, options: nil)
        }
    }

Note the rather convoluted `if {}` statement. We do a bit of checking up on the Peripheral before moving forward with it.

Let's walk through this vetting:

##### The [`devices`]() Array

This is an Array property of the [`ITCB_SDK_Central`]() class, and its job is to maintain references to discovered devices. We store the devices as instances of the [`ITCB_SDK_Device_Peripheral`]() class, which is a "wrapper" for our devices.

Like the [`_managerInstance`]() property, it's important for us to maintain **strong** references to these wrappers (which, in turn, have their [own strong references]() to the Peripheral instance). Otherwise, they will be deallocated immediately upon leaving this callback.

It's also important to maintain **only one** reference to each of the instances.

***NOTE:*** *A quick note about how Core Bluetooth stores its entities: Managers and Peripherals are not stored in the Core Bluetooth system, and we need to make sure that we maintain strong references to them. However, Peripheral [`attributes`](https://developer.apple.com/documentation/corebluetooth/cbattribute) are stored by the Core Bluetooth system, and we should try to avoid referencing them with properties; especially with strong references. If we reference them, we should so with weak references. Attributes are subject to change at the whim of the Bluetooth device or the Core Bluetooth system.*

##### The If Statement

Now that **that** is out of the way, let's walk through the `if...{}` statement, line by line.

###### `!devices.contains(where: { $0.uuid == peripheral.identifier.uuidString })`

In the first line, we make sure that we don't already know about the Peripheral. We use the closure-based version of the [`Array.contains(_:)`](https://developer.apple.com/documentation/swift/array/2297359-contains) method, because we need to extract the UUID of each device from its "wrapper" instance.

###### `let peripheralName = peripheral.name`

The second line checks the name of the Peripheral, unwinds its optional, and sets that to a local context constant.

###### `!peripheralName.isEmpty`

The third line just makes sure that this name is valid (has a value). We need this name for display in our table.

###### `(_static_ITCB_SDK_RSSI_Min..._static_ITCB_SDK_RSSI_Max).contains(rssi.intValue)`

The last line makes sure that the signal strength of the Peripheral is within our acceptable range. Note that it is a "Closed" range, that includes the upper and lower bounds.

Once we have all these conditions met, we can assume that we have a valid, newly-discovered Peripheral (a "Magic 8-Ball" device), and can add it to our collection.

We do this by instantiating the "Peripheral wrapper" class ([`ITCB_SDK_Device_Peripheral`]()). When we instantiate that, it will establish itself as the [`CBPeripheralDelegate`](https://developer.apple.com/documentation/corebluetooth/cbperipheraldelegate) for the discovered Peripheral, and will handle callbacks from here on out.

We execute a `print()` statement, so that our console will log the discovery, and append the new device wrapper to our [`devices`]() Array.

We then execute another `print()` statement, reporting that we are about to connect to the device, and call the [`CBCentralManager.connect(_:,options:)`](https://developer.apple.com/documentation/corebluetooth/cbcentralmanager/1518766-connect) method to initiate a connection to the Peripheral.

***NOTE:*** *If we had not just added the newly discovered Peripheral to our [`devices`]() Array (which creates a strong reference), this connection would never happen, as the Peripheral would disappear as soon as this callback was exited. This can be a difficult bug to figure out, as the symptom is simply that the [`CBCentralManagerDelegate.centralManager(_:,didConnect:)`](https://developer.apple.com/documentation/corebluetooth/cbcentralmanagerdelegate/1518969-centralmanager) method is never called, and the [`CBCentralManagerDelegate.centralManager(_:,didFailToConnect:,error:)`](https://developer.apple.com/documentation/corebluetooth/cbcentralmanagerdelegate/1518988-centralmanager) method is also never called.*

#### Responding to A Device Connection

The last part of establishing [`CBCentralManagerDelegate`](https://developer.apple.com/documentation/corebluetooth/cbcentralmanagerdelegate) conformance, is to add [a callback](https://developer.apple.com/documentation/corebluetooth/cbcentralmanagerdelegate/1518969-centralmanager) to "catch" a successful connection. Since this is a very basic demo, and we're trying to keep things simple, we won't add [a callback](https://developer.apple.com/documentation/corebluetooth/cbcentralmanagerdelegate/1518988-centralmanager) to catch unsuccessful connections, but we should, in "real life."

Inside the extension, just below the discovery callback, we should add the following code:

    public func centralManager(_ centralManager: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Successfully Connected to \(peripheral.name ?? "ERROR").")
        print("Discovering Services for \(peripheral.name ?? "ERROR").")
        peripheral.discoverServices([_static_ITCB_SDK_8BallServiceUUID])
    }

This is the [`CBCentralManagerDelegate.centralManager(_:,didConnect:)`](https://developer.apple.com/documentation/corebluetooth/cbcentralmanagerdelegate/1518969-centralmanager) method. It is called when a successful connection to the device occurs.

In this, we simply execute a couple of `print()` statements, recording the event(Note that we use [the Nil-Coalescing Operator](https://littlegreenviper.com/miscellany/swiftwater/the-nil-coalescing-operator/)), and then ask the newly-connected Peripheral to [discover its Services](https://developer.apple.com/documentation/corebluetooth/cbperipheral/1518706-discoverservices).

***NOTE:*** *Note that we add a "filter" to the [`CBPeripheral.discoverServices(_:)`](https://developer.apple.com/documentation/corebluetooth/cbperipheral/1518706-discoverservices) method, so it will only search for our "Magic 8-Ball" Service.*

### AND WE'RE DONE WITH THIS STEP

All the rest of the action will happen in the [`CBPeripheralDelegate`](https://developer.apple.com/documentation/corebluetooth/cbperipheraldelegate) callbacks, which we'll tackle in the next major step.

**IT STILL DOESN'T WORK**

Despite the apps stil not working, there's now a lot more happening under the hood. If we run the app in Central Mode, and run another device in Peripheral Mode, we should see something like this in the debugger console:

    Scanning for Peripherals
    Peripheral Discovered: iPhone Xs Max, RSSI: -34
    Connecting to iPhone Xs Max.
    Successfully Connected to iPhone Xs Max.
    Discovering Services for iPhone Xs Max.
    2020-05-15 11:50:27.106865-0400 Bluetooth 8-Ball On Mac[12724:438012] [CoreBluetooth] API MISUSE: Discovering services for peripheral <CBPeripheral: 0x6000033340a0, identifier = 0AD4EE4D-F702-4C62-BA7A-4AB5054C1186, name = iPhone Xs Max, state = connected> while delegate is either nil or does not implement peripheral:didDiscoverServices:

Note that charming "API MISUSE" error ("`API MISUSE: Discovering services for peripheral <CBPeripheral: 0x6000033340a0, identifier = 0AD4EE4D-F702-4C62-BA7A-4AB5054C1186, name = iPhone Xs Max, state = connected> while delegate is either nil or does not implement peripheral:didDiscoverServices:`"). That's because we have yet to implement the [`CBPeripheralDelegate`](https://developer.apple.com/documentation/corebluetooth/cbperipheraldelegate) conformance in the app.

***NOTE:*** *It can take some time for a device to be discovered.*

## WHERE WE ARE NOW

At this point, we have added the following code to the [`ITCB/src/Shared/internal/ITCB_SDK_Central_internal_Callbacks.swift`]() file, between the original static constants, and the `ITCB_SDK_Device_Peripheral` extension:

    internal let _static_ITCB_SDK_RSSI_Min = -60
    internal let _static_ITCB_SDK_RSSI_Max = -20

    extension ITCB_SDK_Central {
        override var _managerInstance: Any! {
            get {
                if super._managerInstance == nil {
                    super._managerInstance = CBCentralManager(delegate: self, queue: nil)
                }
            
                return super._managerInstance
            }
        
            set {
                super._managerInstance = newValue
            }
        }
    }

    extension ITCB_SDK_Central: CBCentralManagerDelegate {
        public func centralManagerDidUpdateState(_ centralManager: CBCentralManager) {
            if centralManager.state == .poweredOn {
                print("Scanning for Peripherals")
                centralManager.scanForPeripherals(withServices: [_static_ITCB_SDK_8BallServiceUUID], options: nil)
            }
        }
    
        public func centralManager(_ centralManager: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
            if  !devices.contains(where: { $0.uuid == peripheral.identifier.uuidString }),
                let peripheralName = peripheral.name,
                !peripheralName.isEmpty,
                (_static_ITCB_SDK_RSSI_Min..._static_ITCB_SDK_RSSI_Max).contains(rssi.intValue) {
                print("Peripheral Discovered: \(peripheralName), RSSI: \(rssi)")
                devices.append(ITCB_SDK_Device_Peripheral(peripheral, owner: self))
                print("Connecting to \(peripheralName).")
                centralManager.connect(peripheral, options: nil)
            }
        }
    
        public func centralManager(_ centralManager: CBCentralManager, didConnect peripheral: CBPeripheral) {
            print("Successfully Connected to \(peripheral.name ?? "ERROR").")
            print("Discovering Services for \(peripheral.name ?? "ERROR").")
            peripheral.discoverServices([_static_ITCB_SDK_8BallServiceUUID])
        }
    }

Running the app in Central Mode still doesn't do anything, but we can see some output in the console, showing that devices are being discovered.

## NEXT STEP

Go back to the main lesson, and open the `01-SecondStep` directory, then, open the `ITCB.xcworkspace` workspace with Xcode, and follow the steps in the `README.md` file.
