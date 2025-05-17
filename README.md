# Decentralized Environmental Compliance Monitoring System (DECMS)

## Overview

The Decentralized Environmental Compliance Monitoring System (DECMS) is a blockchain-based platform that revolutionizes how industrial facilities monitor, verify, and report environmental compliance data. By leveraging smart contracts, IoT sensor integration, and tamper-proof record-keeping, DECMS creates a transparent, auditable system that benefits regulators, facilities, and the public while ensuring environmental protection standards are met.

## Core Components

### 1. Facility Verification Contract

The Facility Verification Contract establishes a trusted registry of industrial sites with verified identity and operational parameters.

**Key Features:**
- Cryptographically secure facility registration and authentication
- Multi-signature verification process involving regulators and third-party auditors
- Storage of essential facility metadata including:
    - Geographic coordinates and physical boundaries
    - Industry classification and operational parameters
    - Regulatory jurisdiction and applicable standards
    - Historical compliance record
- Revocation and suspension mechanisms for non-compliant facilities
- Integration with existing governmental facility ID systems

```solidity
struct Facility {
    address facilityAddress;
    string facilityName;
    string facilityId;            // Government-issued ID
    string industryType;
    string[] applicableRegulations;
    string geographicData;        // GeoJSON data
    address[] authorizedPersonnel;
    bool isVerified;
    uint256 verificationTimestamp;
    address verifiedBy;           // Regulatory authority address
    bool isSuspended;
    string metadataURI;           // IPFS hash for additional documentation
}
```

### 2. Permit Management Contract

The Permit Management Contract maintains an immutable record of authorized emission thresholds and operational constraints for each facility.

**Key Features:**
- Digital representation of environmental permits with full versioning
- Structured parameters for allowed emissions by type and quantity
- Time-bound permit validity with renewal process
- Conditional permit logic with seasonal or operational variations
- Amendment history with authority signatures
- Cross-referencing with regulatory standards across jurisdictions
- Integration with fee payment and financial compliance

```solidity
struct Permit {
    uint256 permitId;
    address facilityAddress;
    string permitType;
    uint256 issueDate;
    uint256 expirationDate;
    mapping(string => uint256) emissionLimits;  // Pollutant type -> limit in standardized units
    string[] conditionalRequirements;
    address issuingAuthority;
    uint256 lastAmendmentDate;
    string amendmentHistory;      // IPFS hash for amendment documentation
    bool isActive;
    string permitDocumentURI;     // IPFS hash for original permit document
}
```

### 3. Sensor Data Contract

The Sensor Data Contract securely captures, validates, and stores environmental monitoring data from IoT devices and manual inputs.

**Key Features:**
- Secure data ingestion from trusted IoT sensor networks
- Cryptographic verification of data source and integrity
- Tamper-proof storage of time-series environmental metrics
- Support for multiple pollutant types and measurement units
- Data validation against calibration standards
- Management of sensor metadata and calibration records
- Handling of data corrections with full audit trail

```solidity
struct SensorReading {
    uint256 readingId;
    address facilityAddress;
    string sensorId;
    string metricType;        // e.g., "NOx", "PM2.5", "CO2"
    uint256 timestamp;
    uint256 value;
    string unit;              // e.g., "mg/m3", "ppm"
    uint8 accuracyPercentage;
    string dataHash;          // Hash of raw sensor data
    bool isManualEntry;
    bool isCorrected;
    uint256 correctionTimestamp;
    string correctionReason;
    string rawDataURI;        // IPFS hash for raw data
}
```

### 4. Violation Detection Contract

The Violation Detection Contract automatically identifies and records potential regulatory breaches based on permit conditions and sensor data.

**Key Features:**
- Real-time comparison of sensor data against permit thresholds
- Implementation of complex compliance rules and calculations
- Detection of various violation types:
    - Instantaneous exceedances
    - Time-weighted average violations
    - Reporting deadline breaches
    - Equipment malfunction events
- Classification of violation severity and regulatory impact
- Integration with notification systems for immediate alerts
- Dispute resolution mechanisms for contested violations
- Correlation with operational data for root cause analysis

