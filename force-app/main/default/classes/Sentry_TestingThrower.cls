/**
 * Created by jmather on 2019-08-08.
 */

public with sharing class Sentry_TestingThrower {
    class MyException extends Sentry_Exception {}

    public void throwException() {
        MyException ex = (MyException) Sentry_ExceptionFactory.build(MyException.class);
        ex.setMessage('Something broke.');
        throw ex;
    }
}