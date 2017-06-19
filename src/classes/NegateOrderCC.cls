/**
* @description Class that will clone an Order and it's related Order Line Items and the Line Attributes of Orders Line Item
* @author Cloudsherpas
* @date 4-30-2014
*/
public with sharing class NegateOrderCC extends OrderCloner {
/**
* @description The constuctor
* @author Cloudsherpas
* @date 4-30-2014
*/ 

 public String ChangeTypeLabel {get; set;}

    public NegateOrderCC(){
        if(ApexPages.currentPage().getParameters().containsKey('id')){
            Id parentOrderId = ApexPages.currentPage().getParameters().get('id');
            init(parentOrderId, 'Negate');
        }
    }
    
    
    public List<SelectOption> getChangeTypeVal(){
           List<SelectOption> options = new List<SelectOption>();
        
           Schema.DescribeFieldResult fieldChangeType = Order__c.Change_Type__c.getDescribe();
           ChangeTypeLabel  = fieldChangeType.getLabel();
           List<Schema.PicklistEntry> changeTypePickVal = fieldChangeType.getPicklistValues();
        
           for( Schema.PicklistEntry f : changeTypePickVal)
               {
                options.add(new SelectOption(f.getLabel(), f.getValue()));
               }       
           return options;
    }
    
    public PageReference Save(){
            
            return  super.saveOrder(ChangeTypeLabel);
            //return ;
    }
    
    
    override protected void handleUniqueProcessAfter(){
        try{
            if(ParentOrder != null && ClonedOrder != null){
                ParentOrder.OrderStatus__c = 'Negated';
                update ParentOrder;
            }
        }catch(Exception e){
            addError('An error occurred please contact your administrator.');
        }
    }
}