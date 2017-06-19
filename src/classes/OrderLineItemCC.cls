public class OrderLineItemCC {
    
    public List<QueuesObject> queueList{get;set;}
    public String selectedQueue{get;set;}
    public Boolean showinput{get;set;}
    public Boolean showoutput{get;set;}
    public OrderLineItemCC(ApexPages.StandardController controller){
        searchQueue();
    }
    /**
    * @description A method that will be executed once the page is called. 
    * @author Cloudsherpas
    * @date 6-19-2014
    * @param none
    * @returns none
    */     
    public void searchQueue(){
        selectedQueue = 'Sample Queue';
        showinput = false;
        showoutput = true;
    } 
}