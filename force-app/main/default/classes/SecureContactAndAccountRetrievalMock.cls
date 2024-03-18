/**
 * @description       : 
 * @author            : Daniel Haro
 * @group             : 
 * @last modified on  : 03-18-2024
 * @last modified by  : Daniel Haro
**/
@isTest
global class SecureContactAndAccountRetrievalMock implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type','application/json');
        res.setBody('[{"accountNumber":"CD451796","accountId":"001bm000000AvDgAAK" , "Address" : {"street":"love.st" , "city" :"Austin" , "state" : "TX" , "zip" : "343434" }},{"accountNumber":"CD451795","accountId":"001bm000000AvDgAAK" ,"Address" : {"street":"love.st" , "city" :"Austin" , "state" : "TX" , "zip" : "343434"}}]');
        res.setStatusCode(200);
        return res;
    }

}