TextToSpeech
============

Example iOS app to take advantage of the text to speech features enabled starting in iOS7

This sample project is a single view application that shows off some of the text to speech features that were first introduced in the iOS7 SDK. You type in text in a textbox, select a voice type, speed, pitch and pause cutoff type and then play and stop playback of the text translated to voice. The app also registers itself to play speech when the app is running the background with full audio control capability. Here are the major libraries used:

AVSpeechSynthesizer
AVSpeechUtterance
AVAudioSession
MediaPlayer

This was deployed on iOS 8 using XCode 6 but should work just fine on iOS 7 using XCode 5.
