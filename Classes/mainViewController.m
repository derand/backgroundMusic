    //
//  mainViewController.m
//  backgroundMusic
//
//  Created by maliy on 7/15/10.
//  Copyright 2010 interMobile. All rights reserved.
//

#import "mainViewController.h"


@implementation mainViewController

#pragma mark lifeCycle

- (id) init
{
	if (self = [super init])
	{
		
		// создаем класс-плейер
		NSURL *file = [[NSURL alloc] initFileURLWithPath:
					   [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"a_hot.caf"]];
		NSError *err = nil;
		player = [[AVAudioPlayer alloc] initWithContentsOfURL:file error:&err];
		[file release];
		player.numberOfLoops = -1;
		player.delegate = self;
		[player prepareToPlay];
	}
	return self;
}

- (void) dealloc
{
	[player release];
	
	[super dealloc];
}

#pragma mark -

// событие нажатия на кнопку Play/Stop
- (void) playStop:(id) sender
{
	if (player.playing)
	{
		[player stop];
		[playStopBtn setTitle:NSLocalizedString(@"Play", @"") forState:UIControlStateNormal];

		[tmUpdaterTimer invalidate];
		[tmUpdaterTimer release];
		tmUpdaterTimer = nil;
	}
	else
	{
		[player play];
		[playStopBtn setTitle:NSLocalizedString(@"Stop", @"") forState:UIControlStateNormal];
		
		tmUpdaterTimer = [[NSTimer scheduledTimerWithTimeInterval:0.2
														   target:self selector:@selector(timerAction:)
														 userInfo:nil repeats:YES] retain];
		
	}
}

// изменяется положение слайдера
- (void) changeTime:(UISlider *) sender
{
	if (!moving)
	{
		isPlaying = player.playing;
		if (player.playing)
		{
			[player stop];
		}
		moving = YES;
	}
	player.currentTime = sender.value;
//	[self timerAction:nil];
}

// окончание изменения позиции слайдера
- (void) endChangeTime:(UISlider *) sender
{
	moving = NO;
	if (isPlaying)
	{
		[player play];
	}
}

// обновление слайдера
- (void) timerAction:(NSTimer *) sender
{
	NSTimeInterval ct = player.currentTime;
	[tmSlider setValue:ct animated:YES];
}

// изменение свичера
- (void) modeChange:(UISwitch *) swch
{
	if (swch.on)
	{
		AudioSessionInitialize(NULL, kCFRunLoopDefaultMode, NULL, self);
		UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
		AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
		AudioSessionSetActive(true);
		
		swch.enabled = NO;
	}
}


#pragma mark AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)_player successfully:(BOOL)flag
{
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)_player
{
	isPlaying = player.playing;
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)_player withFlags:(NSUInteger)flags
{
	if (isPlaying)
	{
		[player play];
	}
}

#pragma mark -

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
	[super loadView];
	
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	
	UIView *contentView = [[UIView alloc] initWithFrame:screenRect];
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	contentView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.8];
	
	self.view = contentView;
	[contentView release];
	
	playStopBtn = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	playStopBtn.frame = CGRectMake(screenRect.size.width/4.0, screenRect.size.height/4.0, 
								   screenRect.size.width/2.0, screenRect.size.height/4.0);
	playStopBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	playStopBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	playStopBtn.backgroundColor = [UIColor clearColor];
	[playStopBtn setTitle:NSLocalizedString(@"Play", @"") forState:UIControlStateNormal];
	[playStopBtn addTarget:self action:@selector(playStop:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:playStopBtn];

	tmSlider = [[UISlider alloc] initWithFrame:
						CGRectMake(screenRect.size.width/10.0, 
								   screenRect.size.height/20.0,
								   screenRect.size.width-screenRect.size.width/5.0, 43.0)];
	tmSlider.value = 0.0;
	moving = NO;
	[tmSlider addTarget:self action:@selector(changeTime:) forControlEvents:UIControlEventValueChanged];
	[tmSlider addTarget:self action:@selector(endChangeTime:) forControlEvents:UIControlEventTouchUpInside];
	tmSlider.maximumValue = player.duration;
	[self.view addSubview:tmSlider];
	
	CGRect rct;
	UISwitch *tmp_swch = [[UISwitch alloc] initWithFrame:
						  CGRectMake(screenRect.size.width,
									 playStopBtn.frame.origin.y+playStopBtn.frame.size.height+screenRect.size.height/20.0,
									 0.0, 0.0)];
	[tmp_swch addTarget:self
				 action:@selector(modeChange:) 
	   forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:tmp_swch];
	rct = tmp_swch.frame;
	rct.origin.x -= rct.size.width+screenRect.size.width/20.0;
	tmp_swch.frame = rct;
	
	rct = CGRectMake(screenRect.size.width/20.0, rct.origin.y,
					 screenRect.size.width-rct.size.width-screenRect.size.width/10.0, rct.size.height);
	UILabel *tmp_lbl = [[UILabel alloc] initWithFrame:rct];
	tmp_lbl.text = NSLocalizedString(@"Play when screen locked", @"");
	tmp_lbl.backgroundColor = [UIColor clearColor];
	[self.view addSubview:tmp_lbl];
	[tmp_lbl release];
	
	self.navigationItem.title = NSLocalizedString(@"background music", @"");
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	[tmSlider release];
	[playStopBtn release];
}



@end
