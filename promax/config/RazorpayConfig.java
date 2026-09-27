package config;

/**
 * RazorpayConfig - Configuration for Razorpay Payment Gateway
 * Loads API credentials securely from environment variables / system properties.
 * Default credentials run in Sandbox / Test Mode.
 */
public class RazorpayConfig {

    // Default Sandbox Test Credentials (can be overridden by environment variables)
    private static final String DEFAULT_KEY_ID = "rzp_test_1DP5mmOlF5G5ag";
    private static final String DEFAULT_KEY_SECRET = "WflUu2h8a9v6zC7vT8nK1rYq";

    public static String getKeyId() {
        String keyId = System.getenv("RAZORPAY_KEY_ID");
        if (keyId == null || keyId.trim().isEmpty()) {
            keyId = System.getProperty("razorpay.key_id");
        }
        if (keyId == null || keyId.trim().isEmpty()) {
            keyId = DEFAULT_KEY_ID;
        }
        return keyId.trim();
    }

    public static String getKeySecret() {
        String keySecret = System.getenv("RAZORPAY_KEY_SECRET");
        if (keySecret == null || keySecret.trim().isEmpty()) {
            keySecret = System.getProperty("razorpay.key_secret");
        }
        if (keySecret == null || keySecret.trim().isEmpty()) {
            keySecret = DEFAULT_KEY_SECRET;
        }
        return keySecret.trim();
    }

    public static String getCurrency() {
        return "INR";
    }

    public static String getCompanyName() {
        return "HostelSphere Residence";
    }
}
