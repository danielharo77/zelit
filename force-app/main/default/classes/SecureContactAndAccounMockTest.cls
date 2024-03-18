/**
 * @description       : 
 * @author            : Daniel Haro
 * @group             : 
 * @last modified on  : 03-18-2024
 * @last modified by  : Daniel Haro
**/
@istest
public class SecureContactAndAccounMockTest {
       
@IsTest
    static void testCallOut() {
        String dataStream2 ='[{"Account":{"BillingAddress":{"street":"2121 love.St","city":"Austin","state":"TX","postalCode":"78250"},"BillingPostalCode":"78250","Id":"001bm00000155swAAA","Name":"testAccount1","AccountNumber":"CD451796"},"Email":"billsmithtest2@myema (7 more) ...","AccountId":"001bm00000155swAAA","FirstName":"Bill","LastName":"Smith","Id":"003bm000000CU7DAAW"}]';
        String data = '[{"accountNumber":"CD451796","accountId":"001bm000000AvDgAAK"},{"accountNumber":"CD451795","accountId":"001bm000000AvDgAAK"}]';
     	Test.setMock(HttpCalloutMock.class, new SecureContactAndAccountRetrievalMock());
        SecureContactAndAccountRetrieval.callOutWrapper responseData = SecureContactAndAccountRetrieval.postCalloutResponseContents(dataStream2);
	    System.assertEquals(200,responseData.res.getStatusCode());
        System.assert(responseData.res.getBody() != null);
    }
}