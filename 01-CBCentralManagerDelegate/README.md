## CENTRAL DELEGATE COMPLETE (`01-InitialCentral`)

At this point, we have completed the Central discovery and connection phases. Those were handled by [`CBCentralManager`](https://developer.apple.com/documentation/corebluetooth/cbcentralmanager), and [`CBCentralManagerDelegate`](https://developer.apple.com/documentation/corebluetooth/cbcentralmanagerdelegate).

They did the job of finding our peripheral[s], and establishing a connection to [it|them] (This means that the Peripherals are now dedicated to us, and are no longer advertising. They are just waiting for the Central to ask them questions).

In this step, we will implement the [`CBPeripheralDelegate`](https://developer.apple.com/documentation/corebluetooth/cbperipheraldelegate) conformance. There's a lot involved. Most of the Core Bluetooth action happens here.

## FIRST, LET'S SEE WHAT WE HAVE

If you haven't already, open the `ITCB.xcworkspace` workspace with Xcode, and use the Project navigator to select the `ITCB/src/Shared/internal/ITCB_SDK_Central_internal_Callbacks.swift` file.

You should see something like this:

    import CoreBluetooth

    internal let _static_ITCB_SDK_8BallServiceUUID = CBUUID(string: "8E38140A-27BE-4090-8955-4FC4B5698D1E")
    internal let _static_ITCB_SDK_8BallService_Question_UUID = CBUUID(string: "BDD37D7A-F66A-47B9-A49C-FE29FD235A77")
    internal let _static_ITCB_SDK_8BallService_Answer_UUID = CBUUID(string: "349A0D7B-6215-4E2C-A095-AF078D737445")

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
            if  !devices.contains(peripheral),
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

    extension ITCB_SDK_Device_Peripheral {
        func sendQuestion(_ question: String) { }
    }

Remember that we've removed comments, in order to reduce the size of these code listings.

All of our work from here, on, will happen inside this context:

    extension ITCB_SDK_Device_Peripheral {
                    •
                    •
                    •
    }
    
Just assume that we are between those two brackets, and we don't need to worry about the rest of the file.

## ON TO CODING

### STEP ONE: Fill Out the [`sendQuestion(_:)`](https://github.com/LittleGreenViper/ITCB/blob/66e3e076b0bd616f340e47b76a97d0a7f9b6ab86/01-CBCentralManagerDelegate/SDK-src/src/internal/ITCB_SDK_Central_internal_Callbacks.swift#L82) method.

#### FIRST, the Backstory

Remember that local instances of [`CBPeripheral`](https://developer.apple.com/documentation/corebluetooth/cbperipheral) are *not actual one-to-one connections to remote devices*. They are a lot more akin to a "local directory" of the device, holding the "last known state" of the device, and information about its capabilities and data, along with directions for contacting the Peripheral.

##### We Have to Remove Our Hat, and Politely Ask the Peripheral to Set A Value

We "ask a question" by setting the value of one of the two Characteristics to the question (the value of the Characteristic is a simple string).

Except we don't actually "set" the value. Instead, *we send the new value to the Peripheral, and ask it to make it the new value of the Characteristic*. That's The Way of The Bluetooth. The Peripheral is always in charge of its state.

##### An "Evil" Little Swift Trick

Another thing that we did before we got here, was [this little "hack"](https://github.com/LittleGreenViper/ITCB/blob/af31419bea3f5dfb33ff4601aaffe4b719357f37/01-CBCentralManagerDelegate/SDK-src/src/internal/ITCB_SDK_internal.swift#L141) (It's not actually a "hack." It's the way we do stuff in Swift):

    extension Array where Element: CBAttribute {
        public subscript(_ inUUIDString: String) -> Element! {
            for element in self where element.uuid.uuidString == inUUIDString {
                return element
            }
        
            return nil
        }
    }

That's [a constrained Array extension](https://littlegreenviper.com/miscellany/swiftwater/swift-extensions-part-three/), and we use it to look up Attributes (Characteristics and Services, in our case) in an Array by their [`CBUUID`](https://developer.apple.com/documentation/corebluetooth/cbuuid)

What we did, was add a subscript that accepts a String as its argument, and then scans the Array, comparing the IDs, until it finds the one for which we're searching.

Basically, it treats the Array like a `[String: CBAttribute]` Dictionary. Not super-efficient, but we don't need it to be. It will make the code we're about to write a lot simpler, by allowing us to search the built-in Arrays using `CBUUID` Strings.

We also have a cached "[`question`](https://github.com/LittleGreenViper/ITCB/blob/66e3e076b0bd616f340e47b76a97d0a7f9b6ab86/01-CBCentralManagerDelegate/SDK-src/src/public/ITCB_SDK_Protocol.swift#L213)" property (I normally advise against caching Bluetooth values, but this is really the best way to do this, while keeping this code simple). This will hold our outgoing question String.

And finally, we have a stored property called [`_peerInstance`](https://github.com/LittleGreenViper/ITCB/blob/66e3e076b0bd616f340e47b76a97d0a7f9b6ab86/01-CBCentralManagerDelegate/SDK-src/src/internal/ITCB_SDK_internal.swift#L198), which holds a strong reference to either a [`CBPeripheral`](https://developer.apple.com/documentation/corebluetooth/cbperipheral) or a [`CBCentral`](https://developer.apple.com/documentation/corebluetooth/cbcentral) (when operating in Peripheral Mode).

Note that this is a **strong** reference. We need it to be so, because this will hold our only reference to the entity. I won't go into much detail, but I wanted to mention it, as it makes an appearance below.

#### NEXT, The Actual Code

We should replace this:

    func sendQuestion(_ question: String) { }

with this:

    public func sendQuestion(_ inQuestion: String) {
        question = nil
        if  let data = inQuestion.data(using: .utf8),
            let peripheral = _peerInstance as? CBPeripheral,
            let service = peripheral.services?[_static_ITCB_SDK_8BallServiceUUID.uuidString],
            let questionCharacteristic = service.characteristics?[_static_ITCB_SDK_8BallService_Question_UUID.uuidString],
            let answerCharacteristic = service.characteristics?[_static_ITCB_SDK_8BallService_Answer_UUID.uuidString] {
            _timeoutTimer = Timer.scheduledTimer(withTimeInterval: _timeoutLengthInSeconds, repeats: false) { [unowned self] (_) in
                self._timeoutTimer = nil
                self.owner?._sendErrorMessageToAllObservers(error: .sendFailed(ITCB_RejectionReason.deviceOffline))
            }
            _interimQuestion = inQuestion
            peripheral.setNotifyValue(true, for: answerCharacteristic)
            peripheral.writeValue(data, for: questionCharacteristic, type: .withResponse)
        } else if inQuestion.data(using: .utf8) == nil {
            print("Cannot send the question, because the question data is bad.")
            self.owner?._sendErrorMessageToAllObservers(error: .sendFailed(ITCB_RejectionReason.unknown(nil)))
        } else {
            print("Cannot send the question, because the Peripheral may be offline, or have other problems.")
            self.owner?._sendErrorMessageToAllObservers(error: .sendFailed(ITCB_RejectionReason.deviceOffline))
        }
    }

That's quite a handful, eh? Let's walk through it.

The first thing that we do, is clear the [`question`](https://github.com/LittleGreenViper/ITCB/blob/66e3e076b0bd616f340e47b76a97d0a7f9b6ab86/01-CBCentralManagerDelegate/SDK-src/src/public/ITCB_SDK_Protocol.swift#L213) property. It will only hold the question *after* it has been accepted by the Peripheral.

##### That Intricate `if... {}` Statement

We have another of our cascaded AND `if` statements. Let's go through it, line-by-line:

First, we convert the String to a `Data` object (`let data = inQuestion.data(using: .utf8)`). If that fails, the whole shooting match goes down the tubes.

Next, we unwind and cast the [`_peerInstance`](https://github.com/LittleGreenViper/ITCB/blob/66e3e076b0bd616f340e47b76a97d0a7f9b6ab86/01-CBCentralManagerDelegate/SDK-src/src/internal/ITCB_SDK_internal.swift#L198) property to a [`CBPeripheral`](https://developer.apple.com/documentation/corebluetooth/cbperipheral) instance (`let peripheral = _peerInstance as? CBPeripheral`).

Next, we use one of those constrained Array extensions that we mentioned earlier, to get the "Magic 8-Ball" Service from the Peripheral (`let service = peripheral.services?[_static_ITCB_SDK_8BallServiceUUID.uuidString]`).

Next, we do the same for the "question" Characteristic (`let questionCharacteristic = service.characteristics?[_static_ITCB_SDK_8BallService_Question_UUID.uuidString]`).

And lastly, we do the same for the "answer" Characteristic (`let questionCharacteristic = service.characteristics?[_static_ITCB_SDK_8BallService_Answer_UUID.uuidString]`).

##### We Need to Set Our Own Timeout

Core Bluetooth doesn't have a real timeout (in reality, operations will fail, after a certain time, but it can take quite a while). We need to set our own timeout.

In reality, we should have set a timeout for the connection, as well, but I wanted to keep this demonstration as simple as possible.

Our timeout is a very simple "one-shot" timer that notifies all the observers of the SDK (beyond the scope of this demo) that there's been a timeout.

The timeout timer is maintained in the [`_timeoutTimer`](https://github.com/LittleGreenViper/ITCB/blob/66e3e076b0bd616f340e47b76a97d0a7f9b6ab86/01-CBCentralManagerDelegate/SDK-src/src/internal/ITCB_SDK_Central_internal.swift#L121) property.

The timeout duration is defined in the [`_timeoutLengthInSeconds`](https://github.com/LittleGreenViper/ITCB/blob/66e3e076b0bd616f340e47b76a97d0a7f9b6ab86/01-CBCentralManagerDelegate/SDK-src/src/internal/ITCB_SDK_Central_internal.swift#L115) constant.

So the first thing that we do, when we send a question, is establish a 1-second timeout. When we are notified that the question was successfully asked, the timeout is invalidated, and set to `nil`.

##### We Need to Stash Our Question Until We Know It Was Asked

Next, we set the question being asked into an instance property called [`_interimQuestion`](https://github.com/LittleGreenViper/ITCB/blob/66e3e076b0bd616f340e47b76a97d0a7f9b6ab86/01-CBCentralManagerDelegate/SDK-src/src/internal/ITCB_SDK_Central_internal.swift#L127).

This is a "staging area" for the question.

Remember how we don't actually change the value of a Characteristic; instead, asking the Peripheral to do it on our behalf?

We can't change the actual [`question`](https://github.com/LittleGreenViper/ITCB/blob/66e3e076b0bd616f340e47b76a97d0a7f9b6ab86/01-CBCentralManagerDelegate/SDK-src/src/public/ITCB_SDK_Protocol.swift#L213) stored property, until we've been informed that the Peripheral has acceded to our demand, so we "stash" it here.

##### We Need to Set Up Notification for the Answer

Next, we tell the "answer" Characteristic to notify us when it changes. We do that by setting its [`notify`](https://developer.apple.com/documentation/corebluetooth/cbperipheral/1518949-setnotifyvalue) value (again, we are asking the Peripheral to do this on our behalf).

If we **really** wanted to get uptight about this, we would set up a [`CBPeripheralDelegate.peripheral(_:, didUpdateNotificationStateFor:,error:)`](https://developer.apple.com/documentation/corebluetooth/cbperipheraldelegate/1518768-peripheral) callback, and do the next step, there. However, this is complicated enough as it is, so we'll do both of them at once, and I'll show how I deal with this below -it's possible for the notify to be set *after* the question was asked, and we have to anticipate that.

##### We Ask the Peripheral to Set the Question Characteristic to the Question We Are Asking

Finally, we actually ask the Peripheral to set the value of the "question" Characteristic to the question we are asking.

#### Don't Forget Errors

We do have a couple of quick tests for errors during this process. These are not likely to happen, but it's always a good idea to make sure we plan ahead.

### STEP TWO: Establish Our [`CBPeripheralDelegate`](https://developer.apple.com/documentation/corebluetooth/cbperipheraldelegate) Conformance

We will need to establish four callbacks to manage the process of asking a question, and receiving the answer.

#### Discovery Callbacks

The first two callbacks are for the discovery phase, and are only executed when the device has been first discovered by the Central Manager.

If you remember from the first step, the last thing that the Central Manager did, was make the following call:

    peripheral.discoverServices([_static_ITCB_SDK_8BallServiceUUID])

That hands the baton over to the [`CBPeripheralDelegate`](https://developer.apple.com/documentation/corebluetooth/cbperipheraldelegate).

You didn't see it, but when we instantiated our internal [`ITCB_SDK_Device_Peripheral`](https://github.com/LittleGreenViper/ITCB/blob/66e3e076b0bd616f340e47b76a97d0a7f9b6ab86/01-CBCentralManagerDelegate/SDK-src/src/internal/ITCB_SDK_Central_internal.swift#L114) instance, it set itself up as the delegate for the new Peripheral instance, which means that it will "catch" all the callbacks, going forward. It did that in the [`init()`](https://github.com/LittleGreenViper/ITCB/blob/66e3e076b0bd616f340e47b76a97d0a7f9b6ab86/01-CBCentralManagerDelegate/SDK-src/src/internal/ITCB_SDK_Central_internal.swift#L192) initializer.

So that means that the last thing the Central did, was tell the Peripheral to discover its Services, and report the results to its delegate.

***NOTE:*** *We should be aware that a Peripheral won't automatically "know" which Services (and Characteristics, and so on) it has, until after it has "discovered" them, at the behest of the Central. Most Bluetooth entities are like this.*
