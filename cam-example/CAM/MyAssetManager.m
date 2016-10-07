//
//  MyAssetManager.m
//  cam-example
//
//  Created by Robert Balint on 06/10/16.
//  Copyright © 2016 SciApps. All rights reserved.
//

#import "MyAssetManager.h"
#import "MyAssetItemImage.h"

@implementation MyAssetManager

#pragma mark Image related

- (instancetype)init {
    if ((self = [super init])) {
        [self registerThreadForClass:MyAssetItemImage.class];
        [self enumerateImageAssets];
    }
    
    return self;
}

- (void)enumerateImageAssets {
    Class clss = MyAssetItemImage.class;
    CoreAssetWorkerDescriptor *worker = [self.threadDescriptors objectForKey:NSStringFromClass(clss)];
    NSArray<NSString *> *imageList = [self.class listFilesInCacheDirectoryWithExtension:@""
                                                                            withSubpath:@"images"];
    
    @synchronized (worker) {
        for (NSString *imageFilePath in imageList) {
            CoreAssetItemImage *temp = [clss new];
            temp.assetName = [MyAssetItemImage base64DecodePath:[imageFilePath lastPathComponent]];
            [worker.cachedDict setObject:temp forKey:temp.assetName];
        }
    }
}

- (void)checkDownloadState {
    NSUInteger busyWorkerCount = 0;
    
    for (Class clss in self.classList) {
        CoreAssetWorkerDescriptor *worker = [self.threadDescriptors objectForKey:NSStringFromClass(clss)];
        busyWorkerCount += [worker isBusy];
    }
    
    // here you can notify the user about all download finished if needed
}

- (void)resumeDownloadForClass:(Class)clss {
    CoreAssetWorkerDescriptor *worker = [self.threadDescriptors objectForKey:NSStringFromClass(clss)];
    
    [worker resume];
    [worker continueDownload:worker.numWorkers];
    
    [self checkDownloadState];
}

#pragma mark CoreAssetWorkerDelegate methods

- (void)finishedDownloadingAsset:(NSDictionary *)assetDict {
    NSData *connectionData = [assetDict objectForKey:kCoreAssetWorkerAssetData];
    CoreAssetItemNormal *assetItem = [assetDict objectForKey:kCoreAssetWorkerAssetItem];
    id postprocessedData = [assetDict objectForKey:kCoreAssetWorkerAssetPostprocessedData];
    const char *dataBytes = connectionData.bytes;
    const char htmlHeader[] = {'<', 'h', 't', 'm', 'l', '>'};
    //    const char pngHeader[] = {0x89, 'P', 'N', 'G'};
    //    const char gifHeader[] = {'G', 'I', 'F', '8'};
    //    const char jpgHeader[] = {0xFF, 0xD8, 0xFF}; // e0-e1 as 4th byte
    //    NSError *error;
    //    NSDictionary *jsonResponse;
    BOOL isImageAsset = NO;
    
    Class clss = assetItem.class;
    CoreAssetWorkerDescriptor *worker = [self.threadDescriptors objectForKey:NSStringFromClass(clss)];
    
    if (self.terminateDownloads) {
        [assetItem removeStoredFile];
        return;
    }
    else if ([assetItem isKindOfClass:CoreAssetItemImage.class] && postprocessedData && memcmp(dataBytes, htmlHeader, sizeof(htmlHeader))) {
        //TestLog(@"finishedDownloadingAsset: png asset: '%@' class: '%@'", assetItem.assetName, NSStringFromClass(clss));
        isImageAsset = YES;
        
        if ([postprocessedData isKindOfClass:CoreAssetItemErrorImage.class]) {
            TestLog(@"finishedDownloadingAsset: no-pic error asset: '%@' class: '%@'", assetItem.assetName, NSStringFromClass(clss));
            [worker removeAssetFromCache:assetItem removeFile:YES];
        } else {
            worker.successfullDownloadsNum = @(worker.successfullDownloadsNum.integerValue + 1);
        }
    }
    else if (!connectionData.length) {
        TestLog(@"finishedDownloadingAsset: unknown error asset: '%@' class: '%@' zero bytes", assetItem.assetName, NSStringFromClass(clss));
        //[worker removeAssetFromCache:assetItem];
        [self resumeDownloadForClass:clss];
        return;
    }
    else {
        TestLog(@"finishedDownloadingAsset: unknown error asset: '%@' class: '%@' bytes: '%.4s' (%.2x%.2x%.2x%.2x)", assetItem.assetName, NSStringFromClass(clss), dataBytes, (UInt8)dataBytes[0], (UInt8)dataBytes[1], (UInt8)dataBytes[2], (UInt8)dataBytes[3]);
        [worker removeAssetFromCache:assetItem
                          removeFile:YES];
        [self resumeDownloadForClass:clss];
        return;
    }
    
    if (assetItem.shouldCache && ![postprocessedData isKindOfClass:NSNull.class]) {
        [self.dataCache setObject:postprocessedData
                           forKey:assetItem.assetName];
    }
    
    [assetItem sendPostProcessedDataToHandlers:postprocessedData];
    [self.delegates compact];
    
    if (isImageAsset) {
        for (NSObject<CoreAssetManagerDelegate> *delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(cachedImageDictChanged:)]) {
                CoreAssetWorkerDescriptor *worker = [self.threadDescriptors objectForKey:NSStringFromClass(clss)];
                [delegate performSelectorOnMainThread:@selector(cachedImageDictChanged:) withObject:worker.cachedDict waitUntilDone:NO];
            }
        }
    }
    
    [self resumeDownloadForClass:clss];
}

- (void)failedDownloadingAsset:(NSDictionary *)assetDict {
    CoreAssetItemNormal *assetItem = [assetDict objectForKey:kCoreAssetWorkerAssetItem];
    
    Class clss = assetItem.class;
    
    TestLog(@"failedDownloadingAsset: '%@' class: '%@'", assetItem.assetName, NSStringFromClass(clss));
    
    [self resumeDownloadForClass:clss];
}

@end
