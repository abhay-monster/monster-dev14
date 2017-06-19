public class APTS_Order_QueueInterFace implements Queueable, Database.AllowsCallouts{
    
    private seT<id> OldProposalset;
    
    public APTS_Order_QueueInterFace(Set<id> ProposalIdsetArge)
    {
        this.OldProposalset = ProposalIdsetArge;
    }
    public void execute(QueueableContext context) {
       APTS_creditHelper oClass = new APTS_creditHelper();
        oClass.SendForVerification(OldProposalset);
        
    }
}