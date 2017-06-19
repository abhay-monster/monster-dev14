trigger UpdateCaseOnChatterFeedCommentTrigger on FeedComment (after insert) {
    // Antone Kom - created for I-208008: Case Status changed when rep responds via chatter (Feed Comment) with more info
    //
    // Based on "Record Updater Example" code from: 
    // http://andyinthecloud.com/2014/10/26/calling-flow-from-apex/ 
    // and
    // "Recipe 11: Monitor specific keywords on an entity feed" code from: 
    // https://developer.salesforce.com/page/Chatter_Code_Recipes

    //Get the key prefix for the Case object via a describe call.
    String caseKeyPrefix = Case.sObjectType.getDescribe().getKeyPrefix();
    
    // Shyam - 5/3/2017 - S-473243 
    Map<Id, FeedItem> mapFeedItem = new Map<Id, FeedItem>();
    
    for (FeedComment f: trigger.new){
        mapFeedItem.put(f.feedItemId, null);
    }
    
    mapFeedItem = new Map<Id, FeedItem>([SELECT Id, ParentId, CreatedById FROM FeedItem WHERE Id IN :mapFeedItem.keySet()]);
    
    for (FeedComment f: trigger.new)
    {
        String parentId = f.parentId;      // parent Case Id
        FeedItem fItem = mapFeedItem.get(f.feedItemId); // parent Chatter FeedItem
        
        System.debug('FeedComment: ' + f.Id + ' - FeedItem: ' + fItem.Id);
        
        //We compare the start of the 'parentID' field to the Case key prefix to
        //restrict the trigger to act on posts made to the Case object and where CommentBody isn't blank.
        if (parentId.startsWith(caseKeyPrefix) && 
            f.CommentBody != '')
        {            
               
        // Call the Flow
        Map<String, Object> params = new Map<String, Object>();
        params.put('ChatterPost', fItem);
        Flow.Interview.Update_Case_on_Chatter_Post recordUpdaterFlow = new Flow.Interview.Update_Case_on_Chatter_Post(params);
        recordUpdaterFlow.start();
         


        
        // Obtain results
        Case updatedCase = [SELECT Id, Status, SubStatus__c FROM Case WHERE Id = :f.parentId]; 
        System.debug(updatedCase.Id + ' ' + updatedCase.Status + ' ' + updatedCase.SubStatus__c);
        
        
        QuickAction.QuickActionRequest req = new QuickAction.QuickActionRequest();
        req.quickActionName = 'Case.Update_Case_LastModified';
        req.record = updatedCase;
        QuickAction.QuickActionResult res = QuickAction.performQuickAction(req);
            
        }
    }
}