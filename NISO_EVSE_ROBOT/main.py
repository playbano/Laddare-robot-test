import time
import nidaqmx
import os
import requests
import subprocess
import csv
import serial
import re
import threading
from io import StringIO
import Elmatare as Elmatare
from robot.libdocpkg import LibraryDocumentation
from robot import rebot
#from bs4 import BeautifulSoup
from datetime import datetime, timedelta
from nidaqmx.constants import (TerminalConfiguration)
from nidaqmx.constants import LineGrouping
try:
    from robot.libraries.BuiltIn import BuiltIn
    from robot.libraries.BuiltIn import _Misc
    import robot.api.logger as logger
    from robot.api.deco import keyword
    ROBOT = False
except Exception:
    ROBOT = False

def main():
    
    # STARTING RELAY EIGHT IS POWERING THE BOARD.Q
    
    # Run_robot_test is used to run tests and create reports.
    # This way you can tailor your test sequence with your prefered tests to run in one cycle.

    # Charging Cycle Iterations
    iterations = 1
#    time.sleep(1)
#    Start_Relay(8)
#    time.sleep(5)
#    Digital_LED()

#    for i in range(4, 8):
#        time.sleep(2)
#        print("-----------------------------------------------")
#        print("Relay",i)
#        Start_Relay(i)
#        time.sleep(2)
#        Digital_LED()
#        if i == 6 or i == 7:
#            time.sleep(3)
#            Digital_LED()

    #Close_All_Relays
    # Example usage
    
    # STARTUP/INITIATION TESTS
    run_robot_test("Startup Tests", "Start_Charger.robot")
    time.sleep(2)
    #run_robot_test("PCB Tests","ErrorLog.robot")
    
    
    
    
    # RS-485 Test Port 3
    # If entire test runs without exeptions = returns TRUE else FALSE
    #run_robot_test("RS-485 Tests", "RS-485.robot")
    
    # #CHARGING SEQUENCE TESTS
    for i in range(iterations):
        #run_robot_test("Charging Tests","Charging_Sequence_Cloud_Port_1.robot")
        #time.sleep(5)
        #run_robot_test("Charging Tests","Charging_Sequence_Cloud_Port_2.robot")
        #time.sleep(5)
        #run_robot_test("Charging Tests","Charging_Sequence_Cloud_Both_Ports.robot")
        #time.sleep(5)
        #run_robot_test("Charging Tests","Charging_Sequence_No_Cloud_Port_1.robot")
        #time.sleep(2)
        #run_robot_test("Charging Tests","Charging_Sequence_No_Cloud_Port_2.robot")
        #time.sleep(2)
        run_robot_test("Charging Tests","Charging_Sequence_No_Cloud_Both_Ports.robot")
        time.sleep(2)

    # RELAY BOARD FUNCTIONALITY TESTS
    # run_robot_test("Relay Card Tests","Power_Board_Relay_Control_Port_1.robot")
    # run_robot_test("Relay Card Tests","Power_Board_Relay_Control_Port_2.robot")

    # # PCB FUNCTIONALITY TESTS
    # run_robot_test("PCB Tests", "PWM_Duty_Cycle.robot")
    # run_robot_test("PCB Tests", "Relay_Timing_Shut_Off.robot")
    
    # Start_All_Relays()
    # time.sleep(3)
    
    # dubbel_lista = []


    # for i in range(20):
    #     dubbel_varv = duty_cycle = measure_pwm_duty_cycle()  # Du kan ändra detta till det värde du vill spara
    #     dubbel_lista.append(dubbel_varv)
    #     print("ping")
    

    # print(dubbel_lista)
    # print(sum(dubbel_lista) / len(dubbel_lista))
    
    # Start_All_Relays()
    
    
    
    #Start_Relay(0)
    #time.sleep(1)
    #Start_Relay(1)
    #time.sleep(1)
    #Start_Relay(2)
    #time.sleep(1)
    #Start_Relay(3)
    #time.sleep(1)
    #Error_log()
    
    #Start_Relay(4)
    #time.sleep(1)
    #Start_Relay(5)
    #time.sleep(1)
    #Start_Relay(6)
    #time.sleep(1)
    #Start_Relay(7)
    #time.sleep(15)
    print("ping")
    
    
    
    #thread1.start()
    #for i in range(25):
    #    print("--------------------------------------------------------")
        #duty_cycle1 = measure_pwm_duty_cycle(0)
        #duty_cycle2 = measure_pwm_duty_cycle(2)
        
        #print("Duty cycle 1:", duty_cycle1, "%")
        #print("Duty cycle 1:", duty_cycle1 * 0.6, "A")
        #print("CP1:",analog_in(0))
        #print("PP1:",analog_in(1))
        
        #print("Duty cycle 2:", duty_cycle2, "%")
        #print("Duty cycle 2:", duty_cycle2 * 0.6, "A")
        #print("CP2:",analog_in(2))
        #print("PP2:",analog_in(3))
    
    
    #print("Duty cycle 1:", duty_cycle1 , "%")
    #print("Duty cycle 1:", duty_cycle1 * 0.6, "A")
    #print("Duty cycle 2:", duty_cycle2 * 100, "%")
    #print("Duty cycle 2:", duty_cycle2 * 60, "A")
    
    

    
    time.sleep(2)

    
    #print(measure_time(0,0))
   
    Close_All_Relays()
    
