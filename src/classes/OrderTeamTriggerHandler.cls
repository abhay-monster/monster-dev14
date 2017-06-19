public without sharing class OrderTeamTriggerHandler{
  
 public static void beforeInsert(List<OrderTeam__c> orderTeamList){
     set<Id> orderIds = new set<Id>(); 
     map<string,set<string>> mapOrderToTeam = new map<string,set<string>>(); 
     for(OrderTeam__c teammember : orderTeamList){
         if(teammember.Order__c != null && teammember.TeamMember__c != null){
             orderIds.add(teammember.Order__c);
         }
     }
     if(orderIds.isEmpty()) return;
     
     for(Order__c o : [Select Id,(Select Id,TeamMember__c from Order_Teams__r) from Order__c Where Id IN :orderIds]){
        mapOrderToTeam.put(o.Id, new set<string>());
        for(OrderTeam__c member : o.Order_Teams__r){
         mapOrderToTeam.get(o.Id).add(member.TeamMember__c);
        }
     }

     for(OrderTeam__c teammember : orderTeamList){
         
         if( mapOrderToTeam.get( teammember.order__c).contains(teammember.TeamMember__c)){
             teammember.addError('Duplicate Order Team Member Found. Please add new one.');
         }
     }
  
  }
}