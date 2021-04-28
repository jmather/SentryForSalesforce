/**
 * @description       : 
 * @author            : jmather
 * @group             : 
 * @last modified on  : 04-28-2021
 * @last modified by  : Jheel
 * Modifications Log 
 * Ver   Date         Author    Modification
 * 1.0   08-10-2019   jmather   Initial Version
 * 1.1   04-28-2021   Jheel     Added new methods RecordwithCustomException() and RecordCustomExceptionWithoutSendingToSentry() for test class coverge
**/
@IsTest
public with sharing class SentryTest {
    @IsTest
    static void Record() {
        Exception ex;

        Test.setMock(HttpCalloutMock.class, new Sentry_ApiMock());

        Sentry_TestingController controller = new Sentry_TestingController();

        Sentry_Active_Config__c config = Sentry_Active_Config__c.getOrgDefaults();
        config.IsIssueCreationDisabled__c = false;
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
    
    @IsTest
    static void RecordwithCustomException() 
    {
        Exception ex;

        Test.setMock(HttpCalloutMock.class, new Sentry_ApiMock());

        Sentry_TestingController controller = new Sentry_TestingController();

        Sentry_Active_Config__c config = Sentry_Active_Config__c.getOrgDefaults();
        config.IsIssueCreationDisabled__c = false;
        config.IsDebug__c = true;
        config.Sentry_Config__c = 'Test';
        config.Environment_Name__c = 'Test';
        insert config;

        Test.startTest();
        controller.triggerCustomException();
        Test.stopTest();

        System.assertEquals(null, ex);
    }
    
    @IsTest
    static void RecordCustomExceptionWithoutSendingToSentry() 
    {
        Exception ex;

        Test.setMock(HttpCalloutMock.class, new Sentry_ApiMock());

        Sentry_TestingController controller = new Sentry_TestingController();

        Sentry_Active_Config__c config = Sentry_Active_Config__c.getOrgDefaults();
        config.IsIssueCreationDisabled__c = true;
        config.IsDebug__c = true;
        config.Sentry_Config__c = 'Test';
        config.Environment_Name__c = 'Test';
        insert config;

        Test.startTest();
        controller.triggerCustomException();
        Test.stopTest();

        System.assertEquals(null, ex);
    }
}