const Record = artifacts.require("Record");

contract("Record", accounts => {
  let instance;

  const [owner, patient1, patient2, doctor1, doctor2, patient3, doctor3, patient4, patient5, patient6] = accounts;

  beforeEach(async () => {
    instance = await Record.new(); // Fresh contract for each test
  });

  it("should register a patient", async () => {
    await instance.setDetails(
      "IC123", "John Doe", "1234567890", "Male", "1990-01-01",
      "180cm", "75kg", "123 Street", "O+", "Peanuts", "Ibuprofen",
      "Jane Doe", "0987654321", { from: patient1 }
    );

    const data = await instance.searchPatientDemographic(patient1, { from: patient1 });
    assert.equal(data[1], "John Doe", "Patient name should be saved");
  });

  it("should register a doctor", async () => {
    await instance.setDoctor(
      "IC456", "Dr. Smith", "9876543210", "Female", "1980-06-01",
      "MBBS", "Cardiology", { from: doctor1 }
    );

    const doc = await instance.searchDoctor(doctor1, { from: doctor1 });
    assert.equal(doc[1], "Dr. Smith", "Doctor name should be saved");
  });

  it("allows patient to edit their record", async () => {
    await instance.setDetails(
      "001", "Sam", "0123456789", "Male", "1988-08-08",
      "170", "65", "Old Addr", "A-", "Peanuts", "Aspirin", "Leo", "0131122334",
      { from: patient2 }
    );

    await instance.editDetails(
      "001", "Sam Edited", "0987654321", "Male", "1988-08-08",
      "170", "65", "New Addr", "A-", "None", "None", "Leo", "0131122334",
      { from: patient2 }
    );

    const updated = await instance.searchPatientDemographic(patient2, { from: patient2 });
    assert.equal(updated[1], "Sam Edited", "Patient name should be updated");
  });

  it("allows a doctor to edit their profile", async () => {
    await instance.setDoctor(
      "002", "Dr. Jane", "0198887777", "Female", "1985-03-03",
      "MD", "Oncology", { from: doctor2 }
    );

    await instance.editDoctor(
      "002", "Dr. Jane Updated", "0199990000", "Female", "1985-03-03",
      "MD", "Oncology", { from: doctor2 }
    );

    const doctor = await instance.searchDoctor(doctor2, { from: doctor2 });
    assert.equal(doctor[1], "Dr. Jane Updated", "Doctor name should be updated");
  });

  it("prevents one doctor from editing another doctor's profile", async () => {
    await instance.setDoctor(
      "003", "Dr. A", "012", "Male", "1970-01-01", "MBBS", "Cardiology", { from: doctor1 }
    );

    await instance.setDoctor(
      "004", "Dr. B", "013", "Female", "1980-02-02", "MBBS", "Pediatrics", { from: doctor2 }
    );

    try {
      await instance.editDoctor(
        "004", "Dr. B Updated", "014", "Female", "1980-02-02", "MBBS", "Pediatrics",
        { from: doctor1 }
      );
      assert(false);
    } catch (err) {
      assert(err.message.includes("Unauthorized") || err.message.includes("Not registered doctor"), "Access should be denied");
    }
  });

  it("allows patient to grant and revoke permission to doctor", async () => {
    await instance.setDetails(
      "005", "Alice", "0198881111", "Female", "1994-04-04",
      "160", "50", "789 Road", "B+", "None", "None", "Nina", "0131122334",
      { from: patient3 }
    );

    await instance.setDoctor(
      "006", "Dr. Access", "015", "Male", "1975-12-12", "MBBS", "General", { from: doctor3 }
    );

    await instance.givePermission(doctor3, { from: patient3 });

    const data = await instance.searchPatientDemographic(patient3, { from: doctor3 });
    assert.equal(data[1], "Alice", "Doctor should be able to access after permission granted");

    await instance.RevokePermission(doctor3, { from: patient3 });

    try {
      await instance.searchPatientDemographic(patient3, { from: doctor3 });
      assert(false);
    } catch (err) {
      assert(err.message.includes("Access denied"), "Access should be denied after revocation");
    }
  });

  it("allows a doctor to create and retrieve an appointment", async () => {
    await instance.setDetails(
      "007", "Ben", "0191234567", "Male", "1990-01-01",
      "175", "70", "123 Home", "AB", "None", "None", "Emma", "0111111111",
      { from: patient4 }
    );

    await instance.setDoctor(
      "008", "Dr. Appoint", "016", "Male", "1980-11-11", "MD", "Dermatology", { from: doctor1 }
    );

    await instance.setAppointment(
      patient4, "2025-06-15", "10:30 AM", "Skin Infection", "Amoxicillin", "Topical Treatment", "Pending",
      { from: doctor1 }
    );

    const appointments = await instance.getAppointments({ from: doctor1 });
    const appointment = await instance.searchAppointment(appointments[0], { from: doctor1 });

    assert.equal(appointment[4], "Skin Infection");
    assert.equal(appointment[5], "Amoxicillin");
  });

  it("counts the number of registered patients correctly", async () => {
    const beforeCount = await instance.getPatientCount();

    await instance.setDetails(
      "009", "User1", "0190000000", "Male", "1995-01-01",
      "180", "80", "One Place", "A+", "None", "None", "Someone", "0101010101",
      { from: patient5 }
    );

    const afterCount = await instance.getPatientCount();
    assert.equal(afterCount.toNumber(), beforeCount.toNumber() + 1);
  });

  it("supports multiple patients registering with different accounts", async () => {
    await instance.setDetails(
      "010", "Multi1", "0190000001", "Male", "1996-01-01",
      "170", "75", "Addr 1", "B-", "None", "None", "Ref1", "0123456789",
      { from: accounts[8] }
    );

    await instance.setDetails(
      "011", "Multi2", "0190000002", "Female", "1997-01-01",
      "165", "60", "Addr 2", "O+", "None", "None", "Ref2", "0987654321",
      { from: accounts[9] }
    );

    const allPatients = await instance.getPatients();
    assert.include(allPatients, accounts[8], "Patient 1 should be in the list");
    assert.include(allPatients, accounts[9], "Patient 2 should be in the list");
  });

  // --- IPFS File Tests ---

  it("allows patient to upload their file", async () => {
    await instance.setDetails(
      "012", "PatientFileTest", "0191111111", "Female", "1992-02-02",
      "165", "60", "Home 12", "B+", "None", "None", "Ref", "0123456789",
      { from: patient1 }
    );

    await instance.uploadPatientFile("QmPatientFileHash123", { from: patient1 });

    const files = await instance.getPatientFiles(patient1, { from: patient1 });
    assert.include(files, "QmPatientFileHash123", "Patient's IPFS file should be retrievable");
  });

  it("allows doctor to upload file to patient's record with permission", async () => {
    await instance.setDetails(
      "013", "PermPatient", "0192222222", "Male", "1993-03-03",
      "175", "70", "Home 13", "A-", "None", "None", "Ref", "0987654321",
      { from: patient2 }
    );

    await instance.setDoctor(
      "014", "Dr. IPFS", "0123444555", "Male", "1975-05-05", "MBBS", "General",
      { from: doctor1 }
    );

    await instance.givePermission(doctor1, { from: patient2 });

    await instance.uploadPatientFileByDoctor(patient2, "QmDoctorToPatientFile", { from: doctor1 });

    const files = await instance.getPatientFiles(patient2, { from: doctor1 });
    assert.include(files, "QmDoctorToPatientFile", "Doctor should upload file with permission");
  });

  it("allows doctor to upload file to appointment", async () => {
    await instance.setDetails(
      "015", "AppFilePatient", "0193333333", "Female", "1994-04-04",
      "160", "55", "Home 14", "AB+", "None", "None", "Ref", "0111111111",
      { from: patient3 }
    );

    await instance.setDoctor(
      "016", "Dr. AppFile", "0177888999", "Female", "1980-08-08", "MBBS", "ENT",
      { from: doctor2 }
    );

    await instance.setAppointment(
      patient3, "2025-06-20", "2:00 PM", "Checkup", "None", "Routine", "Scheduled",
      { from: doctor2 }
    );

    const apptIds = await instance.getAppointments({ from: doctor2 });
    const appointmentId = apptIds[0].toNumber();

    await instance.uploadAppointmentFile(appointmentId, "QmAppFileHash", { from: doctor2 });

    const appFiles = await instance.getAppointmentFiles(appointmentId, { from: doctor2 });
    assert.include(appFiles, "QmAppFileHash", "Appointment file should be saved and retrievable");
  });
});
//0xaaCc964d3f158C550ba2A9d9C479a6e9B5EA4623