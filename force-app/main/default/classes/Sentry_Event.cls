/**
 * Created by Jacob Mather <jmather@jmather.com> on 2019-03-25.
 */

public without sharing class Sentry_Event {
    // uuid
    public String event_id;

    public String timestamp;

    public String level = 'error';

    public String platform = 'salesforce';

    public Map<String, String> sdk = new Map<String, String> { 'name' => 'sentry.apex', 'version' => '1' };

    public String logger;

    public String server_name;

    public String release;

    public String message;

    public String environment;

    public String[] modules;

    public Map<String, Object> request = Sentry_Context.Basic();

    public Map<String, Object> extra = Sentry_Context.Basic();

    public Map<String, Object> user = Sentry_Context.User();

    public Map<String, Object> contexts = Sentry_Context.OsSystem();

    public Map<String, Object> tags = Sentry_Context.Basic();

    public String[] fingerprint;

    public Map<String, Object> breadcrumbs = Sentry_Context.Breadcrumbs();

    public Map<String, Object> exceptionValues = new Map<String, Object> { 'values' => new List<Map<String, Object>>() };

    public String messageFormatted;

    public String[] messageParams;

    public String stacktrace;

    public Sentry_Event() {
        initialize();
    }

    public Sentry_Event(Sentry_Exception ex) {
        this((Exception) ex);
        System.debug('custom' + ex.getCustomStackTraceAsString());
    }

    public Sentry_Event(Exception ex) {
        initialize();

        Sentry_Log.logSentry('Got exception: ' + ex);
        Sentry_Log.logSentry('Got stack: ' + ex.getStackTraceString());

        Map<String, Object> exData = Sentry_Context.create();
        Map<String, Object> exDataStack = Sentry_Context.create();

        exData.put('type', ex.getTypeName());
        exData.put('message', JSON.serialize(ex.getMessage()));

        List<Map<String, Object>> frames = new List<Map<String, Object>>();

        List<String> lines = ex.getStackTraceString().split('\n');
        if (ex instanceof Sentry_Exception) {
            lines = ((Sentry_Exception) ex).getCustomStackTrace();
        }

        for (Integer i = lines.size() - 1; i >= 0; i--) {
            String line = lines[i];
            Pattern p = Pattern.compile('Class\\.([^\\.]+)\\.([^:]+): line ([0-9]+), column ([0-9]+)');
            Matcher m = p.matcher(line);
            if (m.find()) {
                frames.add(new Map<String, Object> {
                        'class' => m.group(1),
                        'file' => m.group(1) + '.cls',
                        'function' => m.group(1) + '.' + m.group(2) + ', line ' + m.group(3),
                        'line' => m.group(3),
                        'column' => m.group(4)
                });
            }
        }

        exDataStack.put('frames', frames);
        exData.put('stacktrace', exDataStack);

        extra.put('cause', ex.getCause());
        extra.put('line_number', ex.getLineNumber());

        addException(exData);
        message = ex.getMessage();
    }

    private void addException(Map<String, Object> exData) {
        ((List<Map<String, Object>>)exceptionValues.get('values')).add(exData);
    }

    private void initialize() {
        Blob b = Crypto.generateAesKey(128);
        String h = EncodingUtil.convertToHex(b);
        event_id = h.substring(0,8)+ '-' + h.substring(8,12) + '-' + h.substring(12,16) + '-' + h.substring(16,20) + '-' + h.substring(20);

        timestamp = Datetime.now().formatGmt('yyyy-MM-dd') + 'T' + Datetime.now().formatGmt('HH:mm:ss') + 'Z';

        level = 'error';

        environment = Sentry_Config.getEnvironmentName();
    }

    public Map<String, Object> toMessage() {
        Map<String, Object> msg = Sentry_Context.create();
        msg.put('event_id', event_id);
        msg.put('environment', environment);
        msg.put('user', user);
        msg.put('timestamp', timestamp);
        msg.put('sdk', sdk);
        msg.put('platform', platform);
        msg.put('level', level);
        msg.put('exception', exceptionValues);
        return msg;
    }
}