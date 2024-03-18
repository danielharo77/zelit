/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-18-2024
 * @last modified by  : Daniel Haro
**/
public with sharing class wrapper {
    
    public wrapper.Account account;
    public String Email;
    public String AccountId;
    public String FirstName;
    public String LastName;
    public String Id;

    public class BillingAddress {
        @AuraEnabled public String street;
        @AuraEnabled public String city;
        @AuraEnabled public String state;
    }
    
    public class Account {
        @AuraEnabled public BillingAddress BillingAddress;
        @AuraEnabled public String VerificationStatus;
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String AccountNumber;
    }
}