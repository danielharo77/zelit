/**
 * @description       : 
 * @author            : Daniel Haro
 * @group             : 
 * @last modified on  : 03-18-2024
 * @last modified by  : Daniel Haro
**/
public with sharing class contactWrapper {
     
    public contactWrapper.Account account; 
    public String Email;
    public String AccountId;
    public String FirstName;
    public String LastName;
    public String Id;

    public class BillingAddress {
        @AuraEnabled public String fullAddress;
        @AuraEnabled public String street;
        @AuraEnabled public String city;
        @AuraEnabled public String state;
        @AuraEnabled public String postalCode;
        
        public BillingAddress(){
            fullAddress = 'Not assigned';
            street = 'Not assigned';
            city = 'Not assigned';
            state = 'Not assigned';
            postalCode = 'Not assigned';
        }
    }
    
    public class Account {
        @AuraEnabled public contactWrapper.BillingAddress extBillingAddress;
        @AuraEnabled public String status;
        @AuraEnabled public String extStatus;
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String AccountNumber;
        
        public Account(){
        	BillingAddress extBillingAddress = new contactWrapper.BillingAddress();
        	status = 'NONE';
       	 	extStatus = 'NONE';
        	Id = '';
        	Name = 'unassigned';
        	AccountNumber = 'unassigned';
        }
    }
}