def Digital_LED():
    if Daq_in_reader(0,10) is False:
        print("Green LED: ON")
    else: print("Green LED: OFF")
    if Daq_in_reader(0,11) is False:
        print("Blue LED: ON")
    else: print("Blue LED: OFF")
    if Daq_in_reader(0,12) is False:
        print("Red LED: ON")
    else: print("Red LED: OFF")
    
    # merge_and_convert_reports()

#Mäter Analog LED returnerar True/False 
def analog_LED(channel):
    with nidaqmx.Task() as task:
        task.ai_channels.add_ai_voltage_chan("dev1/ai{}".format(channel),min_val=0 ,terminal_config=TerminalConfiguration.RSE)
        LED_V = task.read()
        
        return LED_V

# Opens all relays to power RIG and enable charging states.
@keyword("Start All Relays")
def Start_All_Relays():
    # Powers Up The Board.
    Start_Relay(8)

    # Opens all relays to allow charging state.
    x = range(8)
    for n in x:
        Start_Relay(n)
        time.sleep(0.5)

    time.sleep(2)

# Closes all Relays.
@keyword("Close All Relays")
def Close_All_Relays():
    
    x = range(9)
    for n in x:
        Close_Relay(n)
        time.sleep(0.5)

    time.sleep(2)

# Opens a specified relay.
@keyword("Start Relay")
def Start_Relay(n):
    with nidaqmx.Task() as task:
        task.do_channels.add_do_chan("Dev1/port0/line{}".format(n),
        line_grouping=nidaqmx.constants.LineGrouping.CHAN_FOR_ALL_LINES)
        task.write(True)

# Closes a specified relay.        
@keyword("Close Relay")
def Close_Relay(n):
    with nidaqmx.Task() as task:
        task.do_channels.add_do_chan("Dev1/port0/line{}".format(n),
        line_grouping=nidaqmx.constants.LineGrouping.CHAN_FOR_ALL_LINES)
        task.write(False)

# Reads High or Low digital input on DAQ device.      
@keyword("Digital In")
def Daq_in_reader(port,line):
    with nidaqmx.Task() as task:
        task.di_channels.add_di_chan("Dev1/port{}/line{}".format(port,line))
        high_or_low = task.read()
        return high_or_low

# Reads Continious High or Low inputs on DAQ device.
@keyword("Digital In Counter")
def Daq_in_counter(line):
    name = "name"
    #Gör en funktion som räknar hur många gånger blå LED är HIGH Under charging statet. >2 är lika med blinkande.

# Opens a serial connection via UART.
@keyword("Open Serial")
def Open_Serial(port):
    ser = serial.Serial(port, baudrate=115200, timeout=2)
    if ser:
        return ser
    else: exit

# Closes serial connection via UART.
@keyword("Close Serial")
def Close_Serial(ser):
    ser.close()

# Runs predefined Robot Framework Tests via subprocess.
def run_robot_test(foldername, testname):

    # Ange sökvägen till ditt Robot Framework-test
    robot_test_path = os.path.join("Tests/{}/{}".format(foldername, testname))

    # Skapa mappen "Output" om den inte redan finns
    output_directory = os.path.join(os.path.dirname(os.path.abspath(__file__)), "Output")
    os.makedirs(output_directory, exist_ok=True)

    # Generera unika filnamn med tidsstämpel
    timestamp = datetime.now().strftime("%Y%m%d_%H%M")
    #output_filename = f"output_{testname}_{timestamp}.xml"
    log_filename = f"log_{testname}_{timestamp}.html"
    #report_filename = f"report_{timestamp}.html"

    # Ange sökvägarna för rapport- och loggfiler
    #output_path = os.path.join(output_directory, output_filename)
    log_path = os.path.join(output_directory, log_filename)
    #report_path = os.path.join(output_directory, report_filename)

    # Kör testet med subprocess och ange sökvägarna för rapport- och loggfiler
    subprocess.run(["robot", 
                    "--outputdir", output_directory, 
                    #"--output", output_path, 
                    "--log", log_path, 
                    #"--report", report_path,
                    robot_test_path])
    
