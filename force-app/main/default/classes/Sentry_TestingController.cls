/**
 * @description       : 
 * @author            : jmather
 * @group             : 
 * @last modified on  : 04-28-2021
 * @last modified by  : Jheel
 * Modifications Log 
 * Ver   Date         Author    Modification
 * 1.0   08-10-2019   jmather   Initial Version
 * 1.1   04-28-2021   Jheel     Added logic to trigger Custom Exception
**/
public with sharing class Sentry_TestingController {
    public PageReference triggerCapturedException() {
        try {
            Sentry_TestingMiddleware.doThing();
        } catch (Sentry_Exception e) {
            Sentry.record(e);
            throw e;
        }

        return null;
    }
    
    public PageReference triggerCustomException() 
    {
        List<Sentry_LogMessage> lExtraMessages = new List<Sentry_LogMessage>();
     	lExtraMessages.add(new Sentry_LogMessage(Sentry_LogMessage.LEVEL_INFO, Sentry_LogMessage.LEVEL_DEBUG, Sentry_LogMessage.LEVEL_DEBUG,'Testing debug 1', new Map<String, String>()));   
        Sentry.record('Custom Issue Title',new SYS_CustomException('Custom Exception'), lExtraMessages);
        return null;
    }
}