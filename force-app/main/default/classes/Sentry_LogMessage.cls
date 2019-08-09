/**
 * Created by jmather on 2019-08-08.
 */

global with sharing class Sentry_LogMessage {
    global static final String LEVEL_ERROR = 'error';
    global static final String LEVEL_WARN = 'warn';
    global static final String LEVEL_INFO = 'info';
    global static final String LEVEL_DEBUG = 'debug';
    global static final String LEVEL_TRACE = 'trace';
    public static final String LEVEL_SENTRY_DEBUG = 'sys-debug';

    global String level { get; set; } { level = LEVEL_INFO; }
    global String message { get; set; }
    global Datetime ts { get; private set; } { ts = Datetime.now(); }
    global Map<String, String> data { get; set; } { data = new Map<String, String>(); }

    global Sentry_LogMessage(String level, String message) {
        this.level = (level == LEVEL_ERROR) ? LEVEL_ERROR : LEVEL_INFO;
        this.message = message;
    }

    global Sentry_LogMessage(String level, String message, Map<String, String> logData) {
        this(level, message);

        this.data = logData;
    }
}