/**
 * Created by jmather on 2019-08-10.
 */

@IsTest
public with sharing class Sentry_ApiMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest param1) {
        System.debug(param1);
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        return response;
    }
}