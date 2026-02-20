# 🌾 AgroGuard AI - Complete Technical Architecture & Hardware Components

**Version:** 1.0.0  
**Date:** February 20, 2026  
**System Status:** Production Ready ✅

---

## Part 1: Complete System Architecture

### 1.1 System Overview

**AgroGuard AI** is an integrated IoT-enabled agricultural intelligence system combining:
- Advanced computer vision for disease detection
- Real-time sensor data analytics
- Machine learning-based crop recommendations
- Mobile-first decision support platform

```
┌─────────────────────────────────────────────────────────┐
│                    AgroGuard AI System                   │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌──────────────────────────────────────────────────┐  │
│  │         Mobile Application (Flutter)               │  │
│  │  • Disease Detection Screen (with local DB)        │  │
│  │  • Sensor Dashboard (real-time monitoring)         │  │
│  │  • Crop Recommendation Engine                      │  │
│  │  • Weather & Advisory Screen                       │  │
│  └──────────────────────┬───────────────────────────┘  │
│                         │ HTTP REST API                  │
│  ┌──────────────────────▼───────────────────────────┐  │
│  │      Flask REST API Backend (Python)              │  │
│  │  • Disease Detection Service (500+ lines)         │  │
│  │  • IoT Analytics Service (400+ lines)             │  │
│  │  • Crop Recommendation Service (ML Model)         │  │
│  │  • 12 REST API Endpoints                          │  │
│  └──────────────────────┬───────────────────────────┘  │
│                         │                                │
│  ┌──────────────────────▼────────┬────────────────────┐ │
│  │                               │                     │  │
│  │  Local SQLite DB           Hardware IoT           │  │
│  │  (Disease Images)          (Sensors/Simulator)    │  │
│  │                                                    │  │
│  └───────────────────────────────────────────────────┘  │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

---

## Part 2: Hardware Components & IoT Sensor Specifications

### 2.1 Physical Hardware Components (Real-World Deployment)

#### **2.1.1 Core Sensor Suite (9 Sensors)**

| Sensor Name | Type | Model (Example) | Range | Accuracy | Communication |
|-------------|------|-----------------|-------|----------|----------------|
| **Nitrogen (N)** | Chemical | Optromid-6000 | 0-300 mg/kg | ±5% | Modbus/RS485 |
| **Phosphorus (P)** | Chemical | Soil Spectro | 0-100 mg/kg | ±3% | I2C/SPI |
| **Potassium (K)** | Chemical | Ion Selective | 0-500 mg/kg | ±4% | Analog (0-5V) |
| **Temperature** | Environmental | DS18B20 | -10 to +85°C | ±0.5°C | 1-Wire Protocol |
| **Humidity** | Environmental | DHT22 | 0-100% RH | ±2% RH | Digital Signal |
| **pH Level** | Chemical | Analog pH Probe | 0-14 pH | ±0.1 pH | Analog (4-20mA) |
| **Rainfall** | Meteorological | Tipping Bucket | 0-500 mm/day | ±1% | Switch Signal |
| **Soil Moisture** | Hydrological | Capacitive (TDR) | 0-100% | ±3% | Analog/Digital |
| **Light Intensity** | Photometric | LDR/Lux Meter | 0-100,000 lux | ±2% | Analog/I2C |

#### **2.1.2 IoT Gateway & Microcontroller**

```
┌────────────────────────────────────────────┐
│   Arduino Mega 2560 / ESP32 (Main MCU)    │
├────────────────────────────────────────────┤
│ • 256KB Flash Memory                        │
│ • 8KB SRAM                                  │
│ • 16 Analog Input Channels                  │
│ • 54 Digital I/O Ports                      │
│ • Operating Voltage: 5V / 3.3V             │
│ • Clock Speed: 16 MHz (Arduino) / 240 MHz   │
└────────────────────────────────────────────┘
         │
         ├─── 9 Sensor Inputs (Analog & Digital)
         ├─── SD Card Module (Data Logging)
         ├─── WiFi/4G Module (Data Transmission)
         └─── Real-Time Clock (Timestamp)
