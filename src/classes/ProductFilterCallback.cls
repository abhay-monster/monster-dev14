/**
  * Name: ProductFilterCallback 
  * Date: 2016-12-23
  * Created By: viraj rana S-445850
  * This filter is used in listing catalog products
    */
global with sharing class ProductFilterCallback implements Apttus_Config2.CustomClass.IProductFilterCallback {
      
    /**
  * Callback to return part of SOQL filter clause
  * This filter is used in listing catalog products
  * @param parsms is the CustomClass.ActionParams thatcontains accountIds, locationIds when available
    */
    global String getProductFilterExpr(Apttus_Config2.CustomClass.ActionParams params) {
        system.debug('UserInfo.getUserId()' + UserInfo.getUserId());
        Map<String,Set<String>> mapGroup = new Map<String,Set<String>>();
        for(GroupMember m : [Select Id, UserOrGroupId,GroupId,Group.type,Group.Name From GroupMember Where Group.Name in ('PPC Family User','Premium Job Ad Family User','Super Search Users')]) {
            if(!mapGroup.ContainsKey(m.Group.Name)){
                mapGroup.put(m.Group.Name,New Set<String>());
            }
            mapGroup.get(m.Group.Name).add(m.UserOrGroupId);
        }
        
        String str = '';
        
        if(!mapGroup.ContainsKey('PPC Family User') || (mapGroup.ContainsKey('PPC Family User') && !mapGroup.get('PPC Family User').Contains(userInfo.getUserId()))){
            str = 'Product_Group_Filter__c != \'PPC\'';
        }
        if(!mapGroup.ContainsKey('Premium Job Ad Family User') || (mapGroup.ContainsKey('Premium Job Ad Family User') && !mapGroup.get('Premium Job Ad Family User').Contains(userInfo.getUserId()))){
            if(!String.IsBlank(str)){
                str = str + ' And ';
            }
            str = str + 'Product_Group_Filter__c != \'Premium Job Ads\'';
        }
        if(!mapGroup.ContainsKey('Super Search Users') || (mapGroup.ContainsKey('Super Search Users') && !mapGroup.get('Super Search Users').Contains(userInfo.getUserId()))){
            if(!String.IsBlank(str)){
                str = str + ' And ';
            }
            str = str + 'Product_Group_Filter__c != \'Super Search\'';
        }
        
        return str;
    

  }
    
    /**
    * Callback to return part of SOQLfilter clause
    * This filter is used in listing option products
    * 
    */
    global String getOptionFilterExpr(Apttus_Config2.CustomClass.ActionParams params) {
        return null;      
    }
}