# Retrieves current charger state via UART.
@keyword("Collect State")
def collect_state(ser, timeout=5):
    ser.timeout = timeout
    start_time = time.time()

    # while True:
    #     data = ser.readline().decode('utf-8').strip()
    #     if data:
    #         return data
    output = StringIO()
    while True:
        
        #for _ in range(5):
            data = ser.readline().decode(encoding='utf-8',errors='ignore').strip()
            if data:
                if 'CHARGER: State 1:' in data or 'CHARGER: State 2:' in data:
                    line = str(data)
                    output.write(line)
                    return data
                if 'OCPP:' or 'NVS:' in data:
                    continue
                else:
                    continue
            # if 'CH_STATE' not in data:
            # continue
            
                    
            #if 'CH_STATE' in data:
            #    return data
            return output.getvalue()
            

            elapsed_time = time.time() - start_time
            if elapsed_time >= timeout:
                return None  # Timeout - returnera None för att indikera timeout

# Retrieves current charger state via UART.
@keyword("Collect State 15 sec")
def Collect_State_15sec(ser, state, timeout=15):
    ser.timeout = timeout
    end_time = datetime.now() + timedelta(seconds=timeout)

    while True:
        try:
            data = ser.readline().decode('utf-8').strip()
        except UnicodeDecodeError:
            print("UnicodeDecodeError encountered, skipping invalid data.")
            continue  # Skip the current iteration and continue reading data
        if data:
            if datetime.now() >= end_time:
                return None  # Timeout - returnera None för att indikera timeout
            if state in data and 'CHARGER: State ' in data:
                return data
            else:
                continue
      
# Creates a log of startup routine via UART.
@keyword("Initial Log")
def start_charger(ser):
    
    start_time = time.time()  # Starttidpunkt för timer
    version = []
    Start_Relay(8)
    
    while True:
        if time.time() - start_time >= 10:
            break
        message = ser.readline().decode().strip()
        
        version.append(message)
        # if "App version:" in message:
        #     version_line = message.strip()
        #     version.append(version_line.split("App version:")[1].strip())

        # if "wifi: connected" in message:
        #     version.append(message.strip())


        #logging.info(message)
        

    time.sleep(2)


    return version

@keyword("Create Log")
def initiation_log(data_list):

    now = datetime.now().strftime("%Y-%m-%d_%H-%M")

    output_directory = os.path.join(os.path.dirname(os.path.abspath(__file__)), "Output")
    os.makedirs(output_directory, exist_ok=True)

    # filename = os.path.join(output_directory, f"Initiation_{now}.csv")
    filename = os.path.join(output_directory, "Initiation.csv")

    with open(filename, "w", encoding="utf-8") as file:
        for item in data_list:
            cleaned = re.sub(r'\x1b\[[0-9;]*m', '', item)
            file.write(f"{cleaned}\n")

@keyword("Read Config")
def read_config(search):
    current_directory = os.path.dirname(os.path.abspath(__file__))
    filename = os.path.join(current_directory, "Output", "Initiation.csv")
    result = []

    with open(filename, "r", newline="") as file:
        csv_reader = csv.reader(file)
        for row in csv_reader:
            if any(search in cell for cell in row):
                result.append(row)
    
    return result

# Measures the duty cycle of PWM signal in % high side. (Dependent on config max_current)
def measure_pwm_duty_cycle(n):
    with nidaqmx.Task() as task:
        channel_name =f"Dev1/ai{n}"  # Ange kanal för Daq inläsning av CP/PP värde
        task.ai_channels.add_ai_voltage_chan(channel_name, min_val=-10.0, max_val=10.0, terminal_config=TerminalConfiguration.RSE)  # Uppdatera gränsvärdena efter behov
        samples = task.read(number_of_samples_per_channel=2500)  # Justera antalet prov per kanal efter behov

        #Beräkna duty cycle som andelen av proverna över en tröskel (t.ex. 0.5 för en 50% duty cycle)
        threshold = 0
        above_threshold = sum(1 for sample in samples if sample > threshold)
        duty_cycle = (above_threshold / len(samples))*100

        # Uträkning
        # Duty Cycle +100% = 60 A
        # (%positivePWM/100) * CurrentMax(60A) = A

        return float(duty_cycle) 

