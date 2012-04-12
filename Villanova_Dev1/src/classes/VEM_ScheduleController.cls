public with sharing class VEM_ScheduleController {

        ///////////////
        // Constants //
        ///////////////

        final private String ALL_PROFILE_ID = '';
        //final private Id ALL_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'VEM Standard User' limit 1].Id;

        final private List<Profile> PROFILE_LIST =
                [   SELECT Id, Name
                          FROM Profile
                         WHERE Name LIKE 'VEM %'
                           AND Name NOT IN ('VEM Standard User')
                  ORDER BY Name ];

        ////////////////
        // Properties //
        ////////////////

        private Id m_selectedProfileId = null;
        public Id selectedProfileId
        {
                get
                {
                        if (m_selectedProfileId == null)
                        {
                                Profile userProfile = [ SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1 ];
                                for (Profile profile : PROFILE_LIST)
                                {
                                        if (userProfile.Id == profile.Id)
                                        {
                                                m_selectedProfileId = userProfile.Id;
                                                break;
                                        }
                                }
                        }
                        return m_selectedProfileId;
                }
                set
                {
                        m_selectedProfileId = value;
                }
        }

        private List<SelectOption> m_profileSelectionList = null;
        public List<SelectOption> profileSelectionList
        {
                get
                {
                        if (m_profileSelectionList == null)
                        {
                                m_profileSelectionList = new List<SelectOption>();
                                m_profileSelectionList.add(new SelectOption(ALL_PROFILE_ID, 'All'));
                                for (Profile profile : PROFILE_LIST)
                                {
                                        m_profileSelectionList.add(new SelectOption(profile.Id, profile.Name.replace('VEM ', '').replace(' User', '')));
                                } 
                        }
                        return m_profileSelectionList;
                }
        }

        private Date m_scheduleStartDate = Date.today();
        public Date scheduleStartDate
        {
                get { return m_scheduleStartDate; }
                set { m_scheduleStartDate = value; }
        }

        private Date m_scheduleEndDate = Date.today();
        public Date scheduleEndDate
        {
                get { return m_scheduleEndDate; }
                set { m_scheduleEndDate = value; }
        }

        // Needed to display a Salesforce date-picker
        Opportunity m_proxyObject = new Opportunity();
        public Opportunity proxyObject
        {
                get 
                {
                        if (m_proxyObject.CloseDate == null)
                        {
                                m_proxyObject.CloseDate = scheduleStartDate;
                        }
                        return m_proxyObject;
                }
        }
        public Date scheduleDate
        {
                set { m_proxyObject.CloseDate = value; }
        }

        public String scheduleDateRangeString
        {
                get
                {
                        //format('MMM d, yyyy');
                        if (scheduleStartDate == scheduleEndDate)
                        {
                                return scheduleStartDate.format();
                        }
                        else
                        {
                                return scheduleStartDate.format() + ' - ' + scheduleEndDate.format();
                        }
                }
        }

        public List<VEM_Location__c> locationSchedule
        {
                get
                {
                        return getLocationSchedule(scheduleStartDate, scheduleEndDate);
                }
        }

        /////////////
        // Methods //
        /////////////

        public void handlePreviousDay()
        {
                proxyObject.CloseDate = proxyObject.CloseDate.addDays(-1);
                handleDateChange();
        }

        public void handleNextDay()
        {
                proxyObject.CloseDate = proxyObject.CloseDate.addDays(1);
                handleDateChange();
        }

        public void handleDateChange()
        {
                scheduleStartDate = proxyObject.CloseDate;
                scheduleEndDate = proxyObject.CloseDate;
        }

        private List<VEM_Location__c> getLocationSchedule(Date startDate, Date endDate)
        {
                Set<Id> selectedProfileIdSet = new Set<Id>();
                if (selectedProfileId == null || String.valueOf(selectedProfileId) == ALL_PROFILE_ID)
                {
                        for (Profile profile : PROFILE_LIST)
                        {
                                selectedProfileIdSet.add(profile.Id);
                        }
                }
                else
                {
                        selectedProfileIdSet.add(selectedProfileId);
                }

                return [   SELECT Id, Name,
                                                  (SELECT Id, Name, Event_Type__c, Event_Sponsor__c, Event_Status__c,
                                                                  Start_Date__c, Start_Time__c, Start_Date_Time__c,
                                                                  End_Date__c, End_Time__c, End_Date_Time__c,
                                                                  Expected_Volume__c
                                                         FROM Event_Location__r
                                                        WHERE Start_Date__c >= :startDate
                                                          AND End_Date__c <= :endDate
                                                 ORDER BY Start_Date_Time__c, End_Date_Time__c)
                                         FROM VEM_Location__c
                                        WHERE Approver__r.ProfileId IN :selectedProfileIdSet
                                 ORDER BY Name ];
        }

}