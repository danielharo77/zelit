/**
 * @description       : 
 * @author            : Daniel Haro 
 * @group             : 
 * @last modified on  : 03-18-2024
 * @last modified by  : Daniel Haro
**/
public with sharing class SecureContactAndAccountRetrieval {
    @AuraEnabled(cacheable=true)
    public static List<contact> retrieveContactsAndAccounts(String searchKeyword){
        try {
        		List<contact> contactAccountData = [SELECT FirstName, LastName, Email, Account.Name, Account.BillingAddress ,Account.Verification_Status__c ,
                                                   Account.Id , Account.AccountNumber , Account.BillingPostalCode  FROM Contact 
                                                   WHERE LastName =: searchKeyword OR Email LIKE : '%' + String.escapeSingleQuotes(searchKeyword) + '%'];
			    if(contactAccountData != null && !contactAccountData.isEmpty()){
                    SObjectAccessDecision filterRecords = Security.stripInaccessible( AccessType.READABLE, contactAccountData);
       			    return (filterRecords.getRecords());
                }
            }
        catch(DmlException e) {
           System.debug('The following exception has occurred: ' + e.getMessage());
 			}
        return new List<contact>();
	}

    @AuraEnabled(cacheable=true)
    public static callOutWrapper postCalloutResponseContents(String contactAccountData){ 
        List<contactWrapper> contactData;
        callOutWrapper returnData = new callOutWrapper();
        system.debug('show input for call out method ' +  contactAccountData);
        //fix the status field since we can not use custom field notation with wraper class breaking the deserlization
        contactAccountData = contactAccountData.replace('Verification_Status__c', 'status');
       //rebuild contact data from LWC was unable to pass it back in as is, due to the deepth of objects see assoiated wrapper class for details ContactWrapper
        contactData = (List<contactWrapper>)JSON.deserialize(contactAccountData, List<contactWrapper>.class);
        system.debug('show input for call out method deser ' +  contactData);

        Http h = new Http();
        HttpResponse res = new HttpResponse();
        HttpRequest req = new HttpRequest();
        Map<String, Object> serverResponse;
        String exceptionMessage;
        string endpoint = 'https://api.api-ninjas.com'; 
        string version =  'v1';
        string resource = 'account';
        string location = 'london';

        req.setEndpoint(endpoint + '/' + version + '/' + resource + '?address=' + location);
        req.setMethod('POST');  
        req.setHeader('Accept', '*/*');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(createJson(contactData));
        req.setTimeout(120000);
        try{
           res = h.send(req);
                if (res.getStatusCode() == 200 && res.getBody() != null){
                    system.debug('using top logic');
                    returnData.processedData = deserializeJasonUpdateTabelData(res.getBody(),contactData);
                    returnData.res = res;
                    return returnData;
                }
       }
       catch(Exception e){
            exceptionMessage = e.getMessage();
            system.debug(e.getMessage());
        }
        if(res != null && res.getStatus() != null){
            switch on res.getStatus(){
                when '400' { System.debug('You have sent an imporperly formated request, report this error to your system administator for analysis'); } // bad request throw error or system.debug
                when '404' { System.debug('Server not  found unable to process request, report this error to your system administator for analysis'); } // bad request throw error or system.debug
                when '500' {System.debug('The external server has thrown an internal error, please try your request at a later time.');  } // internal server error
                when else {system.debug('An unhandled error has occured, please report to system administrator.'); } // show status error report error 
            }
        }
        system.debug('using lower logic');

        returnData.processedData = deserializeJasonUpdateTabelData(contactAccountData,contactData);
        returnData.res = null;
        return returnData;
    }

    //create json package to send to ext server
    private static String createJson(List<ContactWrapper>  contactAccountData){
        system.debug('show data ? ' + contactAccountData);
        List<accountRecordexternal> ar = new List<accountRecordexternal>();  
        for(ContactWrapper  record : contactAccountData){
            accountRecordexternal temp = new accountRecordexternal();
            temp.accountId =  record.AccountId;
            temp.accountNumber = record.account.accountNumber;
            system.debug('create json show rec' + temp);
            ar.add(temp);
        }
        return(Json.serialize(ar)); 
    }
     //imaginary server response 
     // [{"AccountName" : "Company A" , "Address" : "address": {"street": "123 Main St", "city": "Anytown", ...} , "Status" : "Verified" , "AccountNumber" : "1214124312" ....} {"AccountName" : "Company B"...}
     //This is my solution to parsing the json (not using the Json parser as it is a messy souition)
    //ment to update the data structure with data retervied from the server, but since there is no actual package method never gets used!
    
    //PLEASE READ : This method is a litte redundant as it assigns existing interal data to the external fileds, its ment to capture the server data, since there is no incomming package,
    //I have it not doig so, the correction would be to use the data from the eesponse to poulate these fields but this breaks the demo.
    private static List<ContactWrapper> deserializeJasonUpdateTabelData(String responseData , List<ContactWrapper> contactAccountData){
        system.debug('show repose data for deserlization-->' + responseData);
        system.debug('show repose data for deserlization-->' + contactAccountData);

        if(responseData != null){
        List<AccountRecordResponse> parsedData = (List<AccountRecordResponse>)JSON.deserialize(responseData, List<AccountRecordResponse>.class);
        Map<String,AccountRecordResponse> mapedResponse = new Map<String,AccountRecordResponse >();
        for(AccountRecordResponse cr :parsedData){
            mapedResponse.put(cr.AccountNumber , cr);
        }
        for(ContactWrapper record : contactAccountData){
            string actnumber = record.account.AccountNumber;
            //Address tempAddress = mapedResponse.get(actnumber).address;
            contactWrapper.BillingAddress tempAddress = record.account.BillingAddress; 
            system.debug('show record' + record);

            system.debug('show tempAddress' + tempAddress);

           // record.account.extBillingAddress.fullAddress = tempAddress.street + ' ' + tempAddress.city + ' ' + tempAddress.state + ' , ' + tempAddress.zip;
            record.account.extBillingAddress = new contactWrapper.BillingAddress();
            record.account.extBillingAddress.street = tempAddress.street;
            record.account.extBillingAddress.city = tempAddress.city;
            record.account.extBillingAddress.state = tempAddress.state;
            record.account.extBillingAddress.postalCode = tempAddress.postalCode; 
            record.account.extStatus = record.account.status;
            system.debug('record.account.extBillingAddress' + record.account.extBillingAddress);

        }              
     return contactAccountData;
    }
    return new List<contactWrapper>();
}

//class used to generate outgoing JSON was not clear what the package should look like, easily updated with this solution
    public class AccountRecordexternal{
        @AuraEnabled public String accountId;
        @AuraEnabled public String accountNumber;
    }

// since its not clear if the incoming response package will be compatible with salesforce field names, I created my own deserialization class
    public class AccountRecordResponse{
        @AuraEnabled public String acountName;
        @AuraEnabled public Address address;
        @AuraEnabled public String status; 
        @AuraEnabled public String accountNumber;
    }
    //support class to handle addresses for deserialization
    public class Address {
        @AuraEnabled public String street;
        @AuraEnabled public String city;
        @AuraEnabled public String state;
        @AuraEnabled public String zip;
    }
    //using call out wraper since response is not the returned value to the LWC but is needed in the test class
    public class callOutWrapper{
        @AuraEnabled public List<ContactWrapper> processedData;
        public HttpResponse res;
    }
}