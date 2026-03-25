public class QuantityTierDAO {
    public static List<Quantitiy_Tier__c> getByCategories(Set<Id> categoryIds) {
        if (categoryIds == null || categoryIds.isEmpty()) return new List<Quantitiy_Tier__c>();
        return [
            SELECT Id, Category__c, Minimum_Quantity__c, Maximum_Quantity__c, Discount__c
            FROM Quantitiy_Tier__c
            WHERE Category__c IN :categoryIds
        ];
    }
}
