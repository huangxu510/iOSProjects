//
//  RoleRecord4Cocoa+Serialize.m
//  jinchuhuo
//
//  Created by huangxu on 16/1/13.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "RoleRecord4Cocoa+Serialize.h"

@implementation RoleRecord4Cocoa (Serialize)

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:self.roleUUID                    forKey:@"roleUUID"];
    [dictionary setObject:self.roleName                    forKey:@"roleName"];
    [dictionary setObject:@(self.canAddPurchaseManifest  ) forKey:@"canAddPurchaseManifest"];
    [dictionary setObject:@(self.canAddShipmentManifest  ) forKey:@"canAddShipmentManifest"];
    [dictionary setObject:@(self.canReturnManifest       ) forKey:@"canReturnManifest"];
    [dictionary setObject:@(self.canDeleteManifest       ) forKey:@"canDeleteManifest"];
    [dictionary setObject:@(self.displayCostPrice        ) forKey:@"displayCostPrice"];
    [dictionary setObject:@(self.displayThisMonthPurchase) forKey:@"displayThisMonthPurchase"];
    [dictionary setObject:@(self.displayInventory        ) forKey:@"displayInventory"];
    [dictionary setObject:@(self.displayThisMonthShipment) forKey:@"displayThisMonthShipment"];
    [dictionary setObject:@(self.canTransferManifest     ) forKey:@"canTransferManifest"];
    [dictionary setObject:@(self.canAssemblingManifest   ) forKey:@"canAssemblingManifest"];
    [dictionary setObject:@(self.canDismountManifest     ) forKey:@"canDismountManifest"];
    [dictionary setObject:@(self.displayPurchaseAnalysis ) forKey:@"displayPurchaseAnalysis"];
    [dictionary setObject:@(self.displayShipmentAnalysis ) forKey:@"displayShipmentAnalysis"];
    [dictionary setObject:@(self.displayProfitAnalysis   ) forKey:@"displayProfitAnalysis"];
    [dictionary setObject:@(self.displayInventoryAnalysis) forKey:@"displayInventoryAnalysis"];
    [dictionary setObject:@(self.canModifyCategory       ) forKey:@"canModifyCategory"];
    [dictionary setObject:@(self.canModifyGoods          ) forKey:@"canModifyGoods"];
    [dictionary setObject:@(self.canModifyUnit           ) forKey:@"canModifyUnit"];
    [dictionary setObject:@(self.canUsePrinter           ) forKey:@"canUsePrinter"];
    
    return dictionary;
}

+ (RoleRecord4Cocoa *)fromDictionary:(NSDictionary *)dictionary
{
    RoleRecord4Cocoa *roleRecord = [[[RoleRecord4Cocoa alloc] init] autorelease];
    
    roleRecord.roleUUID                 = dictionary[@"roleUUID"];
    roleRecord.roleName                 = dictionary[@"roleName"];
    roleRecord.canAddPurchaseManifest   = [dictionary[@"canAddPurchaseManifest"] boolValue];
    roleRecord.canAddShipmentManifest   = [dictionary[@"canAddShipmentManifest"] boolValue];
    roleRecord.canReturnManifest        = [dictionary[@"canReturnManifest"] boolValue];
    roleRecord.canDeleteManifest        = [dictionary[@"canDeleteManifest"] boolValue];
    roleRecord.displayCostPrice         = [dictionary[@"displayCostPrice"] boolValue];
    roleRecord.displayThisMonthPurchase = [dictionary[@"displayThisMonthPurchase"] boolValue];
    roleRecord.displayInventory         = [dictionary[@"displayInventory"] boolValue];
    roleRecord.displayThisMonthShipment = [dictionary[@"displayThisMonthShipment"] boolValue];
    roleRecord.canTransferManifest      = [dictionary[@"canTransferManifest"] boolValue];
    roleRecord.canAssemblingManifest    = [dictionary[@"canAssemblingManifest"] boolValue];
    roleRecord.canDismountManifest      = [dictionary[@"canDismountManifest"] boolValue];
    roleRecord.displayPurchaseAnalysis  = [dictionary[@"displayPurchaseAnalysis"] boolValue];
    roleRecord.displayShipmentAnalysis  = [dictionary[@"displayShipmentAnalysis"] boolValue];
    roleRecord.displayProfitAnalysis    = [dictionary[@"displayProfitAnalysis"] boolValue];
    roleRecord.displayInventoryAnalysis = [dictionary[@"displayInventoryAnalysis"] boolValue];
    roleRecord.canModifyCategory        = [dictionary[@"canModifyCategory"] boolValue];
    roleRecord.canModifyGoods           = [dictionary[@"canModifyGoods"] boolValue];
    roleRecord.canModifyUnit            = [dictionary[@"canModifyUnit"] boolValue];
    roleRecord.canUsePrinter            = [dictionary[@"canUsePrinter"] boolValue];
                                           
    return roleRecord;
}

+ (RoleRecord4Cocoa *)createShopManagerRoleRecord:(NSString *)roleUUID
{
    RoleRecord4Cocoa *roleRecord = [[[RoleRecord4Cocoa alloc] init] autorelease];
    
    roleRecord.roleUUID                 = roleUUID;
    roleRecord.roleName                 = @"";
    roleRecord.canAddPurchaseManifest   = YES;
    roleRecord.canAddShipmentManifest   = YES;
    roleRecord.canReturnManifest        = YES;
    roleRecord.canDeleteManifest        = YES;
    roleRecord.displayCostPrice         = YES;
    roleRecord.displayThisMonthPurchase = YES;
    roleRecord.displayInventory         = YES;
    roleRecord.displayThisMonthShipment = YES;
    roleRecord.canTransferManifest      = YES;
    roleRecord.canAssemblingManifest    = YES;
    roleRecord.canDismountManifest      = YES;
    roleRecord.displayPurchaseAnalysis  = YES;
    roleRecord.displayShipmentAnalysis  = YES;
    roleRecord.displayProfitAnalysis    = YES;
    roleRecord.displayInventoryAnalysis = YES;
    roleRecord.canModifyCategory        = YES;
    roleRecord.canModifyGoods           = YES;
    roleRecord.canModifyUnit            = YES;
    roleRecord.canUsePrinter            = YES;
    
    return roleRecord;
}


@end