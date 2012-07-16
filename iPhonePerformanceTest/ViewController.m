//
//  ViewController.m
//  VectorProcessingBenchmark
//
//  Created by DINA BURRI on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize textAffineTBench;
@synthesize textAffineTBenchNB;
@synthesize textDataSize;
@synthesize slider;
@synthesize myView;
@synthesize segControl;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dataSize = 10;
    
    benchmark = [[Benchmark alloc] init];
    [benchmark testAffineTransform];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


- (IBAction)setBenchmarkType:(id)sender
{
    if(segControl.selectedSegmentIndex == 0) {
        slider.maximumValue = 6;
    }
    else {
        slider.maximumValue = 4;
        
        
        dataSize = (int)pow(10, slider.value);
        NSString *text = [NSString stringWithFormat:@"%i", dataSize];
        textDataSize.text = text;
    }
}

- (IBAction)benchmarkAffine:(id)sender
{
    double time = 0;
    NSString *text;
    if(segControl.selectedSegmentIndex == 0) {
        time = [benchmark benchmarkAffineTransform:dataSize :YES];
        text = [NSString stringWithFormat:@"%f KTPS", (dataSize/(time*1E3))];
    }
    else {
        time = [benchmark benchmarkDetermineTransform:dataSize :YES];
        text = [NSString stringWithFormat:@"%f KEPS", (dataSize/(time*1E3))];
    }
    textAffineTBench.text = text;
}


- (IBAction)benchmarkAffineNB:(id)sender
{
    
    double time = 0;
    NSString *text;
    if(segControl.selectedSegmentIndex == 0) {
        time = [benchmark benchmarkAffineTransform:dataSize :NO];
        text = [NSString stringWithFormat:@"%f KTPS", (dataSize/(time*1E3))];
    }
    else {
        time = [benchmark benchmarkDetermineTransform:dataSize :NO];
        text = [NSString stringWithFormat:@"%f KEPS", (dataSize/(time*1E3))];
    }
    textAffineTBenchNB.text = text;
}

- (IBAction)setDataSize:(id)sender
{
    dataSize = (int)pow(10, slider.value);
    NSString *text = [NSString stringWithFormat:@"%i", dataSize];
    textDataSize.text = text;
}


- (IBAction)runFullBenchmark:(id)sender
{
    NSMutableString *data = [NSMutableString stringWithString:@""];
    [data appendFormat:@"['x', 'BLAS', 'C'],\n"];
    
    if(segControl.selectedSegmentIndex == 0)
    {
        for(int i = 0; i <= 4; ++i)
        {
            for(int j = 1; j < 10; ++j)
            {
                dataSize = (int)pow(10, i) + j*pow(10, i);
                slider.value = dataSize;
                
                [data appendFormat:@"['%i', ",dataSize];
                double time = 0;
                
                // with BLAS
                time = [benchmark benchmarkAffineTransform:dataSize :YES];
                [data appendFormat:@"%f, ",(dataSize/(time*1E3))];
                
                // without BLAS
                time = [benchmark benchmarkAffineTransform:dataSize :NO];
                [data appendFormat:@"%f",(dataSize/(time*1E3))];
                
                [data appendString:@"],\n"];
            }
        }
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [paths objectAtIndex: 0];
        NSString *docFile = [docDir stringByAppendingPathComponent:@"benchmark_transform_blas.txt" ];
        
        NSError *err;
        [data writeToFile:docFile atomically:NO encoding:NSUTF8StringEncoding error:&err];
        
    }
    
    
    if(segControl.selectedSegmentIndex == 1)
    {
        for(int i = 0; i <= 3; ++i)
        {
            for(int j = 1; j < 10; ++j)
            {
                dataSize = (int)pow(10, i) + j*pow(10, i);
                slider.value = dataSize;
                
                [data appendFormat:@"['%i', ",dataSize];
                double time = 0;
                
                // with BLAS
                time = [benchmark benchmarkDetermineTransform:dataSize :YES];
                [data appendFormat:@"%f, ",(dataSize/(time*1E3))];
                
                // without BLAS
                time = [benchmark benchmarkDetermineTransform:dataSize :NO];
                [data appendFormat:@"%f",(dataSize/(time*1E3))];
                
                [data appendString:@"],\n"];
            }
        }
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [paths objectAtIndex: 0];
        NSString *docFile = [docDir stringByAppendingPathComponent:@"benchmark_determine_blas.txt" ];
        
        NSError *err;
        [data writeToFile:docFile atomically:NO encoding:NSUTF8StringEncoding error:&err];
        
    }


    
}


@end
