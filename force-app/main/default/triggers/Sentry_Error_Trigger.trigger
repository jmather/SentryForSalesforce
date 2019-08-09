trigger Sentry_Error_Trigger on Sentry_Error__e (after insert) {
    Sentry_Error_Handler h = new Sentry_Error_Handler();
    h.run();
}