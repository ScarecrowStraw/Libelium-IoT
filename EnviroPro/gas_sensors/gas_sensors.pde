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
#include <WaspWIFI_PRO_V3.h>

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

 // choose socket (SELECT USER'S SOCKET)
///////////////////////////////////////
uint8_t socket = SOCKET0;
///////////////////////////////////////

// choose HTTP server settings
///////////////////////////////////////
char HTTP_SERVER[] = "192.168.0.62";
uint16_t HTTP_PORT = 1883;
char                 databuffer[50];
///////////////////////////////////////

uint8_t error;
uint8_t status;
unsigned long previous;

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
    USB.println(F("Gas Sensors MQTT Publish"));
  
    ///////////////////////////////////////////
    // 1. Turn on the sensors
    /////////////////////////////////////////// 

    // Power on the electrochemical sensor. 
    // If the gases PRO board is off, turn it on automatically.
    // gas_PRO_sensor.ON();
    NO2_PRO_sensor.ON();
    CH4_PRO_sensor.ON(); 
    NH3_PRO_sensor.ON();

     //////////////////////////////////////////////////
    // 1. Switch ON
    //////////////////////////////////////////////////
    error = WIFI_PRO_V3.ON(socket);

    if (error == 0)
    {
      USB.println(F("1. WiFi switched ON"));
    }
    else
    {
      USB.println(F("1. WiFi did not initialize correctly"));
    }

    //////////////////////////////////////////////////
    // 2. Check if connected
    //////////////////////////////////////////////////


    // get actual time
    previous = millis();

    // check connectivity
    status =  WIFI_PRO_V3.isConnected();

    // check if module is connected
    if (status == true)
    {
      USB.println(F("2. WiFi is connected OK"));

      USB.print(F("IP address: "));
      USB.println(WIFI_PRO_V3._ip);

      USB.print(F("GW address: "));
      USB.println(WIFI_PRO_V3._gw);

      USB.print(F("Netmask address: "));
      USB.println(WIFI_PRO_V3._netmask);
    
      USB.print(F(" Time(ms):"));
      USB.println(millis() - previous);
    }
    else
    {
      USB.print(F("2. WiFi is connected ERROR"));
      USB.print(F(" Time(ms):"));
      USB.println(millis() - previous);
      PWR.reboot();
    }



    //////////////////////////////////////////////////
    // 3. Configure HTTP conection
    //////////////////////////////////////////////////

    error = WIFI_PRO_V3.mqttConfiguration(HTTP_SERVER,"user", HTTP_PORT, WaspWIFI_v3::MQTT_TLS_DISABLED);
    if (error == 0)
    {
      USB.println(F("3. MQTT conection configured"));
    }
    else
    {
      USB.print(F("3. MQTT conection configured ERROR"));
    }
    
    // First sleep time
    // After 2 minutes, Waspmote wakes up thanks to the RTC Alarm
    PWR.deepSleep("00:00:02:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_ON);
}

void loop()
{

    //////////////////////////////////////////////////
    // 1. Switch ON
    //////////////////////////////////////////////////
    error = WIFI_PRO_V3.ON(socket);

    gas_PRO_sensor.ON();

    // NDIR gas sensor needs a warm up time at least 120 seconds  
    // To reduce the battery consumption, use deepSleep instead delay
    // After 2 minutes, Waspmote wakes up thanks to the RTC Alarm
    PWR.deepSleep("00:00:02:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_ON);

    if (error == 0)
    {
      USB.println(F("1. WiFi switched ON"));
    }
    else
    {
      USB.println(F("1. WiFi did not initialize correctly"));
    }
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
    USB.println(F(" ppm"));
    USB.print(F("armoniac: "));
    USB.print(armoniac);
    USB.println(F(" ppm"));
    USB.print(F("nitricdioxide: "));
    USB.print(nitricdioxide);
    USB.println(F(" ppm"));
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
    // 3. Publish
    /////////////////////////////////////////// 

    char array0[10];
    //  snprintf(array0, sizeof(array0), "%f", concentration);
    dtostrf(concentration, 10, 2, array0); 
    USB.println(array0);
    error = WIFI_PRO_V3.mqttPublishTopic("CO2",WaspWIFI_v3::QOS_1,WaspWIFI_v3::RETAINED,array0);

    delay(1000);
    char array1[10];
    // snprintf(array1, sizeof(array1), "%f", temperature);
    dtostrf(temperature, 10, 2, array1);
    error = WIFI_PRO_V3.mqttPublishTopic("Temp",WaspWIFI_v3::QOS_1,WaspWIFI_v3::RETAINED,array1);

    delay(1000);
    char array2[10];
    //  snprintf(array2, sizeof(array2), "%f", humidity);
    dtostrf(humidity, 10, 2, array2);
    error = WIFI_PRO_V3.mqttPublishTopic("Humi",WaspWIFI_v3::QOS_1,WaspWIFI_v3::RETAINED,array2);

    delay(1000);
    char array3[10];
    snprintf(array3, sizeof(array3), "%f", pressure);
    dtostrf(pressure, 10, 2, array3);
    error = WIFI_PRO_V3.mqttPublishTopic("Press",WaspWIFI_v3::QOS_1,WaspWIFI_v3::RETAINED,array3);

    delay(1000);
    char array4[10];
    snprintf(array3, sizeof(array4), "%f", pressure);
    dtostrf(armoniac, 10, 2, array4);
    error = WIFI_PRO_V3.mqttPublishTopic("NH3",WaspWIFI_v3::QOS_1,WaspWIFI_v3::RETAINED,array4);

    delay(1000);
    char array5[10];
    snprintf(array5, sizeof(array5), "%f", pressure);
    dtostrf(metan, 10, 2, array5);
    error = WIFI_PRO_V3.mqttPublishTopic("CH4",WaspWIFI_v3::QOS_1,WaspWIFI_v3::RETAINED,array5);

    delay(1000);
    char array6[10];
    snprintf(array6, sizeof(array6), "%f", pressure);
    dtostrf(nitricdioxide, 10, 2, array6);
    error = WIFI_PRO_V3.mqttPublishTopic("NO2",WaspWIFI_v3::QOS_1,WaspWIFI_v3::RETAINED,array6);

    // check response
    if (error == 0)
    {
      USB.println(F("Publish topic done!"));
    }
    else
    {
      USB.println(F("Error publishing topic!"));  
    }  
  
    //////////////////////////////////////////////////
    // 3. Switch OFF
    //////////////////////////////////////////////////
    WIFI_PRO_V3.OFF(socket);
    gas_PRO_sensor.OFF();

    // Go to deepsleep  
    // After 2 minutes, Waspmote wakes up thanks to the RTC Alarm
    PWR.deepSleep("00:00:02:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_ON);
}
