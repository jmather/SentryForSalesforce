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
global with sharing class Sentry_Dsn 
{
    global String privateKey;
    global String publicKey;
    global String projectId;
    global Url sentryUrl;
    global Url url;

    global Sentry_Dsn(String dsn) 
    {
        url = new Url(dsn);
        this.publicKey = getPublicKey(url);
        this.privateKey = getPrivateKey(url);
        this.projectId = getProjectId(url);
        this.sentryUrl = new Url('https://sentry.io/api/' + projectId + '/store/');
    }

    String getProjectId(Url url) {
        String[] pieces = url.getPath().split('/');

        if (pieces.size() == 0) {
            return null;
        }

        return pieces[pieces.size() - 1];
    }

    String getPublicKey(Url url) {
        String userInfo = url.getUserInfo();
        if (String.isBlank(userInfo)) {
            return null;
        }

        if (userInfo.contains(':')) {
            return url.getUserInfo().split(':')[0];
        }

        return userInfo;
    }

    String getPrivateKey(Url url) {
        String[] pieces = url.getUserInfo().split(':');

        if (pieces.size() == 2) {
            return pieces[1];
        }

        return null;
    }
}