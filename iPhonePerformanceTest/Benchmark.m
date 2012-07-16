//
//  Benchmark.m
//  VectorProcessingBenchmark
//
//  Created by DINA BURRI on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Benchmark.h"

@implementation Benchmark


- (double)benchmarkAffineTransform:(int)N:(BOOL)BLAS
{
    // create random data
    float *A = malloc(3*N*sizeof(float));
    float *A_ptr = A;
    for(int i = 0; i < N; ++i)
    {
        *A_ptr++ = (float)arc4random()/4.98;
        *A_ptr++ = (float)arc4random()/4.98;
        *A_ptr++ = 1;
    }
    
    // create random transformation
    float *T = malloc(3*3*sizeof(float));
    float *T_ptr = T;
    for(int i = 0; i < 3*3; ++i)
    {
        *T_ptr++ = (float)arc4random()/4.98;
    }
    T[2] = 0.;
    T[5] = 0.;
    T[8] = 1.;
    
    
    float *B = malloc(3*N*sizeof(float));
    
    NSDate *start = [NSDate date];
    
    if(BLAS) {
        [self performAffineTransform:A :T :B :N];
    }
    else {
        [self performAffineTransformNB:A :T :B :N];
    }
    
    NSDate *stop = [NSDate date];
    NSTimeInterval dt = [stop timeIntervalSinceDate:start];
    
    free(A);
    free(T);
    free(B);
    
    return dt;
}


- (double)benchmarkDetermineTransform:(int)N:(BOOL)BLAS
{
    double dt = 0;
    for(int i = 0; i < N; ++i)
    {
    
        // create two random triangles
        float *A = malloc(3*3*sizeof(float));
        float *B = malloc(3*3*sizeof(float));
        float *A_ptr = A;
        float *B_ptr = B;
        for(int i = 0; i < 3; ++i)
        {
            *A_ptr++ = (float)arc4random()/4.98;
            *A_ptr++ = (float)arc4random()/4.98;
            *A_ptr++ = 1;
            
            *B_ptr++ = (float)arc4random()/4.98;
            *B_ptr++ = (float)arc4random()/4.98;
            *B_ptr++ = 1;
        }
        
        float *T = malloc(3*3*sizeof(float));
        
        NSDate *start = [NSDate date];

        if(BLAS) {
            [self getTransformationMat:A :B :T];
        }
        else {
            [self getTransformationMatNB:A :B :T];
        }
        
        NSDate *stop = [NSDate date];
        dt += [stop timeIntervalSinceDate:start];
        
        free(A);
        free(B);
        free(T);
    }
    
    return dt;
}


- (void)testAffineTransform
{
    int N = 3;
    float A[] = {
        4, 3, 1, 
        2, 3, 1, 
        5, 2, 1
    };
    
    float B[] = {
        4, 3, 1, 
        4, 2, 1, 
        5, 5, 1
    };
    
    float *T = malloc(sizeof(float)*9);
    memset(T, 0, sizeof(float)*9);
    
    float *C = malloc(N*3*sizeof(float));
    memset(C, 0, N*3*sizeof(float));
    
    // -----------------------------
    // Determine transformation matrix
    {
        NSLog(@"A = ");
        for(int i = 0; i < N*3; i += 3)
            NSLog(@"  { %f, %f, %f } ", A[i+0], A[i+1], A[i+2]);
        NSLog(@"B = ");
        for(int i = 0; i < N*3; i += 3)
            NSLog(@"  { %f, %f, %f } ", B[i+0], B[i+1], B[i+2]);
        NSLog(@"T = ");
        for(int i = 0; i < 9; i += 3)
            NSLog(@"  { %f, %f, %f } ", T[i+0], T[i+1], T[i+2]);
        
        [self getTransformationMatNB:A :B :T];
        
        NSLog(@"T = ");
        for(int i = 0; i < 9; i += 3)
            NSLog(@"  { %f, %f, %f } ", T[i+0], T[i+1], T[i+2]);
    }
    
    // -----------------------------
    // Perform transformation
    {
        NSLog(@"A = ");
        for(int i = 0; i < 3*N; i += 3)
            NSLog(@"  { %f, %f, %f } ", A[i+0], A[i+1], A[i+2]);
        NSLog(@"T = ");
        for(int i = 0; i < 9; i += 3)
            NSLog(@"  { %f, %f, %f } ", T[i+0], T[i+1], T[i+2]);
        NSLog(@"C = ");
        for(int i = 0; i < 3*N; i += 3)
            NSLog(@"  { %f, %f, %f } ", C[i+0], C[i+1], C[i+2]);
        
        [self performAffineTransformNB:A :T :C :3];
        
        NSLog(@"C = ");
        for(int i = 0; i < 3*N; i += 3)
            NSLog(@"  { %f, %f, %f } ", C[i+0], C[i+1], C[i+2]);
        
        
        // check result
        int failure = 0;
        int whichValue = -1;
        for(int i = 0; i < N*3; ++i)
        {
            if(B[i] != C[i]) {
                failure = -1;
                whichValue = i;
                break;
            }
        }
        
        if(failure != 0)
            NSLog(@"Failure in testAffineTransform! Values are not equal (B[%i] = %f) != (C[%i] = %f)", whichValue, A[whichValue], whichValue, C[whichValue]);
        else
            NSLog(@"Affine Transform successfully tested...");
        
    }
    
    free(C);
    free(T);
}

