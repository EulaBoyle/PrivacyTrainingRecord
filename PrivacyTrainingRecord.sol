// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {FHE, euint64, eaddress, ebool} from "@fhevm/solidity/lib/FHE.sol";
import {SepoliaConfig} from "@fhevm/solidity/config/ZamaConfig.sol";

contract PrivacyTrainingRecord is SepoliaConfig {
    
    struct TrainingRecord {
        address employee;
        string employeeName;
        string trainingModule;
        ebool encryptedCompletion;
        ebool encryptedCertification;
        uint256 completionTime;
        uint256 expiryTime;
        bool isActive;
        uint256 score;
        string notes;
    }
    
    struct TrainingModule {
        string name;
        string description;
        uint256 duration; // in days
        bool isActive;
    }
    
    mapping(uint256 => TrainingRecord) public trainingRecords;
    mapping(string => TrainingModule) public trainingModules;
    mapping(address => uint256[]) public employeeRecords;
    mapping(address => bool) public authorizedTrainers;
    
    uint256 public recordCounter;
    address public admin;
    
    event TrainingRecordCreated(uint256 indexed recordId, address indexed employee, string trainingModule);
    event TrainingCompleted(uint256 indexed recordId, address indexed employee, bool passed);
    event TrainerAuthorized(address indexed trainer);
    event TrainerRevoked(address indexed trainer);
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }
    
    modifier onlyAuthorizedTrainer() {
        require(authorizedTrainers[msg.sender] || msg.sender == admin, "Not authorized trainer");
        _;
    }
    
    constructor() {
        admin = msg.sender;
        authorizedTrainers[msg.sender] = true;
        
        // Initialize default training modules
        trainingModules["data-privacy"] = TrainingModule({
            name: "Data Privacy Fundamentals",
            description: "Basic data privacy principles and regulations",
            duration: 30,
            isActive: true
        });
        
        trainingModules["gdpr-compliance"] = TrainingModule({
            name: "GDPR Compliance",
            description: "General Data Protection Regulation compliance training",
            duration: 45,
            isActive: true
        });
        
        trainingModules["security-awareness"] = TrainingModule({
            name: "Security Awareness",
            description: "Cybersecurity best practices and threat awareness",
            duration: 60,
            isActive: true
        });
        
        trainingModules["incident-response"] = TrainingModule({
            name: "Incident Response",
            description: "How to respond to privacy and security incidents",
            duration: 30,
            isActive: true
        });
    }
    
    function authorizeTrainer(address _trainer) external onlyAdmin {
        authorizedTrainers[_trainer] = true;
        emit TrainerAuthorized(_trainer);
    }
    
    function revokeTrainer(address _trainer) external onlyAdmin {
        authorizedTrainers[_trainer] = false;
        emit TrainerRevoked(_trainer);
    }
    
    function addTrainingModule(
        string calldata _moduleId,
        string calldata _name,
        string calldata _description,
        uint256 _duration
    ) external onlyAdmin {
        trainingModules[_moduleId] = TrainingModule({
            name: _name,
            description: _description,
            duration: _duration,
            isActive: true
        });
    }
    
    function createTrainingRecord(
        address _employee,
        string calldata _employeeName,
        string calldata _trainingModule
    ) external onlyAuthorizedTrainer returns (uint256) {
        require(trainingModules[_trainingModule].isActive, "Training module not active");
        
        uint256 recordId = recordCounter++;
        TrainingRecord storage record = trainingRecords[recordId];
        
        record.employee = _employee;
        record.employeeName = _employeeName;
        record.trainingModule = _trainingModule;
        record.encryptedCompletion = FHE.asEbool(false);
        record.encryptedCertification = FHE.asEbool(false);
        record.completionTime = 0;
        record.expiryTime = 0;
        record.isActive = true;
        record.score = 0;
        record.notes = "";
        
        FHE.allowThis(record.encryptedCompletion);
        FHE.allowThis(record.encryptedCertification);
        FHE.allow(record.encryptedCompletion, _employee);
        FHE.allow(record.encryptedCertification, _employee);
        
        employeeRecords[_employee].push(recordId);
        
        emit TrainingRecordCreated(recordId, _employee, _trainingModule);
        return recordId;
    }
    
    function completeTraining(
        uint256 _recordId,
        bool _completed,
        bool _certified,
        uint256 _score,
        string calldata _notes
    ) external onlyAuthorizedTrainer {
        TrainingRecord storage record = trainingRecords[_recordId];
        require(record.isActive, "Record not active");
        
        record.encryptedCompletion = FHE.asEbool(_completed);
        record.encryptedCertification = FHE.asEbool(_certified);
        record.completionTime = block.timestamp;
        record.score = _score;
        record.notes = _notes;
        
        if (_completed) {
            TrainingModule memory module = trainingModules[record.trainingModule];
            record.expiryTime = block.timestamp + (module.duration * 1 days);
        }
        
        FHE.allowThis(record.encryptedCompletion);
        FHE.allowThis(record.encryptedCertification);
        FHE.allow(record.encryptedCompletion, record.employee);
        FHE.allow(record.encryptedCertification, record.employee);
        
        emit TrainingCompleted(_recordId, record.employee, _completed);
    }
    
    function getEmployeeTrainingStatus(address _employee) 
        external 
        view 
        returns (uint256[] memory) 
    {
        return employeeRecords[_employee];
    }
    
    function getTrainingRecord(uint256 _recordId) 
        external 
        view 
        returns (
            address employee,
            string memory employeeName,
            string memory trainingModule,
            uint256 completionTime,
            uint256 expiryTime,
            bool isActive,
            uint256 score,
            string memory notes
        ) 
    {
        TrainingRecord storage record = trainingRecords[_recordId];
        require(
            msg.sender == record.employee || 
            authorizedTrainers[msg.sender] || 
            msg.sender == admin,
            "Not authorized to view this record"
        );
        
        return (
            record.employee,
            record.employeeName,
            record.trainingModule,
            record.completionTime,
            record.expiryTime,
            record.isActive,
            record.score,
            record.notes
        );
    }
    
    function getEncryptedCompletion(uint256 _recordId) 
        external 
        view 
        returns (ebool) 
    {
        TrainingRecord storage record = trainingRecords[_recordId];
        require(
            msg.sender == record.employee || 
            authorizedTrainers[msg.sender] || 
            msg.sender == admin,
            "Not authorized"
        );
        return record.encryptedCompletion;
    }
    
    function getEncryptedCertification(uint256 _recordId) 
        external 
        view 
        returns (ebool) 
    {
        TrainingRecord storage record = trainingRecords[_recordId];
        require(
            msg.sender == record.employee || 
            authorizedTrainers[msg.sender] || 
            msg.sender == admin,
            "Not authorized"
        );
        return record.encryptedCertification;
    }
    
    function isTrainingExpired(uint256 _recordId) 
        external 
        view 
        returns (bool) 
    {
        TrainingRecord storage record = trainingRecords[_recordId];
        if (record.expiryTime == 0) return false;
        return block.timestamp > record.expiryTime;
    }
    
    function getActiveTrainingModules() 
        external 
        view 
        returns (
            string[] memory moduleIds,
            string[] memory names,
            string[] memory descriptions,
            uint256[] memory durations
        ) 
    {
        // For simplicity, return the predefined modules
        moduleIds = new string[](4);
        names = new string[](4);
        descriptions = new string[](4);
        durations = new uint256[](4);
        
        moduleIds[0] = "data-privacy";
        names[0] = trainingModules["data-privacy"].name;
        descriptions[0] = trainingModules["data-privacy"].description;
        durations[0] = trainingModules["data-privacy"].duration;
        
        moduleIds[1] = "gdpr-compliance";
        names[1] = trainingModules["gdpr-compliance"].name;
        descriptions[1] = trainingModules["gdpr-compliance"].description;
        durations[1] = trainingModules["gdpr-compliance"].duration;
        
        moduleIds[2] = "security-awareness";
        names[2] = trainingModules["security-awareness"].name;
        descriptions[2] = trainingModules["security-awareness"].description;
        durations[2] = trainingModules["security-awareness"].duration;
        
        moduleIds[3] = "incident-response";
        names[3] = trainingModules["incident-response"].name;
        descriptions[3] = trainingModules["incident-response"].description;
        durations[3] = trainingModules["incident-response"].duration;
    }
}