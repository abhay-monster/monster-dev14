// Antone Kom - test class for UpdateCaseOnChatterFeedCommentTrigger
// created for I-208008

@isTest 
private class UpdCaseOnChatterFeedCommentTest {
    static testMethod void validateUpdateCaseOnChatterFeedCommentTrigger() {
    
       Case c = new Case(Status='Open', SubStatus__c='Open');
       System.debug('Status/SubStatus before inserting new case: ' + c.Status + ' / ' + c.SubStatus__c);
       // insert the case
       insert c;

       // submit a chatter post for the case and set status to Waiting/Waiting on Sales
       FeedItem fi = new FeedItem(Body='Test FeedItem', ParentId=c.Id);
       insert fi;
       
       c.Status = 'Waiting';
       c.SubStatus__c = 'Waiting on Sales';
       update c;
       
       // submit a reply/comment on the original chatter post     
       FeedComment fc = new FeedComment(CommentBody = 'Test FeedComment', FeedItemId=fi.Id);
       insert fc;
    
       // Retrieve the new case, feeditem and feedcomment
       fi = [SELECT Id, ParentId, Body FROM FeedItem WHERE Id =:fi.Id];
       fc = [SELECT Id, ParentId, FeedItemId, CommentBody FROM FeedComment WHERE Id =:fc.Id];
       c = [SELECT Id, Status, SubStatus__c FROM Case WHERE Id =:c.Id];
       System.debug('FeedItem Id: ' + fi.Id + ' ParentId ' + fi.ParentId);
       System.debug('FeedComment Id: ' + fc.Id + ' ParentId ' + fc.ParentId + ' FeedItemId ' + fc.FeedItemId);
       System.debug('Case Id: ' + c.Id + ' Status/SubStatus after trigger fired: ' + c.Status + ' / ' + c.SubStatus__c);

       // Test that the trigger correctly updated the status/substatus when the feed comment was posted
       System.assertEquals('Open', c.Status);
       System.assertEquals('Updated by Chatter', c.SubStatus__c);
    }
}