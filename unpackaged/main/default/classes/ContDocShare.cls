public class ContDocShare {

    @future
    public static void processShare(Set<Id> cdlIds, String netId) {
        
            netId = ''; // ensure we don't use the id passed in
            User Usr = new User();
            Usr = [SELECT Id FROM User WHERE Username like 'servicecloudadmin%' limit 1];
            system.debug('Usr.id ' + Usr.Id );
            netId = Usr.Id;
            list <contentDocumentLink> l_contDL = new list<contentDocumentLink>();                
            // Make all Documents linked to Cases and Email Messages (File attachments) visible by all users
            for(contentDocumentLink contDL : [
                select Id, LinkedEntityId, ContentDocumentId, ShareType, Visibility 
                    from contentDocumentLink
                    where Id in :cdlIds]){
                        
     			// granth 07/05/19 apply to all customer uploaded files 
                if (String.valueOf(contDL.LinkedEntityId).startsWith('500') || String.valueOf(contDL.LinkedEntityId).startsWith('02s')){ // '500' = Case, '02s' = EmailMessage 
                    List<contentDocumentLink> checkNetId = [select id from contentDocumentLink
                            where contentDocumentId = :contDL.ContentDocumentId and LinkedEntityId = :netId limit 1];        
                    if (checkNetId.size() == 0){ // does not exist
                        contentDocumentLink cdl = new contentDocumentLink();
                        cdl.ContentDocumentId = contDL.ContentDocumentId;
                        cdl.LinkedEntityId = netId;
                        if (contDL.ShareType == 'I'){
                            cdl.ShareType = 'V';}
                        else {
                            cdl.ShareType = contDL.ShareType;
                        }
                        cdl.Visibility = contDL.Visibility;
                        l_contDL.add(cdl);
                        
                    }
                }
            }
                
            if (l_contDL.size() > 0){
                 insert l_contDL;
            }
        
    }
}