// ==========================================================
// HostelSphere - MongoDB Database Initialization & Seed Script
// Database Name: hostel_db
// ==========================================================

hostel_db;

// 1. Drop existing collections if re-seeding
db.admins.drop();
db.students.drop();
db.rooms.drop();
db.room_allocations.drop();
db.fees.drop();
db.payments.drop();
db.complaints.drop();
db.counters.drop();

// 2. Admins Collection
db.admins.insertMany([
  {
    adminId: 1,
    name: "System Administrator",
    username: "admin",
    password: "8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918", // SHA-256 for 'admin123'
    createdAt: new Date()
  },
  {
    adminId: 2,
    name: "Chief Warden Sharma",
    username: "warden",
    password: "8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918",
    createdAt: new Date()
  }
]);
db.admins.createIndex({ username: 1 }, { unique: true });

// 3. Rooms Collection
db.rooms.insertMany([
  { roomId: 1, roomNumber: "101", floor: 1, roomType: "Single Sharing", totalBeds: 1, occupiedBeds: 1, availableBeds: 0, status: "Occupied", createdAt: new Date() },
  { roomId: 2, roomNumber: "102", floor: 1, roomType: "Double Sharing", totalBeds: 2, occupiedBeds: 2, availableBeds: 0, status: "Occupied", createdAt: new Date() },
  { roomId: 3, roomNumber: "103", floor: 1, roomType: "Double Sharing", totalBeds: 2, occupiedBeds: 1, availableBeds: 1, status: "Available", createdAt: new Date() },
  { roomId: 4, roomNumber: "104", floor: 1, roomType: "Triple Sharing", totalBeds: 3, occupiedBeds: 1, availableBeds: 2, status: "Available", createdAt: new Date() },
  { roomId: 5, roomNumber: "201", floor: 2, roomType: "Single Sharing", totalBeds: 1, occupiedBeds: 0, availableBeds: 1, status: "Available", createdAt: new Date() },
  { roomId: 6, roomNumber: "202", floor: 2, roomType: "Double Sharing", totalBeds: 2, occupiedBeds: 1, availableBeds: 1, status: "Available", createdAt: new Date() },
  { roomId: 7, roomNumber: "203", floor: 2, roomType: "Triple Sharing", totalBeds: 3, occupiedBeds: 0, availableBeds: 3, status: "Available", createdAt: new Date() },
  { roomId: 8, roomNumber: "301", floor: 3, roomType: "Double Sharing", totalBeds: 2, occupiedBeds: 0, availableBeds: 2, status: "Available", createdAt: new Date() }
]);
db.rooms.createIndex({ roomNumber: 1 }, { unique: true });
db.rooms.createIndex({ roomId: 1 }, { unique: true });