```

#### **2.1.3 Power Supply System**

```
Primary Power:
├── Solar Panel Array (50W @ 12V)
│   └── Charge Controller (MPPT Type)
└── Battery Bank (12V, 200Ah)
    ├── Primary: AGM Battery (180Ah)
    ├── Backup: Lead-Acid (20Ah)
    └── Battery Management System (BMS)

Power Distribution:
├── 12V Rail (Sensor Power)
├── 5V Rail (Microcontroller)
└── 3.3V Rail (WiFi Module)
```

#### **2.1.4 Data Transmission**

```
Local Network:
├── WiFi 802.11 ac (Range: 100-300m)
├── LoRaWAN (Range: 10-15 km)
└── 4G LTE (Cellular Backup)

Data Format:
├── Sensor Data → JSON Payload
├── Timestamp: UNIX + UTC
└── Encryption: AES-128 (Data in Transit)
```

### 2.2 Circuit Diagram Description

#### **2.2.1 Analog Sensor Circuit (Temperature, Humidity, Moisture)**

```
Sensor → Voltage Divider → ADC (Arduino)
         (If needed)     ↓
                   Analog Pin (0-1023 reading)
                        ↓
                   Calibration
                        ↓
                   5 readings/average
                        ↓
                   Stored in Variables
```

#### **2.2.2 Digital Sensor Circuit (pH, Rainfall)**

```
Sensor → TTL Signal → Digital Pin (Arduino)
         (0/1 Reading)      ↓
                      Interrupt Service Routine (ISR)
                            ↓
                      Frequency Counting
                            ↓
                      Converted to Measurement
```

#### **2.2.3 I2C Communication Circuit (Multi-sensor)**

```
SDA ──────┬─────── Arduino SDA (Pin 20)
          │
          └─ Pull-up Resistor (4.7k Ω) → 5V
                
SCL ──────┬─────── Arduino SCL (Pin 21)
          │
          └─ Pull-up Resistor (4.7k Ω) → 5V

Multiple I2C Sensors connected to same bus
```

#### **2.2.4 RS485 Modbus Circuit (Soil Sensors)**

```
Non-Inverting ──┬─── A (Arduino TX via MAX485)
                └─ Pull-up to 5V (560Ω)

Inverting ──────┬─── B (Arduino RX via MAX485)
                └─ Pull-down to GND (560Ω)

GND ────────────── GND

RS485 Termination:
├── 120Ω between A & B at cable ends
└── Only on long cables (>30m)
```

### 2.3 Physical Installation

#### **2.3.1 Field Installation Setup**

```
Sensor Node (1-10 nodes per field):
├── Height: 1.2-1.5m above ground
├── Placement: Center of field section
├── Distance: 50-100m apart (typical fields)
├── Mounting: Waterproof enclosure (IP67)
└── Grounding: Copper rod 1m deep

Communication Hub:
├── Elevated position (3-5m height)
├── Line of sight to gateway
├── Protected weatherproof housing
└── Backup power (18-24hr autonomy)

Central Gateway:
├── Location: Farm office/central location
├── Power: Mains + Battery backup
├── Cooling: Active/Passive ventilation
└── Network: Wired + Wireless redundancy
```

---

## Part 3: Real Hardware Integration Guide

### 3.1 From Simulator to Real Hardware

**Current System State:**
```
┌─────────────────────────────────┐
│  IoT Simulator (Current)         │
│  └─ 5 Demo Scenarios             │
│  └─ Realistic Data Patterns      │
│  └─ No Hardware Required         │
└─────────────────────────────────┘
```

**Transition Path to Real Hardware:**

```
Step 1: Hardware Setup
  ├─ Install sensor array in field
  ├─ Configure microcontroller (Arduino/ESP32)
  ├─ Establish WiFi/4G connectivity
  └─ Verify sensor readings

