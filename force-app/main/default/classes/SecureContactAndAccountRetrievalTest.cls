/**
 * @description       : 
 * @author            : Daniel Haro
 * @group             : 
 * @last modified on  : 03-18-2024
 * @last modified by  : Daniel Haro
**/
@IsTest 
public class SecureContactAndAccountRetrievalTest{
    
    @testSetup static void testData() {
        
        //get user profile id's and role ids
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
        }
}
    
     @IsTest
    	static void testCreateAccount() {
           list<account> accountList= [Select name from Account];
        }
    
    @IsTest
    	static void testgetDataNoRecords() {
            contactWrapper.BillingAddress testBillingaddress = new contactWrapper.BillingAddress();
            contactWrapper.Account accountTest = new contactWrapper.Account();
            SecureContactAndAccountRetrieval.AccountRecordResponse test = new SecureContactAndAccountRetrieval.AccountRecordResponse();
            test.accountNumber = '2424424';
            test.acountName = 'test';
            List<contact> testData = SecureContactAndAccountRetrieval.retrieveContactsAndAccounts('MR.Nobody');
            system.assert(testData.size() == 0 , 'Query returned to many records test failed.');
        }
    
     @IsTest
    	static void testgetDataSingleRecord() {
            List<contact> testData = SecureContactAndAccountRetrieval.retrieveContactsAndAccounts('Haro');
            system.assert(testData.size() == 1 , 'Query returned to many records test failed.');
            system.assert(testData[0].LastName == 'Haro', 'Query returned incorect record(s) Last Name does not match search.');
        }
    
     @IsTest
    	static void testgetDataMultiRecords() {
            List<contact> testData = SecureContactAndAccountRetrieval.retrieveContactsAndAccounts('Smith');
            system.assert(testData.size() > 1 , 'Query returned the wrong number of records test failed.');
            for(contact cr : testData){
            	system.assert(cr.LastName == 'Smith' , 'Query returned incorect record(s) Last Name does not match search.');
            }
        }

//to be moved into a test factory class!
    public static account createAccount(String name, String accountNumber){
        return new account(name = name, BillingStreet = '2121 love.St' ,BillingCity = 'Austin' , BillingState = 'TX' , BillingPostalCode = '78250' , AccountNumber = accountNumber);// 'CD451796');
    }
    
     public static contact createContact(String firstName, String lastName, String email, String accountId){
        return new contact(FirstName = firstName, LastName = lastName, Email = email, AccountId = accountId, MailingStreet = '2121 love.St' , MailingCity = 'Austin' , MailingState = 'TX' , MailingPostalCode = '78250');
    }
    
    
    public static user createUSer(String roleId, String profId, String firstName, String lastName){
        String orgId = UserInfo.getOrganizationId();  
        String dateString =   
        String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');  
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));  
        String uniqueName = orgId + dateString + randomInt;  
        User tempUser = new User(  
            FirstName = firstName,  
            LastName = lastName,  
            email = uniqueName + '@sfdc' + orgId + '.org',  
            Username = uniqueName + '@sfdc' + orgId + '.org',  
            EmailEncodingKey = 'ISO-8859-1',  
            Alias = uniqueName.substring(18, 23),  
            TimeZoneSidKey = 'America/Los_Angeles',  
            LocaleSidKey = 'en_US',  
            LanguageLocaleKey = 'en_US',  
            ProfileId = profId
        );    
        if( String.isBlank(roleId) == false ){
            tempUser.UserRoleId = roleId;
        }
        return tempUser;  
    }

}