// 4. Students Collection (Course is a flexible text string)
db.students.insertMany([
  {
    studentId: 1,
    name: "Aarav Sharma",
    fatherName: "Ramesh Sharma",
    motherName: "Sunita Sharma",
    dob: "2003-05-14",
    gender: "Male",
    mobile: "9876543210",
    email: "aarav.sharma@example.com",
    address: "Flat 402, Green Valley Apartments, New Delhi",
    course: "BCA",
    semester: "Semester 4",
    admissionDate: "2025-07-15",
    username: "student1",
    password: "f9b0f4439c27ee983de37943d0f7ee1a7bcf17849e79f64bf35049c636f32e70", // SHA-256 for 'pass123'
    photo: "default_avatar.svg",
    createdAt: new Date()
  },
  {
    studentId: 2,
    name: "Priya Patel",
    fatherName: "Dinesh Patel",
    motherName: "Meena Patel",
    dob: "2002-11-20",
    gender: "Female",
    mobile: "9876543211",
    email: "priya.patel@example.com",
    address: "12-B, Sunrise Colony, Ahmedabad, Gujarat",
    course: "MCA",
    semester: "Semester 2",
    admissionDate: "2025-08-01",
    username: "student2",
    password: "f9b0f4439c27ee983de37943d0f7ee1a7bcf17849e79f64bf35049c636f32e70",
    photo: "default_avatar.svg",
    createdAt: new Date()
  },
  {
    studentId: 3,
    name: "Rohan Verma",
    fatherName: "Sanjay Verma",
    motherName: "Kavita Verma",
    dob: "2004-01-10",
    gender: "Male",
    mobile: "9876543212",
    email: "rohan.verma@example.com",
    address: "78 Civil Lines, Jaipur, Rajasthan",
    course: "B.Tech CSE",
    semester: "Semester 2",
    admissionDate: "2025-07-20",
    username: "student3",
    password: "f9b0f4439c27ee983de37943d0f7ee1a7bcf17849e79f64bf35049c636f32e70",
    photo: "default_avatar.svg",
    createdAt: new Date()
  },
  {
    studentId: 4,
    name: "Sneha Reddy",
    fatherName: "Venkatesh Reddy",
    motherName: "Lakshmi Reddy",
    dob: "2003-09-08",
    gender: "Female",
    mobile: "9876543213",
    email: "sneha.reddy@example.com",
    address: "H.No 4-55, Jubilee Hills, Hyderabad",
    course: "MBA",
    semester: "Semester 4",
    admissionDate: "2025-07-18",
    username: "student4",
    password: "f9b0f4439c27ee983de37943d0f7ee1a7bcf17849e79f64bf35049c636f32e70",
    photo: "default_avatar.svg",
    createdAt: new Date()
  },
  {
    studentId: 5,
    name: "Vikram Singh",
    fatherName: "Ranbir Singh",
    motherName: "Geeta Singh",
    dob: "2002-03-25",
    gender: "Male",
    mobile: "9876543214",
    email: "vikram.singh@example.com",
    address: "Block C, Sector 15, Chandigarh",
    course: "B.Sc",
    semester: "Semester 6",
    admissionDate: "2024-07-12",
    username: "student5",
    password: "f9b0f4439c27ee983de37943d0f7ee1a7bcf17849e79f64bf35049c636f32e70",
    photo: "default_avatar.svg",
    createdAt: new Date()
  },
  {
    studentId: 6,
    name: "Ananya Iyer",
    fatherName: "Subramanian Iyer",
    motherName: "Radha Iyer",
    dob: "2003-12-14",
    gender: "Female",
    mobile: "9876543215",
    email: "ananya.iyer@example.com",
    address: "24 Gandhi Road, Chennai, Tamil Nadu",
    course: "M.Tech",
    semester: "Semester 2",
    admissionDate: "2025-08-10",
    username: "student6",
    password: "f9b0f4439c27ee983de37943d0f7ee1a7bcf17849e79f64bf35049c636f32e70",
    photo: "default_avatar.svg",
    createdAt: new Date()
  }
]);
db.students.createIndex({ username: 1 }, { unique: true });
db.students.createIndex({ studentId: 1 }, { unique: true });

// 5. Room Allocations Collection
db.room_allocations.insertMany([
  { allocationId: 1, studentId: 1, roomId: 1, allocationDate: "2025-07-16", vacateDate: null, status: "Active", createdAt: new Date() },
  { allocationId: 2, studentId: 2, roomId: 2, allocationDate: "2025-08-02", vacateDate: null, status: "Active", createdAt: new Date() },
  { allocationId: 3, studentId: 3, roomId: 2, allocationDate: "2025-08-02", vacateDate: null, status: "Active", createdAt: new Date() },
  { allocationId: 4, studentId: 4, roomId: 3, allocationDate: "2025-07-19", vacateDate: null, status: "Active", createdAt: new Date() },
  { allocationId: 5, studentId: 5, roomId: 4, allocationDate: "2024-07-15", vacateDate: null, status: "Active", createdAt: new Date() }
]);
db.room_allocations.createIndex({ allocationId: 1 }, { unique: true });
db.room_allocations.createIndex({ studentId: 1 });

