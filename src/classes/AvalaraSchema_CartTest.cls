@isTest
public class AvalaraSchema_CartTest {

    static testMethod void testAvalaraSchema_Cart(){
        Test.startTest();
        AvalaraSchema_Cart.RequestHeader reqHeader = new AvalaraSchema_Cart.RequestHeader();
        reqHeader.EndPoint = 'test';
        String endPoint = reqHeader.EndPoint;
        String method = reqHeader.Method;
        AvalaraSchema_Cart.GetTaxRequest taxReq = new AvalaraSchema_Cart.GetTaxRequest();
        taxReq.serialize();
        Test.stopTest();
    }
}