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
global with sharing class Sentry_Error_Handler 
{
    global void run() 
    {
        List<String> errors = new List<String>();

        for (Sentry_Error__e e : (List<Sentry_Error__e>) Trigger.new) {
            Sentry_Log.logSentry('[Sentry_Error_Handler.run] System event: ' + JSON.serializePretty(e));
            Sentry_Log.logSentry('[Sentry_Error_Handler.run] Sentry event: ' + e.Content__c);

            errors.add(e.Content__c);
        }

        if (errors.isEmpty() || Sentry_Config.canSendToSentry() == false) {
            if (Sentry_Config.canSendToSentry()) {
                Sentry_Log.logSentry('[Sentry_Error_Handler.run] no errors, exiting.');
            } else {
                Sentry_Log.logSentry('[Sentry_Error_Handler.run] sending to sentry is disabled. Not sending ' + errors.size() + ' errors.');
            }

            return;
        }

        Sentry_Log.logSentry('[Sentry_Error_Handler.run] calling sendErrors with ' + errors.size() + ' errors.');

        sendErrors(errors);
    }

    @Future(Callout=true)
    global static void sendErrors(List<String> errors) 
    {
        for (String error : errors) {
            Sentry_Client.sendEventToSentry(error);
        }
    }
}