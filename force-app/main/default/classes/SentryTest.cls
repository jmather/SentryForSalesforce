/**
 * Created by jmather on 2019-08-10.
 */

@IsTest
public with sharing class SentryTest {
    @IsTest
    static void Record() {
        Exception ex;

        Test.setMock(HttpCalloutMock.class, new Sentry_ApiMock());

        Sentry_TestingController controller = new Sentry_TestingController();

        Sentry_Active_Config__c config = Sentry_Active_Config__c.getOrgDefaults();
        config.IsIssueCreationEnabled__c = true;
        config.IsDebug__c = true;
        config.Sentry_Config__c = 'Test';
        config.Environment_Name__c = 'Test';
        insert config;

        Test.startTest();

        try {
            controller.triggerCapturedException();
        } catch (Exception e) {
            ex = e;
        }

        Test.stopTest();

        System.assertNotEquals(null, ex);
    }
}