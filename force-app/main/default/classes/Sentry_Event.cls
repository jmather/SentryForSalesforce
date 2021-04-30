/**
 * @description       : 
 * @author            : jmather
 * @group             : 
 * @last modified on  : 04-29-2021
 * @last modified by  : Jheel
 * Modifications Log 
 * Ver   Date         Author    Modification
 * 1.0   08-10-2019   jmather   Initial Version
 * 1.1   04-28-2021   Jheel     Added logic to send proper detailed data to Sentry with Breadcrumbs as well
 * 1.2   04-29-2021   Jheel     Added global visibility for the class and required methods
 * 1.3   04-29-2021   Jheel     Added logic not to send frames and stacktrace if it is empty and added logic to cover managed package stacktrace
**/
global without sharing class Sentry_Event 
{
    // uuid
    global String event_id;

    global String timestamp;

    global String level = 'error';

    global String platform = 'salesforce';

    global Map<String, String> sdk = new Map<String, String> { 'name' => 'sentry.apex', 'version' => '1' };

    global String logger;

    global String server_name;

    global String release;

    global String message;

    global String environment;

    global String[] modules;

    global Map<String, Object> request = Sentry_Context.Basic();

    global Map<String, Object> extra = Sentry_Context.Basic();

    global Map<String, Object> user = Sentry_Context.User();

    global Map<String, Object> contexts = Sentry_Context.OsSystem();

    global Map<String, Object> tags = Sentry_Context.Basic();

    global String[] fingerprint;

    global Map<String, Object> breadcrumbs = Sentry_Context.Breadcrumbs();

    global Map<String, Object> exceptionValues = new Map<String, Object> { 'values' => new List<Map<String, Object>>() };

    global Map<String, Object> breadcrumbsValues = new Map<String, Object> { 'values' => new List<Map<String, Object>>() };

    global String messageFormatted;

    global String[] messageParams;

    global String stacktrace;

    global Sentry_Event() 
    {
        initialize();
    }

    global Sentry_Event(Sentry_Exception ex) 
    {
        this((Exception) ex);
        System.debug('custom' + ex.getCustomStackTraceAsString());
    }

    global Sentry_Event(Exception ex) 
    {
        this(null, ex, null);
    }

    // Custom Method with custom issueTitle and extra messages
    global Sentry_Event(String issueTitle, Exception ex, List<Sentry_LogMessage> lExtraMessages) 
    {
        initialize();

        Sentry_Log.logSentry('Got exception: ' + ex);
        Sentry_Log.logSentry('Got stack: ' + ex.getStackTraceString());

        Map<String, Object> exceptionData = Sentry_Context.create();
        Map<String, Object> exceptionDataStack = Sentry_Context.create();

        // For setting custom title for the issue which will be created
        if(String.isNotBlank(issueTitle))
        {
            exceptionData.put('type', issueTitle);
        }
        // Default title will be the type of exception occured.
        else
        {
            exceptionData.put('type', ex.getTypeName());
        }
        
        exceptionData.put('message', JSON.serialize(ex.getMessage()));

        List<Map<String, Object>> frames = new List<Map<String, Object>>();

        List<String> lines = ex.getStackTraceString().split('\n');
        if (ex instanceof Sentry_Exception) {
            lines = ((Sentry_Exception) ex).getCustomStackTrace();
        }

        for (Integer i = lines.size() - 1; i >= 0; i--) {
            String line = lines[i];
            Pattern p = Pattern.compile('Class\\.([^\\.]+)\\.([^:]+): line ([0-9]+), column ([0-9]+)');
            Matcher m = p.matcher(line);
            // Sample: Class.SampleClass.execute: line 36, column 1
            if (m.find()) 
            {
                System.debug('@@m:--'+m);
                frames.add(new Map<String, Object> {
                    'class' => m.group(1),
                    'filename' => m.group(1) + '.cls',
                    'function' => m.group(1) + '.' + m.group(2) + ', line ' + m.group(3),
                    'lineno' => Integer.valueOf(m.group(3)),
                    'column' => Integer.valueOf(m.group(4)),
                    'in_app'=> true,
                    'vars' => new Map<String, Object> {
                        'column' => m.group(4),
                        'line' => Integer.valueOf(m.group(3)),
                        'class'=> m.group(1),
                        'function' => m.group(2)
                    }
                });
            }
            else
            {
                p = Pattern.compile('Class\\.([^\\.]+): line ([0-9]+), column ([0-9]+)');
                m = p.matcher(line);
                // Sample: Class.SampleClass1: line 595, column 1
                if (m.find()) 
                {
                    System.debug('@@m:--'+m);
                    frames.add(new Map<String, Object> {
                        'class' => m.group(1),
                        'filename' => m.group(1) + '.cls',
                        'function' => m.group(1) /*+ '.' + m.group(2) */+ ', line ' + m.group(2),
                        'lineno' => Integer.valueOf(m.group(2)),
                        'column' => Integer.valueOf(m.group(3)),
                        'in_app'=> true,
                        'vars' => new Map<String, Object> {
                            'column' => m.group(3),
                            'line' => Integer.valueOf(m.group(2)),
                            'class'=> m.group(1)
                        }
                    });
                }
                // For Managed Package Exceptions. Sample: (Sentry)
                else 
                {
                    frames.add(new Map<String, Object> {
                        'function' => line,
                        'in_app'=> true,
                        'vars' => new Map<String, Object> {
                            'class'=> line
                        }
                    });
                }
            }
        }

        if(!frames.isEmpty())
        {
            exceptionDataStack.put('frames', frames);
            exceptionData.put('stacktrace', exceptionDataStack);
        }
        else 
        {
            if(lExtraMessages == null)
            {
                lExtraMessages = new List<Sentry_LogMessage>();
            }
            lExtraMessages.add(new Sentry_LogMessage(PCH.Sentry_LogMessage.LEVEL_ERROR, ex.getMessage()+'\nStacktrace:-'+ex.getStackTraceString()));
        }

        // add "value" in exceptionData
        exceptionData.put('value', ex.getTypeName()+' '+ex.getMessage());
        exceptionData.put('cause', ex.getCause());
        exceptionData.put('line_number', ex.getLineNumber());

        addException(exceptionData);
        message = ex.getMessage();

        // For loop for adding extra messages in the issue
        if(lExtraMessages != null && !lExtraMessages.isEmpty())
        {
            for(Sentry_LogMessage objSLogMessage: lExtraMessages)
            {
                Map<String, Object> extraData = Sentry_Context.create();
                extraData.put('type', objSLogMessage.type);  
                extraData.put('category', objSLogMessage.category);  
                extraData.put('level', objSLogMessage.level);  
                extraData.put('timestamp', objSLogMessage.ts.formatGmt('yyyy-MM-dd') + 'T' + objSLogMessage.ts.formatGmt('HH:mm:ss') + 'Z');  
                extraData.put('message', objSLogMessage.message);
                
                // Adding extra messages
                addbreadcrumbs(extraData);
            }
        }
    }

    private void addException(Map<String, Object> exData) {
        ((List<Map<String, Object>>)exceptionValues.get('values')).add(exData);
    }

     private void addbreadcrumbs(Map<String, Object> exData) {
        ((List<Map<String, Object>>)breadcrumbsValues.get('values')).add(exData);
    }

    private void initialize() {
        Blob b = Crypto.generateAesKey(128);
        String h = EncodingUtil.convertToHex(b);
        event_id = h.substring(0,8)+ '-' + h.substring(8,12) + '-' + h.substring(12,16) + '-' + h.substring(16,20) + '-' + h.substring(20);

        timestamp = Datetime.now().formatGmt('yyyy-MM-dd') + 'T' + Datetime.now().formatGmt('HH:mm:ss') + 'Z';

        level = Sentry_LogMessage.LEVEL_ERROR;

        environment = Sentry_Config.getEnvironmentName();
    }

    global Map<String, Object> toMessage() 
    {
        Map<String, Object> msg = Sentry_Context.create();
        msg.put('event_id', event_id);
        msg.put('environment', environment);
        msg.put('user', user);
        msg.put('timestamp', timestamp);
        msg.put('sdk', sdk);
        msg.put('platform', platform);
        msg.put('level', level);
        msg.put('exception', exceptionValues);
        msg.put('breadcrumbs', breadcrumbsValues);
        return msg;
    }
}