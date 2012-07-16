//
//  ViewController.h
//  VectorProcessingBenchmark
//
//  Created by DINA BURRI on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Benchmark.h"

@interface ViewController : UIViewController {
    Benchmark *benchmark;
    IBOutlet UITextField *textAffineTBench;
    IBOutlet UITextField *textAffineTBenchNB;
    IBOutlet UITextField *textDataSize;
    IBOutlet UISlider *slider;
    IBOutlet UIView *myView;
    IBOutlet UISegmentedControl *segControl;
    int dataSize;
}

@property (retain) IBOutlet UITextField *textAffineTBench;
@property (retain) IBOutlet UITextField *textAffineTBenchNB;
@property (retain) IBOutlet UITextField *textDataSize;
@property (retain) IBOutlet UISlider *slider;
@property (retain) IBOutlet UIView *myView;
@property (retain) IBOutlet UISegmentedControl *segControl;

- (IBAction)benchmarkAffine:(id)sender;
- (IBAction)benchmarkAffineNB:(id)sender;
- (IBAction)setDataSize:(id)sender;
- (IBAction)setBenchmarkType:(id)sender;
- (IBAction)runFullBenchmark:(id)sender;

@end
