//
//  ZincArchiveExtractTask.m
//  Zinc-ObjC
//
//  Created by Andy Mroczkowski on 1/17/12.
//  Copyright (c) 2012 MindSnacks. All rights reserved.
//

#import "ZincArchiveExtractOperation.h"

#import "ZincInternals.h"
#import "ZincRepo+Private.h"
#import "NSFileManager+ZincTar.h"
#import "ZincSHA.h"
#import "ZincGzip.h"

@interface ZincArchiveExtractOperation ()
@property (nonatomic, weak, readwrite) ZincRepo* repo;
@property (nonatomic, strong, readwrite) ZincManifest* manifest;
@property (nonatomic, copy, readwrite) NSString* archivePath;
@property (nonatomic, copy, readwrite) NSError* error;
@end

@implementation ZincArchiveExtractOperation

- (id) initWithZincRepo:(ZincRepo*)repo archivePath:(NSString*)archivePath manifest:(ZincManifest *)manifest
{
    NSParameterAssert(repo);
    NSParameterAssert(archivePath);
    self = [super init];
    if (self) {
        self.repo = repo;
        self.archivePath = archivePath;
        self.manifest = manifest; // TODO: use manifest to calculate progress
    }
    return self;
}

- (id) initWithZincRepo:(ZincRepo*)repo archivePath:(NSString*)archivePath
{
    return [self initWithZincRepo:repo archivePath:archivePath manifest:nil];
}

- (void) main
{
    NSError* error = nil;
    NSFileManager* fm = [[NSFileManager alloc] init];

    NSString* untarDir = [ZincGetUniqueTemporaryDirectory() stringByAppendingPathComponent:
                          [[self.archivePath lastPathComponent] stringByDeletingPathExtension]];
    
    dispatch_block_t cleanup = ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [fm removeItemAtPath:untarDir error:NULL];
        });
    };

    if (![fm zinc_createFilesAndDirectoriesAtPath:untarDir withTarPath:self.archivePath error:&error]) {
        self.error = error;
        cleanup();
        return;
    }
    
    NSDirectoryEnumerator* dirEnum = [fm enumeratorAtPath:untarDir];
    for (NSString *thePath in dirEnum) {
        
        NSString* filename = thePath;
        if ([[thePath pathExtension] isEqualToString:@"gz"]) {
            filename = [filename stringByDeletingPathExtension];
        }
        
        NSString* targetPath = [self.repo pathForFileWithSHA:filename];
        
        if ([fm fileExistsAtPath:targetPath]) {
            continue;
        }
        
        // uncompress all gz files
        if ([[thePath pathExtension] isEqualToString:@"gz"]) {
            
            NSString* compressedPath = [untarDir stringByAppendingPathComponent:thePath];
            NSString* uncompressedPath = [compressedPath stringByDeletingPathExtension];
            
            if (!ZincGzipInflate(compressedPath, uncompressedPath, 0, &error)) {
                self.error = error;
                cleanup();
                return;
            }
        }
        
        NSString* fullPath = [untarDir stringByAppendingPathComponent:filename];
        
        NSString* expectedSHA = filename;
        
        NSString* actualSHA = ZincSHA1HashFromPath(fullPath, 0, &error);
        if (actualSHA == nil) {
            self.error = error;
            cleanup();
            return;
        }

        if (![actualSHA isEqualToString:expectedSHA]) {
            
            NSDictionary* info = @{@"expectedSHA": expectedSHA,
                                  @"actualSHA": actualSHA,
                                  @"archivePath": self.archivePath};
            self.error = ZincErrorWithInfo(ZINC_ERR_SHA_MISMATCH, info);
            cleanup();
            return;

        } else {
        
            if (![fm zinc_moveItemAtPath:fullPath toPath:targetPath error:&error]) {
                self.error = error;
                cleanup();
                return;
            }
            
            ZincAddSkipBackupAttributeToFileWithPath(targetPath);
        }
    }
    
    cleanup();
}

@end
