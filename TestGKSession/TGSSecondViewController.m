//
//  TGSSecondViewController.m
//  TestGKSession
//
//  Created by kyoko.niida on 13/02/11.
//  Copyright (c) 2013年 kyoko.niida. All rights reserved.
//

#import "TGSSecondViewController.h"

@interface TGSSecondViewController ()

@end

@implementation TGSSecondViewController

@synthesize mSession;

- (void)dealloc {
	[mPeers release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    sendButton.enabled = NO;
    index = 0;
	mPicker=[[GKPeerPickerController alloc] init];
	mPicker.delegate=self;
	mPicker.connectionTypesMask = GKPeerPickerConnectionTypeNearby | GKPeerPickerConnectionTypeOnline;
	mPeers=[[NSMutableArray alloc] init];
	[mPicker show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)peerPickerController:(GKPeerPickerController *)picker didSelectConnectionType:(GKPeerPickerConnectionType)type{
	if (type == GKPeerPickerConnectionTypeOnline) {
        picker.delegate = nil;
        [picker dismiss];
        [picker autorelease];
    }
}

- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type{
    
	//UIApplication *app=[UIApplication sharedApplication];
	NSString *txt=mTextField.text;
    
	GKSession* session = [[GKSession alloc] initWithSessionID:@"gavi" displayName:txt sessionMode:GKSessionModePeer];
    [session autorelease];
    return session;
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session{
    
	NSLog(@"Connected from %@",peerID);
    
	// Use a retaining property to take ownership of the session.
    self.mSession = session;
	// Assumes our object will also become the session's delegate.
    session.delegate = self;
    [session setDataReceiveHandler: self withContext:nil];
	// Remove the picker.
    picker.delegate = nil;
    [picker dismiss];
    [picker autorelease];
	// Start your game.
}

/*
 * メモリ使用量を標準出力に吐き出します。
 * 実行されるのはDEBUG変数が定義されている時だけです。
 */
- (void) printMemorySize {
    struct task_basic_info t_info;
    mach_msg_type_number_t t_info_count = TASK_BASIC_INFO_COUNT;
    
    if (task_info(current_task(), TASK_BASIC_INFO,
                  (task_info_t)&t_info, &t_info_count)!= KERN_SUCCESS) {
        NSLog(@"%s(): Error in task_info(): %s", __FUNCTION__, strerror(errno));
    }
    
    float unitSize = 1.0;
    u_int rss = t_info.resident_size;
    NSLog(@"RSS: %0.1f %@", rss/unitSize, @"Bytes");
}

- (UIImage*) createBackgroundImage:(UIColor*)color withSize:(CGSize)size {
    UIImage *screenImage;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    view.layer.cornerRadius = 5;
    view.clipsToBounds = true;
    view.backgroundColor = color;
    UIGraphicsBeginImageContext(size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    screenImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [view release];
    return screenImage;
}

- (void) send {
    SInt8 *intData = malloc(1000);
    for(int i=0; i<1000; i++) {
        intData[i] = 0;
    }
    for (int i=0; i<1000; i++) {
        [mSession sendData:[NSData dataWithBytesNoCopy:intData length:1000 freeWhenDone:NO] toPeers:mPeers withDataMode:GKSendDataReliable error:nil];
        if(++index % 100 == 0) {
            [self printMemorySize];
        }
    }
    free(intData);
    sendButton.enabled = YES;
}

- (IBAction) sendButtonDown:(id)sender {
    sendButton.enabled = NO;
    [self send];
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
    if(++index % 100 == 0) {
        [self printMemorySize];
    }
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker{
    
}

#pragma mark GameSessionDelegate stuff

/* Indicates a state change for the given peer.
 */
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    switch (state) {
        case GKPeerStateConnected:
			mTextView.text= [NSString stringWithFormat:@"%@\n%@%@", mTextView.text, @"Connected from pier ", peerID];
			[mPeers addObject:peerID];
            [sendButton setBackgroundImage:
             [self createBackgroundImage: [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0]
                                withSize:[sendButton bounds].size]
                                  forState:UIControlStateNormal];
            sendButton.enabled = YES;
			break;
        case GKPeerStateDisconnected:
			[mPeers removeObject:peerID];
			NSString *str=[NSString stringWithFormat:@"%@\n%@%@",mTextView.text,@"DisConnected from pier ",peerID];
			mTextView.text= str;
			NSLog(@"%@", str);
			break;
        case GKPeerStateAvailable:
            NSLog(@"discover,peerId[%@] ", peerID);
            [session connectToPeer:peerID withTimeout:10];
            break;
        case GKPeerStateUnavailable:
            NSLog(@"lost,peerId[%@] ", peerID);
            break;
        case GKPeerStateConnecting:
            NSLog(@"try connect,peerId[%@] ", peerID);
            break;
    }
}

@end
