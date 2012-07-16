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
    int numTests = 10;
    float tmpBLAS[numTests];
    float tmpNBLAS[numTests];
    
    // -----------------------------------------
    // affine transform test
    {
        NSLog(@"affine transform test");
        NSMutableString *data = [NSMutableString stringWithString:@""];
        [data appendFormat:@"N, BLAS, C\n"];
        
        for(int i = 0; i <= 5; ++i)
        {
            for(int j = 0; j < 10; ++j)
            {
                dataSize = (int)pow(10, i) + j*pow(10, i);
                slider.value = dataSize;
                for(int k = 0; k < numTests; ++k)
                {
                    double time = 0;
                    
                    // with BLAS
                    time = [benchmark benchmarkAffineTransform:dataSize :YES];
                    tmpBLAS[k] = (dataSize/(time*1E3));
                    
                    // without BLAS
                    time = [benchmark benchmarkAffineTransform:dataSize :NO];
                    tmpNBLAS[k] = (dataSize/(time*1E3));
                }
                
                float blas = 0;
                float nblas = 0;
                for(int k = 0; k < numTests; ++k)
                {
                    blas += tmpBLAS[k];
                    nblas += tmpNBLAS[k];
                }
                
                [data appendFormat:@"%i, %f, %f \n", dataSize, blas/numTests, nblas/numTests];
                
                NSLog(@"1 at step %i", dataSize);
            }
        }
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [paths objectAtIndex: 0];
        NSString *docFile = [docDir stringByAppendingPathComponent:@"benchmark_transform_blas.txt" ];
        
        NSError *err;
        [data writeToFile:docFile atomically:NO encoding:NSUTF8StringEncoding error:&err];
        
    }
    
    // -----------------------------------------
    // determine the transformation matrix
    {
        NSLog(@"determine the transformation matrix");
        NSMutableString *data = [NSMutableString stringWithString:@""];
        [data appendFormat:@"N, BLAS, C\n"];
        
        for(int i = 0; i <= 3; ++i)
        {
            for(int j = 0; j < 10; ++j)
            {
                dataSize = (int)pow(10, i) + j*pow(10, i);
                slider.value = dataSize;
                for(int k = 0; k < numTests; ++k)
                {
                    double time = 0;
                    
                    // with BLAS
                    time = [benchmark benchmarkDetermineTransform:dataSize :YES];
                    tmpBLAS[k] = (dataSize/(time*1E3));
                    
                    // without BLAS
                    time = [benchmark benchmarkDetermineTransform:dataSize :NO];
                    tmpNBLAS[k] = (dataSize/(time*1E3));
                }
            
                float blas = 0;
                float nblas = 0;
                for(int k = 0; k < numTests; ++k)
                {
                    blas += tmpBLAS[k];
                    nblas += tmpNBLAS[k];
                }
                
                [data appendFormat:@"%i, %f, %f \n", dataSize, blas/numTests, nblas/numTests];
                NSLog(@"2 at step %i", dataSize);
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
