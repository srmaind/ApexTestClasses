@RestResource(urlMapping='/scoping/*')
global without sharing class FormidableScopingWebhook {

    @HttpPost
    global static String handlePost() {
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        String requestBody = req.requestBody.toString();
        requestBody = requestBody.replace(',]', ']');
        System.debug('requestBody = ' + requestBody);
        ScopingFormEntry scopingFormEntry = (ScopingFormEntry) JSON.deserialize(
            requestBody, ScopingFormEntry.class
        );
        System.debug('scopingFormEntry = ' + JSON.serializePretty(scopingFormEntry));
        processScopingAsClaim(scopingFormEntry);
        return requestBody;
    }

    private static void processScopingAsClaim(ScopingFormEntry scopingFormEntry) {
        System.debug('scopingFormEntry.claimNumber = ' + scopingFormEntry.claimNumber);
        if (String.isNotBlank(scopingFormEntry.claimNumber)) {
            List<Claim__c> claim = [
                SELECT  Id, Name, Estimator_Name__c
                FROM    Claim__c
                WHERE   Name = :scopingFormEntry.claimNumber
            ];
            if (claim.isEmpty()) {
                return;
            }
            claim[0].Stage__c = 'Scoping';
            // claim[0]. = scopingFormEntry.uniqueId;
            // claim[0].Estimator_Name__c = scopingFormEntry.estimatorName;
            claim[0].Scope_Date__c = Date.valueOf(scopingFormEntry.scopeDate);
            // claim[0]. = scopingFormEntry.scopeTime;
            claim[0].Loss_Property_Type__c = scopingFormEntry.propertyType;
            claim[0].Scope_Type__c = scopingFormEntry.propertyType;
            claim[0].Commercial_Description__c = String.isBlank(scopingFormEntry.buildingUse) ? NULL : scopingFormEntry.buildingUse.trim().removeStart('<p>').removeEnd('</p>');
            claim[0].Fire_Inspector_Released_the_Site__c = scopingFormEntry.fireInspectorReleasedTheSite;
            claim[0].Fire_Inspector_Released_the_Site_Notes__c = String.isBlank(scopingFormEntry.fireInspectorNotes) ? NULL : scopingFormEntry.fireInspectorNotes.trim().removeStart('<p>').removeEnd('</p>');
            claim[0].Odor_Level__c = scopingFormEntry.odorLevel;
            claim[0].Visible_Soot__c = scopingFormEntry.visibleSoot;
            claim[0].Visible_Soot_Notes__c = String.isBlank(scopingFormEntry.odorSootNotes) ? NULL : scopingFormEntry.odorSootNotes.trim().removeStart('<p>').removeEnd('</p>');
            claim[0].Odor_Level_Description__c = String.isBlank(scopingFormEntry.odorSootNotes) ? NULL : scopingFormEntry.odorSootNotes.trim().removeStart('<p>').removeEnd('</p>');
            claim[0].Relative_Humidity__c = scopingFormEntry.relativeHumidity;
            claim[0].Temperature__c = scopingFormEntry.temperature;
            claim[0].Total_CF__c = String.isBlank(scopingFormEntry.totalCubicFootageCF) ? NULL : scopingFormEntry.totalCubicFootageCF.trim().removeStart('<p>').removeEnd('</p>');
            claim[0].Specific_Floor_Dimensions_or_Section_D__c = String.isBlank(scopingFormEntry.specificFloorDimensionsOrSectionDetails) ? NULL : scopingFormEntry.specificFloorDimensionsOrSectionDetails.trim().removeStart('<p>').removeEnd('</p>');
            claim[0].Number_of_floors_Number__c = scopingFormEntry.numberOfFloors;
            // claim[0]. = scopingFormEntry.numberOfFloorsNotes;
            claim[0].Attic_Height__c = String.isBlank(scopingFormEntry.atticHeight) ? NULL : Integer.valueOf(scopingFormEntry.atticHeight);
            claim[0].Attic_Height_Notes__c = String.isBlank(scopingFormEntry.atticHeightNotes) ? NULL : scopingFormEntry.atticHeightNotes.trim().removeStart('<p>').removeEnd('</p>');
            claim[0].Ceiling_Height__c = String.isBlank(scopingFormEntry.ceilingHeight) ? NULL : Integer.valueOf(scopingFormEntry.ceilingHeight);
            claim[0].Ceiling_Height_Notes__c = String.isBlank(scopingFormEntry.ceilingHeightNotes) ? NULL : scopingFormEntry.ceilingHeightNotes.trim().removeStart('<p>').removeEnd('</p>');
            claim[0].Location_and_Source_of_Fire__c = String.isBlank(scopingFormEntry.locationAndSourceOfFire) ? NULL : scopingFormEntry.locationAndSourceOfFire.trim().removeStart('<p>').removeEnd('</p>');
            // claim[0]. = scopingFormEntry.fireDamagedMaterialDetails;
            claim[0].Building_Currently_Occupied__c = 'Yes'.equalsIgnoreCase(scopingFormEntry.buildingOccupied);
            claim[0].Building_Currently_Occupied_Notes__c = String.isBlank(scopingFormEntry.buildingOccupiedNotes) ? NULL : scopingFormEntry.buildingOccupiedNotes.trim().removeStart('<p>').removeEnd('</p>');
            claim[0].Special_Contents__c = String.isBlank(scopingFormEntry.specialContents) ? NULL : scopingFormEntry.specialContents.trim().removeStart('<p>').removeEnd('</p>');
            claim[0].Contents_to_be_Treated__c = 'Yes'.equalsIgnoreCase(scopingFormEntry.contentsToBeTreated);
            claim[0].Contents_to_be_Treated_Notes__c = String.isBlank(scopingFormEntry.contentsTreatmentNotes) ? NULL : scopingFormEntry.contentsTreatmentNotes.trim().removeStart('<p>').removeEnd('</p>');
            claim[0].Restoration_Work_Conducted_to_Date__c = 'Yes'.equalsIgnoreCase(scopingFormEntry.restorationWorkConductedToDate);
            claim[0].Restoration_Work_Conducted_to_Date_Not__c = String.isBlank(scopingFormEntry.restorationWorkConductedNotes) ? NULL : scopingFormEntry.restorationWorkConductedNotes.trim().removeStart('<p>').removeEnd('</p>');
            claim[0].Char_Damage__c = 'Yes'.equalsIgnoreCase(scopingFormEntry.charDamage);
            claim[0].Char_Damage_Notes__c = String.isBlank(scopingFormEntry.charDamageNotes) ? NULL : scopingFormEntry.charDamageNotes.trim().removeStart('<p>').removeEnd('</p>');
            claim[0].Hazardous_Materials_Onsite__c = 'Yes'.equalsIgnoreCase(scopingFormEntry.hazardousMaterialsOnsite);
            claim[0].Hazardous_Materials_Onsite_Notes__c = String.isBlank(scopingFormEntry.hazardousMaterialsOnsiteNotes) ? NULL : scopingFormEntry.hazardousMaterialsOnsiteNotes.trim().removeStart('<p>').removeEnd('</p>');
            claim[0].Underside_Roof_Deck__c = String.isBlank(scopingFormEntry.undersideRoofDeck) ? NULL : scopingFormEntry.undersideRoofDeck.replace(', ', ';');
            claim[0].Underside_Roof_Deck_Notes__c = String.isBlank(scopingFormEntry.undersideRoofDeckNotes) ? NULL : scopingFormEntry.undersideRoofDeckNotes.trim().removeStart('<p>').removeEnd('</p>');
            claim[0].Insulation__c = String.isBlank(scopingFormEntry.insulation) ? NULL : scopingFormEntry.insulation.replace(', ', ';').replace('other ', 'other;');
            claim[0].Insulation_Notes__c = String.isBlank(scopingFormEntry.insulationNotes) ? NULL : scopingFormEntry.insulationNotes.trim().removeStart('<p>').removeEnd('</p>');
            claim[0].Drop_Ceiling__c = 'Yes'.equalsIgnoreCase(scopingFormEntry.dropCeilings);
            claim[0].Drop_Ceiling_Notes__c = String.isBlank(scopingFormEntry.dropCeilingNotes) ? NULL : scopingFormEntry.dropCeilingNotes.trim().removeStart('<p>').removeEnd('</p>');
            claim[0].Smoke_Detectors__c = 'Yes'.equalsIgnoreCase(scopingFormEntry.smokeDetectors);
            claim[0].Smoke_Detectors_Notes__c = String.isBlank(scopingFormEntry.smokeDetectorNotes) ? NULL : scopingFormEntry.smokeDetectorNotes.trim().removeStart('<p>').removeEnd('</p>');
            claim[0].Fire_Suppression_System__c = 'Yes'.equalsIgnoreCase(scopingFormEntry.fireSuppressionSystem);
            claim[0].Fire_Suppression_System_Notes__c = String.isBlank(scopingFormEntry.fireSupressionNotes) ? NULL : scopingFormEntry.fireSupressionNotes.trim().removeStart('<p>').removeEnd('</p>');
            claim[0].Alarm_System__c = 'Yes'.equalsIgnoreCase(scopingFormEntry.alarmSystem);
            claim[0].Alarm_System_Notes__c = String.isBlank(scopingFormEntry.alarmSystemNotes) ? NULL : scopingFormEntry.alarmSystemNotes.trim().removeStart('<p>').removeEnd('</p>');
            claim[0].Uncovered_or_Breached_Openings__c = String.isBlank(scopingFormEntry.uncoveredOrBreachedOpeningsNotes) ? NULL : scopingFormEntry.uncoveredOrBreachedOpeningsNotes.trim().removeStart('<p>').removeEnd('</p>');
            claim[0].Industrial_Hygienist_Report_Available__c = 'Yes'.equalsIgnoreCase(scopingFormEntry.industrialHygienistReportAvailable);
            claim[0].Industrial_Hygienist_Report_Link__c = scopingFormEntry.industrialHygienistReportUpload;
            claim[0].Restoration_Contractor_Report_Available__c = 'Yes'.equalsIgnoreCase(scopingFormEntry.restorationReportAvailable);
            claim[0].Restoration_Report_Upload__c = scopingFormEntry.restorationReportUpload;
            claim[0].Blueprint_or_Site_Drawing_Available__c = 'Yes'.equalsIgnoreCase(scopingFormEntry.blueprintOrSiteDrawingAvailable);
            claim[0].Blueprint_or_Site_Drawing_Upload_Link__c = scopingFormEntry.blueprintOrSiteDrawingUpload;
            claim[0].Water_Available__c = 'Yes'.equalsIgnoreCase(scopingFormEntry.waterAvailable);
            claim[0].Water_Available_Notes__c = String.isBlank(scopingFormEntry.waterAvailableNotes) ? NULL : scopingFormEntry.waterAvailableNotes.trim().removeStart('<p>').removeEnd('</p>');
            // claim[0].Electrical_Panel__c = scopingFormEntry.electricalPanelAccessible;
            claim[0].Electrical_Panel__c = String.isBlank(scopingFormEntry.electricalPanelNotes) ? NULL : scopingFormEntry.electricalPanelNotes.trim().removeStart('<p>').removeEnd('</p>');
            claim[0].Power_Available__c = 'Yes'.equalsIgnoreCase(scopingFormEntry.powerAvailable);
            claim[0].Power_Available_Notes__c = String.isBlank(scopingFormEntry.powerAvailableNotes) ? NULL : scopingFormEntry.powerAvailableNotes.trim().removeStart('<p>').removeEnd('</p>');
            claim[0].HVAC_working__c = 'Yes'.equalsIgnoreCase(scopingFormEntry.hvacWorking);
            claim[0].HVAC_working_Notes__c = String.isBlank(scopingFormEntry.hvacNotes) ? NULL : scopingFormEntry.hvacNotes.trim().removeStart('<p>').removeEnd('</p>');
            claim[0].Ductwork_Intact__c = 'Yes'.equalsIgnoreCase(scopingFormEntry.ductworkIntact);
            claim[0].Ductwork_Intact_Notes__c = String.isBlank(scopingFormEntry.ductworkNotes) ? NULL : scopingFormEntry.ductworkNotes.trim().removeStart('<p>').removeEnd('</p>');
            claim[0].Recommendations__c = String.isBlank(scopingFormEntry.recommendations) ? NULL : scopingFormEntry.recommendations.trim().removeStart('<p>').removeEnd('</p>');
            claim[0].Generator_and_Power_Distribution_Plan__c = String.isBlank(scopingFormEntry.generatorAndPowerDistributionPlan) ? NULL : scopingFormEntry.generatorAndPowerDistributionPlan.trim().removeStart('<p>').removeEnd('</p>');
            claim[0].Supplemental_Heat_Needed__c = 'Yes'.equalsIgnoreCase(scopingFormEntry.supplementalHeatNeeded);
            claim[0].Heat_Excel_Spreadsheet__c = String.isBlank(    scopingFormEntry.heatExcelSpreadsheet) ? NULL : scopingFormEntry.heatExcelSpreadsheet.trim().removeStart('<p>').removeEnd('</p>');
            // claim[0]. = scopingFormEntry.temperatureExpectations;
            claim[0].Temperature_Expectations__c = String.isBlank(scopingFormEntry.temperatureExpectationsNotes) ? NULL : scopingFormEntry.temperatureExpectationsNotes.trim().removeStart('<p>').removeEnd('</p>');
            claim[0].Restoration_Work_needed_before_treatment__c = String.isBlank(scopingFormEntry.restorationWorkNeededBeforeTreatment) ? NULL : scopingFormEntry.restorationWorkNeededBeforeTreatment.trim().removeStart('<p>').removeEnd('</p>');
            claim[0].Containment__c = String.isBlank(scopingFormEntry.containment) ? NULL : scopingFormEntry.containment.trim().removeStart('<p>').removeEnd('</p>');
            claim[0].Building_Access__c = String.isBlank(scopingFormEntry.buildingAccess) ? NULL : scopingFormEntry.buildingAccess.trim().removeStart('<p>').removeEnd('</p>');
            claim[0].Concerns_or_Expectations_of_client_or_in__c = String.isBlank(scopingFormEntry.concernsExpectationsOfClientOrInsured) ? NULL : scopingFormEntry.concernsExpectationsOfClientOrInsured.trim().removeStart('<p>').removeEnd('</p>');
            claim[0].Number_of_Machines__c = String.isBlank(scopingFormEntry.numberOfMachines) ? NULL : Integer.valueOf(scopingFormEntry.numberOfMachines);
            claim[0].CFM__c = String.isBlank(scopingFormEntry.cfm) ? NULL : Integer.valueOf(scopingFormEntry.cfm);
            claim[0].Total_CFM__c = String.isBlank(scopingFormEntry.totalCfm) ? NULL : Integer.valueOf(scopingFormEntry.totalCfm);
            try {
                claim[0].Min_Per_Turn__c = String.isBlank(scopingFormEntry.minPerTurn) ? NULL : Decimal.valueOf(scopingFormEntry.minPerTurn);
            } catch (Exception excp) {}
            // claim[0]. = scopingFormEntry.numberOfTurns;
            claim[0].Total_Treatment_Min__c = scopingFormEntry.totalTreatmentMin;
            try {
                claim[0].Total_Run_Time__c = String.isBlank(scopingFormEntry.totalRunTimeInHours) ? NULL : Decimal.valueOf(scopingFormEntry.totalRunTimeInHours);
            } catch (Exception excp) {}
            claim[0].Scoping_Photos_Upload_Link__c = scopingFormEntry.photosUpload;
            claim[0].Scoping_Report_Upload_Link__c = scopingFormEntry.scopingReportUpload;
            claim[0].Additional_Comments__c = String.isBlank(scopingFormEntry.additionalInformation) ? NULL : scopingFormEntry.additionalInformation.trim().removeStart('<p>').removeEnd('</p>');

            if (scopingFormEntry.attendees != NULL && !scopingFormEntry.attendees.isEmpty()) {
                List<Account> lstAttendeeCompany = new List<Account>();
                List<Contact> lstAttendeeContact = new List<Contact>();
                List<Scope_Attendee__c> lstAttendee = new List<Scope_Attendee__c>();
                Map<String, Id> mapCompanyNameToAccountId = new Map<String, Id>();
                for (Attendee scopeAttendee : scopingFormEntry.attendees) {
                    mapCompanyNameToAccountId.put(scopeAttendee.companyName, NULL);
                }
                for (Account account : [
                    SELECT  Id, Name
                    FROM    Account
                    WHERE   Name IN :mapCompanyNameToAccountId.keySet()
                ]) {
                    mapCompanyNameToAccountId.put(account.Name, account.Id);
                }

                Set<String> setCompanyName = new Set<String>();

                for (String companyName : mapCompanyNameToAccountId.keySet()) {
                    Id companyId = mapCompanyNameToAccountId.get(companyName);
                    if (companyId == NULL) {
                        setCompanyName.add(companyName);
                    }
                }

                if (!setCompanyName.isEmpty()) {
                    for (Account account : [
                        SELECT  Id, Name
                        FROM    Account
                        WHERE   Name IN :setCompanyName
                    ]) {
                        mapCompanyNameToAccountId.put(account.Name, account.Id);
                    }
                }

                for (Attendee scopeAttendee : scopingFormEntry.attendees) {
                    lstAttendeeContact.add(new Contact(
                        AccountId = mapCompanyNameToAccountId.get(scopeAttendee.companyName),
                        FirstName = scopeAttendee.name.contains(' ') ? scopeAttendee.name.substringBeforeLast(' ') : NULL,
                        LastName = scopeAttendee.name.contains(' ') ? scopeAttendee.name.substringAfterLast(' ') : scopeAttendee.name,
                        Title = scopeAttendee.title,
                        Email = scopeAttendee.email,
                        Phone = scopeAttendee.phone
                    ));
                }
                insert lstAttendeeContact;

                for (Contact contact : lstAttendeeContact) {
                    lstAttendee.add(new Scope_Attendee__c(
                        Claim_Number__c = claim[0].Id,
                        Attendee_Contact_name__c = contact.Id
                    ));
                }
                insert lstAttendee;
            }

            for (Contact contact : [
                SELECT  Id, Name, Email
                FROM    Contact
                WHERE   Name IN (:scopingFormEntry.estimatorName)
                ORDER BY CreatedDate DESC
                LIMIT   1
            ]) {
                if (String.isNotBlank(scopingFormEntry.estimatorName)) {
                    claim[0].Estimator_Name__c = contact.Id;
                }
            }

            if (claim[0].Estimator_Name__c == NULL && String.isNotBlank(scopingFormEntry.estimatorName)) {
                Contact estimator = new Contact(
                    FirstName = scopingFormEntry.estimatorName.contains(' ') ? scopingFormEntry.estimatorName.substringBeforeLast(' ') : NULL,
                    LastName = scopingFormEntry.estimatorName.contains(' ') ? scopingFormEntry.estimatorName.substringAfterLast(' ') : scopingFormEntry.estimatorName
                );
                insert estimator;
                claim[0].Estimator_Name__c = estimator.Id;
            }

            System.debug('claim = ' + JSON.serializePretty(claim));
            update claim;
        }

    }

    @HttpGet
    global static String handleGet() {
        return '';
    }

    public class ScopingFormEntry {
        public String entryId;  //171
        public String entryKey; //vhjvo
        public String formName; //Intake Form
        public String claimNumber;  //854620
        public String uniqueId;
        public String estimatorName;
        public String scopeDate;
        public String scopeTime;
        public String propertyType;
        public String buildingUse;
        public String fireInspectorReleasedTheSite;
        public String fireInspectorNotes;
        public String odorLevel;
        public String visibleSoot;
        public String odorSootNotes;
        public String relativeHumidity;
        public String temperature;
        public String totalCubicFootageCF;
        public String specificFloorDimensionsOrSectionDetails;
        public String numberOfFloors;
        public String numberOfFloorsNotes;
        public String atticHeight;
        public String atticHeightNotes;
        public String ceilingHeight;
        public String ceilingHeightNotes;
        public String locationAndSourceOfFire;
        public String fireDamagedMaterialDetails;
        public String buildingOccupied;
        public String buildingOccupiedNotes;
        public String specialContents;
        public String contentsToBeTreated;
        public String contentsTreatmentNotes;
        public String restorationWorkConductedToDate;
        public String restorationWorkConductedNotes;
        public String charDamage;
        public String charDamageNotes;
        public String hazardousMaterialsOnsite;
        public String hazardousMaterialsOnsiteNotes;
        public String undersideRoofDeck;
        public String undersideRoofDeckNotes;
        public String insulation;
        public String insulationNotes;
        public String dropCeilings;
        public String dropCeilingNotes;
        public String smokeDetectors;
        public String smokeDetectorNotes;
        public String fireSuppressionSystem;
        public String fireSupressionNotes;
        public String alarmSystem;
        public String alarmSystemNotes;
        public String uncoveredOrBreachedOpeningsNotes;
        public String industrialHygienistReportAvailable;
        public String industrialHygienistReportUpload;
        public String restorationReportAvailable;
        public String restorationReportUpload;
        public String blueprintOrSiteDrawingAvailable;
        public String blueprintOrSiteDrawingUpload;
        public String waterAvailable;
        public String waterAvailableNotes;
        public String electricalPanelAccessible;
        public String electricalPanelNotes;
        public String powerAvailable;
        public String powerAvailableNotes;
        public String hvacWorking;
        public String hvacNotes;
        public String ductworkIntact;
        public String ductworkNotes;
        public String recommendations;
        public String generatorAndPowerDistributionPlan;
        public String supplementalHeatNeeded;
        public String heatExcelSpreadsheet;
        public String temperatureExpectations;
        public String temperatureExpectationsNotes;
        public String restorationWorkNeededBeforeTreatment;
        public String containment;
        public String buildingAccess;
        public String concernsExpectationsOfClientOrInsured;
        public String numberOfMachines;
        public String cfm;
        public String totalCfm;
        public String minPerTurn;
        public String numberOfTurns;
        public String totalTreatmentMin;
        public String totalRunTimeInHours;
        public String photosUpload;
        public String scopingReportUpload;
        public String additionalInformation;
        public Attendee[] attendees;
    }

    public class Attendee {
        public String id; //319,
        public String name; //"Attendee1",
        public String title; //"attendee1",
        public String companyName; //"Company 1",
        public String phone; //"(111) 111-1111ext 1111111",
        public String email; //"attendee1@mail.com"
    }

}