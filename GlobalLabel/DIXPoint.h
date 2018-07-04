//
//  DIXPoint.h
//  GlobalLabel
//
//  Created by Shannon MYang on 2018/7/2.
//  Copyright © 2018年 Shannon MYang. All rights reserved.
//

#ifndef DIXPoint_h
#define DIXPoint_h

//定义三维空间坐标系相关的三个坐标x，y，z
struct DIXPoint {
    CGFloat x;
    CGFloat y;
    CGFloat z;
};

typedef struct DIXPoint DIXPoint;

//定义点的坐标
DIXPoint DIXPointMake(CGFloat x, CGFloat y, CGFloat z) {
    DIXPoint point;
    point.x = x;
    point.y = y;
    point.z = z;
    return point;
}


#endif /* DIXPoint_h */
