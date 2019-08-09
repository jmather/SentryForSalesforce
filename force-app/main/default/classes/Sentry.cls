/**
 * Created by Jacob Mather <jmather@jmather.com> on 2019-06-25.
 */

public without sharing class Sentry {
    public static void record(Exception e) {
        Sentry_Event err = convertExceptionToError(e);

        sendEvent(err);
    }

    private static Sentry_Event convertExceptionToError(Exception e) {
        return new Sentry_Event(e);
    }

    private static void sendEvent(Sentry_Event err) {
        Sentry_Log.logSentry('[Sentry.sendEvent] event: ' + JSON.serializePretty(err));
        Sentry_Log.logSentry('[Sentry.sendEvent] message: ' + JSON.serializePretty(err.toMessage()));

        Sentry_Error__e e = new Sentry_Error__e(Content__c = JSON.serialize(err.toMessage()));
        EventBus.publish(e);
    }
}