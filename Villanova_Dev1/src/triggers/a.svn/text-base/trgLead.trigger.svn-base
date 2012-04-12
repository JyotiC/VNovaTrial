trigger trgLead on Lead (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
	//BEFORE
	if (Trigger.isBefore){
		//INSERT UPDATE
		if (Trigger.isInsert || Trigger.isUpdate){
			for (Lead l : Trigger.new){
				if (l.Encrypted_Key__c == null){
					DateTime now = System.now();
					String formattednow = now.formatGmt('yyyy-MM-dd')+'T'+ now.formatGmt('HH:mm:ss')+'.'+now.formatGMT('SSS')+'Z';
					String canonical = l.id + l.Name + l.OwnerId + formattednow;
					Blob bsig = Crypto.generateDigest('MD5', Blob.valueOf(canonical));
					String token = EncodingUtil.base64Encode(bsig);
				
					if(token.length() > 255) {
						token = token.substring(0,254);
					}
					try {
						l.Encrypted_Key__c = Encodingutil.urlEncode(token, 'UTF-8').replaceAll('%','_');
					}catch (Exception e){
						system.debug('EncrytpedKey__c assignment failed:' +e);
					}
				}//end if encrypted key is null
				
				if ((Trigger.isInsert &&l.User_Specified_Company__c != null)
					|| (Trigger.isUpdate &&l.User_Specified_Company__c != Trigger.oldMap.get(l.Id).User_Specified_Company__c
					&&l.User_Specified_Company__c != null)
				){
					l.Company = l.User_Specified_Company__c;
				}
				
			}
		}//END INSERT UPDATE
	}//END BEFORE
}