# Measures the time for relayboard to shutdown in case of lack of Ground or PP signal.
@keyword("Relay Timing")
def measure_time(line,relay):
    # Skapa ett DAQ-objekt
    with nidaqmx.Task() as task:
        # Ange inställningar för mätningen
        task.di_channels.add_di_chan("Dev1/port1/line{}".format(line))
        time_to_stop = datetime.now()
        # Stäng reläet
        Close_Relay(relay)

        # Mät tiden tills spänningen blir låg
        while True:
            voltage = task.read()
            if voltage == False:
                time_to_stop = (datetime.now() - time_to_stop)
                result = time_to_stop.total_seconds() * 1000 
                break

    # Returnera tiden det tog från att reläet stängdes till att spänningen blev låg
    return result
    #return time.monotonic() / 1000

# Gets current CP and PP signal voltage value depending on what state charger is in.
@keyword("Get CP/PP Value")
def analog_in(channel):
    with nidaqmx.Task() as task:
        task.ai_channels.add_ai_voltage_chan("dev1/ai{}".format(channel),min_val=0 ,terminal_config=TerminalConfiguration.RSE)
        CP_PP = task.read()

        while CP_PP < 1:
            CP_PP = task.read()
        
        return CP_PP * 2

# Validates if there is a wifi connection. (Included in startup.)
@keyword("Validate Wifi")
def validate_wifi(ser, timeout=5):
    # ser = serial.Serial('COM9', baudrate=115200)
    ser.timeout = timeout
    start_time = time.time()

    # while True:
    #     data = ser.readline().decode('utf-8').strip()
    #     if data:
    #         return data
    while True:
        data = ser.readline().decode('utf-8').strip()
        if data:
            if 'wifi: got ip' in data:
                return data

        elapsed_time = time.time() - start_time
        if elapsed_time >= timeout:
            return None  # Timeout - returnera None för att indikera timeout

# API call to start a remote transaction via cloud if its accepted.
@keyword("Start Transaction")
def start_transaction(connector, macAddress):
    url = f"http://20.240.4.177/API/RemoteStartTransaction/{macAddress}/{connector}/RobotTest@ithing.se"  #Ange URL:en för API:et du vill anropa

    response = requests.get(url)  # Skicka GET-förfrågan till API:et

    if response.status_code == 200:  # Kontrollera om förfrågan lyckades
        return response.text  # Returnera innehållet i svaret från API:et
    else:
        return "Request Failed."  # Om förfrågan misslyckades kan du hantera det här

# API call to get last known transaction of connector and chargepoint, and then stop the transaction.
@keyword("Stop Transaction")
def stop_transaction(connector, macAddress):
    # GET TRANSACTION ID.
    transaction_url = f"http://20.240.4.177/API/LastTransaction/{macAddress}/{connector}"  #Ange URL:en för API:et du vill anropa
    transaction_id = ""
    transaction_response = requests.get(transaction_url)  # Skicka GET-förfrågan till API:et
    
    if transaction_response.status_code == 200:  # Kontrollera om förfrågan lyckades
        data = transaction_response.json()
        transaction_id = data.get("TransactionId")  # Returnera innehållet i svaret från API:et
    else:
        return "No Transaction ID found."
    
    url = f"http://20.240.4.177/API/RemoteStopTransaction/{macAddress}/{transaction_id}"  #Ange URL:en för API:et du vill anropa

    print(url)
    response = requests.get(url)  # Skicka GET-förfrågan till API:et

    if response.status_code == 200:  # Kontrollera om förfrågan lyckades
        return response.text  # Returnera innehållet i svaret från API:et
    else:
        return "Error finding transaction"
    
