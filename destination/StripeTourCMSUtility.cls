global without sharing class StripeTourCMSUtility
{
    public StripeTourUtility stripeTourUtil;
    public EEG_SiteProperties siteProperty {get;set;}
    public EEG_RegistrationUtility eegRegistrationUtility;
    public String eventRoadshowRecId {get;set;}
    public String eventRecId {get;set;}
    public Boolean invalidRegistrationError {get;set;}
    public Boolean isCurrentRoadshowRegistrationNotOpened {get;set;}
    public Boolean isCurrentRoadshowRegistrationClosed {get;set;}
    public String eventRoadshowName {get;set;}
    public String eventRoadshowDveName {get;set;}
    public String utmParamString {get;set;}
    public Boolean hideAgendaSection {get;set;}
    public Boolean hideSpeakersSection {get;set;}
    public Boolean hideSponsorsSection {get;set;}
    // Case Number 00096347
    Boolean isRegBackDoorEnabled;

    // Case Number 00097224/00098140
    public String eventRoadshowSplashMessage {get;set;}
    public String eventRoadshowSplashMessage2 {get;set;}

    // Case Number 00097276
    String regionBackDoorParam;
    Boolean isRegionBackDoorEnabed;

    // As Per Case 99545
    public Boolean isRegistrationCapacisssssyyyyyyyyyyyyyyyyyyzzzzzzzzzzzzzztyReached{get;set;}

    // As Per Case 99545
    public String eventRoadshowCapacityReachedMessage {get;set;}
    public String eventRoadshowCapacityReachedMessage2 {get;set;}

    public StripeTourCMSUtility()
    {
        stripeTourUtil = new StripeTourUtility();
        siteProperty = stripeTourUtil.siteProperty;
        eegRegistrationUtility = new EEG_RegistrationUtility();
        invalidRegistrationError = false;
        isCurrentRoadshowRegistrationNotOpened = false;
        isCurrentRoadshowRegistrationClosed = false;
        utmParamString = '';
        hideAgendaSection = false;
        hideSpeakersSection = false;
        hideSponsorsSection = false;

        eventRecId = siteProperty.EVENT_ID;
        eventRoadshowDveName = eegRegistrationUtility.returnParamValue('rshow');
        utmParamString = stripeTourUtil.createUTMParamString();
        isRegBackDoorEnabled = false;
        isRegionBackDoorEnabed = false;
        isRegistrationCapacityReached = false;

        if(String.isNotBlank(eventRoadshowDveName))
        {
            // Case Number 00096347
            String regBackDoorParam = eegRegistrationUtility.returnParamValue('showallrshowreg');
            isRegBackDoorEnabled = (String.isNotBlank(regBackDoorParam) && regBackDoorParam.equalsIgnoreCase('true'));

            if(isRegBackDoorEnabled)
            {
                if(String.isNotBlank(utmParamString)){
                    utmParamString = utmParamString + '&showallrshowreg=' + regBackDoorParam;
                }
                else {
                    utmParamString = 'showallrshowreg=' + regBackDoorParam;
                }
            }

            // Case Number 00097276
            regionBackDoorParam = eegRegistrationUtility.returnParamValue('allowregion');
            if(String.isNotBlank(regionBackDoorParam))
            {
                if(String.isNotBlank(utmParamString)){
                    utmParamString = utmParamString + '&allowregion=' + regionBackDoorParam;
                }
                else {
                    utmParamString = 'allowregion=' + regionBackDoorParam;
                }

                regionBackDoorParam = eegRegistrationUtility.decode(regionBackDoorParam);
            }

            Event_Roadshow_Setting__c eventRoadshowRecord = stripeTourUtil.getEventRoadshowSettingById(eventRoadshowDveName, eventRecId);

            if(eventRoadshowRecord != null && eventRoadshowRecord.Id != null)
            {
                Datetime currentDateTime = Datetime.now();

                eventRoadshowName = eventRoadshowRecord.Name;
                eventRoadshowRecId = eventRoadshowRecord.Id;
                // As Per Case 99545 we are using the "Event_Roadshow_Setting__c.Event_Registration_Close_Error_Message__c" <AND> "Event_Roadshow_Setting__c.Event_Registration_Close_Error_Message_1__c" fields for displaying the registration close message instead of "Event_Roadshow_Setting__c.Splash_Message__c" <AND> "Event_Roadshow_Setting__c.Splash_Message_2__c" fields.
                /*eventRoadshowSplashMessage = eventRoadshowRecord.Splash_Message__c;
                eventRoadshowSplashMessage2 = eventRoadshowRecord.Splash_Message_2__c;*/
                eventRoadshowSplashMessage = eventRoadshowRecord.Event_Registration_Close_Error_Message__c;
                eventRoadshowSplashMessage2 = eventRoadshowRecord.Event_Registration_Close_Error_Message_1__c;
                hideAgendaSection = eventRoadshowRecord.Hide_Section_1__c;
                hideSpeakersSection = eventRoadshowRecord.Hide_Section_2__c;
                hideSponsorsSection = eventRoadshowRecord.Hide_Section_3__c;
                isRegionBackDoorEnabed = (String.isNotBlank(regionBackDoorParam) && regionBackDoorParam.equalsIgnoreCase(eventRoadshowRecord.Registration_Backdoor_Value__c));
                isCurrentRoadshowRegistrationNotOpened = (eventRoadshowRecord.Event_Registration_Start_Date__c != null && eventRoadshowRecord.Event_Registration_Start_Date__c > currentDateTime && !isRegBackDoorEnabled && !isRegionBackDoorEnabed);
                isCurrentRoadshowRegistrationClosed = (eventRoadshowRecord.Event_Registration_Close_Date__c != null && eventRoadshowRecord.Event_Registration_Close_Date__c <= currentDateTime && !isRegBackDoorEnabled && !isRegionBackDoorEnabed);

                // As Per Case 99545
                isRegistrationCapacityReached = (!isRegionBackDoorEnabed && stripeTourUtil.isRegistrationCapacityReached(eventRecId, eventRoadshowRecId, eventRoadshowRecord.Capacity__c));
                eventRoadshowCapacityReachedMessage = eventRoadshowRecord.Splash_Message__c;
                eventRoadshowCapacityReachedMessage2 = eventRoadshowRecord.Splash_Message_2__c;
            }
            else {
                invalidRegistrationError = true;
            }
        }
        else {
            invalidRegistrationError = true;
        }
    }

    global class CMSStaticPageWithLocalizationWrapper
    {
        public String id {get;set;}
        public Boolean isActive {get;set;}
        public String content1 {get;set;}
        public String content2 {get;set;}
        public String description {get;set;}
        public String sectionType {get;set;}
        public String sectionName {get;set;}
        public String subSectionName {get;set;}
        public String AWSCloudFrontImageFileName {get;set;}
        public String whoCanSee {get;set;}
        public String name {get;set;}
        public Integer orderOfDisplay {get;set;}
        public String speaker1Name {get;set;}
        public String speaker1Title {get;set;}
        public String speaker1Bio {get;set;}
        public String speaker1Image {get;set;}
        public String speaker2Name {get;set;}
        public String speaker2Title {get;set;}
        public String speaker2Bio {get;set;}
        public String speaker2Image {get;set;}
        public String infoText {get;set;}
        public String infoTime {get;set;}
        public String infoEmail {get;set;}
        public String infoPhoneNumber1 {get;set;}
        public String infoPhoneNumber2 {get;set;}
        public String infoLocation {get;set;}
        public Double geoMapLocationLatitude {get;set;}
        public Double geoMapLocationLongitude {get;set;}
        public String infoHeader1 {get;set;}
        public String infoHeader2 {get;set;}
        public String infoHeader3 {get;set;}
        // As Per Case 99545
        public String content1Text {get;set;}

        public Map<String, CMSStaticPageLocalizationWrapper> mapOfCMSLocalizationWrap {get;set;}
        public List<CMSSpeakerWithLocalizationWrapper> listCMSSpeakerWithLocalizationWrap {get;set;}

        public CMSStaticPageWithLocalizationWrapper(CMS_Static_Page__c cms)
        {
            if(cms != null && cms.Id != null)
            {
                this.id = cms.Id;
                this.isActive = cms.Is_Active__c;
                this.content1 = cms.Content_1__c;
                this.content2 = cms.Content_2__c;
                this.description = cms.Description__c;
                this.sectionType = cms.Section_Type__c;
                this.sectionName = cms.Section_Name__c;
                this.subSectionName = cms.Sub_Section_Name__c;
                this.AWSCloudFrontImageFileName = cms.AWS_Cloud_Front_Image_File_Name__c;
                this.whoCanSee = cms.Who_Can_See__c;
                this.name = cms.Name__c;
                this.orderOfDisplay = (Integer) cms.Order_of_Display__c;
                this.speaker1Name = cms.Speaker_Name__c;
                this.speaker1Title = cms.Speaker_Title__c;
                this.speaker1Bio = cms.Speaker_Bio__c;
                this.speaker1Image = cms.Speaker_Image__c;
                this.speaker2Name = cms.Speaker_Name_2__c;
                this.speaker2Title = cms.Speaker_Title_2__c;
                this.speaker2Bio = cms.Speaker_Bio_2__c;
                this.speaker2Image = cms.Speaker_Image_2__c;
                this.infoText = cms.Info_Text__c;
                this.infoTime = cms.Info_Time__c;
                this.infoEmail = cms.Info_Email__c;
                this.infoPhoneNumber1 = cms.Info_Phone_Number_1__c;
                this.infoPhoneNumber2 = cms.Info_Phone_Number_2__c;
                this.infoLocation = cms.Info_Location__c;
                this.infoHeader1 = cms.Info_Header_1__c;
                this.infoHeader2 = cms.Info_Header_2__c;
                this.infoHeader3 = cms.Info_Header_3__c;
                this.content1Text = cms.Content_1_Text__c;

                if(cms.Geo_Map_Location__c != null)
                {
                    Location loc = cms.Geo_Map_Location__c;
                    this.geoMapLocationLatitude = loc.latitude;
                    this.geoMapLocationLongitude = loc.longitude;
                }

                if(cms.CMS_Static_Page_Localizations__r != null && cms.CMS_Static_Page_Localizations__r.size() > 0)
                {
                    this.mapOfCMSLocalizationWrap = new Map<String, CMSStaticPageLocalizationWrapper>();

                    for (CMS_Static_Page_Localization__c cmslz : cms.CMS_Static_Page_Localizations__r)
                    {
                        this.mapOfCMSLocalizationWrap.put(cmslz.Language__c, new CMSStaticPageLocalizationWrapper(cmslz));
                    }
                }
            }
        }

        public CMSStaticPageWithLocalizationWrapper(CMS_Static_Page__c cms, List<CMS_Speaker__c> listOfCMSSpkr)
        {
            if(cms != null && cms.Id != null)
            {
                this.id = cms.Id;
                this.isActive = cms.Is_Active__c;
                this.content1 = cms.Content_1__c;
                this.content2 = cms.Content_2__c;
                this.description = cms.Description__c;
                this.sectionType = cms.Section_Type__c;
                this.sectionName = cms.Section_Name__c;
                this.subSectionName = cms.Sub_Section_Name__c;
                this.AWSCloudFrontImageFileName = cms.AWS_Cloud_Front_Image_File_Name__c;
                this.whoCanSee = cms.Who_Can_See__c;
                this.name = cms.Name__c;
                this.orderOfDisplay = (Integer) cms.Order_of_Display__c;
                this.speaker1Name = cms.Speaker_Name__c;
                this.speaker1Title = cms.Speaker_Title__c;
                this.speaker1Bio = cms.Speaker_Bio__c;
                this.speaker1Image = cms.Speaker_Image__c;
                this.speaker2Name = cms.Speaker_Name_2__c;
                this.speaker2Title = cms.Speaker_Title_2__c;
                this.speaker2Bio = cms.Speaker_Bio_2__c;
                this.speaker2Image = cms.Speaker_Image_2__c;
                this.infoText = cms.Info_Text__c;
                this.infoTime = cms.Info_Time__c;
                this.infoEmail = cms.Info_Email__c;
                this.infoPhoneNumber1 = cms.Info_Phone_Number_1__c;
                this.infoPhoneNumber2 = cms.Info_Phone_Number_2__c;
                this.infoLocation = cms.Info_Location__c;
                this.infoHeader1 = cms.Info_Header_1__c;
                this.infoHeader2 = cms.Info_Header_2__c;
                this.infoHeader3 = cms.Info_Header_3__c;
                this.content1Text = cms.Content_1_Text__c;

                if(cms.Geo_Map_Location__c != null)
                {
                    Location loc = cms.Geo_Map_Location__c;
                    this.geoMapLocationLatitude = loc.latitude;
                    this.geoMapLocationLongitude = loc.longitude;
                }

                if(cms.CMS_Static_Page_Localizations__r != null && cms.CMS_Static_Page_Localizations__r.size() > 0)
                {
                    this.mapOfCMSLocalizationWrap = new Map<String, CMSStaticPageLocalizationWrapper>();

                    for (CMS_Static_Page_Localization__c cmslz : cms.CMS_Static_Page_Localizations__r)
                    {
                        this.mapOfCMSLocalizationWrap.put(cmslz.Language__c, new CMSStaticPageLocalizationWrapper(cmslz));
                    }
                }

                if(listOfCMSSpkr != null && listOfCMSSpkr.size() > 0)
                {
                    this.listCMSSpeakerWithLocalizationWrap = new List<CMSSpeakerWithLocalizationWrapper>();

                    for (CMS_Speaker__c cmsspkrwl : listOfCMSSpkr)
                    {
                        this.listCMSSpeakerWithLocalizationWrap.add(new CMSSpeakerWithLocalizationWrapper(cmsspkrwl));
                    }
                }
            }
        }
    }

    global class CMSStaticPageLocalizationWrapper
    {
        public String id {get;set;}
        public Boolean isActive {get;set;}
        public String content1 {get;set;}
        public String content2 {get;set;}
        public String description {get;set;}
        public String sectionName {get;set;}
        public String name {get;set;}
        public String language {get;set;}
        public String infoText {get;set;}
        public String infoTime {get;set;}
        public String infoLocation {get;set;}
        public String infoHeader1 {get;set;}
        public String infoHeader2 {get;set;}
        public String infoHeader3 {get;set;}
        // As Per Case 99545
        public String content1Text {get;set;}

        public CMSStaticPageLocalizationWrapper(CMS_Static_Page_Localization__c cmsl)
        {
            this.id = cmsl.Id;
            this.isActive = cmsl.Is_Active__c;
            this.content1 = cmsl.Content_1__c;
            this.content2 = cmsl.Content_2__c;
            this.description = cmsl.Description__c;
            this.sectionName = cmsl.Section_Name__c;
            this.name = cmsl.Name__c;
            this.language = cmsl.Language__c;
            this.infoText = cmsl.Info_Text__c;
            this.infoTime = cmsl.Info_Time__c;
            this.infoLocation = cmsl.Info_Location__c;
            this.infoHeader1 = cmsl.Info_Header_1__c;
            this.infoHeader2 = cmsl.Info_Header_2__c;
            this.infoHeader3 = cmsl.Info_Header_3__c;
            this.content1Text = cmsl.Content_1_Text__c;
        }
    }

    global class CMSSpeakerWithLocalizationWrapper
    {
        public String spkrId {get;set;}
        public String spkrFirstName {get;set;}
        public String spkrLastName {get;set;}
        public String spkrTitle {get;set;}
        public String spkrBio {get;set;}
        public String spkrImage {get;set;}
        public String spkrDescription {get;set;}
        public String spkrCompany {get;set;}
        public String spkrCompanyLogoUrl {get;set;}
        public String spkrCompanyUrl {get;set;}
        public String spkrTwitterUrl {get;set;}
        public String spkrLinkedInUrl {get;set;}
        public Integer spkrOrderOfDisaplay {get;set;}
        public Boolean spkrIsActive {get;set;}
        public Map<String, CMSSpeakerLocalizationWrapper> mapOfCMSSpeakerLocalizationWrap {get;set;}

        public CMSSpeakerWithLocalizationWrapper(CMS_Speaker__c cmsspkr)
        {
            this.spkrId = cmsspkr.Id;
            this.spkrFirstName = cmsspkr.First_Name__c;
            this.spkrLastName = cmsspkr.Last_Name__c;
            this.spkrTitle = cmsspkr.Title__c;
            this.spkrBio = cmsspkr.Biography__c;
            this.spkrImage = cmsspkr.Speaker_Image__c;
            this.spkrDescription = cmsspkr.Description__c;
            this.spkrCompany = cmsspkr.Company__c;
            this.spkrCompanyLogoUrl = cmsspkr.Company_Logo_URL__c;
            this.spkrCompanyUrl = cmsspkr.Company_URL__c;
            this.spkrTwitterUrl = cmsspkr.Twitter__c;
            this.spkrLinkedInUrl = cmsspkr.LinkedIn__c;
            this.spkrOrderOfDisaplay = (Integer) cmsspkr.Order_Of_Display__c;
            this.spkrIsActive = cmsspkr.Is_Active__c;

            if(cmsspkr.CMS_Speaker_Localizations__r != null && cmsspkr.CMS_Speaker_Localizations__r.size() > 0)
            {
                this.mapOfCMSSpeakerLocalizationWrap = new Map<String, CMSSpeakerLocalizationWrapper>();

                for (CMS_Speaker_Localization__c cmsspkrlz : cmsspkr.CMS_Speaker_Localizations__r)
                {
                    this.mapOfCMSSpeakerLocalizationWrap.put(cmsspkrlz.Language__c, new CMSSpeakerLocalizationWrapper(cmsspkrlz));
                }
            }
        }
    }

    global class CMSSpeakerLocalizationWrapper
    {
        public String spkrId {get;set;}
        public String spkrFirstName {get;set;}
        public String spkrLastName {get;set;}
        public String spkrTitle {get;set;}
        public String spkrBio {get;set;}
        public String spkrDescription {get;set;}
        public Boolean spkrIsActive {get;set;}
        public String language {get;set;}
        // Case Number 00097988
        public String spkrCompany {get;set;}

        public CMSSpeakerLocalizationWrapper(CMS_Speaker_Localization__c cmsspkrl)
        {
            this.spkrId = cmsspkrl.Id;
            this.spkrFirstName = cmsspkrl.First_Name__c;
            this.spkrLastName = cmsspkrl.Last_Name__c;
            this.spkrTitle = cmsspkrl.Title__c;
            this.spkrBio = cmsspkrl.Biography__c;
            this.spkrDescription = cmsspkrl.Description__c;
            this.spkrIsActive = cmsspkrl.Is_Active__c;
            this.language = cmsspkrl.Language__c;
            this.spkrCompany = cmsspkrl.Company__c;
        }
    }

    global static List<CMS_Static_Page__c> getListOfCMSStaticPageRecordsWithLocalization(String eventId, String eventRoadshowId, String additionalQuery, Boolean isWithLocalization, Boolean isActive)
    {
        if(String.isNotBlank(eventId))
        {
            eventId = String.escapeSingleQuotes(eventId);

            if(String.isNotBlank(eventRoadshowId)){
                eventRoadshowId = String.escapeSingleQuotes(eventRoadshowId);
            }

            additionalQuery = String.isNotBlank(additionalQuery) ? ' AND ' + additionalQuery : '';

            String CMSStaticPageLocalizationQueryString = ' ';

            if(isWithLocalization != null && isWithLocalization)
            {
                CMSStaticPageLocalizationQueryString = ' , (SELECT Id, Is_Active__c, Content_1__c, Content_2__c, Description__c, Section_Name__c, Name__c, Language__c, Info_Text__c, Info_Time__c, Info_Location__c, Info_Header_1__c, Info_Header_2__c, Info_Header_3__c, Content_1_Text__c FROM CMS_Static_Page_Localizations__r WHERE Is_Active__c =: isActive AND Language__c != null) ';
            }

            String SOQLQueryString = 'SELECT Id, Is_Active__c, Content_1__c, Content_2__c, Description__c, Section_Type__c, Section_Name__c, Sub_Section_Name__c, AWS_Cloud_Front_Image_File_Name__c, Who_Can_See__c, Name__c, Order_of_Display__c, Speaker_Name__c, Speaker_Title__c, Speaker_Bio__c, Speaker_Image__c, Speaker_Name_2__c, Speaker_Title_2__c, Speaker_Bio_2__c, Speaker_Image_2__c, Info_Text__c, Info_Time__c, Info_Email__c, Info_Phone_Number_1__c, Info_Phone_Number_2__c, Info_Location__c, Geo_Map_Location__c, Info_Header_1__c, Info_Header_2__c, Info_Header_3__c, Content_1_Text__c ' + CMSStaticPageLocalizationQueryString + 'FROM CMS_Static_Page__c WHERE Event__c =: eventId AND Event_Roadshow_Setting__c =: eventRoadshowId AND Is_Active__c =: isActive ' + additionalQuery;

            return Database.query(SOQLQueryString);
        }

        return new List<CMS_Static_Page__c>();
    }

    global static Map<String, List<CMS_Speaker__c>> getMapOfCMSSpeakersWithLocalization(String eventId, String eventRoadshowId, Boolean isWithLocalization, Boolean isActive)
    {
        Map<String, List<CMS_Speaker__c>> mapOfCMSSpeakersWithLocalizationRec = new Map<String, List<CMS_Speaker__c>>();

        if(String.isNotBlank(eventId))
        {
            eventId = String.escapeSingleQuotes(eventId);

            if(String.isNotBlank(eventRoadshowId)){
                eventRoadshowId = String.escapeSingleQuotes(eventRoadshowId);
            }

            String CMSSpeakersLocalizationQueryString = ' ';

            if(isWithLocalization != null && isWithLocalization)
            {
                CMSSpeakersLocalizationQueryString = ' , (SELECT Id, First_Name__c, Last_Name__c, Title__c, Biography__c, Description__c, Is_Active__c, Language__c, Company__c FROM CMS_Speaker_Localizations__r WHERE Is_Active__c =: isActive AND Language__c != null) ';
            }

            String SOQLQueryString = 'SELECT Id, First_Name__c, Last_Name__c, Title__c, Biography__c, Speaker_Image__c, Description__c, Company__c, Company_Logo_URL__c, Company_URL__c, Twitter__c, LinkedIn__c, Order_Of_Display__c, Is_Active__c, CMS_Static_Page__c' + CMSSpeakersLocalizationQueryString + 'FROM CMS_Speaker__c WHERE EventID__c =: eventId AND Event_Roadshow_Setting__c =: eventRoadshowId AND Is_Active__c =: isActive AND CMS_Static_Page__c != null ORDER BY Order_of_Display__c ASC NULLS FIRST';

            List<CMS_Speaker__c> listOfCMSSpkrWithLocalization = Database.query(SOQLQueryString);

            if(listOfCMSSpkrWithLocalization != null && listOfCMSSpkrWithLocalization.size() > 0)
            {
                for (CMS_Speaker__c spkr : listOfCMSSpkrWithLocalization)
                {
                    if(mapOfCMSSpeakersWithLocalizationRec != null && mapOfCMSSpeakersWithLocalizationRec.size() > 0 && mapOfCMSSpeakersWithLocalizationRec.containsKey(spkr.CMS_Static_Page__c))
                    {
                        List<CMS_Speaker__c> listSpkrs = mapOfCMSSpeakersWithLocalizationRec.get(spkr.CMS_Static_Page__c);
                        listSpkrs.add(spkr);
                        mapOfCMSSpeakersWithLocalizationRec.put(spkr.CMS_Static_Page__c, listSpkrs);
                    }
                    else
                    {
                        mapOfCMSSpeakersWithLocalizationRec.put(spkr.CMS_Static_Page__c, new List<CMS_Speaker__c>{spkr});
                    }
                }
            }
        }

        return mapOfCMSSpeakersWithLocalizationRec;
    }

    global static List<CMSStaticPageWithLocalizationWrapper> parseListOfCMSStaticPageRecordsWithLocalizationToWrapperList(List<CMS_Static_Page__c> listOfCMSStaticPageRecords, Map<String, List<CMS_Speaker__c>> mapOfCMSSpkrsWithLocalization, String whoCanSee, Boolean isAllCMSStaticPageReocrds)
    {
        List<CMSStaticPageWithLocalizationWrapper> listOfCMSStaticPageWithLocalizationWrap = new List<CMSStaticPageWithLocalizationWrapper>();

        try
        {
            if(listOfCMSStaticPageRecords != null && listOfCMSStaticPageRecords.size() > 0)
            {
                /* If the whoCanSee is blank then we display the CMS records which has whoCanSee value 'None' */
                whoCanSee = String.isNotBlank(whoCanSee) ? whoCanSee.toLowerCase() : 'none';

                for(CMS_Static_Page__c cms : listOfCMSStaticPageRecords)
                {
                    List<String> listWhoCanSee = new List<String>();
                    if(cms.Who_Can_See__c != null){
                        listWhoCanSee = cms.Who_Can_See__c.toLowerCase().split(';');
                    }

                    /*
                        For Admin and Editor users we need to display all CMS records <AND>
                        if the CMS record's whoCanSee == All we need do display those records to all users expect whoCanSee == null users.
                        So we have add all the records to the list wrapper
                    */
                    if(mapOfCMSSpkrsWithLocalization != null && mapOfCMSSpkrsWithLocalization.size() > 0 && mapOfCMSSpkrsWithLocalization.containsKey(cms.Id))
                    {
                        if(isAllCMSStaticPageReocrds || listWhoCanSee.contains('all')){
                            listOfCMSStaticPageWithLocalizationWrap.add(new CMSStaticPageWithLocalizationWrapper(cms, mapOfCMSSpkrsWithLocalization.get(cms.Id)));
                        }
                        /* If the whoCanSee is not blank then we display the CMS records which has same whoCanSee value */
                        else if(String.isNotBlank(whoCanSee) && listWhoCanSee.contains(whoCanSee)){
                            listOfCMSStaticPageWithLocalizationWrap.add(new CMSStaticPageWithLocalizationWrapper(cms, mapOfCMSSpkrsWithLocalization.get(cms.Id)));
                        }
                    }
                    else
                    {
                        if(isAllCMSStaticPageReocrds || listWhoCanSee.contains('all')){
                            listOfCMSStaticPageWithLocalizationWrap.add(new CMSStaticPageWithLocalizationWrapper(cms));
                        }
                        /* If the whoCanSee is not blank then we display the CMS records which has same whoCanSee value */
                        else if(String.isNotBlank(whoCanSee) && listWhoCanSee.contains(whoCanSee)){
                            listOfCMSStaticPageWithLocalizationWrap.add(new CMSStaticPageWithLocalizationWrapper(cms));
                        }
                    }
                }
            }
        }
        catch(Exception e)
        {
            System.debug('Exception parseListOfCMSStaticPageRecordsWithLocalizationToWrapperList ----> '+ e.getMessage());
        }

        return listOfCMSStaticPageWithLocalizationWrap;
    }

    @RemoteAction
    global static Map<String, List<CMSStaticPageWithLocalizationWrapper>> getListOfCMSStaticPageWrapperWithLocalizationByEventId(String eventId, String eventRoadshowId)
    {
        Map<String, List<CMSStaticPageWithLocalizationWrapper>> listOfCMSStaticPageWrapperWithLocalizationMap = new Map<String, List<CMSStaticPageWithLocalizationWrapper>>();

        try
        {
            if(String.isNotBlank(eventId))
            {
                List<CMS_Static_Page__c> listOfCMSPageWithLocalization = getListOfCMSStaticPageRecordsWithLocalization(eventId, eventRoadshowId, 'Section_Type__c != null ORDER BY Order_of_Display__c ASC NULLS FIRST', true, true);
                Map<String, List<CMS_Speaker__c>> mapOfCMSSpkrsWithLocalization = getMapOfCMSSpeakersWithLocalization(eventId, eventRoadshowId, true, true);

                listOfCMSStaticPageWrapperWithLocalizationMap =  generateMapOfCMSStaticPageWithLocalizationWrapper(parseListOfCMSStaticPageRecordsWithLocalizationToWrapperList(listOfCMSPageWithLocalization, mapOfCMSSpkrsWithLocalization, 'All', false));
            }
        }
        catch(Exception e)
        {
            System.debug('Exception getListOfCMSStaticPageWrapperWithLocalizationByEventId ----> '+ e.getMessage());
        }

        return listOfCMSStaticPageWrapperWithLocalizationMap;
    }

    global static List<CMS_Speaker__c> getListOfCMSSpeakersWithLocalization(String eventId, String eventRoadshowId, String additionalQuery, Boolean isWithLocalization, Boolean isActive)
    {
        if(String.isNotBlank(eventId))
        {
            eventId = String.escapeSingleQuotes(eventId);

            if(String.isNotBlank(eventRoadshowId)){
                eventRoadshowId = String.escapeSingleQuotes(eventRoadshowId);
            }

            additionalQuery = String.isNotBlank(additionalQuery) ? ' AND ' + additionalQuery : '';

            String CMSSpeakersLocalizationQueryString = ' ';

            if(isWithLocalization != null && isWithLocalization){
                CMSSpeakersLocalizationQueryString = ' , (SELECT Id, First_Name__c, Last_Name__c, Title__c, Biography__c, Description__c, Is_Active__c, Language__c, Company__c FROM CMS_Speaker_Localizations__r WHERE Is_Active__c =: isActive AND Language__c != null) ';
            }

            String SOQLQueryString = 'SELECT Id, First_Name__c, Last_Name__c, Title__c, Biography__c, Speaker_Image__c, Description__c, Company__c, Company_Logo_URL__c, Company_URL__c, Twitter__c, LinkedIn__c, Order_Of_Display__c, Is_Active__c' + CMSSpeakersLocalizationQueryString + 'FROM CMS_Speaker__c WHERE EventID__c =: eventId AND Event_Roadshow_Setting__c =: eventRoadshowId AND Is_Active__c =: isActive' + additionalQuery;

            return Database.query(SOQLQueryString);
        }

        return new List<CMS_Speaker__c>();
    }

    global static List<CMSSpeakerWithLocalizationWrapper> parseListOfCMSSpeakerRecordsWithLocalizationToWrapperList(List<CMS_Speaker__c> listOfCMSSpeakers)
    {
        List<CMSSpeakerWithLocalizationWrapper> listOfCMSSpeakersWrapper = new List<CMSSpeakerWithLocalizationWrapper>();

        try
        {
            if(listOfCMSSpeakers != null && listOfCMSSpeakers.size() > 0)
            {
                for (CMS_Speaker__c cmsspkr : listOfCMSSpeakers)
                {
                    listOfCMSSpeakersWrapper.add(new CMSSpeakerWithLocalizationWrapper(cmsspkr));
                }
            }
        }
        catch (Exception e)
        {
            System.debug('Exception parseListOfCMSSpeakerRecordsWithLocalizationToWrapperList ----> '+ e.getMessage());
        }

        return listOfCMSSpeakersWrapper;
    }

    @RemoteAction
    global static List<CMSSpeakerWithLocalizationWrapper> getListOfCMSSpeakerWrapperWithLocalizationByEventId(String eventId, String eventRoadshowId)
    {
        try
        {
            if(String.isNotBlank(eventId)){
                return parseListOfCMSSpeakerRecordsWithLocalizationToWrapperList(getListOfCMSSpeakersWithLocalization(eventId, eventRoadshowId, 'EventID__c != null ORDER BY Order_of_Display__c ASC NULLS FIRST', true, true));
            }
        }
        catch(Exception e)
        {
            System.debug('Exception getListOfCMSSpeakerWrapperWithLocalizationByEventId ----> '+ e.getMessage());
        }

        return new List<CMSSpeakerWithLocalizationWrapper>();
    }

    static Map<String, List<CMSStaticPageWithLocalizationWrapper>> generateMapOfCMSStaticPageWithLocalizationWrapper(List<CMSStaticPageWithLocalizationWrapper> listOfCMSStaticPageWithLocalization)
    {
        Map<String, List<CMSStaticPageWithLocalizationWrapper>> mapOfListCMSStaticPageWithLocalization = new Map<String, List<CMSStaticPageWithLocalizationWrapper>>();

        if(listOfCMSStaticPageWithLocalization != null && listOfCMSStaticPageWithLocalization.size() > 0)
        {
            for(CMSStaticPageWithLocalizationWrapper cmsStaticPageWithLocalizationWrap : listOfCMSStaticPageWithLocalization)
            {
                if(String.isNotBlank(cmsStaticPageWithLocalizationWrap.sectionType))
                {
                    if(mapOfListCMSStaticPageWithLocalization != null && mapOfListCMSStaticPageWithLocalization.size() > 0 && mapOfListCMSStaticPageWithLocalization.containsKey(cmsStaticPageWithLocalizationWrap.sectionType))
                    {
                        List<CMSStaticPageWithLocalizationWrapper> listCMSWrapper = mapOfListCMSStaticPageWithLocalization.get(cmsStaticPageWithLocalizationWrap.sectionType);
                        listCMSWrapper.add(cmsStaticPageWithLocalizationWrap);
                    }
                    else
                    {
                        mapOfListCMSStaticPageWithLocalization.put(cmsStaticPageWithLocalizationWrap.sectionType, new List<CMSStaticPageWithLocalizationWrapper>{cmsStaticPageWithLocalizationWrap});
                    }
                }
            }
        }

        return mapOfListCMSStaticPageWithLocalization;
    }
}