@RestResource(urlMapping='/webhook/*')
global without sharing class QuickBooksOnlineWebhook {

    @TestVisible
    private static String authorization;

    @HttpPost
    global static String handlePost() {
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        System.debug(req.requestBody.toString());
        String requestBody = req.requestBody.toString();
        QboWebhookNotif qboNotif = (QboWebhookNotif) JSON.deserialize(requestBody, QboWebhookNotif.class);
        System.debug('qboNotif = ' + JSON.serializePretty(qboNotif));
        QuickbooksOnlineApi.authorize();
        String responseStr = QuickbooksOnlineApi.getRecordInfo(
            qboNotif.eventNotifications[0].realmId,
            qboNotif.eventNotifications[0].dataChangeEvent.entities[0].name.toLowerCase(),
            qboNotif.eventNotifications[0].dataChangeEvent.entities[0].id
        );

        try {
            QuickbooksOnlineApi.commitAuthToDatabase();
        } catch (Exception excp) {
            Database.insert(
                new QBOLog__c(
                    Request__c = requestBody,
                    ErrorDescription__c = excp.getMessage(),
                    ExceptionTypeName__c = excp.getTypeName(),
                    LineNumber__c = excp.getLineNumber(),
                    StackTraceString__c = excp.getStackTraceString()
                ),
                false
            );
        }

        Map<String, Object> mapResponse = (Map<String, Object>) JSON.deserializeUntyped(responseStr);
        System.debug('mapResponse = ' + JSON.serializePretty(mapResponse));
        Object objRecordInfo = mapResponse.get(qboNotif.eventNotifications[0].dataChangeEvent.entities[0].name);
        String recordInfoStr = JSON.serializePretty(objRecordInfo);
        System.debug('recordInfoStr = ' + recordInfoStr);
        // clsRecordInfo recordInfo = (clsRecordInfo) JSON.deserialize(recordInfoStr, clsRecordInfo.class);
        RecordInfo recordInfo = (RecordInfo) JSON.deserialize(responseStr, RecordInfo.class);
        System.debug('recordInfo = ' + JSON.serializePretty(recordInfo));
        switch on qboNotif.eventNotifications[0].dataChangeEvent.entities[0].name {
            when 'Estimate' {
                String claimNumber;
                if (recordInfo.estimate != NULL && recordInfo.estimate.customField != NULL) {
                    for (cls_CustomField customField : recordInfo.estimate.customField) {
                        if (customField.Name == 'Claim Number') {
                            claimNumber = customField.StringValue;
                        }
                    }
                }
                List<Claim__c> claim = [
                    SELECT  Id
                    FROM    Claim__c
                    WHERE   Name = :claimNumber
                ];
                if (!claim.isEmpty()) {
                    List<Estimate__c> estimate = [
                        SELECT  Id
                        FROM    Estimate__c
                        WHERE   Claim__r.Name = :claimNumber
                            AND Id__c = :recordInfo.estimate.Id
                    ];
                    if (estimate.isEmpty()) {
                        estimate.add(new Estimate__c());
                    }
                    estimate[0].Claim__c = claim[0].Id;
                    estimate[0].EstimateNumber__c = recordInfo.estimate.DocNumber;
                    estimate[0].EstimateTotal__c = recordInfo.estimate.TotalAmt;
                    estimate[0].Id__c = recordInfo.estimate.Id;
                    try {
                        upsert estimate;
                    } catch (Exception excp) {
                        Database.insert(
                            new QBOLog__c(
                                Request__c = requestBody,
                                ErrorDescription__c = excp.getMessage(),
                                ExceptionTypeName__c = excp.getTypeName(),
                                LineNumber__c = excp.getLineNumber(),
                                StackTraceString__c = excp.getStackTraceString()
                            ),
                            false
                        );
                    }
                }
            }
            when 'Invoice' {
                String claimNumber;
                if (recordInfo.invoice != NULL && recordInfo.invoice.customField != NULL) {
                    for (cls_CustomField customField : recordInfo.invoice.customField) {
                        if (customField.Name == 'Claim Number') {
                            claimNumber = customField.StringValue;
                        }
                    }
                }
                List<Claim__c> claim = [
                    SELECT  Id
                    FROM    Claim__c
                    WHERE   Name = :claimNumber
                ];
                if (!claim.isEmpty()) {
                    List<Invoice__c> invoice = [
                        SELECT  Id
                        FROM    Invoice__c
                        WHERE   Claim__r.Name = :claimNumber
                            AND Id__c = :recordInfo.invoice.Id
                    ];
                    if (invoice.isEmpty()) {
                        invoice.add(new Invoice__c());
                    }
                    invoice[0].Claim__c = claim[0].Id;
                    invoice[0].InvoiceNumber__c = recordInfo.invoice.DocNumber;
                    invoice[0].InvoiceAmount__c = recordInfo.invoice.TotalAmt;
                    invoice[0].Balance__c = recordInfo.invoice.Balance;
                    invoice[0].InvoiceDate__c = Date.valueOf(recordInfo.invoice.TxnDate);
                    invoice[0].Id__c = recordInfo.invoice.Id;
                    try {
                        upsert invoice;
                    } catch (Exception excp) {
                        Database.insert(
                            new QBOLog__c(
                                Request__c = requestBody,
                                ErrorDescription__c = excp.getMessage(),
                                ExceptionTypeName__c = excp.getTypeName(),
                                LineNumber__c = excp.getLineNumber(),
                                StackTraceString__c = excp.getStackTraceString()
                            ),
                            false
                        );
                    }
                }
            }
            when else {

            }
        }
        return 'success';
    }

    @HttpGet
    global static String handleGet() {
        return 'success';
    }

    public class QboWebhookNotif{
        public cls_eventNotifications[] eventNotifications;
    }

    class cls_eventNotifications {
        public String realmId;	//4620816365266772770
        public cls_dataChangeEvent dataChangeEvent;
    }

    class cls_dataChangeEvent {
        public cls_entities[] entities;
    }

    class cls_entities {
        public String name;	//Customer
        public String id;	//3
        public String operation;	//Update
        public String lastUpdated;	//2023-01-11T14:24:58.000Z
    }

    class clsRecordInfo {
        public String DocNumber;
        public Double TotalAmt;
        public String TxnDate;
        public cls_CustomField[] CustomField;
    }

    public class RecordInfo {
        // public String time;	//2023-02-18T13:11:44.641-08:00
        public cls_Invoice Invoice;
        public cls_Estimate Estimate;
    }

    class cls_Invoice {
        public Double Balance;	//0
        public cls_BillEmail BillEmail;
        public String EmailStatus;	//NotSet
        public String PrintStatus;	//NotSet
        public boolean ApplyTaxAfterDiscount;
        public Double TotalAmt;	//2369.52
        public String DueDate;	//2022-12-28
        public cls_SalesTermRef SalesTermRef;
        public cls_BillAddr BillAddr;
        public cls_CustomerMemo CustomerMemo;
        public cls_CustomerRef CustomerRef;
        public cls_TxnTaxDetail TxnTaxDetail;
        public cls_Line[] Line;
        public cls_LinkedTxn[] LinkedTxn;
        public cls_CurrencyRef CurrencyRef;
        public String TxnDate;	//2022-11-28
        public String DocNumber;	//1004
        public cls_CustomField[] CustomField;
        public cls_MetaData MetaData;
        public String SyncToken;	//15
        public String Id;	//12
        public boolean sparse;
        public String domain;	//QBO
        public boolean AllowOnlineACHPayment;
        public boolean AllowOnlineCreditCardPayment;
        public boolean AllowOnlinePayment;
        public boolean AllowIPNPayment;
    }
    class cls_BillEmail {
        public String Address;	//Cool_Cars@intuit.com
    }
    class cls_SalesTermRef {
        public String name;	//Net 30
        public String value;	//3
    }
    class cls_BillAddr {
        // public String Long;	//-122.4336537
        public String Lat;	//37.4300318
        public String PostalCode;	//94213
        public String CountrySubDivisionCode;	//CA
        public String City;	//Half Moon Bay
        public String Line1;	//65 Ocean Dr.
        public String Id;	//4
    }
    class cls_CustomerMemo {
        public String value;	//Thank you for your business and have a great day!
    }
    class cls_CustomerRef {
        public String name;	//Cool Cars
        public String value;	//3
    }
    class cls_TxnTaxDetail {
        public cls_TaxLine[] TaxLine;
        public Double TotalTax;	//175.52
        public cls_TxnTaxCodeRef TxnTaxCodeRef;
    }
    class cls_TaxLine {
        public cls_TaxLineDetail TaxLineDetail;
        public String DetailType;	//TaxLineDetail
        public Double Amount;	//175.52
    }
    class cls_TaxLineDetail {
        public Double NetAmountTaxable;	//2194
        public Double TaxPercent;	//8
        public boolean PercentBased;
        public cls_TaxRateRef TaxRateRef;
    }
    class cls_TaxRateRef {
        public String value;	//3
    }
    class cls_TxnTaxCodeRef {
        public String value;	//2
    }
    class cls_Line {
        public cls_SalesItemLineDetail SalesItemLineDetail;
        public String DetailType;	//SalesItemLineDetail
        public Double Amount;	//20
        public String Description;	//Sprinkler Heads
        public Double LineNum;	//1
        public String Id;	//1
    }
    class cls_SalesItemLineDetail {
        public cls_TaxCodeRef TaxCodeRef;
        public Double Qty;	//10
        public Double UnitPrice;	//2
        public cls_ItemRef ItemRef;
    }
    class cls_TaxCodeRef {
        public String value;	//TAX
    }
    class cls_ItemRef {
        public String name;	//Landscaping:Sprinklers:Sprinkler Heads
        public String value;	//16
    }
    class cls_LinkedTxn {
        public String TxnType;	//Payment
        public String TxnId;	//120
    }
    class cls_CurrencyRef {
        public String name;	//United States Dollar
        public String value;	//USD
    }
    class cls_CustomField {
        public String StringValue;	//1234
        public String Type;	//StringType
        public String Name;	//Claim Number
        public String DefinitionId;	//1
    }
    class cls_MetaData {
        public String LastUpdatedTime;	//2023-02-18T11:31:38-08:00
        public String CreateTime;	//2022-12-07T15:04:04-08:00
    }

    //
    //Generated by AdminBooster
    //

    class cls_Estimate {
        public cls_BillEmail BillEmail;
        public String EmailStatus;	//NotSet
        public String PrintStatus;	//NeedToPrint
        public boolean ApplyTaxAfterDiscount;
        public Double TotalAmt;	//70
        public cls_ShipAddr ShipAddr;
        public cls_BillAddr BillAddr;
        public cls_CustomerMemo CustomerMemo;
        public cls_CustomerRef CustomerRef;
        public cls_TxnTaxDetail TxnTaxDetail;
        public cls_Line[] Line;
        public cls_LinkedTxn[] LinkedTxn;
        public String TxnStatus;	//Closed
        public cls_CurrencyRef CurrencyRef;
        public String TxnDate;	//2022-12-06
        public String DocNumber;	//1001
        public cls_CustomField[] CustomField;
        public cls_MetaData MetaData;
        public String SyncToken;	//2
        public String Id;	//46
        public boolean sparse;
        public String domain;	//QBO
    }

    class cls_ShipAddr {
        // public String Long;	//INVALID
        public String Lat;	//INVALID
        public String PostalCode;	//94326
        public String CountrySubDivisionCode;	//CA
        public String City;	//Bayshore
        public String Line1;	//500 Red Rock Rd.
        public String Id;	//21
    }
}