- (void)inverseMatd:(double*)A:(long)N
{
    long pivotArray[N];
    long info;
    double lapWS[N*N];

    long workLength = N*N;
    long lda = N;
    dgetrf_(&N, &N, A, &lda, pivotArray, &info);
    dgetri_(&N, A, &N, pivotArray, lapWS, &workLength, &info);
}


- (void)inverseMatf:(const float*)A:(long)N:(float*)B
{
    // create temporary double array
    double *At = malloc(N*N*sizeof(double));
    const float *A_ptr = A;
    double *At_ptr = At;
    for(int i = 0; i < N*N; ++i)
        *At_ptr++ = *A_ptr++;

    // calculate inverse mat
    [self inverseMatd:At :N];
    
    // copy double array back
    float *B_ptr = B;
    At_ptr = At;
    for(int i = 0; i < N*N; ++i)
        *B_ptr++ = *At_ptr++;
    
    free(At);
}

// --------------------------------------------
// BLAS test for affine transformation
- (void)getTransformationMat:(float*)A:(float*)B:(float*)T
{
    int lda = 3;
    int ldb = 3;
    int ldc = 3;

    float scale = 1.0;
    
    
    // make matrix A inverse
    float *Ai = malloc(3*3*sizeof(float));
    [self inverseMatf:A :3 :Ai];

    
    //NSLog(@"Ai = ");
    //for(int i = 0; i < 9; i += 3)
    //    NSLog(@"  { %f, %f, %f } ", Ai[i+0], Ai[i+1], Ai[i+2]);
    
    cblas_sgemm(  CblasRowMajor,
                CblasNoTrans,
                CblasNoTrans,
                3,            // num of rows in matrices A and C
                3,            // num of col in matrices B and C
                3,            // Num of col in matrix A; number of rows in matrix B.
                scale,       // alpha
                Ai,            // matrix A
                lda,          // size of the first dimension of matrix A
                B,            // matrix B
                ldb,          // size of the first dimension of matrix B
                scale,       // beta
                T,            // matrix C
                ldc           // size of the first dimention of matrix C
                );
    
    free(Ai);
    
}


