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
@property (weak, nonatomic) IBOutlet UILabel *animationDurationLabel;
@property (weak, nonatomic) IBOutlet UILabel *alphaLabel;

@end

@implementation ViewController

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"%s; keyPath = [%@], change = %@", __FUNCTION__, keyPath, change);
    self.animationDurationLabel.text = [NSString stringWithFormat:@"%f", self.quadView.animationDuration];
    self.alphaLabel.text = [NSString stringWithFormat:@"%f", self.quadView.alpha];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.quadView addObserver:self
                    forKeyPath:@"animationDuration"
                       options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
                       context:nil];
    [self.quadView addObserver:self
                    forKeyPath:@"alpha"
                       options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
                       context:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)useGeometryFlippingChanged:(UISwitch *)sender {
    self.quadView.useGeometryFlipping = sender.on;
}

- (IBAction)animationDurationChanged:(UISlider *)sender {
    self.quadView.animationDuration = sender.value;
}

- (IBAction)alphaChanged:(UISlider *)sender {
    self.quadView.alpha = sender.value;
}

@end
