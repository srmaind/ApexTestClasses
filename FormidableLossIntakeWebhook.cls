@RestResource(urlMapping='/loss-intake/*')
global without sharing class FormidableLossIntakeWebhook {

    @HttpPost
    global static String handlePost() {
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        String requestBody = req.requestBody.toString();
        System.debug(requestBody);
        LossIntakeFormEntry lossIntakeFormEntry = (LossIntakeFormEntry) JSON.deserialize(
            requestBody, LossIntakeFormEntry.class
        );
        System.debug('lossIntakeFormEntry = ' + JSON.serializePretty(lossIntakeFormEntry));
        processLossIntakeAsClaim(lossIntakeFormEntry);
        return requestBody;
    }

    private static void processLossIntakeAsClaim(LossIntakeFormEntry lossIntakeFormEntry) {
        Claim__c claim = new Claim__c(
            // OwnerId = '',
            // = lossIntakeFormEntry.entryId,
            // = lossIntakeFormEntry.entryKey
            // = lossIntakeFormEntry.showImage
            // = lossIntakeFormEntry.formName
            // = Date.valueOf(lossIntakeFormEntry.requestDate)
            Stage__c = 'Loss Intake',
            Formidable_Requester_Name__c = lossIntakeFormEntry.requesterName,
            Requester_Phone_and_Ext_donotuse__c = lossIntakeFormEntry.requesterPhone,
            Role_of_Requester__c = lossIntakeFormEntry.roleofRequester,
            Formidable_Insurance_Company__c = lossIntakeFormEntry.insuranceCompany,
            Insurance_Company_Other__c = lossIntakeFormEntry.insuranceCompanyOther,
            Name = lossIntakeFormEntry.claimNumber,
            Loss_Date__c = lossIntakeFormEntry.lossDate == NULL ? NULL : Date.valueOf(lossIntakeFormEntry.lossDate),
            Loss_Damage__c = String.join(lossIntakeFormEntry.lossDamageType.split(', '), ';'),
            Loss_Property_Type__c = lossIntakeFormEntry.lossPropertyType,
            Formidable_Loss_Address__c = lossIntakeFormEntry.address,
            Loss_Description__c = lossIntakeFormEntry.lossDescription,
            Formidable_ACORD__c = lossIntakeFormEntry.uploadAcord,
            ACORD__c = lossIntakeFormEntry.uploadAcord,
            Formidable_Loss_Intake_Photos__c = lossIntakeFormEntry.uploadPhotos,
            Loss_Intake_Photos__c = lossIntakeFormEntry.uploadPhotos,
            InsuredName__c = lossIntakeFormEntry.insuredName1,
            InsuredPhone__c = lossIntakeFormEntry.insuredPhone1,
            InsuredEmail__c = lossIntakeFormEntry.insuredEmail1,
            InsuredName2__c = lossIntakeFormEntry.insuredName2,
            InsuredPhone2__c = lossIntakeFormEntry.insuredPhone2,
            InsuredEmail2__c = lossIntakeFormEntry.insuredEmail2,
            Referred_By__c = lossIntakeFormEntry.referredByName,
            InsuredComments__c = lossIntakeFormEntry.insuredNotes,
            Loss_Address__Street__s = lossIntakeFormEntry.street.trim(),
            Loss_Address__City__s = lossIntakeFormEntry.city,
            Loss_Address__StateCode__s = getStateCode(lossIntakeFormEntry.state),
            Loss_Address__PostalCode__s = lossIntakeFormEntry.zip,
            Loss_Address__CountryCode__s = 'US'
        );

        for (Contact contact : [
            SELECT  Id, Name, Email
            FROM    Contact
            WHERE   Name IN (:lossIntakeFormEntry.requesterName, :lossIntakeFormEntry.referredByName)
            ORDER BY CreatedDate ASC
        ]) {
            if (String.isNotBlank(lossIntakeFormEntry.requesterName)) {
                claim.RequesterName__c = contact.Id;
            }
            if (String.isNotBlank(lossIntakeFormEntry.referredByName)) {
                claim.ReferredByName__c = contact.Id;
            }
        }

        if (claim.RequesterName__c == NULL && String.isNotBlank(lossIntakeFormEntry.requesterName)) {
            Contact requesterContact = new Contact(
                FirstName = lossIntakeFormEntry.requesterName.contains(' ') ? lossIntakeFormEntry.requesterName.substringBeforeLast(' ') : NULL,
                LastName = lossIntakeFormEntry.requesterName.contains(' ') ? lossIntakeFormEntry.requesterName.substringAfterLast(' ') : lossIntakeFormEntry.requesterName,
                Phone = lossIntakeFormEntry.requesterPhone
            );
            insert requesterContact;
            claim.RequesterName__c = requesterContact.Id;
        }
        if (claim.ReferredByName__c == NULL && String.isNotBlank(lossIntakeFormEntry.referredByName)) {
            Contact referrerContact = new Contact(
                FirstName = lossIntakeFormEntry.referredByName.contains(' ') ? lossIntakeFormEntry.referredByName.substringBeforeLast(' ') : NULL,
                LastName = lossIntakeFormEntry.referredByName.contains(' ') ? lossIntakeFormEntry.referredByName.substringAfterLast(' ') : lossIntakeFormEntry.referredByName
            );
            insert referrerContact;
            claim.ReferredByName__c = referrerContact.Id;
        }

        insert claim;
    }

    public static String getStateCode(String stateName) {
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Schema.DescribeFieldResult stateCodeFieldResult = SobjectType.Claim__c.fields.Loss_Address__StateCode__s;

        Schema.DescribeFieldResult control = SobjectType.Claim__c.fields.Loss_Address__CountryCode__s;
        List<Schema.PicklistEntry> controlEntries;
        if(control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }

        for (Schema.PicklistEntry entry : stateCodeFieldResult.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                        String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                            (controlEntries == null
                                    ?   (Object) (index == 1)
                                    :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                            );
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                        continue;
                    if ('US'.equalsIgnoreCase((String) controlValue) || 'United States'.equalsIgnoreCase((String) controlValue)) {
                        if (entry.getLabel() == stateName) {
                            return entry.getValue();
                        }
                    }
                }
            }
        }
        return NULL;
    }

    @HttpGet
    global static String handleGet() {
        return '';
    }

    public class LossIntakeFormEntry {
        public String entryId;	//171
        public String entryKey;	//vhjvo
        public String showImage;	//true
        public String formName;	//Intake Form
        public String requestDate;	//January 26, 2023
        public String requesterName;	//Requester Name
        public String requesterPhone;	//(000) 000-0000 ext 0000000
        public String roleofRequester;	//Independant Agent
        public String insuranceCompany;	//Acuity Insurance
        public String insuranceCompanyOther;	//Other Insurance Company
        public String claimNumber;	//854620
        public String lossDate;	//January 19, 2023
        public String lossDamageType;	//Fire Smoke, Odor, Water, Other Damage Type
        public String lossPropertyType;	//Residential
        public String address;	//Line 1, Line 2, City, Texas, 45646
        public String lossDescription;	//Loss Description
        public String uploadAcord;	//https://biosweeptools.com/testing/frm_file/aWQ6MTExfGZpbGVuYW1lOlBuZ3RyZWXigJRvZmZlci1iYW5uZXItZm9yLXNhbGUtZGlzY291bnRfNjQ2OTYxNy0zLnBuZ3xzaXplOnRodW1ibmFpbA==
        public String uploadPhotos;	//https://biosweeptools.com/testing/frm_file/aWQ6MTEyfGZpbGVuYW1lOm11bGVzb2Z0X2xvZ29faWNvbl8xNzA5MzMtOC5wbmd8c2l6ZTp0aHVtYm5haWw=
        public String insuredName1;	//Insured 1
        public String insuredPhone1;	//(111) 111-1111 ext 1111111
        public String insuredEmail1;	//insured1@mail.com
        public String insuredName2;	//Insured 2
        public String insuredPhone2;	//(222) 222-2222 ext 2222222
        public String insuredEmail2;	//insured2@mail.com
        public String referredByName;	//Referred by
        public String insuredNotes;	//Insured Notes
        public String street;	//Line 1 Line 2
        public String city;	//City
        public String state;	//Texas
        public String zip;	//45646
        public String country;	//
    }

}