trigger QuoteLineItemTrigger on QuoteLineItem (before insert, before update) {
    Set<Id> productIds = new Set<Id>();
    
    for (QuoteLineItem qli : Trigger.new) {
        if (qli.Product2Id != null) {
            productIds.add(qli.Product2Id);
        }
    }
    
    if (!productIds.isEmpty()) {
        Map<Id, Product2> productMap = new Map<Id, Product2>(
            [SELECT Id, Category__c FROM Product2 WHERE Id IN :productIds]
        );
        
        for (QuoteLineItem qli : Trigger.new) {
            if (qli.Product2Id != null && productMap.containsKey(qli.Product2Id)) {
                // This maps the ID of the Category, not the Name
                qli.Category__c = productMap.get(qli.Product2Id).Category__c;
            }
        }
    }
}