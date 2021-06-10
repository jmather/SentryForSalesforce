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
global abstract class Sentry_Context 
{
    global static Map<String, Object> create() 
    {
        return new Map<String, Object>();
    }

    global static Map<String, Object> Basic() 
    {
        return new Map<String, Object>();
    }

    global static Map<String, Object> Breadcrumbs() 
    {
        Map<String, Object> data = create();
        data.put('values', create());
        return data;
    }

    global static Map<String, Object> OsSystem() 
    {
        return new Map<String, Object> {
                'os' => Server(),
                'runtime' => Runtime(),
                'org' => Org()
        };
    }

    global static Map<String, String> Org() 
    {
        return new Map<String, String> {
                'name' => Sentry_Environment.getInstanceLabel(),
                'type' => String.valueOf(Sentry_Environment.getInstanceType())
        };
    }

    global static Map<String, String> Server() 
    {
        return new Map<String, String> {
                'name' => 'Salesforce',
                'version' => '1'
        };
    }

    global static Map<String, String> Runtime() 
    {
        return new Map<String, String> {
                'name' => 'Apex',
                'version' => '1'
        };
    }

    global static Map<String, String> User() 
    {
        return new Map<String, String> {
                'id' => UserInfo.getUserId(),
                'username' => UserInfo.getUserName(),
                'email' => UserInfo.getUserEmail()
        };
    }
}