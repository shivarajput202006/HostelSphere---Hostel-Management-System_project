package dao;

import com.mongodb.client.MongoCollection;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.ReplaceOptions;
import org.bson.Document;
import util.MongoDBConnection;

import java.math.BigDecimal;

/**
 * FoodPriceDAO - Manages admin-configurable food pricing stored in MongoDB.
 * Collection: food_prices
 * Documents: { _id: "veg", price: <double> }, { _id: "nonveg", price: <double> }
 */
public class FoodPriceDAO {

    private MongoCollection<Document> getCollection() {
        return MongoDBConnection.getCollection("food_prices");
    }

    /**
     * Get the configured Veg food price. Returns default 3000.0 if not set.
     */
    public BigDecimal getVegPrice() {
        return getPrice("veg", 3000.0);
    }

    /**
     * Get the configured Non-Veg food price. Returns default 4000.0 if not set.
     */
    public BigDecimal getNonVegPrice() {
        return getPrice("nonveg", 4000.0);
    }

    /**
     * Set the Veg food price.
     */
    public boolean setVegPrice(BigDecimal price) {
        if (price == null || price.compareTo(BigDecimal.ZERO) < 0) {
            price = BigDecimal.ZERO;
        }
        return setPrice("veg", price);
    }

    /**
     * Set the Non-Veg food price.
     */
    public boolean setNonVegPrice(BigDecimal price) {
        if (price == null || price.compareTo(BigDecimal.ZERO) < 0) {
            price = BigDecimal.ZERO;
        }
        return setPrice("nonveg", price);
    }

    public boolean updatePrices(BigDecimal vegPrice, BigDecimal nonVegPrice) {
        boolean s1 = setVegPrice(vegPrice);
        boolean s2 = setNonVegPrice(nonVegPrice);
        return s1 && s2;
    }

    /**
     * Get the food price for a given food type string.
     * Returns BigDecimal.ZERO for "No Food" or unknown types.
     */
    public BigDecimal getPriceByType(String foodType) {
        if (foodType == null) return BigDecimal.ZERO;
        String trimmed = foodType.trim();
        if ("Veg".equalsIgnoreCase(trimmed)) {
            return getVegPrice();
        } else if ("Non-Veg".equalsIgnoreCase(trimmed) || "NonVeg".equalsIgnoreCase(trimmed)) {
            return getNonVegPrice();
        } else {
            return BigDecimal.ZERO;
        }
    }

    private BigDecimal getPrice(String id, double defaultVal) {
        try {
            Document doc = getCollection().find(Filters.eq("_id", id)).first();
            if (doc != null) {
                Double price = doc.getDouble("price");
                if (price != null) {
                    return BigDecimal.valueOf(price);
                }
            }
            // Initialize default if not found
            setPrice(id, BigDecimal.valueOf(defaultVal));
            return BigDecimal.valueOf(defaultVal);
        } catch (Exception e) {
            e.printStackTrace();
            return BigDecimal.valueOf(defaultVal);
        }
    }

    private boolean setPrice(String id, BigDecimal price) {
        try {
            Document doc = new Document("_id", id)
                    .append("price", price.doubleValue())
                    .append("updatedAt", new java.util.Date());
            getCollection().replaceOne(
                    Filters.eq("_id", id),
                    doc,
                    new ReplaceOptions().upsert(true)
            );
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
