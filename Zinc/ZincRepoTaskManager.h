//
//  ZincRepoTaskManager.h
//  Zinc-ObjC
//
//  Created by Andy Mroczkowski on 5/13/13.
//  Copyright (c) 2013 MindSnacks. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZincRepo;
@class ZincTask;
@class ZincTaskDescriptor;

@interface ZincRepoTaskManager : NSObject

- (id) initWithZincRepo:(ZincRepo*)zincRepo networkOperationQueue:(NSOperationQueue*)networkQueue;

@property (nonatomic, weak) ZincRepo* repo;

@property (atomic, readonly, strong) NSMutableArray* tasks;

- (void) suspendAllTasks;
- (void) suspendAllTasksAndWaitExecutingTasksToComplete;
- (void) resumeAllTasks;
- (BOOL) isSuspended;

/**

 @discussion Internal method to queue or get a task.

 @param taskDescriptor Descriptor describing the task to be queued. Will attempt to get an existing task if present
 @param input Abritrary data to pass to the task, akin to `userInfo`
 @param parent If not nil, the task will be added as a dependency to parent, i.e., `[parent addDependency:task]`
 @param dependencies Additional dependencies of the task. i.e., `[task addDependency:dep]`

 */
- (ZincTask*) queueTaskForDescriptor:(ZincTaskDescriptor*)taskDescriptor input:(id)input parent:(NSOperation*)parent dependencies:(NSArray*)dependencies;

// Convenience methods - omitted parameters are nil

- (ZincTask*) queueTaskForDescriptor:(ZincTaskDescriptor*)taskDescriptor;
- (ZincTask*) queueTaskForDescriptor:(ZincTaskDescriptor*)taskDescriptor input:(id)input;
- (ZincTask*) queueTaskForDescriptor:(ZincTaskDescriptor*)taskDescriptor input:(id)input dependencies:(NSArray*)dependencies;

- (void) addOperation:(NSOperation*)operation;

/**
 @discussion default is YES
 */
@property (atomic, assign) BOOL executeTasksInBackgroundEnabled;

@end
