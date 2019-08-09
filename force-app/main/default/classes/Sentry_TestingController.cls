/**
 * Created by jmather on 2019-08-08.
 */

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
}