# Mäter Left L1 och Right L1, Loggar om laddning bryts
def Error_log(ser):
    Log = []
    vState1 = vState2 = True
    numberofErrorsPort1 = numberofErrorsPort2 = 0
    now = datetime.now()
    #end_time = now.replace(hour=8, minute=10, second=12, microsecond=0)
    end_time = datetime.now() + timedelta(hours=2)
    # Write to a file in a subfolder named "output"
    output_folder = 'output'
    file_path = os.path.join(output_folder, 'ErrorLog.csv')
    
    write_to_csv(file_path,'RUNNING!','w')
    with nidaqmx.Task() as task:
            # Ange inställningar för mätningen
            task.di_channels.add_di_chan("Dev1/port0/line{}".format(14))
            task.di_channels.add_di_chan("Dev1/port0/line{}".format(15))
            #Läser om Sista relät drar, Skriver då ut loggar.
            while True:
                voltage = task.read()
                try:
                    data = ser.readline().decode('utf-8').strip()
                    if len(Log) >= 10:
                        Log.clear()
                    Log.append(data)
                except UnicodeDecodeError:
                    print("UnicodeDecodeError encountered, skipping invalid data.")
                    continue  # Skip the current iteration and continue reading data
                
                #Port1(Right)
                if voltage[0] == True:
                    vState1 = True
                if voltage[0] == False and vState1 == True:
                    numberofErrorsPort1 = numberofErrorsPort1 + 1
                    vState1 = False
                    write_to_csv(file_path,'\nError Port1(Right) Number:'+str(numberofErrorsPort1),'a')
                    write_to_csv(file_path,datetime.now(),'a')
                    for i in range(len(Log)):
                        write_to_csv(file_path,Log[i],'a')
                    
                #Port2(Left)
                if voltage[1] == True:
                    vState2 = True
                if voltage[1] == False and vState2 == True:
                    numberofErrorsPort2 = numberofErrorsPort2 + 1
                    vState2 = False
                    write_to_csv(file_path,'\nError Port2(Left) Number:'+str(numberofErrorsPort2),'a')
                    write_to_csv(file_path,datetime.now(),'a')
                    for i in range(len(Log)):
                        write_to_csv(file_path,Log[i],'a')
                
                if datetime.now() >= end_time:
                    contents = []
                    try:
                        with open(file_path, mode='r', newline='', encoding='utf-8') as file:
                            reader = csv.reader(file)
                            for row in reader:
                                contents.append(row)
                    except Exception as e:
                        print(f"Error reading CSV file: {e}")
                        
                    return str(contents)
                if voltage[0] == False or voltage[1] == False:
                    try:
                        continue
                    except UnicodeDecodeError:
                        print("UnicodeDecodeError encountered, skipping invalid data.")
                        continue  # Skip the current iteration and continue reading data
                              
def write_to_csv(filename, string_data, mode):
    """
    Writes a string to a CSV file.

    Parameters:
    filename (str): The relative or absolute path of the CSV file.
    string_data (str): The string data to write to the CSV file.
    append (bool): If True, data will be appended to the file. If False, the file will be overwritten.
    """
    # Ensure the directory exists
    os.makedirs(os.path.dirname(filename), exist_ok=True)

    
    try:
        with open(filename, mode=mode, newline='', encoding='utf-8') as file:
            writer = csv.writer(file)
            
            # Write the string data as a row in the CSV file
            writer.writerow([string_data])

    except Exception as e:
        print(f"Error writing to CSV file: {e}")

def get_xml_files(folder):

    return [os.path.join(folder, f) for f in os.listdir(folder) if f.endswith(".xml")]

def merge_and_convert_reports():
    output_folder = "Output"

    xml_files = get_xml_files(output_folder)
    port_1_files = [f for f in xml_files if "Port_1" in f]
    port_2_files = [f for f in xml_files if "Port_2" in f]

    if port_1_files:
        # Slå samman XML-rapporter för Port_1
        merged_xml_file_port_1 = os.path.join(output_folder, "Port_1_merged_report.xml")
        subprocess.run(["rebot", "--output", output_folder, "--merge", "-o", merged_xml_file_port_1] + port_1_files)
        print("Merged XML report for Port_1 generated successfully.")

        # Omvandla den sammanfogade XML-rapporten till HTML med standardmallen
        subprocess.run(["rebot", "--output", output_folder, "--output", os.path.join(output_folder, "Port_1_merged_report.html"), "--template", "path/to/robotframework_default_template.html", merged_xml_file_port_1])
        print("Converted merged XML report for Port_1 to HTML.")

    if port_2_files:
        # Slå samman XML-rapporter för Port_2
        merged_xml_file_port_2 = os.path.join(output_folder, "Port_2_merged_report.xml")
        subprocess.run(["rebot", "--output", output_folder, "--merge", "-o", merged_xml_file_port_2] + port_2_files)
        print("Merged XML report for Port_2 generated successfully.")

        # Omvandla den sammanfogade XML-rapporten till HTML med standardmallen
        subprocess.run(["rebot", "--output", output_folder, "--output", os.path.join(output_folder, "Port_2_merged_report.html"), "--template", "path/to/robotframework_default_template.html", merged_xml_file_port_2])
        print("Converted merged XML report for Port_2 to HTML.")

    print("Merged HTML reports generated successfully.")

if __name__ == "__main__":
    main()