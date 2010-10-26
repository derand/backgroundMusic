//
//  mainViewController.h
//  backgroundMusic
//
//  Created by maliy on 7/15/10.
//  Copyright 2010 interMobile. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface mainViewController : UIViewController <AVAudioPlayerDelegate>
{
	UIButton *playStopBtn;
	
	AVAudioPlayer *player;
	BOOL isPlaying;
	UISlider *tmSlider;
	BOOL moving;
	
	NSTimer *tmUpdaterTimer;

}

@end
