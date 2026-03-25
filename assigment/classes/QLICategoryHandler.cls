public class QLICategoryHandler {
    public static void processCategoryUpdate(List<QuoteLineItem> newItems) {
        Set<Id> productIds = new Set<Id>();
        Set<Id> pbeIds = new Set<Id>();
        
        for (QuoteLineItem qli : newItems) {
            if (qli.Product2Id != null) {
                productIds.add(qli.Product2Id);
            } else if (qli.PricebookEntryId != null) {
                pbeIds.add(qli.PricebookEntryId);
            }
        }
        
        Map<Id, Id> pbeToProductMap = new Map<Id, Id>();
        if (!pbeIds.isEmpty()) {
            for (PricebookEntry pbe : PricebookEntryDAO.getByIds(pbeIds)) {
                pbeToProductMap.put(pbe.Id, pbe.Product2Id);
                productIds.add(pbe.Product2Id);
            }
        }
        
        Map<Id, Product2> productMap = new Map<Id, Product2>();
        if (!productIds.isEmpty()) {
            productMap = new Map<Id, Product2>(Product2DAO.getByIds(productIds));
        }
        
        for (QuoteLineItem qli : newItems) {
            Id prodId = qli.Product2Id != null ? qli.Product2Id : pbeToProductMap.get(qli.PricebookEntryId);
            if (prodId != null && productMap.containsKey(prodId)) {
                if(productMap.get(prodId).Category__c != null) {
                    qli.Category__c = productMap.get(prodId).Category__c;
                }
            }
        }
    }
}
