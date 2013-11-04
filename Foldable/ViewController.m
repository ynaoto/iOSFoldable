//
//  ViewController.m
//  Foldable
//
//  Created by Naoto Yoshioka on 2013/11/03.
//  Copyright (c) 2013年 Naoto Yoshioka. All rights reserved.
//

#import "ViewController.h"
#import "QuadImageView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet QuadImageView *quadImageView;

@end

@implementation ViewController

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (touch.view == self.quadImageView.topLeftImageView) {
        NSLog(@"%s: topLeftImageView", __FUNCTION__);
    } else if (touch.view == self.quadImageView.topRightImageView) {
        NSLog(@"%s: topRightImageView", __FUNCTION__);
    } else if (touch.view == self.quadImageView.bottomLeftImageView) {
        NSLog(@"%s: bottomLeftImageView", __FUNCTION__);
    } else if (touch.view == self.quadImageView.bottomRightImageView) {
        NSLog(@"%s: bottomRightImageView", __FUNCTION__);
    } else {
        NSLog(@"%s: no interest", __FUNCTION__);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.quadImageView.topLeftImageView.userInteractionEnabled = YES;
    self.quadImageView.topRightImageView.userInteractionEnabled = YES;
    self.quadImageView.bottomLeftImageView.userInteractionEnabled = YES;
    self.quadImageView.bottomRightImageView.userInteractionEnabled = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
