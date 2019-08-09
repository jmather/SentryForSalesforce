/**
 * Created by jmather on 2019-08-08.
 */

public with sharing class Sentry_TestingMiddleware {
    public static void doThing() {
        Sentry_TestingThrower thrower = new Sentry_TestingThrower();

        thrower.throwException();
    }
}