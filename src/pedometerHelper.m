#import "pedometerHelper.h"
#import <CoreMotion/CoreMotion.h>
#import <CoreMotion/CMPedometer.h>
#import <Foundation/Foundation.h>
#import <Foundation/NSDate.h>

#include "dart-sdk/include/dart_api_dl.h"

// Need to import the dart headers to get the definitions Dart_CObject
#include "dart-sdk/include/dart_api_dl.h"


// Helper function that takes a pointer to CMPedometer data and cinverts it to a Dart C Object
static Dart_CObject NSObjectToCObject(CMPedometerData* n) {
  Dart_CObject cobj;
  cobj.type = Dart_CObject_kInt64;
  cobj.value.as_int64 = (int64_t) n;
  return cobj;
}

// Function that accepts a start date string, dart port, and starts the pedometer and forwards the resulting data.
void startPedometer(Dart_Port sendPort, CMPedometer* pedometer, NSDate* start, NSDate* end){
  NSLog(@"Created pedometer");

  // Start the pedometer
  [pedometer queryPedometerDataFromDate:start toDate:end withHandler:^(CMPedometerData *pedometerData, NSError *error) {
    if(error == nil){
      NSLog(@"data:%@", pedometerData.numberOfSteps);
      NSLog(@"start:%@", pedometerData.startDate);
      NSLog(@"end:%@", pedometerData.endDate);
      pedometerData = [pedometerData retain];
      Dart_CObject data = NSObjectToCObject(pedometerData);
      const bool success = Dart_PostCObject_DL(sendPort, &data);
      NSLog(@"Finished sending");
    }
    else{
      NSLog(@"Error:%@", error);
    }
  }];
}