```solidity
enum ViolationType {
    INSTANTANEOUS_EXCEEDANCE,
    TIME_WEIGHTED_AVERAGE,
    REPORTING_FAILURE,
    EQUIPMENT_MALFUNCTION,
    PERMIT_CONDITION_BREACH
}

enum SeverityLevel {
    MINOR,
    MODERATE,
    MAJOR,
    CRITICAL
}

struct Violation {
    uint256 violationId;
    address facilityAddress;
    ViolationType violationType;
    SeverityLevel severityLevel;
    uint256 detectionTimestamp;
    string metricType;
    uint256 recordedValue;
    uint256 thresholdValue;
    uint256 exceedancePercentage;
    string[] relatedReadingIds;
    bool isConfirmed;
    bool isDisputed;
    string remediationPlan;
    uint256 resolutionTimestamp;
    string evidenceURI;       // IPFS hash for violation evidence
}
```

### 5. Reporting Contract

The Reporting Contract generates authenticated compliance disclosures for regulatory submissions and public transparency.

**Key Features:**
- Automated generation of compliance reports at required intervals
- Digital signatures from facility operators and regulators
- Customizable report templates for different jurisdictions
- Public and private reporting capabilities with selective disclosure
- Integration with regulatory filing systems via API
- Comprehensive audit trail for report generation and submission
- Analytics capabilities for trend analysis and benchmarking
- Support for different reporting formats (PDF, structured data)

```solidity
enum ReportStatus {
    DRAFT,
    SUBMITTED,
    ACCEPTED,
    REJECTED,
    AMENDED
}

struct ComplianceReport {
    uint256 reportId;
    address facilityAddress;
    string reportType;
    uint256 reportingPeriodStart;
    uint256 reportingPeriodEnd;
    uint256 generationTimestamp;
    uint256 submissionTimestamp;
    ReportStatus status;
    string[] includedMetrics;
    uint256[] detectedViolations;
    address[] signatories;
    mapping(address => bool) hasSigned;
    string reportDataURI;     // IPFS hash for complete report data
    string publicDisclosureURI;  // IPFS hash for public version
    string feedbackURI;       // IPFS hash for regulatory feedback
}
```

## Technical Architecture

DECMS is built on a hybrid architecture that combines blockchain security with high-performance data processing:

- **Blockchain Layer**: Ethereum-compatible network (mainnet or dedicated sidechain)
- **Data Storage**: Combination of on-chain critical records and IPFS for large datasets
- **Oracle Network**: Chainlink for secure external data feeds and API connections
- **IoT Integration**: Secure sensor network with tamper-proof hardware integration
- **Analytics Engine**: Off-chain processing for complex compliance calculations
- **API Layer**: REST interfaces for integration with existing environmental systems
- **Identity Layer**: Decentralized identity solutions for secure authentication

## System Diagram

```
┌──────────────────┐         ┌─────────────────┐         ┌───────────────┐
│                  │         │                 │         │               │
│  IoT Sensors     │━━━━━━━━▶│  Oracle Network │━━━━━━━━▶│ Sensor Data   │
│  & Monitoring    │         │  (Chainlink)    │         │ Contract      │
│                  │         │                 │         │               │
└──────────────────┘         └─────────────────┘         └───────┳───────┘
                                                                 ┃
                                                                 ▼
┌──────────────────┐         ┌─────────────────┐         ┌───────────────┐
│                  │         │                 │         │               │
│  Regulatory      │━━━━━━━━▶│  Facility       │◀━━━━━━━▶│ Permit        │
│  Authorities     │         │  Verification   │         │ Management    │
│                  │         │  Contract       │         │ Contract      │
└──────────────────┘         └─────────────────┘         └───────┳───────┘
                                      ┃                          ┃
                                      ▼                          ▼
┌──────────────────┐         ┌─────────────────┐         ┌───────────────┐
│                  │         │                 │         │               │
│  Facility        │◀━━━━━━━▶│  Violation      │◀━━━━━━━▶│ Reporting     │
│  Operators       │         │  Detection      │         │ Contract      │
│                  │         │  Contract       │         │               │
└──────────────────┘         └─────────────────┘         └───────────────┘
                                      ┃                          ┃
                                      ▼                          ▼
┌──────────────────┐         ┌─────────────────┐         ┌───────────────┐
│                  │         │                 │         │               │
│  Public          │◀━━━━━━━▶│  IPFS Storage   │◀━━━━━━━▶│ Regulatory    │
│  Stakeholders    │         │  (Documents)    │         │ Systems       │
│                  │         │                 │         │               │
└──────────────────┘         └─────────────────┘         └───────────────┘
```

## Getting Started

### Prerequisites

- Node.js (v16+)
- Hardhat or Truffle development framework
- MetaMask or similar Web3 provider
- IoT sensor development kit (for testing)

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/decms.git

