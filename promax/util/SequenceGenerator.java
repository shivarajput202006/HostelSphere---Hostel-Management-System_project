package util;

import com.mongodb.client.MongoCollection;
import com.mongodb.client.model.FindOneAndUpdateOptions;
import com.mongodb.client.model.ReturnDocument;
import com.mongodb.client.model.Updates;
import org.bson.Document;

import static com.mongodb.client.model.Filters.eq;

/**
 * SequenceGenerator - Generates auto-incrementing integer IDs for entities in MongoDB
 */
public class SequenceGenerator {

    /**
     * Atomically returns the next sequential integer ID for the specified sequence name.
     * @param sequenceName e.g., "studentId", "roomId", "allocationId", "feeId", "complaintId", "paymentId"
     * @return Next integer sequence value
     */
    public static int getNextSequence(String sequenceName) {
        MongoCollection<Document> counters = MongoDBConnection.getCollection("counters");

        FindOneAndUpdateOptions options = new FindOneAndUpdateOptions()
                .upsert(true)
                .returnDocument(ReturnDocument.AFTER);

        Document updated = counters.findOneAndUpdate(
                eq("_id", sequenceName),
                Updates.inc("seq", 1),
                options
        );

        if (updated != null && updated.get("seq") != null) {
            Object val = updated.get("seq");
            if (val instanceof Number) {
                return ((Number) val).intValue();
            }
        }
        return (int) (System.currentTimeMillis() % 1000000);
    }
}
