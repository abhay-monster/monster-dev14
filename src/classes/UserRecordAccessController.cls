/**
 * @author  Divino Brinas <divino.brinas@cloudsherpas.com>
 * @since   06.01.2015
 */
 public without sharing class UserRecordAccessController{
   public User subjectUser {get;set;}
   private ApexPages.StandardController controller {get;set;}
   public string subjectId {get;set;}
   public boolean isvisible {get;set;}
   public UserRecordAccessController(ApexPages.StandardController controller){
      //check to see if running within subtab on chatter profile
       subjectId = ApexPages.currentPage().getParameters().get('sfdc.userId');
       isvisible = true;
       System.debug('Page Key==' + ApexPages.currentPage().getParameters().keySet());
       System.debug('Page Parameter==' + String.valueOf(ApexPages.currentPage().getParameters()));

       if (subjectId!=null){
            // running within subtab so inject user id so that standard controller picks 
            // up the record correctly
           ApexPages.currentPage().getParameters().put('id',subjectId);
       }
       else {
           isvisible = false;
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Channel Alignment Page is only displayed on My Profile page'));             
       } 
       
       this.controller = controller;
       subjectUser = (user)controller.getRecord();
   }
   
   public PageReference save() {
       //controller.save();
       User userToSave = (User)controller.getRecord();
       update userToSave ;
       ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, Label.Saved_Successfully));
       return ApexPages.currentPage();
   }
 }