//
//  TGSSecondViewController.h
//  TestGKSession
//
//  Created by kyoko.niida on 13/02/11.
//  Copyright (c) 2013年 kyoko.niida. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <GameKit/GameKit.h>
#import "mach/mach.h"

@interface TGSSecondViewController : UIViewController <GKPeerPickerControllerDelegate,GKSessionDelegate> {
    IBOutlet UIButton *sendButton;
	GKPeerPickerController *mPicker;
	GKSession *mSession;
	IBOutlet UITextField *mTextField;
	IBOutlet UITextView *mTextView;
	NSMutableArray *mPeers;
    int index;
}

@property (retain) GKSession *mSession;

- (IBAction) sendButtonDown:(id)sender;

@end
