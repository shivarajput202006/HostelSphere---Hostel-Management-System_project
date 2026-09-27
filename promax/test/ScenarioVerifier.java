package test;

import dao.AdminDAO;
import dao.FeeDAO;
import dao.FoodPriceDAO;
import dao.StudentDAO;
import model.Admin;
import model.Fee;
import model.Student;

import java.math.BigDecimal;
import java.sql.Date;
import java.util.List;

public class ScenarioVerifier {

    public static void main(String[] args) {
        System.out.println("===============================================================");
        System.out.println("   RUNNING ALL 10 TEST SCENARIOS FOR HOSTEL MANAGEMENT SYSTEM   ");
        System.out.println("===============================================================\n");

        StudentDAO studentDAO = new StudentDAO();
        FeeDAO feeDAO = new FeeDAO();
        FoodPriceDAO foodPriceDAO = new FoodPriceDAO();
        AdminDAO adminDAO = new AdminDAO();

        int passed = 0;
        int failed = 0;

        // Cleanup any old test records
        int testStudentId1 = 99991;
        int testStudentId2 = 99992;
        studentDAO.deleteStudent(testStudentId1);
        studentDAO.deleteStudent(testStudentId2);

        // -----------------------------------------------------------------
        // TEST 1 — New Student Creation -> Fee Not Generated
        // -----------------------------------------------------------------
        try {
            System.out.println("[TEST 1] Testing New Student Registration & Fee Status...");
            Student newStudent = new Student();
            newStudent.setStudentId(testStudentId1);
            newStudent.setName("Test Student One");
            newStudent.setEmail("test1@example.com");
            newStudent.setMobile("9876543210");
            newStudent.setCourse("B.Tech CSE");
            newStudent.setSemester("Semester 3");
            newStudent.setPassword("pass123");
            newStudent.setStatus("Active");

            boolean registered = studentDAO.addStudent(newStudent);
            if (!registered) throw new RuntimeException("Failed to register test student 1");

            List<Fee> fees = feeDAO.getFeesByStudentId(testStudentId1);
            if (fees == null || fees.isEmpty()) {
                System.out.println("  -> PASS: No fee record exists in MongoDB for new student.");
                System.out.println("  -> Dashboard Fee Status: Fee Not Generated / Awaiting Fee Generation");
                System.out.println("  -> Dues display: Total=--, Paid=--, Due=--");
                passed++;
            } else {
                System.out.println("  -> FAIL: Fee record was automatically generated! Count: " + fees.size());
                failed++;
            }
        } catch (Exception e) {
            System.out.println("  -> FAIL: " + e.getMessage());
            failed++;
        }

        // -----------------------------------------------------------------
        // TEST 2 — Admin Generates Veg Fee
        // -----------------------------------------------------------------
        String vegReceipt = "";
        try {
            System.out.println("\n[TEST 2] Testing Admin Generates Veg Fee...");
            foodPriceDAO.updatePrices(new BigDecimal("3000.00"), new BigDecimal("4000.00"));
            BigDecimal vegPrice = foodPriceDAO.getVegPrice(); // 3000

            BigDecimal hostelFee = new BigDecimal("20000.00");
            BigDecimal otherCharges = new BigDecimal("500.00");
            BigDecimal initialPaid = BigDecimal.ZERO;

            Fee fee = feeDAO.generateFee(testStudentId1, hostelFee, "Veg", vegPrice, otherCharges, initialPaid, "Cash", "Fall 2026");
            vegReceipt = fee.getReceiptNumber();

            BigDecimal expectedTotal = new BigDecimal("23500.00"); // 20000 + 3000 + 500
            if (fee.getTotalFee().compareTo(expectedTotal) == 0 &&
                fee.getPaidAmount().compareTo(BigDecimal.ZERO) == 0 &&
                fee.getDueAmount().compareTo(expectedTotal) == 0 &&
                "Pending".equalsIgnoreCase(fee.getStatus()) &&
                "Veg".equalsIgnoreCase(fee.getFoodType()) &&
                fee.getReceiptNumber() != null) {
                System.out.println("  -> PASS: Veg Fee generated successfully. Total = ₹" + fee.getTotalFee() + ", Due = ₹" + fee.getDueAmount() + ", Status = " + fee.getStatus() + ", Receipt = " + fee.getReceiptNumber());
                passed++;
            } else {
                System.out.println("  -> FAIL: Unexpected values in generated Veg Fee: " + fee);
                failed++;
            }
        } catch (Exception e) {
            System.out.println("  -> FAIL: " + e.getMessage());
            failed++;
        }

        // -----------------------------------------------------------------
        // TEST 3 — Admin Generates Non-Veg Fee
        // -----------------------------------------------------------------
        try {
            System.out.println("\n[TEST 3] Testing Admin Generates Non-Veg Fee...");
            Student student2 = new Student();
            student2.setStudentId(testStudentId2);
            student2.setName("Test Student Two");
            student2.setEmail("test2@example.com");
            student2.setMobile("9876543211");
            student2.setCourse("MCA");
            student2.setSemester("Semester 1");
            student2.setPassword("pass123");
            student2.setStatus("Active");
            studentDAO.addStudent(student2);

            BigDecimal nonVegPrice = foodPriceDAO.getNonVegPrice(); // 4000
            BigDecimal hostelFee = new BigDecimal("20000.00");
            BigDecimal otherCharges = BigDecimal.ZERO;

            Fee nonVegFee = feeDAO.generateFee(testStudentId2, hostelFee, "Non-Veg", nonVegPrice, otherCharges, BigDecimal.ZERO, "UPI", "Fall 2026");
            BigDecimal expectedTotal = new BigDecimal("24000.00"); // 20000 + 4000

            if (nonVegFee.getTotalFee().compareTo(expectedTotal) == 0 &&
                "Non-Veg".equalsIgnoreCase(nonVegFee.getFoodType()) &&
                nonVegFee.getFoodAmount().compareTo(new BigDecimal("4000.00")) == 0 &&
                "Pending".equalsIgnoreCase(nonVegFee.getStatus())) {
                System.out.println("  -> PASS: Non-Veg Fee generated successfully. Total = ₹" + nonVegFee.getTotalFee() + ", Food Amount = ₹" + nonVegFee.getFoodAmount() + ", Status = " + nonVegFee.getStatus());
                passed++;
            } else {
                System.out.println("  -> FAIL: Unexpected non-veg fee values: " + nonVegFee);
                failed++;
            }
        } catch (Exception e) {
            System.out.println("  -> FAIL: " + e.getMessage());
            failed++;
        }

        // -----------------------------------------------------------------
        // TEST 4 — No Food Option
        // -----------------------------------------------------------------
        try {
            System.out.println("\n[TEST 4] Testing No Food Fee Option (₹0 Food Amount)...");
            BigDecimal foodPrice = foodPriceDAO.getPriceByType("No Food");
            BigDecimal hostelFee = new BigDecimal("20000.00");
            BigDecimal other = new BigDecimal("1000.00");

            Fee noFoodFee = new Fee();
            noFoodFee.setStudentId(testStudentId2);
            noFoodFee.setHostelFee(hostelFee);
            noFoodFee.setFoodType("No Food");
            noFoodFee.setFoodAmount(foodPrice);
            noFoodFee.setOtherCharges(other);
            noFoodFee.setTotalFee(hostelFee.add(foodPrice).add(other));
            noFoodFee.setPaidAmount(BigDecimal.ZERO);
            noFoodFee.setDueAmount(noFoodFee.getTotalFee());
            noFoodFee.calculateDue();

            if (foodPrice.compareTo(BigDecimal.ZERO) == 0 &&
                noFoodFee.getTotalFee().compareTo(new BigDecimal("21000.00")) == 0 &&
                noFoodFee.getFoodAmount().compareTo(BigDecimal.ZERO) == 0) {
                System.out.println("  -> PASS: No Food option correctly evaluated with Food Amount = ₹0.00, Total = ₹" + noFoodFee.getTotalFee());
                passed++;
            } else {
                System.out.println("  -> FAIL: Food price is not zero for No Food: " + foodPrice);
                failed++;
            }
        } catch (Exception e) {
            System.out.println("  -> FAIL: " + e.getMessage());
            failed++;
        }

        // -----------------------------------------------------------------
        // TEST 5 — Partial Payment Calculation
        // -----------------------------------------------------------------
        try {
            System.out.println("\n[TEST 5] Testing Partial Payment (e.g. Total = ₹25,000, Paid = ₹10,000)...");
            Fee testFee = new Fee();
            testFee.setTotalFee(new BigDecimal("25000.00"));
            testFee.setPaidAmount(new BigDecimal("10000.00"));
            testFee.calculateDue();

            if (testFee.getDueAmount().compareTo(new BigDecimal("15000.00")) == 0 &&
                "Partially Paid".equalsIgnoreCase(testFee.getStatus())) {
                System.out.println("  -> PASS: Due Amount = ₹" + testFee.getDueAmount() + ", Status = " + testFee.getStatus());
                passed++;
            } else {
                System.out.println("  -> FAIL: Due amount or status incorrect: Due=" + testFee.getDueAmount() + ", Status=" + testFee.getStatus());
                failed++;
            }
        } catch (Exception e) {
            System.out.println("  -> FAIL: " + e.getMessage());
            failed++;
        }

        // -----------------------------------------------------------------
        // TEST 6 — Full Payment Calculation
        // -----------------------------------------------------------------
        try {
            System.out.println("\n[TEST 6] Testing Full Payment (e.g. Total = ₹25,000, Paid = ₹25,000)...");
            Fee testFee = new Fee();
            testFee.setTotalFee(new BigDecimal("25000.00"));
            testFee.setPaidAmount(new BigDecimal("25000.00"));
            testFee.calculateDue();

            if (testFee.getDueAmount().compareTo(BigDecimal.ZERO) == 0 &&
                "Complete".equalsIgnoreCase(testFee.getStatus())) {
                System.out.println("  -> PASS: Due Amount = ₹" + testFee.getDueAmount() + ", Status = " + testFee.getStatus());
                passed++;
            } else {
                System.out.println("  -> FAIL: Due amount or status incorrect: Due=" + testFee.getDueAmount() + ", Status=" + testFee.getStatus());
                failed++;
            }
        } catch (Exception e) {
            System.out.println("  -> FAIL: " + e.getMessage());
            failed++;
        }

        // -----------------------------------------------------------------
        // TEST 7 — Student Profile Edit
        // -----------------------------------------------------------------
        try {
            System.out.println("\n[TEST 7] Testing Student Profile Edit (Non-sensitive fields)...");
            Student s = studentDAO.getStudentById(testStudentId1);
            s.setName("Updated Test Name");
            s.setMobile("9988776655");
            s.setEmail("updated.test1@example.com");
            s.setAddress("456 Resident Avenue, Campus Tower B");
            s.setDob(Date.valueOf("2003-05-15"));
            s.setGender("Male");

            boolean updated = studentDAO.updateStudentPersonal(s);
            Student retrieved = studentDAO.getStudentById(testStudentId1);

            if (updated && 
                "Updated Test Name".equals(retrieved.getName()) &&
                "9988776655".equals(retrieved.getMobile()) &&
                "updated.test1@example.com".equals(retrieved.getEmail()) &&
                "456 Resident Avenue, Campus Tower B".equals(retrieved.getAddress())) {
                System.out.println("  -> PASS: Student profile successfully updated and refreshed from database.");
                passed++;
            } else {
                System.out.println("  -> FAIL: Student profile update was not saved properly in DB.");
                failed++;
            }
        } catch (Exception e) {
            System.out.println("  -> FAIL: " + e.getMessage());
            failed++;
        }

        // -----------------------------------------------------------------
        // TEST 8 — Unauthorized Student Update Enforcement
        // -----------------------------------------------------------------
        try {
            System.out.println("\n[TEST 8] Testing Backend Security / Protection Against Unauthorized Field Tampering...");
            Student original = studentDAO.getStudentById(testStudentId1);
            String originalRoom = original.getRoomNumber();
            String originalCourse = original.getCourse();

            // Attempt to tamper with room and course via updateStudentPersonal
            Student maliciousAttempt = new Student();
            maliciousAttempt.setStudentId(testStudentId1);
            maliciousAttempt.setName("Legit Name");
            maliciousAttempt.setMobile("9988776655");
            maliciousAttempt.setRoomNumber("TAMPERED_ROOM_999");
            maliciousAttempt.setCourse("TAMPERED_COURSE_PHD");

            // updateStudentPersonal only updates allowed fields (name, mobile, email, address, dob, gender, guardian, etc.)
            studentDAO.updateStudentPersonal(maliciousAttempt);

            Student afterAttempt = studentDAO.getStudentById(testStudentId1);
            if ((originalRoom == null && afterAttempt.getRoomNumber() == null || (originalRoom != null && originalRoom.equals(afterAttempt.getRoomNumber()))) &&
                originalCourse.equals(afterAttempt.getCourse())) {
                System.out.println("  -> PASS: Protected fields (Room, Course, Fees) were NOT modified. Authorization/DAO constraints enforced.");
                passed++;
            } else {
                System.out.println("  -> FAIL: Student was able to tamper with protected fields! Room=" + afterAttempt.getRoomNumber());
                failed++;
            }
        } catch (Exception e) {
            System.out.println("  -> FAIL: " + e.getMessage());
            failed++;
        }

        // -----------------------------------------------------------------
        // TEST 9 — Food Price Change Preserves Historical Invoices
        // -----------------------------------------------------------------
        try {
            System.out.println("\n[TEST 9] Testing Food Price Change & Historical Receipt Integrity...");
            // Old receipt in Test 2 had Veg = 3000
            Fee oldFee = feeDAO.getFeeByReceiptNumber(vegReceipt);
            BigDecimal oldFoodAmount = oldFee.getFoodAmount();

            // Now Admin changes Veg price to 3500
            foodPriceDAO.updatePrices(new BigDecimal("3500.00"), new BigDecimal("4500.00"));
            BigDecimal newVegPrice = foodPriceDAO.getVegPrice();

            // Re-fetch old receipt
            Fee recheckedOldFee = feeDAO.getFeeByReceiptNumber(vegReceipt);

            // Generate a brand new fee with new price
            Fee newFee = feeDAO.generateFee(testStudentId1, new BigDecimal("20000.00"), "Veg", newVegPrice, BigDecimal.ZERO, BigDecimal.ZERO, "Cash", "Spring 2027");

            if (recheckedOldFee.getFoodAmount().compareTo(new BigDecimal("3000.00")) == 0 &&
                newFee.getFoodAmount().compareTo(new BigDecimal("3500.00")) == 0) {
                System.out.println("  -> PASS: Historical fee receipt maintained original Veg price (₹" + recheckedOldFee.getFoodAmount() + "), while new fee used updated price (₹" + newFee.getFoodAmount() + ").");
                passed++;
            } else {
                System.out.println("  -> FAIL: Historical price was altered! Old=" + recheckedOldFee.getFoodAmount() + ", New=" + newFee.getFoodAmount());
                failed++;
            }
        } catch (Exception e) {
            System.out.println("  -> FAIL: " + e.getMessage());
            failed++;
        }

        // -----------------------------------------------------------------
        // TEST 10 — Print Receipt Integrity & Details
        // -----------------------------------------------------------------
        try {
            System.out.println("\n[TEST 10] Testing Print Receipt Structure & Information Retrieval...");
            Fee sampleFee = feeDAO.getFeeByReceiptNumber(vegReceipt);
            Student student = studentDAO.getStudentById(sampleFee.getStudentId());

            boolean hasAllDetails = sampleFee.getReceiptNumber() != null &&
                                    sampleFee.getHostelFee() != null &&
                                    sampleFee.getFoodType() != null &&
                                    sampleFee.getFoodAmount() != null &&
                                    sampleFee.getTotalFee() != null &&
                                    sampleFee.getPaidAmount() != null &&
                                    sampleFee.getDueAmount() != null &&
                                    student != null;

            if (hasAllDetails) {
                System.out.println("  -> PASS: Receipt contains full breakdown: Hostel=₹" + sampleFee.getHostelFee() + 
                                   ", Food=" + sampleFee.getFoodType() + " (₹" + sampleFee.getFoodAmount() + 
                                   "), Total=₹" + sampleFee.getTotalFee() + 
                                   ", Paid=₹" + sampleFee.getPaidAmount() + 
                                   ", Due=₹" + sampleFee.getDueAmount() + 
                                   ", Status=" + sampleFee.getStatus());
                passed++;
            } else {
                System.out.println("  -> FAIL: Missing fields on receipt.");
                failed++;
            }
        } catch (Exception e) {
            System.out.println("  -> FAIL: " + e.getMessage());
            failed++;
        }

        // Clean up test data
        studentDAO.deleteStudent(testStudentId1);
        studentDAO.deleteStudent(testStudentId2);

        System.out.println("\n===============================================================");
        System.out.println("   TEST SUITE SUMMARY: " + passed + " PASSED, " + failed + " FAILED");
        System.out.println("===============================================================");
    }
}
