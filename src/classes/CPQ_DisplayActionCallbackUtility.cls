/*
*************************************************************************************
Class Name     :  CPQ_DisplayActionCallbackUtility
Purpose        :  This class will implements IDisplayActionCallback which can override action buttons on Catalogue Page, Cart Page and Intalled product page based on certain condition.
History:                                                            
-------                                                            
VERSION  AUTHOR         DATE            DETAIL                TICKET REFERENCE/ NO.
1.       Viraj           10/25/2016
**************************************************************************************
*/

global with sharing class CPQ_DisplayActionCallbackUtility implements Apttus_Config2.CustomClass.IDisplayActionCallback{
        
   //Global Variables 
   public static Apttus_Config2__ProductConfiguration__c prodConfigObj;
   public static List<Apttus_Config2.DisplayActionInfo> ActionInfoList;
    
    /*
    *************************************************************************************
     * Method Name  :  start
     * Description  :  Interface method. This method sets the action info list. It serve below purpose.
                       1. Control buttons visiblity on installed page.
                       2. If Quote Type is Renewal, it will disable Add-On button and if Quote type is Add-On then it will disable Submit for approval button  
     * Return Type  :  None
     * Parameters   :  Apttus_Config2.ProductConfiguration, List<Apttus_Config2.DisplayActionInfo>
    *************************************************************************************
    */    
    global static void start(Apttus_Config2.ProductConfiguration cart, List<Apttus_Config2.DisplayActionInfo> disActionInfoList){
        if(cart != null){
            prodConfigObj = cart.getConfigSO();
        }
        
        if(disActionInfoList != null){
            ActionInfoList = disActionInfoList;
        }
         
        
    }
    
    global static void setActionProperties(Apttus_Config2.CustomClass.ActionParams actionParam){
        for(Apttus_Config2.DisplayActionInfo actionInfoInst : ActionInfoList ){
            Apttus_Config2__ConfigCustomDisplayActions__c ActionSOInst = actionInfoInst.ActionSO;
            if(ActionSOInst.Apttus_Config2__ActionName__c.equalsIgnoreCase(Label.SubmitForApproval)){
                if(prodConfigObj.Apttus_CQApprov__Approval_Status__c != null && prodConfigObj.Apttus_CQApprov__Approval_Status__c.EqualsIgnoreCase('Approval Required')){
                    actionInfoInst.IsEnabled = true;
                }else{
                    actionInfoInst.IsEnabled = false;
                }
            }
        }
          
    }
}