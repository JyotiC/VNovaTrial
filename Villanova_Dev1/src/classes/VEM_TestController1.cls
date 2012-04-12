public with sharing class VEM_TestController1
{

        public string reportName { get; set; }

        private VEM_Event__c m_event = new VEM_Event__c();
        public VEM_Event__c getProxyObject()
        {
                return m_event;
        }

        public PageReference save()
        {
                return null;
        }

        public PageReference cancel()
        {
                return null;
        }

}