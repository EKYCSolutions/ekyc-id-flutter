# ekyc_id_flutter

A new flutter plugin project.

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

## Installation

To use this plugin, add `ekyc_id_flutter` as a dependency in your pubspec.yaml file.

# Liveness Detection
## Usage

### 1. Create a `LivenessDetectionController`

```
  late LivenessDetectionController controller;
```
### 2. Create a LivenessDetection widget into your widget tree

```
@override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: LivenessDetection(
          onCreated: onLivenessDetectionCreated,
        ),
      ),
    );
  }
```

Initialize your controller with `onCreated`.

```
void onLivenessDetectionCreate (LivenessDetectionController controller) async {
    this.controller = controller;
    await this.controller.start(
      onInitialized: onInitialized,
      onFocus: onFocus,
      onFocusDropped: onFocusDropped,
      onFrame: onFrame,
      onPromptCompleted: onPromptCompleted,
      onCountDownChanged: onCountDownChanged,
      onAllPromptsCompleted: onAllPromptCompleted,
    );
  }
```

#### a. Get initialization progress

We can detect when the detection process start with `onInitialized` function. 

This is a good place to handling any loading animation you have.
#### b. Handle Focus and Unfocus Event

Use `onFocus` and `onFocusDropped` to detect whether the camera has focus on the subject.


#### c. Handle Liveness Prompts

`onPromptCompleted` function return back `LivenessPrompt` result such as

- `BLINKING`
- `LOOK_LEFT`
- `LOOK_RIGHT`

#### d. Get Countdown Progress

Shows current countdown.

#### e. Extract Frame Information

This function return back `FrameStatus`. 

Retrieve information about subject in the camera view eg. the subject's face is too far or to close.

- `PREPARING`
- `PROCESSING`
- `NO_FACE_FOUND`
- `FACE_FOUND`
- `FACE_TOO_BIG`
- `FACE_TOO_SMALL`
- `FACE_NOT_IN_CENTER`
- `MULTIPLE_FACES_FOUND`

Use this information to provide feedback to user.


#### f. Extract Liveness Detection Result

After completed all prompt you will get the detection result with `onAllPromptCompleted`.

*Full example in `/example/lib/main.dart` folder*



## Document Scanner

## Usage

### 1. Create a `DocumentScannerController`

```
  late DocumentScannerController controller;
```
### 2. Create a DocumentScanner widget into your widget tree


```
@override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: DocumentScanner(
          onCreated: onDocumentScannerCreated,
        ),
      ),
    );
  }
```


Initialize your controller with `onCreated`.

```
void onDocumentScannerCreated (DocumentScannerController controller) async {
    this.controller = controller;
    await this.controller.start(
      onInitialized: onInitialized,
      onFrame: onFrame,
      onDetection: onDetection,
    );
  }
```

#### a. Get initialization progress

We can detect when the detection process start with `onInitialized` function. 

#### b. Extract Frame Information

This function return back `FrameStatus`. 

Retrieve information about subject in the camera view eg. the subject's face is too far or to close.

- `PREPARING`
- `PROCESSING`
- `DOCUMENT_NOT_FOUND`
- `DOCUMENT_FOUND`
- `DOCUMENT_TOO_BIG`
- `DOCUMENT_TOO_SMALL`
- `DOCUMENT_NOT_IN_CENTER`


Use this information to provide feedback to user.


### c. Extract Detection Result

`onDetection` function return back the extracted information of the  document.