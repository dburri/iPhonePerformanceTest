//
//  Benchmark.h
//  VectorProcessingBenchmark
//
//  Created by DINA BURRI on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

@interface Benchmark : NSObject


- (double)benchmarkAffineTransform:(int)N :(BOOL)BLAS;
- (double)benchmarkDetermineTransform:(int)N :(BOOL)BLAS;

- (void)testAffineTransform;

- (void)getTransformationMat:(float*)A:(float*)B:(float*)T;
- (void)getTransformationMatNB:(float*)A:(float*)B:(float*)T;

- (void)performAffineTransform:(float*)A:(float*)T:(float*)B:(int)N;
- (void)performAffineTransformNB:(float*)A:(float*)T:(float*)B:(int)N;

- (void)inverseMatf:(const float*)A:(long)N:(float*)B;
- (void)inverseMatd:(double*)A:(long)N;

@end
