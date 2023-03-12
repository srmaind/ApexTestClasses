public with sharing class QuickbooksOnlineAuthController {

    public String authorizationCode {get; set;}

    public QuickbooksOnlineAuthController() {
        getAuthorizationCode();
    }

    private void getAuthorizationCode() {
        authorizationCode = QuickbooksOnlineApi.getAuthorizationCode();
    }

    public PageReference initiateAuthorization() {
        return new PageReference(QuickbooksOnlineApi.createAuthorizationGetRequest());
    }

}