# Navigate to project directory
cd decms

# Install dependencies
npm install

# Compile smart contracts
npx hardhat compile

# Run tests
npx hardhat test

# Deploy to local blockchain
npx hardhat run scripts/deploy.js --network localhost

# Start the frontend application
cd frontend
npm install
npm start
```

### Configuration

Configure the system by modifying the `config.js` file:

```javascript
module.exports = {
  // Network configuration
  networks: {
    development: {
      url: "http://localhost:8545",
    },
    goerli: {
      url: process.env.GOERLI_RPC_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
  
  // System parameters
  systemParams: {
    minSensorUpdateFrequency: 300,  // seconds
    maxReportingDelay: 86400,       // 24 hours in seconds
    violationConfirmationPeriod: 7200,  // 2 hours in seconds
    requiredAuthorities: 2,         // Number of authorities needed for verification
  },
  
  // Supported pollutant types and units
  pollutants: {
    "NOx": {
      units: ["mg/m3", "ppm"],
      conversionFactor: 1.88,  // mg/m3 per ppm at standard conditions
      defaultThreshold: 200    // Default limit in mg/m3
    },
    "SO2": {
      units: ["mg/m3", "ppm"],
      conversionFactor: 2.62,
      defaultThreshold: 350
    },
    "PM2.5": {
      units: ["μg/m3"],
      defaultThreshold: 25
    },
    // Additional pollutants...
  },
  
  // Regulatory jurisdiction configurations
  jurisdictions: {
    "US-EPA": {
      reportingPeriods: {
        "quarterly": 7776000,  // 90 days in seconds
        "annual": 31536000     // 365 days in seconds
      },
      requiredReports: ["emissions", "malfunctions", "exceedances"]
    },
    "EU-ETS": {
      reportingPeriods: {
        "monthly": 2592000,    // 30 days in seconds
        "annual": 31536000
      },
      requiredReports: ["ghg-emissions", "energy-consumption"]
    },
    // Additional jurisdictions...
  }
};
```

## Usage Examples

### Registering a New Facility

```javascript
const FacilityVerification = artifacts.require("FacilityVerification");

module.exports = async function(callback) {
  const facilityContract = await FacilityVerification.deployed();
  
  // IPFS hash containing facility documentation
  const metadataURI = "QmZ9Nd1XcQ8zTK2M31stN8xbGms3rQKx8xFpUMac3Qap4Y";
  
  await facilityContract.registerFacility(
    "Greenfield Manufacturing Plant",
    "EPA-FAC-12345678",
    "Chemical Manufacturing",
    ["Clean Air Act", "Clean Water Act", "RCRA"],
    "{\"type\":\"Polygon\",\"coordinates\":[[[-73.9876,40.7661],[-73.9876,40.7671],[-73.9866,40.7671],[-73.9866,40.7661],[-73.9876,40.7661]]]}",
    [
      "0x1234567890123456789012345678901234567890",  // Facility manager address
      "0x2345678901234567890123456789012345678901"   // Environmental compliance officer address
    ],
    metadataURI,
    { from: facilityManagerAccount }
  );
  
  callback();
};
```

### Creating a New Permit

```javascript
const PermitManagement = artifacts.require("PermitManagement");

module.exports = async function(callback) {
  const permitContract = await PermitManagement.deployed();
  
  // IPFS hash containing permit documentation
  const permitURI = "QmX7d8FdhtJTR6xiy6mXUgbKFtAF5aB7MqzhdZnKLo2Xqb";
  
  const pollutantLimits = [
    { pollutant: "NOx", limit: 150, unit: "mg/m3" },
    { pollutant: "SO2", limit: 200, unit: "mg/m3" },
    { pollutant: "PM2.5", limit: 20, unit: "μg/m3" }
  ];
  
  const currentTime = Math.floor(Date.now() / 1000);
  const expirationTime = currentTime + (365 * 24 * 60 * 60);  // 1 year validity
  
  await permitContract.createPermit(
    facilityAddress,
    "Air Emissions Permit",
    currentTime,
    expirationTime,
    pollutantLimits,
    [
      "No operations during air quality alerts",
      "Quarterly stack testing required",
      "Continuous emissions monitoring required for NOx and SO2"
    ],
    permitURI,
    { from: regulatoryAuthorityAccount }
  );
  
  callback();
};
```

### Submitting Sensor Data

```javascript
const SensorData = artifacts.require("SensorData");

module.exports = async function(callback) {
  const sensorContract = await SensorData.deployed();
  
  // IPFS hash containing raw sensor data files
  const rawDataURI = "QmY3X8Gp3UEbLRdRjVQ7MKU91RtstYK8mPJJCKP6F8YryA";
  
  await sensorContract.submitReading(
    facilityAddress,
    "NOx-SENSOR-001",
    "NOx",
    Math.floor(Date.now() / 1000),
    143,  // Value
    "mg/m3",
    95,   // 95% accuracy
    "0x7a3d4b7a2c3f2a4d5e8f7a9c8b7d6a5f4e3d2c1b0a9z8y7x6w5v4u3t2s1r0q",  // Data hash
    false,  // Not a manual entry
    rawDataURI,
    { from: sensorOracleAccount }
  );
  
  callback();
};
```

### Generating a Compliance Report

```javascript
const ReportingContract = artifacts.require("ReportingContract");

module.exports = async function(callback) {
  const reportingContract = await ReportingContract.deployed();
  
  // IPFS hash containing compiled report data
  const reportDataURI = "QmT2S4v1ZvG7V8KD7bYsLLD9JGY1gW1Dco2FLvz1zTYxPb";
  
  // Public disclosure document (redacted version)
  const publicDisclosureURI = "QmU3F4WKx1Gx7H2Z6JyV8YnLbDxKQ5QpZLcY9YJL7z9WpZ";
  
  const reportingPeriodStart = Math.floor(Date.now() / 1000) - (90 * 24 * 60 * 60);  // 90 days ago
  const reportingPeriodEnd = Math.floor(Date.now() / 1000);
  
  await reportingContract.generateReport(
    facilityAddress,
    "Quarterly-Emissions-Report",
    reportingPeriodStart,
    reportingPeriodEnd,
    ["NOx", "SO2", "PM2.5"],
    [1, 4, 7],  // Violation IDs to include
    reportDataURI,
    publicDisclosureURI,
    { from: facilityComplianceOfficerAccount }
  );
  
  callback();
};
```

## Benefits

### For Regulatory Authorities
- Automated monitoring reduces inspection costs
- Real-time visibility into facility operations
- Tamper-proof record of environmental data
- Standardized format for cross-jurisdiction analysis
- Efficient allocation of enforcement resources

### For Facilities
- Streamlined compliance reporting reduces administrative burden
- Early violation detection prevents major incidents
- Transparent record keeping demonstrates good faith efforts
- Reduced cost of environmental audits
- Potential for reduced insurance premiums

### For the Public
- Increased transparency of industrial environmental impacts
- Access to verified emissions data
- Improved environmental outcomes in communities
- Enhanced accountability of both industry and regulators

## Security Considerations

- **Data Integrity**: Multi-signature validation for critical data points
- **Access Control**: Granular permissions using role-based access control
- **Sensor Security**: Tamper-evident hardware with cryptographic attestation
- **Audit Trails**: Complete history of all data modifications
- **Data Privacy**: Selective disclosure for sensitive commercial information
- **Regulatory Override**: Emergency access provisions for critical situations

## Future Roadmap

- **Q3 2025**: Launch with air emissions monitoring focus
- **Q4 2025**: Add water quality monitoring capabilities
- **Q1 2026**: Implement waste management tracking
- **Q2 2026**: Deploy greenhouse gas reporting module
- **Q3 2026**: Integrate with carbon credit trading platforms
- **Q4 2026**: Launch community monitoring integration
- **2027**: Expand to global multi-jurisdiction support

## Governance

The DECMS system is governed by a multi-stakeholder governance structure:

- **Technical Committee**: Oversees system upgrades and technical standards
- **Regulatory Council**: Ensures alignment with evolving compliance requirements
- **Industry Advisory Board**: Provides feedback on usability and implementation
- **Community Representatives**: Represent public interest in environmental data

## Contributing

We welcome contributions from environmental experts, blockchain developers, and regulatory specialists. Please see [CONTRIBUTING.md](./CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](./LICENSE) file for details.

## Acknowledgments

- This project was developed in collaboration with [Environmental Protection Agency]
- Special thanks to [Environmental Technology Partners]
- Research supported by [Environmental Monitoring Research Institute]

## Contact

- Website: [www.decms.org](https://www.decms.org)
- Email: info@decms.org
- Twitter: [@DECMSystem](https://twitter.com/DECMSystem)
- GitHub: [github.com/decms](https://github.com/decms)
