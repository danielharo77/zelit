/**
 * @description       : Search Tool to look up acconts intergated with ext system for account verfication and reterive addresses 
 * @author            : Daniel Haro
 * @last modified on  : 03-18-2024
 * @last modified by  : Daniel Haro
**/
import { LightningElement,track, wire } from 'lwc';
import getData from'@salesforce/apex/SecureContactAndAccountRetrieval.retrieveContactsAndAccounts';
import accountService from'@salesforce/apex/SecureContactAndAccountRetrieval.postCalloutResponseContents';

export default class ContactVerificationLWC extends LightningElement {

    @track contacts = []; 
    @track fields = [];
    @track extAccounts = [];

    columns = [
    {
        label: 'First Name',
        fieldName: 'FirstName',
        type: 'text',
        sortable: true
    },
    {
        label: 'Last Name',
        fieldName: 'LastName',
        type: 'Date',
        sortable: true
    },
    {
        label: 'Email',
        fieldName: 'Email',
        type: 'text',
        sortable: true
    },
    {
        label: 'Address',
        fieldName: 'BillingAddress',
        type: 'text',
        sortable: true
    },
    {
        label: 'Verification Status',
        fieldName: 'Verification_Status__c',
        type: 'text',
        sortable: true
    },
];
    updateKeyWord(event){
        this.searchWord = event.target.value;  
    }
    handleSearchClick(){
        this.extAccounts = [];
        this.fields = [];
        this.accountCalloutData = [];
        if(this.searchWord){
            getData({ searchKeyword: this.searchWord })
		        .then(result => {
                     if(result.length > 0){
                        this.contacts = [...result];
                        //create array to pass to callout method
                        for (let i in this.contacts) {
                            this.accountCalloutData.push({'accountId' : this.contacts[i].Account.Id , "accountNumber" : this.contacts[i].Account.AccountNumber});
                        }
                        accountService({ contactAccountData: JSON.stringify(this.contacts) }).then(result2 => {
                            //here we would replace the internal fields with external ones since there is no real package being recieved leaving as is see Contact wrapper class and deserlization method
                            //in the apex class
                            this.extAccounts = [result2.processedData]; 
                            for (let i in this.contacts) {
                                this.fields = [...this.fields,{'FirstName' : this.contacts[i].FirstName , 'LastName' : this.contacts[i].LastName,'Email' : this.contacts[i].Email, 
                                            'BillingAddress' : this.contacts[i].Account.BillingAddress.street,'Verification_Status__c' : this.contacts[i].Account.Verification_Status__c}];
                            }
                        })
                    .catch(error => {
                        console.log('error found!' , error.message);
                        this.error = error;
                        this.contacts = undefined;
                    })
                }
            else{
                 //prints out "NO records Found" message in data tabel to let the user know there where no matches for the given search
                 // (using email field to roughly center the message in the datatable)
                 this.fields = [{'Email' : 'NO Records FOUND'}] 
                }
        	this.error = undefined;
 		})
		.catch(error => {
            console.log('error found!' + this.error);
			this.error = error;
			this.contacts = undefined;
		})
        }
    }
}