- (void)getTransformationMatNB:(float*)A:(float*)B:(float*)T
{
//    // (x11*x22 -x12*x21 - x11*x32 + x12*x31 + x21*x32 - x22*x31)
//    float s = A[0]*A[4] - A[1]*A[3] - A[0]*A[7] + A[1]*A[6] + A[3]*A[7] - A[4]*A[6];
//    s = 1/s;
//    
//    // a1 = -(x12*y21 - x22*y11 - x12*y31 + x32*y11 + x22*y31 - x32*y21)
//    T[0] = -s*(A[1]*B[4] - A[5]*B[0] + A[1]*B[6] + A[7]*B[0] + A[4]*B[6] - A[7]*B[3]);
//    
//    // a2 = (x11*y21 - x21*y11 - x11*y31 + x31*y11 + x21*y31 - x31*y21)
//    T[3] = s*(A[0]*B[3] - A[3]*B[0] + A[0]*B[6] + A[6]*B[0] + A[3]*B[6] - A[6]*B[3]);
//    
//    // a3 = (x11*x22*y31 - x11*x32*y21 - x12*x21*y31 + 
//    //       x12*x31*y21 + x21*x32*y11 - x22*x31*y11)
//    T[6]  = s*(A[0]*A[4]*B[6] - A[0]*A[7]*B[3] + A[1]*A[3]*B[6]);
//    T[6] += s*(A[1]*A[6]*B[3] + A[3]*A[7]*B[0] - A[4]*A[6]*B[0]);
//    
//    // a4 = -(x12*y22 - x22*y12 - x12*y32 + x32*y12 + x22*y32 - x32*y22)
//    T[1] = -s*(A[1]*B[4] - A[4]*B[1] + A[1]*B[7] + A[7]*B[1] + A[4]*B[7] - A[7]*B[4]);
//    
//    // a5 = (x11*y22 - x21*y12 - x11*y32 + x31*y12 + x21*y32 - x31*y22)
//    T[4] = s*(A[0]*B[4] - A[3]*B[1] + A[0]*B[7] + A[6]*B[1] + A[3]*B[7] - A[6]*B[4]);
//    
//    // a6 = (x11*x22*y32 - x11*x32*y22 - x12*x21*y32 +
//    //       x12*x31*y22 + x21*x32*y12 - x22*x31*y12)
//    T[7] =  s*(A[0]*A[4]*B[7] - A[0]*A[7]*B[4] + A[1]*A[3]*B[7]);
//    T[7] += s*(A[1]*A[6]*B[4] + A[3]*A[7]*B[1] - A[4]*A[6]*B[1]);
    
    
    
    float x11 = A[0];
    float x12 = A[1];
    float x21 = A[3];
    float x22 = A[4];
    float x31 = A[6];
    float x32 = A[7];
    float y11 = B[0];
    float y12 = B[1];
    float y21 = B[3];
    float y22 = B[4];
    float y31 = B[6];
    float y32 = B[7];
    
    // a1
    T[0] = ((y11-y21)*(x12-x32)-(y11-y31)*(x12-x22))/((x11-x21)*(x12-x32)-(x11-x31)*(x12-x22));
    
    // a2
    T[3] = ((y11-y21)*(x11-x31)-(y11-y31)*(x11-x21))/((x12-x22)*(x11-x31)-(x12-x32)*(x11-x21));
    
    // a3
    T[6] = y11-T[0]*x11-T[3]*x12;
    
    // a4
    T[1] = ((y12-y22)*(x12-x32)-(y12-y32)*(x12-x22))/((x11-x21)*(x12-x32)-(x11-x31)*(x12-x22));
    
    // a5
    T[4] = ((y12-y22)*(x11-x31)-(y12-y32)*(x11-x21))/((x12-x22)*(x11-x31)-(x12-x32)*(x11-x21));
    
    // a6
    T[7] = y12-T[1]*x11-T[4]*x12;

    T[2] = 0;
    T[5] = 0;
    T[8] = 1;
    
}

- (void)performAffineTransform:(float*)A:(float*)T:(float*)B:(int)N
{
    int lda = 3;
    int ldt = 3;
    int ldb = 3;
    
    float scale = 1.0;
    
    cblas_sgemm(  CblasRowMajor,
                CblasNoTrans,
                CblasNoTrans,
                N,            // num of rows in matrices A and C
                3,            // num of col in matrices B and C
                3,            // Num of col in matrix A; number of rows in matrix B.
                scale,       // alpha
                A,            // matrix A
                lda,          // size of the first dimension of matrix A
                T,            // matrix B
                ldt,          // size of the first dimension of matrix B
                scale,       // beta
                B,            // matrix C
                ldb           // size of the first dimention of matrix C
                );
}


- (void)performAffineTransformNB:(float*)A:(float*)T:(float*)B:(int)N
{

    for(int i = 0; i < N; ++i)
    {
        int p = i*3;
        for(int j = 0; j < 3; ++j)
        {
            float tmp = 0.;
            for(int k = 0; k < 3; ++k)
            {
                tmp += A[p+k] * T[j+k*3];
            }
            B[p+j] = tmp;
        }
    }
}

@end