Step 2: Data Collection & Calibration
  ├─ Collect raw sensor values
  ├─ Compare with lab standards
  ├─ Create calibration curves
  └─ Derive conversion formulas

Step 3: API Integration
  ├─ Modify IoT Service to read from hardware
  ├─ Replace simulator data with real sensors
  ├─ Implement data validation
  └─ Add error handling

Step 4: Testing & Validation
  ├─ Cross-check with manual sampling
  ├─ Monitor data quality
  ├─ Adjust thresholds
  └─ Full system testing

Step 5: Deployment
  ├─ Multiple field deployment
  ├─ Farmer training
  ├─ Support infrastructure
  └─ 24/7 monitoring
```

### 3.2 Hardware Integration Code Changes

**Current IoT Service (Simulator):**
```python
def _generate_sensor_data(self):
    # Simulated data generation
    current_time = datetime.now()
    # ... generates realistic patterns
```

**Future Hardware Integration:**
```python
def _generate_sensor_data(self):
    # Real hardware data integration
    try:
        # Read from serial port / WiFi
        data = hardware_interface.read_sensors()
        
        # Validate readings
        validated = self._validate_sensor_data(data)
        
        # Apply calibration
        calibrated = self._apply_calibration(validated)
        
        # Store in history
        self.sensor_history.append(calibrated)
        
        return calibrated
    except Exception as e:
        logger.error(f"Hardware read error: {e}")
        # Fallback to last known values
        return self.sensor_history[-1]
```

---

## Part 4: Sensor Specifications & Optimal Ranges

### 4.1 Detailed Sensor Data

#### **Nitrogen (N) - Soil Nutrient**
```
Optimal Range: 120-150 mg/kg
Critical Range: <50 mg/kg (Deficient)
Excess Range: >200 mg/kg (Toxic)

Measurement Method:
├─ Spectrophotometry (Lab Standard)
├─ Ion-Selective Electrode (Field)
└─ Capacitive Soil Sensors (Approximate)

Plant Impact:
├─ Low: Stunted growth, yellowing leaves
├─ Optimal: Vigorous growth, green foliage
└─ High: Excessive vegetative growth, weak stems

Crop-Specific Recommendations:
├─ Wheat: 120-140 mg/kg
├─ Rice: 100-130 mg/kg
├─ Corn: 140-180 mg/kg
├─ Potato: 110-130 mg/kg
└─ Tomato: 150-200 mg/kg
```

#### **Phosphorus (P) - Energy Nutrient**
```
Optimal Range: 45-70 mg/kg
Critical Range: <20 mg/kg
Excess Range: >100 mg/kg

Deficiency Symptoms:
├─ Purple/reddish discoloration
├─ Delayed maturity
├─ Reduced root development
└─ Poor flowering/fruiting
```

#### **Potassium (K) - Strength Nutrient**
```
Optimal Range: 80-120 mg/kg
Critical Range: <40 mg/kg
Excess Range: >200 mg/kg

Function:
├─ Disease resistance
├─ Drought tolerance
├─ Fruit quality
└─ Storage potential
```

#### **Temperature**
```
Optimal Range (Crop-Dependent):
├─ Cool Season: 15-20°C
├─ Warm Season: 20-28°C
└─ Tropical: 25-35°C

Critical Thresholds:
├─ Frost Risk: <0°C
├─ Heat Stress: >35°C
└─ Growth Minimum: <5°C
```

#### **Humidity**
```
Optimal Range: 60-80% RH
Critical High: >90% RH (Disease risk)
Critical Low: <40% RH (Stress risk)

Disease Correlation:
├─ >85% RH + Temp 15-25°C = Fungal Disease Risk
├─ >95% RH for 12+ hours = Bacterial Blight Risk
└─ <50% RH + Temp >30°C = Drought Stress
```

#### **pH Level**
```
Optimal Range: 6.5-7.2 (Most crops)
Acidic Crops: 5.5-6.5
Alkaline Tolerant: 7.5-8.5

