public class Product2DAO {
    public static List<Product2> getByIds(Set<Id> productIds) {
        if (productIds == null || productIds.isEmpty()) return new List<Product2>();
        return [SELECT Id, Category__c FROM Product2 WHERE Id IN :productIds];
    }
}
