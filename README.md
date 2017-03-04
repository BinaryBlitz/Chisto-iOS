# Chisto

- Ruby version: 2.4.0
- System dependencies: `$ gem install cocoapods`
- Install dependencies: `$ pod install`
- Deployment instructions: `$ fastlane beta` for beta build, `$ fastlane release` for iTunes Connect

## Architecture
### Data
* DataManager
  + Singletone. Contains of the methods which are used to work with data. Uses NetworkManager instance to make backend API calls
* NetworkManager
  + Backend API calls
* ProfileManager
  - Singletone. Storing and updating current profile
    + userProfile property is a RxSwift variable which contains current user profile. Sends events when a profile object in Realm updates.
 
### RxUtils
- Extensions and classes created to simplify some operations with RxSwift

### Style
- Colors and fonts provided by the app design. Imported from Zeplin.

### UI
Every directory here(except Common) contains of:
  1. A Storyboard file consisting of a single ViewController scene
  2. A corresponding ViewController subclass
  3. A ViewModel class containing observables, variables for binding, methods etc., which are prepared in the init() method
  4. (Optionaly) A views folder containing of views and corresponding viewModels used in current scene
  
* Common
  - Extensions and classes created to simplify some operations with UI, also some views which are used more than in one screen
  
### Util
  - Extensions and classes created to simplify some operations with Swift and Foundation

