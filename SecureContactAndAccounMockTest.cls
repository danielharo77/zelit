@istest
public class SecureContactAndAccounMockTest {

  
    
    @testSetup static void testData() {
        
 /*/       //get user profile id's and role ids
        Map<String,User> userMap = new Map<String,User>();
        Map<String,String> profileMap = new Map<String,String>();
        Map<String,String> rolesMap = new Map<String,String>();
        List<Profile> profiles = [Select Id, name from profile];
        List<UserRole> roles = [Select id , name from UserRole];
        List<User> userList = new List<User>();
        List<Contact> contactList = new List<Contact>();
        List<Account> accountList = new List<Account>();

        Account testAccount1;
        Account testAccount2;
        contact testContact1;
        contact testContact2;
        contact testContact3;
        
        for(profile cr : profiles){
            profileMap.put(cr.name , cr.Id);
        }
        for(UserRole cr : roles){
            rolesMap.put(cr.name , cr.Id);
        }
        User testUser1 = createUser(rolesmap.get('CEO'),profileMAp.get('Custom: Marketing Profile'),'Daniel','Haro');
        User testUser2 = createUser(rolesmap.get('CFO'),profileMAp.get('System Administrator'),'Dan','Haro');
        userList.add(testUser1);
        userList.add(testUser2);
        insert userList;
        
        System.runAs(testUser2) {
        	testAccount1 = createAccount('testAccount1','CD451796');
            testAccount2 = createAccount('testAccount2','CD451795');
            system.debug('show account data ' + testAccount1);
            accountList.add(testAccount1);
            accountList.add(testAccount2);
        	insert(accountList);
        	testContact1 = createContact('Dan' , 'Haro' , 'dantest1@myEmail1.org',testAccount1.Id);
           	testContact2 = createContact('Bill' , 'Smith' , 'billSmithtest2@myEmail1.org',testAccount1.Id);
           	testContact3 = createContact('Ray' , 'Smith' , 'RaySmithtest2@myEmail1.org',testAccount1.Id);
			testContact1.AccountId = testAccount1.Id;
            testContact2.AccountId = testAccount1.Id;
			testContact3.AccountId = testAccount1.Id;
            contactList.add(testContact1);
            contactList.add(testContact2);
            contactList.add(testContact3);
            insert contactList;
    /*/  
    }
    
    
       @IsTest
    static void testCallOut() {
       // LIST<user> userList = [SELECT Id,LastName FROM user WHERE LastName =: 'Haro'];
      //  List<contact> data = JSON.serialize(SecureContactAndAccountRetrieval.retrieveContactsAndAccounts('Smith'));
       //  List<contact> data = SecureContactAndAccountRetrieval.retrieveContactsAndAccounts('Smith');
       // System.runAs(userList[0]) {
       // 
       string dataStream2 ='[{"Account":{"BillingAddress":{"street":"2121 love.St","city":"Austin","state":"TX","postalCode":"78250"},"BillingPostalCode":"78250","Id":"001bm00000155swAAA","Name":"testAccount1","AccountNumber":"CD451796"},"Email":"billsmithtest2@myema (7 more) ...","AccountId":"001bm00000155swAAA","FirstName":"Bill","LastName":"Smith","Id":"003bm000000CU7DAAW"}]';
       system.debug('show data strewm 2::: ' + datastream2);
        String data = '[{"accountNumber":"CD451796","accountId":"001bm000000AvDgAAK"},{"accountNumber":"CD451795","accountId":"001bm000000AvDgAAK"}]';
        	Test.setMock(HttpCalloutMock.class, new SecureContactAndAccountRetrievalMock());
        	SecureContactAndAccountRetrieval.callOutWrapper responseData = SecureContactAndAccountRetrieval.postCalloutResponseContents(dataStream2);
			system.debug('resData ' + responseData);
    		system.debug('resData process' + responseData.processedData);
     		system.debug('resData process' + responseData.res);

        	System.assertEquals(200,responseData.res.getStatusCode());
        	system.debug('show resBodyData ' + responseData.res.getBody());
        	System.assert(responseData.res.getBody() != null);
        //{"Account":{"BillingAddress":{"street":"312 Constitution Place\r\nAustin, TX 78767\r\nUSA","city":"Austin","state":"TX","postalCode":"78767"},"Verification_Status__c":"Verified","BillingPostalCode":"78767","Id":"001bm000000AvDgAAK","Name":"Edge Communications","AccountNumber":"CD451796"},"Email":"sean@edge.com","AccountId":"001bm000000AvDgAAK","FirstName":"Sean","LastName":"Forbes","Id":"003bm0000005V3XAAU"},{"Account":{"BillingAddress":{"street":"312 Constitution Place\r\nAustin, TX 78767\r\nUSA","city":"Austin","state":"TX","postalCode":"78767"},"Verification_Status__c":"Verified","BillingPostalCode":"78767","Id":"001bm000000AvDgAAK","Name":"Edge Communications","AccountNumber":"CD451796"},"Email":"janeforbes@edge.com","AccountId":"001bm000000AvDgAAK","FirstName":"Jane","LastName":"Forbes","Id":"003bm0000006bL3AAI"}      
        
       // }
    }
}