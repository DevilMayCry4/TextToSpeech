//
//  ViewController.h
//  TextToSpeech
//
//  Created by Brett DiDonato on 9/26/14.
//  Copyright (c) 2014 BSD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController : UIViewController <AVSpeechSynthesizerDelegate, AVAudioPlayerDelegate, UIPickerViewDelegate, UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UILabel *speedValueLabel;
@property (strong, nonatomic) IBOutlet UIStepper *speedStepper;
@property (strong, nonatomic) IBOutlet UILabel *pitchValueLabel;
@property (strong, nonatomic) IBOutlet UIStepper *pitchStepper;
@property (strong, nonatomic) IBOutlet UIPickerView *voicePicker;
@property (strong, nonatomic) IBOutlet UISegmentedControl *pauseSettingSegmentedControl;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *playPauseBarButtonItem;


@property (strong, nonatomic) AVSpeechSynthesizer *synthesizer;
@property (strong, nonatomic) NSMutableArray *voices;
@property (strong, nonatomic) AVSpeechSynthesisVoice *voice;

@end

