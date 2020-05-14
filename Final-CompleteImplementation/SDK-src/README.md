![Icon](../img/icon.png)

#[The SDKs](https://github.com/LittleGreenViper/TheBasicsOfCoreBluetooth/tree/master/SDK-src)

## Common Core

The entirety of [the SDK code](https://github.com/LittleGreenViper/TheBasicsOfCoreBluetooth/tree/master/SDK-src/src) is shared between platforms, with the exception of [this file](https://github.com/LittleGreenViper/TheBasicsOfCoreBluetooth/blob/master/SDK-src/src/internal/ITCB_SDK_Peripheral_internal.swift), which is only included in the [MacOS](https://github.com/LittleGreenViper/TheBasicsOfCoreBluetooth/tree/master/SDK-src/ITCB_SDK_Mac) and [iOS/iPadOS](https://github.com/LittleGreenViper/TheBasicsOfCoreBluetooth/tree/master/SDK-src/ITCB_SDK_iOS) targets (it implements Peripheral Mode, which is not supported in TV or Watch).

The various target directories ([MacOS](https://github.com/LittleGreenViper/TheBasicsOfCoreBluetooth/tree/master/SDK-src/ITCB_SDK_Mac), [iOS](https://github.com/LittleGreenViper/TheBasicsOfCoreBluetooth/tree/master/SDK-src/ITCB_SDK_iOS), [watchOS](https://github.com/LittleGreenViper/TheBasicsOfCoreBluetooth/tree/master/SDK-src/ITCB_SDK_Watch), and [tvOS](https://github.com/LittleGreenViper/TheBasicsOfCoreBluetooth/tree/master/SDK-src/ITCB_SDK_TVOS)) contain only a single [plist](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=13&cad=rja&uact=8&ved=2ahUKEwjytoaSy7HpAhXagnIEHdRwDRUQFjAMegQIPBAB&url=https%3A%2F%2Fdeveloper.apple.com%2Flibrary%2Farchive%2Fdocumentation%2FGeneral%2FReference%2FInfoPlistKeyReference%2FArticles%2FAboutInformationPropertyListFiles.html&usg=AOvVaw2rlth1YGdVn8U50mCDZp-n) file, each.

There is a separate target for each platform, with the naming convention of "ITCB_SDK_*`XXX`*", where "*`XXX`*" is replaced with the target operating system ("Mac", "iOS", "Watch", or "TV").

Each target is [a dynamic "pure Swift" framework](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/DynamicLibraries/100-Articles/OverviewOfDynamicLibraries.html). By "pure Swift," we mean that there is no [bridging header](https://developer.apple.com/documentation/swift/imported_c_and_objective-c_apis/importing_swift_into_objective-c). Only Swift applications can use the SDK.
