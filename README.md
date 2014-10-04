TextToSpeech
============

Example iOS app to take advantage of the text to speech features enabled starting in iOS 7

This sample project is a single view application that shows off some of the text to speech features that were first introduced in the iOS 7 SDK. You type in text in a textbox, select a voice type, speed, pitch and pause cutoff type and then play and stop playback of the text translated to voice. The app also registers itself to play speech when the app is running the background with full audio control capability. Here are the major libraries used:

<ul>
<li>AVSpeechSynthesizer</li>
<li>AVSpeechUtterance</li>
<li>AVAudioSession</li>
<li>MediaPlayer</li>
</ul>

This was deployed on iOS 8 using XCode 6 but should work just fine on iOS 7 using XCode 5.

<b>Simulator Issue in XCode 6:</b><br>
As of XCode 6.0.1 the simulator appears to not work at all with the AVSpeechSynthesizer. If you get an error message like the following, it is a simulator issue and not a program issue. It should work fine on any compatible iOS device.

Speech initialization error: 2147483665

<img src="https://s3.amazonaws.com/BSDTemp/texttospeechscreenshot1.png">
