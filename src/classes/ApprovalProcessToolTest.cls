@isTest(SeeAllData=true)
private class ApprovalProcessToolTest {
    static testMethod void runTest() {
        ApprovalProcessTool apt = new ApprovalProcessTool();
        apt.run();
    }
}