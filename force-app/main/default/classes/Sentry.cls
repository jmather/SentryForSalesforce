/**
 * @description       : 
 * @author            : jmather
 * @group             : 
 * @last modified on  : 04-29-2021
 * @last modified by  : Jheel
 * Modifications Log 
 * Ver   Date         Author    Modification
 * 1.0   08-10-2019   jmather   Initial Version
 * 1.1   04-28-2021   Jheel     Added a method to send custom title and breadcrumbs to Sentry
 * 1.2   04-29-2021   Jheel     Added global visibility for the class and required methods
**/
global without sharing class Sentry 
{
    global static void record(Exception e) 
    {
        Sentry_Event err = convertExceptionToError(e);
        sendEvent(err);
    }

    global static void record(String issueTitle, Exception e, List<Sentry_LogMessage> lExtraMessages) 
    {
        Sentry_Event err = convertExceptionToError(issueTitle, e, lExtraMessages);
        sendEvent(err);
    }

    private static Sentry_Event convertExceptionToError(Exception e) {
        return new Sentry_Event(e);
    }

    private static Sentry_Event convertExceptionToError(String issueTitle, Exception e, List<Sentry_LogMessage> lExtraMessages) 
    {
        return new Sentry_Event(issueTitle, e, lExtraMessages);
    }

    private static void sendEvent(Sentry_Event err) {
        Sentry_Log.logSentry('[Sentry.sendEvent] event: ' + JSON.serializePretty(err));
        Sentry_Log.logSentry('[Sentry.sendEvent] message: ' + JSON.serializePretty(err.toMessage()));

        Sentry_Error__e e = new Sentry_Error__e(Content__c = JSON.serialize(err.toMessage()));
        EventBus.publish(e);
    }
}