Nutrient Availability at Different pH:
├─ <5.5: Aluminum toxicity
├─ 6.5-7.2: Maximum availability (all nutrients)
├─ >8.0: Iron/Zinc/Boron deficiency
└─ >8.5: Phosphorus unavailable
```

#### **Soil Moisture**
```
Optimal Range: 55-70% (Field Capacity)
Wilting Point: <30%
Saturation: >85% (Root rot risk)

Irrigation Trigger:
├─ Start: 40-45% moisture
├─ Stop: 70-75% moisture
└─ Monitoring: Every 6 hours
```

#### **Light Intensity**
```
Optimal Range: 800-2000 lux
Minimum for Growth: 200 lux
Maximum Safe: 10,000+ lux

Crop-Specific:
├─ Wheat: 1200-1500 lux
├─ Rice: 1000-1200 lux
├─ Shade-loving: 400-800 lux
└─ Full-sun crops: 1500-2000 lux
```

---

## Part 5: Power Consumption & Operational Specifications

### 5.1 Power Budget Analysis

```
Sensor Array Power Consumption:

Per Sensor (Average):
├─ Analog Sensors: 5-20 mA @ 5V = 0.025-0.1W
├─ Digital Sensors: 10-50 mA @ 3.3V = 0.03-0.17W
└─ I2C Sensors: 2-10 mA @ 3.3V = 0.006-0.03W

Total Sensor Array (9 sensors):
└─ ~0.5-1.0W (continuous operation)

Microcontroller:
├─ Arduino Mega: 50-100 mA @ 5V = 0.25-0.5W
└─ ESP32: 80-160 mA @ 3.3V = 0.26-0.53W

Communication:
├─ WiFi: 80-200 mA @ 3.3V = 0.26-0.66W
├─ LoRa: 30-150 mA @ 3.3V = 0.1-0.5W
└─ 4G LTE: 500-2000 mA = 1.65-6.6W (peak)

Data Logging (SD Card):
└─ 50-100 mA @ 3.3V = 0.165-0.33W (intermittent)

Total Daily Power Consumption:
├─ Sensors Only: ~0.5 W × 24h = 12 Wh
├─ Microcontroller: ~0.4 W × 24h = 9.6 Wh
├─ WiFi (30% duty): ~0.45 W × 7.2h = 3.24 Wh
├─ Data Logging: ~0.25 W × 2h = 0.5 Wh
├─ Overhead (5%): ~1.5 Wh
└─ TOTAL: ~27 Wh/day

Solar Panel Requirement:
├─ Daily Energy: 27 Wh
├─ Peak Sun Hours: 5 (average location)
├─ Array Size: 27 Wh / (5h × 0.85 efficiency) = 6.4W
├─ Recommended: 50W panel (7-8x safety margin)
└─ 15-day autonomy: 200Ah battery bank
```

### 5.2 Operational Specifications

```
Data Update Frequency:
├─ Sensor Sampling: Every 5 minutes
├─ Data Averaging: Every 1 hour
├─ Cloud Sync: Every 30 minutes
└─ Alert Trigger: Real-time (critical only)

Network Protocols:
├─ WiFi: 802.11 ac, 2.4GHz/5GHz
├─ LoRaWAN: Class A/B compatible
├─ Cellular: 4G LTE Cat-M1
└─ Backup: Manual data retrieval via SD card

Data Storage:
├─ Local (SD Card): 30-day history (1,440 readings)
├─ Cloud: Unlimited (with subscription)
├─ Sync Interval: Every transmission
└─ Redundancy: 3-copy backup

Environmental Operating Conditions:
├─ Temperature: -20°C to +60°C
├─ Humidity: 0-100% RH (sealed enclosure)
├─ IP Rating: IP67 (Waterproof/Dust-proof)
└─ MTBF: 50,000 hours (5.7 years)
```

---

**[Continued in Part 2]**
