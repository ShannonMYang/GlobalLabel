
//
//  DIXMatrix.h
//  GlobalLabel
//
//  Created by Shannon MYang on 2018/7/2.
//  Copyright © 2018年 Shannon MYang. All rights reserved.
//

#ifndef DIXMatrix_h
#define DIXMatrix_h

#import "DIXPoint.h"

struct DIXMatrix {
    NSInteger column;
    NSInteger row;
    CGFloat matrix[4][4];
};

typedef struct DIXMatrix DIXMatrix;

static DIXMatrix DIXMatrixMake(NSInteger column, NSInteger row) {
    DIXMatrix matrix;
    matrix.column = column;
    matrix.row = row;
    for (NSInteger i = 0; i < column; i++) {
        for (NSInteger j = 0; j < row; j++) {
            matrix.matrix[i][j] = 0;
        }
    }
    return matrix;
}

static DIXMatrix DIXMatrixMakeFromArray(NSInteger column, NSInteger row, CGFloat *data) {
    DIXMatrix matrix = DIXMatrixMake(column, row);
    for (NSInteger i = 0; i < column; i ++) {
        CGFloat *temp = data + (i * row);
        for (NSInteger j = 0; j < row; j++) {
            matrix.matrix[i][j] = *(temp + j);
        }
    }
    return matrix;
}

static DIXMatrix DIXMatrixMutiply(DIXMatrix a, DIXMatrix b) {
    DIXMatrix result = DIXMatrixMake(a.column, b.row);
    for(NSInteger i = 0; i < a.column; i ++){
        for(NSInteger j = 0; j < b.row; j ++){
            for(NSInteger k = 0; k < a.row; k++){
                result.matrix[i][j] += a.matrix[i][k] * b.matrix[k][j];
            }
        }
    }
    return result;
}

static DIXPoint DIXPointMakeRotation(DIXPoint point, DIXPoint direction, CGFloat angle) {
    if (angle == 0) {
        return point;
    }
    
    CGFloat temp2[1][4] = {point.x, point.y, point.z, 1};
    
    DIXMatrix result = DIXMatrixMakeFromArray(1, 4, *temp2);
    
    if (direction.z * direction.z + direction.y * direction.y != 0) {
        CGFloat cos1 = direction.z / sqrt(direction.z * direction.z + direction.y * direction.y);
        CGFloat sin1 = direction.y / sqrt(direction.z * direction.z + direction.y * direction.y);
        CGFloat t1[4][4] = {{1, 0, 0, 0}, {0, cos1, sin1, 0}, {0, -sin1, cos1, 0}, {0, 0, 0, 1}};
        DIXMatrix m1 = DIXMatrixMakeFromArray(4, 4, *t1);
        result = DIXMatrixMutiply(result, m1);
    }
    
    if (direction.x * direction.x + direction.y * direction.y + direction.z * direction.z != 0) {
        CGFloat cos2 = sqrt(direction.y * direction.y + direction.z * direction.z) / sqrt(direction.x * direction.x + direction.y * direction.y + direction.z * direction.z);
        CGFloat sin2 = -direction.x / sqrt(direction.x * direction.x + direction.y * direction.y + direction.z * direction.z);
        CGFloat t2[4][4] = {{cos2, 0, -sin2, 0}, {0, 1, 0, 0}, {sin2, 0, cos2, 0}, {0, 0, 0, 1}};
        DIXMatrix m2 = DIXMatrixMakeFromArray(4, 4, *t2);
        result = DIXMatrixMutiply(result, m2);
    }
    
    CGFloat cos3 = cos(angle);
    CGFloat sin3 = sin(angle);
    CGFloat t3[4][4] = {{cos3, sin3, 0, 0}, {-sin3, cos3, 0, 0}, {0, 0, 1, 0}, {0, 0, 0, 1}};
    DIXMatrix m3 = DIXMatrixMakeFromArray(4, 4, *t3);
    result = DIXMatrixMutiply(result, m3);
    
    if (direction.x * direction.x + direction.y * direction.y + direction.z * direction.z != 0) {
        CGFloat cos2 = sqrt(direction.y * direction.y + direction.z * direction.z) / sqrt(direction.x * direction.x + direction.y * direction.y + direction.z * direction.z);
        CGFloat sin2 = -direction.x / sqrt(direction.x * direction.x + direction.y * direction.y + direction.z * direction.z);
        CGFloat t2_[4][4] = {{cos2, 0, sin2, 0}, {0, 1, 0, 0}, {-sin2, 0, cos2, 0}, {0, 0, 0, 1}};
        DIXMatrix m2_ = DIXMatrixMakeFromArray(4, 4, *t2_);
        result = DIXMatrixMutiply(result, m2_);
    }
    
    if (direction.z * direction.z + direction.y * direction.y != 0) {
        CGFloat cos1 = direction.z / sqrt(direction.z * direction.z + direction.y * direction.y);
        CGFloat sin1 = direction.y / sqrt(direction.z * direction.z + direction.y * direction.y);
        CGFloat t1_[4][4] = {{1, 0, 0, 0}, {0, cos1, -sin1, 0}, {0, sin1, cos1, 0}, {0, 0, 0, 1}};
        DIXMatrix m1_ = DIXMatrixMakeFromArray(4, 4, *t1_);
        result = DIXMatrixMutiply(result, m1_);
    }
    
    DIXPoint resultPoint = DIXPointMake(result.matrix[0][0], result.matrix[0][1], result.matrix[0][2]);
    
    return resultPoint;
}


#endif /* DIXMatrix_h */
