# ![DxF Logo](/logo.png)

This project demonstrates how new Pega's DX API may be integrated with 3th party SDKs such as Google's [Flutter](https://flutter.dev/).

This Flutter project allows to build an Android and/or iOS application that communicate with Pega's DX API via HTTP Rest calls to dynamically render its UI.

## What. Is. This

- This project is just a **DEMO**. It should not be treated as a complete Fit-All Application or sound SDK to build upon. It's currently lacking support for many DX API features and due to the dynamic nature of Pega and DX API, the application will throw errors, not properly display or display incomplete chunks of UI or even crash and/or stop responding.
- It may be treated by developers as a **boilerplate** application, as it provides some architecture foundations which play out very well with Pega Platform and DX API natures.

## The architecture

- Similar to Constellation's Web version, the application uses a [Flux](https://facebook.github.io/flux/) architecture to build it's UI. That's no surprise, as it fits very well into the DX API response model, as well as with Flutter API to build UI. It's not mandatory though.
- Also, similar to Constellation's Web version, the application uses a [Redux](https://redux.js.org/) state container, as it's a natural fit for [Flux](https://facebook.github.io/flux/) and scales up pretty well as the application's complexity increases. It's not mandatory though. Other state management approaches have been considered but, due to the dynamic nature of Pega Platform and DX API, a single and global state container is the easiest way to tackle state management in a Constellation app.

## Enough! Let's get started

### Hold your horses, Bill
- You will need a Pega Platform 8.4 instance and a Constellation App configured. Lucky for us, Pega Platform 8.4 comes with a bundled demo Constellation App, aka. "Space Travel". You can use this app.
- Your user will need `YourApp:PegaAPI` Role in the Access Group. Lucky for us, `user@constellation.com`, does already have this role.

### I said, let's! get! started!

- [Install](https://flutter.dev/docs/get-started/install) Flutter's SDK on your local environment. All Windows (yes, that's right), macOS and Linux are supported, but you will need macOS to build for iOS.
- Run `flutter doctor` to ensure your local environment meets the requirements to build Android and/or iOS Flutter Application. Try to cross all the checkboxes.
- Open the project on IntelliJ IDEA or Android Studio. If `flutter doctor`, didn't tell you so, **you must install the Flutter plugin for you IDE**.
- With the plugin installed, open `pubspec.yaml` then click on `Packages get`. Alternatively from the command line `flutter packages get` from the project's root directory. This will install the project's package dependencies.
- For some reason I can't understand, you will need to run `pod install` from `ios` folder if you want to run the app on iOS (it's something with cocoa, so it can't be dangerous)
- To point to your Pega instance (see the above [section](#hold-your-horses-bill)), open `utils/dx_api.dart` and change `_username`, `_password` and `_baseUrl` to use your Pega Platform 8.4 instance.
- Select your favorite device/emulator and hit the Run/Debug button.
