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
@property (weak, nonatomic) IBOutlet FoldableQuadImageView *view1;
@property (weak, nonatomic) IBOutlet FoldableQuadImageView *view2;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view1.useGeometryFlipping = YES;
    self.view2.useGeometryFlipping = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
