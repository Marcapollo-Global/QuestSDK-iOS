# QuestSDK

<!--
[![CI Status](http://img.shields.io/travis/Shine Chen/QuestSDK.svg?style=flat)](https://travis-ci.org/Shine Chen/QuestSDK)
-->
[![Version](https://img.shields.io/cocoapods/v/QuestSDK.svg?style=flat)](http://cocoapods.org/pods/QuestSDK)
[![License](https://img.shields.io/cocoapods/l/QuestSDK.svg?style=flat)](http://cocoapods.org/pods/QuestSDK)
[![Platform](https://img.shields.io/cocoapods/p/QuestSDK.svg?style=flat)](http://cocoapods.org/pods/QuestSDK)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## How-To-Use

API documentation is available at [CocoaDocs - QuestSDK](http://cocoadocs.org/docsets/QuestSDK/)

## Getting Started

QuestSDK is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "QuestSDK"
```

## Author

marcapollo.com

## License

QuestSDK is available under the MIT license. See the LICENSE file for more info.

## Troubleshooting
### App cannot detect beacons, and iOS deson't prompt to ask user for authorization.
http://nevan.net/2014/09/core-location-manager-changes-in-ios-8/

<b>The first thing you need to do is to add one or both of the following keys to your Info.plist file:</b>
```
NSLocationWhenInUseUsageDescription
NSLocationAlwaysUsageDescription
```
