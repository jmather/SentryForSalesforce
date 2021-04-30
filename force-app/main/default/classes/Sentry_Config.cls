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
global without sharing class Sentry_Config 
{
    private static Boolean isInDebugMode = null;
    private static Sentry_Active_Config__c activeConfig;
    private static Sentry_Config__mdt config;

    global static Sentry_Config__mdt getConfig() 
    {
        checkDebugging();

        if (config == null) {
            Sentry_Active_Config__c ac = getActiveConfig();

            String configName = ac.Sentry_Config__c;

            if (configName == null) {
                configName = 'Default';
            }

            Sentry_Log.logSentry('[Sentry_Config.getConfig] looking up config named: ' + configName);

            // nothing meaningful to order them by, no system modification time on custom metadata?
            List<Sentry_Config__mdt> configs = [
                    SELECT
                            Id,
                            DSN__c
                    FROM Sentry_Config__mdt
                    WHERE DeveloperName = :configName];

            Sentry_Log.logSentry('[Sentry_Config.getConfig] found configs: ' + configs);

            if (configs.isEmpty()) {
                throw new SentryConfigException(Label.Sentry_could_not_find_a_configuration_to_use);
            }

            config = configs[0];
        }

        return config;
    }

    global static String getEnvironmentName() 
    {
        Sentry_Active_Config__c ac = getActiveConfig();

        if (String.isBlank(ac.Environment_Name__c)) {
            return Sentry_Environment.getInstanceLabel();
        }

        return ac.Environment_Name__c;
    }

    global static Sentry_Dsn getDsn() 
    {
        return new Sentry_Dsn(getConfig().DSN__c);
    }

    global static Boolean checkDebugging() 
    {
        if (isInDebugMode == null) {
            Sentry_Active_Config__c ac = getActiveConfig();

            if (ac.IsDebug__c == null) {
                isInDebugMode = false;
            } else {
                isInDebugMode = ac.IsDebug__c;
            }

            Sentry_Log.debugSentry = isInDebugMode;
        }

        return isInDebugMode;
    }

    global static Boolean canSendToSentry() 
    {
        Sentry_Active_Config__c ac = getActiveConfig();

        Sentry_Log.logSentry('[Sentry_config.canSendToSentry] active config: ' + JSON.serializePretty(ac));

        if (ac.IsIssueCreationDisabled__c == null) {
            return true;
        }

        return ac.IsIssueCreationDisabled__c == false;
    }

    private static Sentry_Active_Config__c getActiveConfig() 
    {
        if (activeConfig == null) {
            activeConfig = Sentry_Active_Config__c.getOrgDefaults();
        }

        return activeConfig;
    }

    global class SentryConfigException extends Exception {}
}