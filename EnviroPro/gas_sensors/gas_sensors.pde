/*  
 *  ------------  [GP_v30_01] - Electrochemical gas sensors  -------------- 
 *  
 *  Explanation: This is the basic code to manage and read an electrochemical
 *  gas sensor. These sensors include: CO, O2, O3, NO, NO2, SO2, NH3, H2, H2S,
 *  HCl, HCN, PH3, ETO and Cl2. Cycle time: 2 minutes
 *  
 *  Copyright (C) 2016 Libelium Comunicaciones Distribuidas S.L. 
 *  http://www.libelium.com 
 *  
 *  This program is free software: you can redistribute it and/or modify  
 *  it under the terms of the GNU General Public License as published by  
 *  the Free Software Foundation, either version 3 of the License, or  
 *  (at your option) any later version.  
 *   
 *  This program is distributed in the hope that it will be useful,  
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of  
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the  
 *  GNU General Public License for more details.  
 *   
 *  You should have received a copy of the GNU General Public License  
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.  
 * 
 *  Version:           3.1
 *  Design:            David Gascón 
 *  Implementation:    Alejandro Gállego
 */

#include <WaspSensorGas_Pro.h>

/*
 * Define object for sensor: gas_PRO_sensor
 * Input to choose board socket. 
 * Waspmote OEM. Possibilities for this sensor:
 *   - SOCKET_1 
 *  - SOCKET_2
 *  - SOCKET_3
 *  - SOCKET_4
 *  - SOCKET_5
 *  - SOCKET_6
 * P&S! Possibilities for this sensor:
 *  - SOCKET_A
 *  - SOCKET_B
 *  - SOCKET_C
 *  - SOCKET_F
 */
Gas gas_PRO_sensor(SOCKET_A);
Gas NH3_PRO_sensor(SOCKET_C);
Gas NO2_PRO_sensor(SOCKET_B);
Gas CH4_PRO_sensor(SOCKET_F);

float concentration;  // Stores the concentration level in ppm

// 9378 sensor
float armoniac;   // NH3 

float nitricdioxide; // NO2
float metan; // CH4

float temperature;  // Stores the temperature in ºC
float humidity;   // Stores the realitve humidity in %RH
float pressure;   // Stores the pressure in Pa

void setup()
{
    USB.println(F("Electrochemical gas sensor example"));
  
    ///////////////////////////////////////////
    // 1. Turn on the sensors
    /////////////////////////////////////////// 

    // Power on the electrochemical sensor. 
    // If the gases PRO board is off, turn it on automatically.
    gas_PRO_sensor.ON();
    NO2_PRO_sensor.ON();
    CH4_PRO_sensor.ON(); 
    NH3_PRO_sensor.ON();
    
    // First sleep time
    // After 2 minutes, Waspmote wakes up thanks to the RTC Alarm
    PWR.deepSleep("00:00:02:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_ON);
}

void loop()
{
    ///////////////////////////////////////////
    // 2. Read sensors
    ///////////////////////////////////////////  

    // Read the electrochemical sensor and compensate with the temperature internally
    concentration = gas_PRO_sensor.getConc();

    // Read enviromental variables
    temperature = gas_PRO_sensor.getTemp();
    humidity = gas_PRO_sensor.getHumidity();
    pressure = gas_PRO_sensor.getPressure();

    armoniac = NH3_PRO_sensor.getConc();
    nitricdioxide = NO2_PRO_sensor.getConc();
    metan = CH4_PRO_sensor.getConc();

    // And print the values via USB
    USB.println(F("***************************************"));
    USB.print(F("Gas concentration: "));
    USB.print(concentration);
    USB.print(F("armoniac: "));
    USB.print(armoniac);
    USB.print(F("nitricdioxide: "));
    USB.print(nitricdioxide);
    USB.print(F("metan: "));
    USB.print(metan);
    USB.println(F(" ppm"));
    USB.print(F("Temperature: "));
    USB.print(temperature);
    USB.println(F(" Celsius degrees"));
    USB.print(F("RH: "));
    USB.print(humidity);
    USB.println(F(" %"));
    USB.print(F("Pressure: "));
    USB.print(pressure);
    USB.println(F(" Pa"));

    ///////////////////////////////////////////
    // 5. Sleep
    /////////////////////////////////////////// 

    // Go to deepsleep  
    // After 2 minutes, Waspmote wakes up thanks to the RTC Alarm
    PWR.deepSleep("00:00:02:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_ON);
}
