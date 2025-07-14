// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Record {

    struct Patient {
        string ic;
        string name;
        string phone;
        string gender;
        string dob;
        string height;
        string weight;
        string houseaddr;
        string bloodgroup;
        string allergies;
        string medication;
        string emergencyName;
        string emergencyContact;
        address addr;
        uint date;
    }

    struct Doctor {
        string ic;
        string name;
        string phone;
        string gender;
        string dob;
        string qualification;
        string major;
        address addr;
        uint date;
    }

    struct Appointment {
        uint id;
        address doctoraddr;
        address patientaddr;
        string date;
        string time;
        string prescription;
        string description;
        string diagnosis;
        string status;
        uint creationDate;
    }

    address public owner;

    mapping(address => Patient) public patients;
    mapping(address => Doctor) public doctors;
    mapping(uint => Appointment) public appointments;
    mapping(address => bool) public isPatient;
    mapping(address => bool) public isDoctor;
    mapping(address => mapping(address => bool)) public isApproved;

    address[] public patientList;
    address[] public doctorList;
    uint[] public appointmentIds;

    mapping(address => uint) public AppointmentPerPatient;

    uint public patientCount;
    uint public doctorCount;
    uint public appointmentCount;
    uint public permissionGrantedCount;

    // IPFS mappings
    mapping(address => string[]) public patientFiles;
    mapping(uint => string[]) public appointmentFiles;

    modifier onlyPatient() {
        require(isPatient[msg.sender], "Not registered patient");
        _;
    }

    modifier onlyDoctor() {
        require(isDoctor[msg.sender], "Not registered doctor");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setDetails(
        string memory _ic, string memory _name, string memory _phone, string memory _gender, string memory _dob,
        string memory _height, string memory _weight, string memory _houseaddr, string memory _bloodgroup,
        string memory _allergies, string memory _medication, string memory _emergencyName, string memory _emergencyContact
    ) external {
        require(!isPatient[msg.sender], "Already registered");

        patients[msg.sender] = Patient({
            ic: _ic,
            name: _name,
            phone: _phone,
            gender: _gender,
            dob: _dob,
            height: _height,
            weight: _weight,
            houseaddr: _houseaddr,
            bloodgroup: _bloodgroup,
            allergies: _allergies,
            medication: _medication,
            emergencyName: _emergencyName,
            emergencyContact: _emergencyContact,
            addr: msg.sender,
            date: block.timestamp
        });

        patientList.push(msg.sender);
        isPatient[msg.sender] = true;
        isApproved[msg.sender][msg.sender] = true;
        patientCount++;
    }

    function editDetails(
        string memory _ic, string memory _name, string memory _phone, string memory _gender, string memory _dob,
        string memory _height, string memory _weight, string memory _houseaddr, string memory _bloodgroup,
        string memory _allergies, string memory _medication, string memory _emergencyName, string memory _emergencyContact
    ) external onlyPatient {
        Patient storage p = patients[msg.sender];

        p.ic = _ic;
        p.name = _name;
        p.phone = _phone;
        p.gender = _gender;
        p.dob = _dob;
        p.height = _height;
        p.weight = _weight;
        p.houseaddr = _houseaddr;
        p.bloodgroup = _bloodgroup;
        p.allergies = _allergies;
        p.medication = _medication;
        p.emergencyName = _emergencyName;
        p.emergencyContact = _emergencyContact;
    }

    function setDoctor(
        string memory _ic, string memory _name, string memory _phone, string memory _gender, string memory _dob,
        string memory _qualification, string memory _major
    ) external {
        require(!isDoctor[msg.sender], "Already registered");

        doctors[msg.sender] = Doctor({
            ic: _ic,
            name: _name,
            phone: _phone,
            gender: _gender,
            dob: _dob,
            qualification: _qualification,
            major: _major,
            addr: msg.sender,
            date: block.timestamp
        });

        doctorList.push(msg.sender);
        isDoctor[msg.sender] = true;
        doctorCount++;
    }

    function editDoctor(
        string memory _ic, string memory _name, string memory _phone, string memory _gender, string memory _dob,
        string memory _qualification, string memory _major
    ) external onlyDoctor {
        Doctor storage d = doctors[msg.sender];

        d.ic = _ic;
        d.name = _name;
        d.phone = _phone;
        d.gender = _gender;
        d.dob = _dob;
        d.qualification = _qualification;
        d.major = _major;
    }

    function setAppointment(
        address _patient, string memory _date, string memory _time, string memory _diagnosis,
        string memory _prescription, string memory _description, string memory _status
    ) external onlyDoctor {
        appointmentCount++;
        appointments[appointmentCount] = Appointment({
            id: appointmentCount,
            doctoraddr: msg.sender,
            patientaddr: _patient,
            date: _date,
            time: _time,
            diagnosis: _diagnosis,
            prescription: _prescription,
            description: _description,
            status: _status,
            creationDate: block.timestamp
        });

        appointmentIds.push(appointmentCount);
        AppointmentPerPatient[_patient]++;
    }

    function updateAppointment(
        uint _id, string memory _date, string memory _time, string memory _diagnosis,
        string memory _prescription, string memory _description, string memory _status
    ) external onlyDoctor {
        Appointment storage a = appointments[_id];
        require(a.doctoraddr == msg.sender, "Unauthorized");

        a.date = _date;
        a.time = _time;
        a.diagnosis = _diagnosis;
        a.prescription = _prescription;
        a.description = _description;
        a.status = _status;
    }

    function givePermission(address _doctor) external returns (bool) {
        isApproved[msg.sender][_doctor] = true;
        permissionGrantedCount++;
        return true;
    }

    function RevokePermission(address _doctor) external returns (bool) {
        isApproved[msg.sender][_doctor] = false;
        return true;
    }

    function getPatients() external view returns (address[] memory) {
        return patientList;
    }

    function getDoctors() external view returns (address[] memory) {
        return doctorList;
    }

    function getAppointments() external view returns (uint[] memory) {
        return appointmentIds;
    }

    function searchPatientDemographic(address _address) external view returns (
        string memory, string memory, string memory, string memory, string memory, string memory, string memory
    ) {
        require(isApproved[_address][msg.sender], "Access denied");
        Patient storage p = patients[_address];
        return (p.ic, p.name, p.phone, p.gender, p.dob, p.height, p.weight);
    }

    function searchPatientMedical(address _address) external view returns (
        string memory, string memory, string memory, string memory, string memory, string memory
    ) {
        require(isApproved[_address][msg.sender], "Access denied");
        Patient storage p = patients[_address];
        return (p.houseaddr, p.bloodgroup, p.allergies, p.medication, p.emergencyName, p.emergencyContact);
    }

    function searchDoctor(address _address) external view returns (
        string memory, string memory, string memory, string memory, string memory, string memory, string memory
    ) {
        require(isDoctor[_address], "Not a registered doctor");
        Doctor storage d = doctors[_address];
        return (d.ic, d.name, d.phone, d.gender, d.dob, d.qualification, d.major);
    }

    function searchAppointment(uint _id) external view returns (
        address, string memory, string memory, string memory, string memory, string memory, string memory, string memory
    ) {
        Appointment storage a = appointments[_id];
        Doctor storage d = doctors[a.doctoraddr];
        return (a.doctoraddr, d.name, a.date, a.time, a.diagnosis, a.prescription, a.description, a.status);
    }

    function searchRecordDate(address _address) external view returns (uint) {
        return patients[_address].date;
    }

    function searchDoctorDate(address _address) external view returns (uint) {
        return doctors[_address].date;
    }

    function searchAppointmentDate(uint _id) external view returns (uint) {
        return appointments[_id].creationDate;
    }

    function getPatientCount() external view returns (uint) {
        return patientCount;
    }

    function getDoctorCount() external view returns (uint) {
        return doctorCount;
    }

    function getAppointmentCount() external view returns (uint) {
        return appointmentCount;
    }

    function getPermissionGrantedCount() external view returns (uint) {
        return permissionGrantedCount;
    }

    function getAppointmentPerPatient(address _address) external view returns (uint) {
        return AppointmentPerPatient[_address];
    }

    // New: Upload IPFS file by patient
    function uploadPatientFile(string memory ipfsHash) external onlyPatient {
        patientFiles[msg.sender].push(ipfsHash);
    }

    // New: Upload IPFS file by doctor with patient's permission
    function uploadPatientFileByDoctor(address _patient, string memory ipfsHash) external onlyDoctor {
        require(isApproved[_patient][msg.sender], "Doctor not authorized by patient");
        patientFiles[_patient].push(ipfsHash);
    }

    // New: Upload IPFS file to appointment
    function uploadAppointmentFile(uint appointmentId, string memory ipfsHash) external onlyDoctor {
        require(appointments[appointmentId].doctoraddr == msg.sender, "Not appointment owner");
        appointmentFiles[appointmentId].push(ipfsHash);
    }

    // New: Get patient file hashes
    function getPatientFiles(address _patient) external view returns (string[] memory) {
        require(
            msg.sender == _patient || isApproved[_patient][msg.sender],
            "Not authorized to view files"
        );
        return patientFiles[_patient];
    }

    // New: Get appointment file hashes
    function getAppointmentFiles(uint appointmentId) external view returns (string[] memory) {
        require(
            msg.sender == appointments[appointmentId].doctoraddr ||
            msg.sender == appointments[appointmentId].patientaddr,
            "Not authorized to view appointment files"
        );
        return appointmentFiles[appointmentId];
    }
}
