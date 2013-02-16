//
//  TGSFirstViewController.h
//  TestGKSession
//
//  Created by kyoko.niida on 13/02/11.
//  Copyright (c) 2013年 kyoko.niida. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <GameKit/GameKit.h>
#import "mach/mach.h"

@interface TGSFirstViewController : UIViewController <GKSessionDelegate> {
    IBOutlet UIButton *sendButton;
    GKSession *session;
    NSString *peerId;
    int index;
}

- (IBAction) sendButtonDown:(id)sender;

@end
