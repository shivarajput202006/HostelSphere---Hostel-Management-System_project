package util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * PasswordUtil - Secure hashing utility using SHA-256
 * Supports verification for both hashed values and legacy/plain seeds.
 */
public class PasswordUtil {

    /**
     * Hashes a plain password using SHA-256
     * @param password Plain text password
     * @return Hexadecimal hashed string
     */
    public static String hashPassword(String password) {
        if (password == null || password.trim().isEmpty()) {
            return "";
        }
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(password.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
            return password; // Fallback
        }
    }

    /**
     * Checks if input password matches stored password.
     * Checks both SHA-256 match and direct match (for easy initial demo seeds).
     */
    public static boolean checkPassword(String inputPassword, String storedPassword) {
        if (inputPassword == null || storedPassword == null) {
            return false;
        }
        // Direct match (for initial database seeds like 'admin123' / 'pass123')
        if (inputPassword.equals(storedPassword)) {
            return true;
        }
        // SHA-256 hash match
        String hashedInput = hashPassword(inputPassword);
        return hashedInput.equalsIgnoreCase(storedPassword);
    }
}
