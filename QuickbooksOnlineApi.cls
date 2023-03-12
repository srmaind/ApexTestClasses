public without sharing class QuickbooksOnlineApi {

    @TestVisible
    private static QuickbooksOnlineAuth__c quickbooksOnlineAuth {get; set;}
    @TestVisible
    private static String state = String.valueOf(Datetime.now().getTime()) + String.valueOf(Math.random());
    @TestVisible
    private static String authorization;

    public QuickbooksOnlineApi() {

    }

    public static void commitAuthToDatabase() {
        update quickbooksOnlineAuth;
    }

    public static void authorize() {
        if (quickbooksOnlineAuth == NULL) {
            quickbooksOnlineAuth = [
                SELECT  Id, TokenEndpoint__c, AccessToken__c, AccessTokenExpiresOn__c, AccessTokenType__c,
                        RefreshTokenExpiresOn__c, RefreshToken__c, GrantTypeRefreshToken__c, ClientId__c,
                        ClientSecret__c, ApiBaseUrl__c, ApiBaseUrlSandbox__c, GrantTypeAuthorizationCode__c,
                        RedirectUri__c, AuthorizationCode__c
                FROM    QuickbooksOnlineAuth__c
                LIMIT    1
            ];
        }
        Datetime now = Datetime.now();
        if (quickbooksOnlineAuth.AccessTokenExpiresOn__c <= now) {
            AccessTokenResponse accessTokenResponse;
            if (quickbooksOnlineAuth.RefreshTokenExpiresOn__c <= now) {
                accessTokenResponse = fetchTokensWithAuthorizationCode();
            } else {
                accessTokenResponse = fetchTokensWithRefreshToken();
            }
            quickbooksOnlineAuth.AccessTokenType__c = accessTokenResponse.token_type;
            quickbooksOnlineAuth.AccessToken__c = accessTokenResponse.access_token;
            quickbooksOnlineAuth.AccessTokenExpiresOn__c = now.addSeconds(accessTokenResponse.expires_in);
            quickbooksOnlineAuth.RefreshToken__c = accessTokenResponse.refresh_token;
            quickbooksOnlineAuth.RefreshTokenExpiresOn__c = now.addSeconds(
                accessTokenResponse.x_refresh_token_expires_in
            );
        }
        authorization = quickbooksOnlineAuth.AccessTokenType__c + ' ' + quickbooksOnlineAuth.AccessToken__c;
    }

    public static String getAuthorizationCode() {
        return [
            SELECT  Id, AuthorizationCode__c
            FROM    QuickbooksOnlineAuth__c
            LIMIT   1
        ].AuthorizationCode__c;
    }

    public static String createAuthorizationGetRequest() {
        quickbooksOnlineAuth = [
            SELECT  Id, AuthorizationEndpoint__c, ClientId__c, ClientSecret__c, Scope__c, RedirectUri__c
            FROM    QuickbooksOnlineAuth__c
            LIMIT   1
        ];
        return quickbooksOnlineAuth.AuthorizationEndpoint__c +
                '?client_id=' + quickbooksOnlineAuth.ClientId__c +
                '&scope=' + quickbooksOnlineAuth.Scope__c +
                '&redirect_uri=' + quickbooksOnlineAuth.RedirectUri__c +
                '&state=' + state +
                '&response_type=code';
    }

    public static void saveAuthorizationCode(Map<String, String> params) {
        if (params != NULL) {
            String code = params.get('code');
            String realmId = params.get('realmId');
            if (code != NULL || realmId != NULL) {
                quickbooksOnlineAuth = [
                    SELECT  Id, ClientId__c, ClientSecret__c, TokenEndpoint__c, RedirectUri__c, AuthorizationCode__c,
                            GrantTypeAuthorizationCode__c, GrantTypeRefreshToken__c
                    FROM    QuickbooksOnlineAuth__c
                    LIMIT   1
                ];
                if (realmId != NULL) {
                    quickbooksOnlineAuth.RealmId__c = realmId;
                }
                if (code != NULL) {
                    quickbooksOnlineAuth.AuthorizationCode__c = code;
                    Datetime now = Datetime.now();
                    AccessTokenResponse accessTokenResponse = fetchTokensWithAuthorizationCode();
                    quickbooksOnlineAuth.AccessTokenType__c = accessTokenResponse.token_type;
                    quickbooksOnlineAuth.AccessToken__c = accessTokenResponse.access_token;
                    quickbooksOnlineAuth.AccessTokenExpiresOn__c = now.addSeconds(accessTokenResponse.expires_in);
                    quickbooksOnlineAuth.RefreshToken__c = accessTokenResponse.refresh_token;
                    quickbooksOnlineAuth.RefreshTokenExpiresOn__c = now.addSeconds(
                        accessTokenResponse.x_refresh_token_expires_in
                    );
                    // accessTokenResponse = fetchTokensWithRefreshToken();

                }
                commitAuthToDatabase();
            }
        }
    }

    public static AccessTokenResponse fetchTokensWithAuthorizationCode() {
        String grantTypeAuthorizationCode = quickbooksOnlineAuth.GrantTypeAuthorizationCode__c;
        String redirectUri = quickbooksOnlineAuth.RedirectUri__c;
        String authorizationCode = quickbooksOnlineAuth.AuthorizationCode__c;
        String body = 'grant_type=' + EncodingUtil.urlEncode(grantTypeAuthorizationCode, 'UTF-8') +
                '&code=' + EncodingUtil.urlEncode(authorizationCode, 'UTF-8') +
                '&redirect_uri=' + EncodingUtil.urlEncode(redirectUri, 'UTF-8');

        HttpRequest req = new HttpRequest();
        req.setEndpoint(quickbooksOnlineAuth.TokenEndpoint__c);
        req.setMethod('POST');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64encode(
            Blob.valueOf(quickbooksOnlineAuth.ClientId__c + ':' + quickbooksOnlineAuth.ClientSecret__c)
        ));
        System.debug('body = ' + body);
        req.setBody(body);
        HttpResponse res = new Http().send(req);
        String responseBody = res.getBody();
        System.debug('responseBody = ' + responseBody);
        AccessTokenResponse accessTokenResponse = (AccessTokenResponse) JSON.deserialize(
            responseBody, AccessTokenResponse.class
        );
        System.debug('accessTokenResponse = ' + JSON.serializePretty(accessTokenResponse));
        return accessTokenResponse;
    }

    public static AccessTokenResponse fetchTokensWithRefreshToken() {
        String grantTypeRefreshToken = quickbooksOnlineAuth.GrantTypeRefreshToken__c;
        String refreshToken = quickbooksOnlineAuth.RefreshToken__c;
        String body = 'grant_type=' + EncodingUtil.urlEncode(grantTypeRefreshToken, 'UTF-8') +
                '&refresh_token=' + EncodingUtil.urlEncode(refreshToken, 'UTF-8');
        System.debug('body = ' + body);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(quickbooksOnlineAuth.TokenEndpoint__c);
        req.setMethod('POST');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64encode(
            Blob.valueOf(quickbooksOnlineAuth.ClientId__c + ':' + quickbooksOnlineAuth.ClientSecret__c)
        ));
        req.setBody(body);
        HttpResponse res = new Http().send(req);
        String responseBody = res.getBody();
        System.debug('responseBody = ' + responseBody);
        AccessTokenResponse accessTokenResponse = (AccessTokenResponse) JSON.deserialize(
            responseBody, AccessTokenResponse.class
        );
        System.debug('accessTokenResponse = ' + JSON.serializePretty(accessTokenResponse));
        return accessTokenResponse;
    }

    public static String getRecordInfo(String realmId, String entityType, String entityId) {
        authorize();
        String baseUrl = quickbooksOnlineAuth.ApiBaseUrlSandbox__c;
        String getRecordInfoUrl = baseUrl + '/company/' + realmId + '/' + entityType + '/' + entityId;
        System.debug('authorization = ' + authorization);
        Http httpObject = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(getRecordInfoUrl);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Authorization', authorization);
        HttpResponse response = httpObject.send(request);
        Integer statusCode = response.getStatusCode();
        String responseBody = response.getBody();

        return responseBody;
    }

    public class AccessTokenResponse {
        public String token_type;
        public Integer expires_in;
        public String refresh_token;
        public Integer x_refresh_token_expires_in;
        public String access_token;
    }
}