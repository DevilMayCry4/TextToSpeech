//
//  ViewController.m
//  TextToSpeech
//
//  Created by Brett DiDonato on 9/26/14.
//  Copyright (c) 2014 BSD. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
BOOL didStartSpeaking;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize background audio session
    NSError *error = NULL;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    if(error) {
        NSLog(@"@error: %@", error);
    }
    [session setActive:YES error:&error];
    if (error) {
        NSLog(@"@error: %@", error);
    }
    
    // Enabled remote controls
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    // Voice setup
    self.voicePicker.delegate = self;
    self.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-us"];
    self.voices = [NSMutableArray arrayWithObjects:
                   @{@"voice" : @"en-us", @"label" : @"American English (Female)"},
                   @{@"voice" : @"en-au", @"label" : @"Australian English (Female)"},
                   @{@"voice" : @"en-gb", @"label" : @"British English (Male)"},
                   @{@"voice" : @"en-ie", @"label" : @"Irish English (Female)"},
                   @{@"voice" : @"en-za", @"label" : @"South African English (Female)"},
                   nil];
    
    // Synthesizer setup
    self.synthesizer = [[AVSpeechSynthesizer alloc] init];
    self.synthesizer.delegate = self;
    
    // UITextView delegate
    self.textView.delegate = self;
    
    // This notifcation is generated from the AppDelegate applicationDidBecomeActive method to make sure that if the play or pause button is updated in the background then the button will be updated in the toolbar
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateToolbar) name:@"updateToolbar" object:nil];
}

- (IBAction)handleSpeedStepper:(UIStepper *)sender
{
    double speedValue = self.speedStepper.value;
    [self.speedValueLabel setText:[NSString stringWithFormat:@"%.1f", speedValue]];
}

- (IBAction)handlePitchStepper:(UIStepper *)sender
{
    double pitchValue = self.pitchStepper.value;
    [self.pitchValueLabel setText:[NSString stringWithFormat:@"%.1f", pitchValue]];
}

- (IBAction)handlePlayPauseButton:(UIBarButtonItem *)sender
{
    if (self.synthesizer.speaking && !self.synthesizer.paused) {
        if (self.pauseSettingSegmentedControl.selectedSegmentIndex == 0) {
            // Stop immediately
            [self.synthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        }
        else {
            // Stop at end of current word
            [self.synthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryWord];
            
        }
        [self updateToolbarWithButton:@"play"];
    }
    else if (self.synthesizer.paused) {
        [self.synthesizer continueSpeaking];
        [self updateToolbarWithButton:@"pause"];
    }
    else {
        [self speakUtterance];
        [self updateToolbarWithButton:@"pause"];
    }
}

- (void)speakUtterance
{
    NSLog(@"speakUtterance");
    didStartSpeaking = NO;
    NSString *textToSpeak = [NSString stringWithFormat:@"%@", self.textView.text];
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:textToSpeak];
    utterance.rate = self.speedStepper.value;
    utterance.pitchMultiplier = self.pitchStepper.value;
    utterance.voice = self.voice;
    [self.synthesizer speakUtterance:utterance];
    [self displayBackgroundMediaFields];
}

- (void)displayBackgroundMediaFields
{
    MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"Play"]];
    
    NSDictionary *info = @{ MPMediaItemPropertyTitle: self.textView.text,
                            MPMediaItemPropertyAlbumTitle: @"TextToSpeech App",
                            MPMediaItemPropertyArtwork: artwork};
    
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = info;
}

- (void)updateToolbar
{
    if (self.synthesizer.speaking && !self.synthesizer.paused) {
        [self updateToolbarWithButton:@"pause"];
    }
    else {
        [self updateToolbarWithButton:@"play"];
    }
}

- (void)updateToolbarWithButton:(NSString *)buttonType
{
    NSLog(@"updateToolbarWithButton: %@", buttonType);
    UIBarButtonItem *audioControl;
    if ([buttonType isEqualToString:@"play"]) {
        // Play
        audioControl = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(handlePlayPauseButton:)];
    }
    else {
        // Pause
        audioControl = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(handlePlayPauseButton:)];
    }
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [self.toolbar setItems:@[flexibleItem, audioControl, flexibleItem]];
}

- (void)setTextViewTextWithColoredCharacterRange:(NSRange)characterRange
{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:self.textView.text];
    [text addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:NSMakeRange(0, self.textView.text.length)];
    [text addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:characterRange];
    self.textView.attributedText = text;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent
{
    NSLog(@"receivedEvent: %@", receivedEvent);
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlPlay:
                NSLog(@"UIEventSubtypeRemoteControlPlay");
                if (self.synthesizer.speaking) {
                    [self.synthesizer continueSpeaking];
                }
                else {
                    [self speakUtterance];
                }
                break;
                
            case UIEventSubtypeRemoteControlPause:
                NSLog(@"pause - UIEventSubtypeRemoteControlPause");
                
                if (self.pauseSettingSegmentedControl.selectedSegmentIndex == 0) {
                    // Pause immediately
                    [self.synthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
                }
                else {
                    // Pause at end of current word
                    [self.synthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryWord];
                }
                break;
                
            case UIEventSubtypeRemoteControlTogglePlayPause:
                if (self.synthesizer.paused) {
                    NSLog(@"UIEventSubtypeRemoteControlTogglePlayPause");
                    [self.synthesizer continueSpeaking];
                }
                else {
                    NSLog(@"UIEventSubtypeRemoteControlTogglePlayPause");
                    if (self.pauseSettingSegmentedControl.selectedSegmentIndex == 0) {
                        // Pause immediately
                        [self.synthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
                    }
                    else {
                        // Pause at end of current word
                        [self.synthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryWord];
                    }
                }
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                NSLog(@"UIEventSubtypeRemoteControlNextTrack - appropriate for playlists");
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                NSLog(@"UIEventSubtypeRemoteControlPreviousTrack - appropriatefor playlists");
                break;
                
            default:
                break;
        }
    }
}

#pragma mark UIPickerViewDelegate Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.voices.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *rowLabel = [[UILabel alloc] init];
    NSDictionary *voice = [self.voices objectAtIndex:row];
    rowLabel.text = [voice objectForKey:@"label"];
    return rowLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component
{
    NSDictionary *voice = [self.voices objectAtIndex:row];
    NSLog(@"new picker voice selected with label: %@", [voice objectForKey:@"label"]);
    self.voice = [AVSpeechSynthesisVoice voiceWithLanguage:[voice objectForKey:@"voice"]];
}

#pragma mark SpeechSynthesizerDelegate methods

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance
{
    // This is a workaround of a bug. When we change the voice the first time the speech utterence is set fails silently. We check that the method willSpeakRangeOfSpeechString is called and set didStartSpeaking to YES there. If this method is not called (silent fail) then we simply request to speak again.
    if (!didStartSpeaking) {
        [self speakUtterance];
    }
    else {
        [self updateToolbarWithButton:@"play"];
        [self setTextViewTextWithColoredCharacterRange:NSMakeRange(0, 0)];
    }
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance
{
    didStartSpeaking = YES;
    [self setTextViewTextWithColoredCharacterRange:characterRange];
}

#pragma mark UITextViewDelegate Methods

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma mark Cleanup Methods

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateToolbar" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
