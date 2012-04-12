/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class VEM_LocationTest
{

    static testMethod void testValidateParentLocation()
    {
		VEM_Location__c parent = new VEM_Location__c();
		parent.Name = 'Parent';
		parent.Location_Type__c = 'Building';
		parent.Zone__c = 'Main Campus - East';
		parent.Parent_Location__c = null;
		parent.Approver__c = UserInfo.getUserId();
		insert parent;

		VEM_Location__c child = new VEM_Location__c();
		child.Name = 'Child';
		child.Location_Type__c = 'Building';
		child.Zone__c = 'Main Campus - East';
		child.Parent_Location__c = null;
		child.Approver__c = UserInfo.getUserId();
		insert child;

		//This is needed to test the trigger
		child.Parent_Location__c = parent.Id;
		update child;

		VEM_Location__c newParent = parent.clone(false);
		newParent.Parent_Location__c = child.Id;

		List<VEM_Location__c> oldParentList = new List<VEM_Location__c>();
		oldParentList.add(parent);

		List<VEM_Location__c> newParentList = new List<VEM_Location__c>();
		newParentList.add(newParent);

    	Test.startTest();
		Boolean result1 = VEM_Location.validateParentLocation(oldParentList, oldParentList);
		Boolean result2 = VEM_Location.validateParentLocation(oldParentList, newParentList);
		Test.stopTest();

		system.assert(result1);
		system.assert(!result2);
    }

}