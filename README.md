#  Bell Test App

This application was created for non-commercial use and its sole purspose is proof of skill for the Bell company.
For reviewer info: there seems to be a simulator bug when activating a search text field on a simulator, it’s preferable to run it on a device.

# Steps to run the app (Happy path):

## Clone or download the repo using green button in top right corner ## Open .workspace file in the Xcode. Try to run on a simulator or a device
 ##Steps to run the app (Sad path):

## Clone or download the repo using green button in top right corner ## Open .workspace file in the Xcode. Try to run on a simulator or a device
## Not working. Navigate to the project folder using Terminal command “cd <folder address>”
## Run “pod update” command in the terminal
## Try to run the project
## If still not working run “pod deintegrate” command and then “pod install” command
## Try run the project
## If still not working please contact me for assistance

## The app has several features: 
### tweet search in a given customizable radius around users current location if the permission is provided, otherwise searchwon't work
### tweet search by query of hashtags or keywords
### tweet like and retweet for authenticated user
### tweets are playable & viewable.
    
## The app relies on two external dependencies managed by Cocoapods. They are TwitterKit and RxSwift. 

### TwitterKit is the main framework for the application it does most of the job in API communication and content rendering.
### RxSwift is used for reactive MVVM architectural pattern.
    
## There are test that cover bonus part of the task
    
# Test assignment
Bell iOS and Android assignment

Using the Twitter API, create a native application build A) a data visualizer for Twitter, based on the location of the most recent tweets that have geolocation information. In particular, you will use the Twitter framework to get the most recent tweets within a 5 km (distance can be customizable) radius of the user’s current location and display it on a map.

If the user taps on one of the pins, a small view should display some information about the tweet, and a button to take them to a separate view that displays more information about the tweet (user’s twitter handle, the tweet’s text, timestamp, user’s avatar, etc.). On this separate view, the user should have the option of favoriting or retweeting that particular tweet (this can also be accomplished using the Twitter Framework).

B) The application should be able to display tweets search results based on keywords and hashtags. The listed tweets containing images and videos should be viewable and playable respectively.

Bonus: While on the map, the app can continuously poll for new tweets, and display them on the map when they are received.  Once 100 pins have been placed on the map, the 10 oldest tweets should be removed. If the app gets data for more than 100 tweets, it should display the most recent 100. Displaying too many pins on the map can slow down the event handling on the UI. 
Documentation:
https://developer.twitter.com/en/docs.html

Requirements:
•    App must be developed natively (Swift or Kotlin)
•    Easy to use UI and never be blocked.
•    Be sure to make network requests asynchronously (UI can’t be blocked)
•    Code must be written in the latest version of Swift for iOS or Kotlin for Android
•    Code must compile and run on latest version XCode and Android Studio 
•    We’re trying to restrict the usage of third-party libraries as much as possible. For this assignment, you should use Volley for Android and Alamofire for iOS for network calling.
•    If you do use a 3rd party library, a good reason needs to be provided, however we only allow 3 third party libs to be used including Volley or Alamofire.
•    Applying Material Design or Human Interface Guidelines for UI/UX.
•    This assignment should be done in a period of less than 3 days.

