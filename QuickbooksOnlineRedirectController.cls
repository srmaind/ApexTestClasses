public with sharing class QuickbooksOnlineRedirectController {

    public Map<String, String> params {get; set;}

    public QuickbooksOnlineRedirectController() {

    }

    public PageReference saveAuthorizationCode() {
        params = ApexPages.currentPage().getParameters();
        System.debug('params = ' + JSON.serializePretty(params));
        if (params.containsKey('code') && params.containsKey('realmId')) {
            QuickbooksOnlineApi.saveAuthorizationCode(params);
        }
        return Page.QuickbooksOnlineAuth;
    }

}