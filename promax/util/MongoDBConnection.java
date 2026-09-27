package util;

import com.mongodb.ConnectionString;
import com.mongodb.MongoClientSettings;
import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import config.MongoDBConfig;
import org.bson.Document;

import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * MongoDBConnection - Singleton Connection Manager for MongoDB
 */
public class MongoDBConnection {

    private static MongoClient mongoClient = null;
    private static MongoDatabase database = null;
    private static final Object LOCK = new Object();

    static {
        // Reduce verbose Mongo driver logging in console
        Logger.getLogger("org.mongodb.driver").setLevel(Level.WARNING);
    }

    private MongoDBConnection() {}

    /**
     * Retrieves or creates the singleton MongoDatabase instance
     */
    public static MongoDatabase getDatabase() {
        if (database == null) {
            synchronized (LOCK) {
                if (database == null) {
                    try {
                        String uri = MongoDBConfig.getConnectionString();
                        String dbName = MongoDBConfig.getDatabaseName();

                        ConnectionString connString = new ConnectionString(uri);
                        MongoClientSettings settings = MongoClientSettings.builder()
                                .applyConnectionString(connString)
                                .applyToSocketSettings(builder -> 
                                    builder.connectTimeout(5000, TimeUnit.MILLISECONDS)
                                           .readTimeout(10000, TimeUnit.MILLISECONDS))
                                .applyToClusterSettings(builder ->
                                    builder.serverSelectionTimeout(5000, TimeUnit.MILLISECONDS))
                                .build();

                        mongoClient = MongoClients.create(settings);
                        database = mongoClient.getDatabase(dbName);

                        // Ping and initialize collections/seed
                        MongoDBConfig.initializeDatabase(database);
                        System.out.println("[MongoDBConnection] Connected successfully to MongoDB: " + dbName);
                    } catch (Exception e) {
                        System.err.println("[MongoDBConnection] Failed to connect to MongoDB: " + e.getMessage());
                        e.printStackTrace();
                    }
                }
            }
        }
        return database;
    }

    /**
     * Get a specific MongoDB collection
     */
    public static MongoCollection<Document> getCollection(String collectionName) {
        MongoDatabase db = getDatabase();
        if (db == null) {
            throw new IllegalStateException("MongoDB Database is not available. Please verify MongoDB server is running.");
        }
        return db.getCollection(collectionName);
    }

    /**
     * Closes the MongoDB client connection pool
     */
    public static void close() {
        synchronized (LOCK) {
            if (mongoClient != null) {
                try {
                    mongoClient.close();
                    System.out.println("[MongoDBConnection] MongoDB connection closed.");
                } catch (Exception ignored) {}
                mongoClient = null;
                database = null;
            }
        }
    }
}
