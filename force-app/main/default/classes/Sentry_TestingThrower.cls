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
global with sharing class Sentry_TestingThrower 
{
    class MyException extends Sentry_Exception {}

    global void throwException() 
    {
        MyException ex = (MyException) Sentry_ExceptionFactory.build(MyException.class);
        ex.setMessage('Something broke.');
        throw ex;
    }
}