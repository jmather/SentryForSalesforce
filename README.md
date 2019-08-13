# Sentry for Salesforce

## Installation

### An Unmanaged Package for installation into a production org

[https://login.salesforce.com/packaging/installPackage.apexp?p0=04t2E000003VoDZQA0](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t2E000003VoDZQA0)

### An Unmanaged Package for installation into a sandbox or scratch org

&lt;your org url&gt;/packaging/installPackage.apexp?p0=04t2E000003VoDZQA0 

### Other

Upload the code with SFDX. To be expanded upon later!

## Configuration

1. Go to Custom Code > Custom Metadata
2. Click "Manage Records" on "Sentry Config"
3. Click "Edit" on "Default"
4. Put in your Sentry DSN in the "DSN" field
5. Save!

### Additional configuration

There is also a Custom Setting which you can use.

1. Go to Custom Code > Custom Settings
2. Click "Manage Records" on "Sentry Active Config"
3. Click "New"
4. `Environment Name` is the name of the environment that will show up in Sentry.
5. `Debug` turns on developer debugging for the Salesforce for Sentry internals.
6. `Is Issue Creation Enabled` turns on actually sending errors to Sentry.
7. `Sentry Config DeveloperName` takes the DeveloperName of a `Sentry Config` entry, and uses that configuration. This makes it easy to have sentry disabled by default in cloned sandboxes. Just make a `Sentry Config` for Production, and set the `Sentry Config DeveloperName` to that in your Production environment.

## Usage

```
try {
    doSomethingExceptional();
} catch (Exception e) {
    Sentry.record(e);
    throw e;
}
```

### WAIT WHAT?! THAT WON'T WORK!

Behind the scenes, the exception is serialized, and published **immediately** to the EventBus, via the `Sentry_Error__c` event.

After that, an Apex Trigger is listening for new `Sentry_Error__e` after inserts, and hands them off to a `@Future` which makes the API calls to Sentry. 

This means you can **record** exceptions AND **throw** them, to prevent bad things from happening.

## Stack Traces

By default, Custom Exceptions in Apex do not get the privilege of having stack traces. See the [known issue - no fix](https://success.salesforce.com/issues_view?id=a1p300000008dVIAAY) report for more details about that.

Don't give up hope, though! All is not lost!

If you use the `Sentry_Exception` class included in this package, you will have stack traces exposed. It requires two steps to work correctly:

1. Extend your custom exception from `Sentry_Exception` instead of `Exception`.
2. Create your exception instances using the `Sentry_ExceptionFactory`.

Here's an example from [Sentry_TestingThrower.cls](force-app/main/default/classes/Sentry_TestingThrower.cls):

```
public with sharing class Sentry_TestingThrower {
    class MyException extends Sentry_Exception {}

    public void throwException() {
        MyException ex = (MyException) Sentry_ExceptionFactory.build(MyException.class);
        ex.setMessage('Something broke.');
        throw ex;
    }
}
```

## Logging

There is an included `Sentry_Log` class with methods for logging Error, Warn, Info, Debug, and Trace messages.

At some point this will get wired up to Sentry's breadcrumbs, to pass additional data through to your Sentry report.

## Testing

Do you have everything configured and ready to go? Open up the `Sentry Testing` tab and click on that `Trigger an exception!` button.

You will see the sort of error you would expect with an uncaught exception being thrown.

Now check Sentry, and you should see an error present!

## Contributing code

Help is definitely welcome! This does the basics, but it could be so much better!

Right now, it seriously needs some tests. Seriously.

The biggest tips I can give you for testing additional development work are:

1. Turn on `Debug` in the `Active Sentry Config` Custom Setting. It will make everything produce a lot more logs.
2. If you're working on something in the `Sentry_Error_Handler`, be sure to go to the Developer Console > Debug > Change Log Levels, and add the Automated Process user in the `User Tracing for All Users` section. The query to find the User Id you need is `SELECT Id FROM User WHERE Name = 'Automated Process'`.

