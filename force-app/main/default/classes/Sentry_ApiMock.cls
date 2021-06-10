/**
 * @description       : 
 * @author            : jmather
 * @group             : 
 * @last modified on  : 04-29-2021
 * @last modified by  : Jheel
 * Modifications Log 
 * Ver   Date         Author    Modification
 * 1.0   08-10-2019   jmather   Initial Version
 * 1.1   04-29-2021   Jheel     Added global visibility for the class and required methods
**/
@IsTest
global with sharing class Sentry_ApiMock implements HttpCalloutMock 
{
    global HttpResponse respond(HttpRequest param1) 
    {
        System.debug(param1);
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        return response;
    }
}