// 6. Fees Collection
db.fees.insertMany([
  { feeId: 1, studentId: 1, totalFee: 45000.0, paidAmount: 45000.0, dueAmount: 0.0, paymentDate: "2025-07-16", paymentMode: "Razorpay Online (UPI/Card)", receiptNumber: "REC-2025-001", paymentStatus: "PAID", razorpayPaymentId: "pay_test_001", razorpayOrderId: "order_test_001", createdAt: new Date() },
  { feeId: 2, studentId: 2, totalFee: 40000.0, paidAmount: 25000.0, dueAmount: 15000.0, paymentDate: "2025-08-02", paymentMode: "Razorpay Online (UPI/Card)", receiptNumber: "REC-2025-002", paymentStatus: "PAID", razorpayPaymentId: "pay_test_002", razorpayOrderId: "order_test_002", createdAt: new Date() },
  { feeId: 3, studentId: 3, totalFee: 40000.0, paidAmount: 40000.0, dueAmount: 0.0, paymentDate: "2025-08-03", paymentMode: "Cash", receiptNumber: "REC-2025-003", paymentStatus: "PAID", razorpayPaymentId: null, razorpayOrderId: null, createdAt: new Date() },
  { feeId: 4, studentId: 4, totalFee: 40000.0, paidAmount: 20000.0, dueAmount: 20000.0, paymentDate: "2025-07-20", paymentMode: "Razorpay Online (UPI/Card)", receiptNumber: "REC-2025-004", paymentStatus: "PAID", razorpayPaymentId: "pay_test_004", razorpayOrderId: "order_test_004", createdAt: new Date() },
  { feeId: 5, studentId: 5, totalFee: 35000.0, paidAmount: 35000.0, dueAmount: 0.0, paymentDate: "2025-07-15", paymentMode: "Razorpay Online (UPI/Card)", receiptNumber: "REC-2025-005", paymentStatus: "PAID", razorpayPaymentId: "pay_test_005", razorpayOrderId: "order_test_005", createdAt: new Date() }
]);
db.fees.createIndex({ feeId: 1 }, { unique: true });
db.fees.createIndex({ receiptNumber: 1 }, { unique: true });
db.fees.createIndex({ studentId: 1 });

// 7. Payments Collection (Dedicated Razorpay Payment Log)
db.payments.insertMany([
  { paymentId: "PAY0001", razorpayOrderId: "order_test_001", razorpayPaymentId: "pay_test_001", studentId: 1, studentName: "Aarav Sharma", amount: 45000.0, currency: "INR", paymentStatus: "SUCCESS", paymentDate: new Date(), paymentMethod: "UPI", signatureVerificationStatus: true, receiptNumber: "REC-2025-001", createdAt: new Date() },
  { paymentId: "PAY0002", razorpayOrderId: "order_test_002", razorpayPaymentId: "pay_test_002", studentId: 2, studentName: "Priya Patel", amount: 25000.0, currency: "INR", paymentStatus: "SUCCESS", paymentDate: new Date(), paymentMethod: "Cards", signatureVerificationStatus: true, receiptNumber: "REC-2025-002", createdAt: new Date() }
]);
db.payments.createIndex({ paymentId: 1 }, { unique: true });
db.payments.createIndex({ razorpayPaymentId: 1 }, { unique: true, sparse: true });

// 8. Complaints Collection
db.complaints.insertMany([
  { complaintId: 1, studentId: 1, category: "Electricity Problem", subject: "Ceiling fan making squeaking noise", description: "The ceiling fan in Room 101 rotates very slowly and makes loud noises.", complaintDate: new Date(), status: "Resolved", adminResponse: "Electrician replaced the fan capacitor and lubricated the motor bearing. Working fine now.", resolvedDate: new Date() },
  { complaintId: 2, studentId: 2, category: "Water Problem", subject: "Low water pressure in bathroom geyser", description: "Hot water flow in Room 102 attached bathroom is very low in morning hours.", complaintDate: new Date(), status: "In Progress", adminResponse: "Plumbing team has inspected pipeline and descaling is scheduled.", resolvedDate: null },
  { complaintId: 3, studentId: 3, category: "Maintenance Problem", subject: "Study table drawer lock broken", description: "The study table drawer key is stuck inside the lock cylinder.", complaintDate: new Date(), status: "Pending", adminResponse: null, resolvedDate: null }
]);
db.complaints.createIndex({ complaintId: 1 }, { unique: true });
db.complaints.createIndex({ studentId: 1 });

// 9. Sequence Counters Collection
db.counters.insertMany([
  { _id: "studentId", seq: 6 },
  { _id: "roomId", seq: 8 },
  { _id: "allocationId", seq: 5 },
  { _id: "feeId", seq: 5 },
  { _id: "complaintId", seq: 3 },
  { _id: "paymentId", seq: 2 }
]);

print("HostelSphere MongoDB Initialization & Demo Seed Completed Successfully!");
