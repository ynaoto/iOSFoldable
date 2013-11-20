//
//  ViewController.m
//  Foldable
//
//  Created by Naoto Yoshioka on 2013/11/03.
//  Copyright (c) 2013年 Naoto Yoshioka. All rights reserved.
//

#import "ViewController.h"
#import "FoldableQuadImageView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet FoldableQuadImageView *quadView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)useGeometryFlippingChanged:(UISwitch *)sender {
    self.quadView.useGeometryFlipping = sender.on;
}

@end
