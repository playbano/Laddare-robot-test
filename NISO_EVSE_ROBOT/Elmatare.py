import serial
import time
import os 
from datetime import datetime
import subprocess
import threading
import test as testet
 

# Configure serial port
SERIAL_PORT = 'COM9'  
BAUD_RATE = 115200

USERWH = 123456
USERAMPERE = 10
USERVOLT = 213

#ANVÄND I ROBOT
def read_and_answer_ROBOT(ser, userAmpere, userWh, userVolt, send_count = 0, total_sends = 2):
        testAmpere = userAmpere
        print("Sending:",userAmpere)
        while True:
  
                hex_data = ser.read().hex()  # Read 
                if not hex_data:
                    print("Not recieving from",SERIAL_PORT, "exiting...")
                    return False
                #Searching for Slave ID
                if hex_data in ['01','03']:
                    slave_ID = hex_data
                    hex_list = [hex_data]
                    
                    # Read 7 bytes
                    for _ in range(7):
                        data = ser.read()
                        hex_data = data.hex()
                        hex_list.append(hex_data)       
                        
                    if  hex_list[1]=='04':

                        if hex_list[2] == '05' and hex_list[3] == '00':
                            Serial_Send(ser,Wh_Answer(slave_ID,userWh))
                        
                        if hex_list[2]=='00'and hex_list[3] == '00':
                            Serial_Send(ser,Volt_Answer(slave_ID,userVolt))
                        
                        if hex_list[3] == '0c':
                            Serial_Send(ser,Ampere_Answer(slave_ID,userAmpere))
                            #print("Sendnr: ",send_count,"/",total_sends)
                            send_count += 1
                                    
                            if send_count > total_sends:
                                if userAmpere == testAmpere:
                                    return True
                                userAmpere = testAmpere
                            
                                
                                    
                            
                            

                else:
                    pass
        return True

#ANVÄND STANDALONE
def read_and_answer_STANDALONE(ser, userAmpere, userWh, userVolt, send_count = 1, total_sends = 10):
        print("Sending:",userAmpere)
        
        while True:
  
                hex_data = ser.read().hex()  # Read 
                
                if not hex_data:
                    print("Not recieving from",SERIAL_PORT, "exiting...")
                    return False
                #Searching for Slave ID
                if hex_data in ['01','03']:
                    slave_ID = hex_data
                    hex_list = [hex_data]
                    
                    # Read 7 bytes
                    for _ in range(7):
                        data = ser.read()
                        hex_data = data.hex()
                        hex_list.append(hex_data) 
                        if hex_list[1] != '04':
                            break      
                        
                    if  hex_list[1]=='04':

                        if hex_list[2] == '05' and hex_list[3] == '00':
                            Serial_Send(ser,Wh_Answer(slave_ID,userWh))
                            
                        
                        if hex_list[2]=='00'and hex_list[3] == '00':
                            Serial_Send(ser,Volt_Answer(slave_ID,userVolt))
                            
                        
                        if hex_list[2]=='00' and hex_list[3] == '0c':
                            Serial_Send(ser,Ampere_Answer(slave_ID,userAmpere))
                            print("Sendnr: ",send_count,"/",total_sends)
                            send_count += 1
                            
                                    
                            if send_count > total_sends:
                                if userAmpere > 20:
                                    
                                    userVolt /= 2
                                    userWh /= 2
                                    userAmpere /= 2
                                    send_count = 1
                                    print("--------------------------------------------------------")
                                    print("Sending",userAmpere)
                                    print("--------------------------------------------------------")
                                send_count = 1
                                userAmpere += 2
                                
                                    
                            
                            

                else:
                    pass
        return True

def receive_serial_data(port, baudrate, userAmpere=USERAMPERE, userKWhTOT=USERWH, userVolt=USERVOLT):  
    try:
        # Open serial port
        ser = open_serial_port(port, baudrate)
        print(f"Listening on {port}...")
        serialReturn = False
        #serialReturn = read_and_answer_STANDALONE(ser,userAmpere,userKWhTOT,userVolt)
        serialReturn = read_and_answer_ROBOT(ser,userAmpere,userKWhTOT,userVolt)


    except serial.SerialException as e:
        print("Serial port error:", e)
        return False
    except KeyboardInterrupt:
        # Handle KeyboardInterrupt (Ctrl+C) to gracefully exit the loop
        print("\nLoop interrupted by user.")
    finally:
        if ser.is_open:
            close_serial_port(ser)
            if serialReturn == True: return True
            else: return False

def open_serial_port(port, baudrate):
    ser = serial.Serial(port, baudrate,timeout=5)
    if ser:
        return ser
    else: exit

def close_serial_port(ser):
    ser.close()
    return print("Port Closed")

def kWh_Add_0(kWh):
    kWh=kWh*10
    return int(kWh)

def AMPERE_Add_000(ampere):
    ampere = ampere * 1000
    return int(ampere)

def Wh_Answer(slave_ID,userWh):
    
    convertList = uint64_to_little_endian_bytes(userWh)
    print(convertList)
    
    WhAnswerList = [slave_ID,'04','04']
    
    #print("-------------------------------------------------------------------------------------------")
    #print("Sending to Port:",slave_ID)
    
    #kWh tot
    #print("Sending ",userWh,"Wh ","to Port ",slave_ID)
    WhAnswerList.extend(convertList)
    
    #print(WhAnswerList)
    
    WhAnswer = ''.join(WhAnswerList)
    #print(WhAnswer)
    completed_answer= CRCReturn(WhAnswer)
    #print("Completed answer:",completed_answer)
    if len(completed_answer) % 2 != 0:
        completed_answer = "0" + completed_answer  # Prepend a '0' if necessary
    #print("Bytes: ",HEX_to_Bytes(completed_answer))
    return HEX_to_Bytes(completed_answer)

def Volt_Answer(slave_ID,userVolt):
    
    volt = kWh_Add_0(userVolt)
    
    convertList= USER_Input_to_hex(volt)
    
    voltAnswerList = [slave_ID,'04','12','00','00','00','00','00','00','00','00','00','00','00','00']
    #print("-------------------------------------------------------------------------------------------")
    #print("Sending to Port:",slave_ID)
    #L1
    #print("Sending ",userVolt,"Volts ","to L1")
    voltAnswerList[3]=convertList[0]
    voltAnswerList[4]=convertList[1]
    #L2
    #print("Sending ",userVolt,"Volts ","to L2")
    voltAnswerList[7]=convertList[0]
    voltAnswerList[8]=convertList[1]
    #L3
    #print("Sending ",userVolt,"Volts ","to L3")
    voltAnswerList[11]=convertList[0]
    voltAnswerList[12]=convertList[1]
    
    voltAnswer = ''.join(voltAnswerList)
    #print(ampereAnswer)
    #print("Bytes :",HEX_to_Bytes(CRCCalc.CRCReturn(ampereAnswer)))
    return HEX_to_Bytes(CRCReturn(voltAnswer))

def Ampere_Answer(slave_ID,userAmpere):
    
    ampere = AMPERE_Add_000(userAmpere)
    
    convertList= USER_Input_to_hex(ampere)
    
    ampereAnswerList = [slave_ID,'04','12','00','00','00','00','00','00','00','00','00','00','00','00']
    #print("-------------------------------------------------------------------------------------------")
    #print("Sending to Port:",slave_ID)
    #L1
    print("Sending ",userAmpere,"A ","to L1")
    ampereAnswerList[3]=convertList[0]
    ampereAnswerList[4]=convertList[1]
    #L2
    #print("Sending ",userAmpere,"A ","to L2")
    ampereAnswerList[7]=convertList[0]
    ampereAnswerList[8]=convertList[1]
    #L3
    #print("Sending ",userAmpere,"A ","to L3")
    ampereAnswerList[11]=convertList[0]
    ampereAnswerList[12]=convertList[1]
    
    ampereAnswer = ''.join(ampereAnswerList)
    #print(ampereAnswer)
    #print("Bytes :",HEX_to_Bytes(CRCCalc.CRCReturn(ampereAnswer)))
    return HEX_to_Bytes(CRCReturn(ampereAnswer))

def HEX_to_Bytes(answer):
    return bytes.fromhex(answer)
    
def Serial_Send(ser, answer):
    ser.write(answer)
    return #print("Sent:", answer)

def USER_Input_to_hex (userInput):
    if userInput < 0:
        hex_bytes = userInput.to_bytes(2, byteorder='big', signed=True).hex()
        hex_bytes = hex_bytes.zfill(4)
        byte1 = hex_bytes[:2]  # First byte (most significant byte)
        byte2 = hex_bytes[2:]  # Second byte (least significant byte)
        hex_list = [byte1, byte2]
        return hex_list
        
        
    else:    
        # Convert decimal to hexadecimal
        hex_value = hex(userInput)[2:]  # Convert to hexadecimal and remove '0x' prefix

        # Ensure the hex string is 4 characters (2 bytes)
        hex_value = hex_value.zfill(4)

        # Extract the bytes in the desired order
        byte1 = hex_value[:2]  # First byte (most significant byte)
        byte2 = hex_value[2:]  # Second byte (least significant byte)

        # Create a list containing these bytes in the desired order
        hex_list = [byte1, byte2]
    
        #print(hex_list)  # Output: ['1B', '58']
        return hex_list

def uint64_to_little_endian_bytes(value):
    # Ensure the value is within the range of an unsigned 64-bit integer
    if not (0 <= value < 2**64):
        raise ValueError("The value is out of range for a 64-bit unsigned integer.")
    
    # Convert the integer to a 16-character hex string, padding with zeros if necessary
    hex_string = f"{value:016x}"
    
    # Split the hex string into pairs of characters (each pair represents one byte)
    hex_bytes = [hex_string[i:i+2] for i in range(0, 16, 2)]
    
    # Convert to little-endian by reversing the list
    hex_bytes_little_endian = hex_bytes[::-1]
    value = hex_bytes_little_endian[1]
    hex_bytes_little_endian[1]=hex_bytes_little_endian[0]
    hex_bytes_little_endian[0]=value
    value = hex_bytes_little_endian[3]
    hex_bytes_little_endian[3]=hex_bytes_little_endian[2]
    hex_bytes_little_endian[2]=value
    hex_bytes_little_endian.pop()
    hex_bytes_little_endian.pop()
    hex_bytes_little_endian.pop()
    hex_bytes_little_endian.pop()
    
    return hex_bytes_little_endian
# Runs predefined Robot Framework Tests via subprocess.
def run_robot_test(testname): 
    # Ange sökvägen till ditt Robot Framework-test
    robot_test_path = os.path.join("Tests/{}".format(testname))

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

def modbusCrc(msg:str) -> int:
    crc = 0xFFFF
    for n in range(len(msg)):
        crc ^= msg[n]
        for i in range(8):
            if crc & 1:
                crc >>= 1
                crc ^= 0xA001
            else:
                crc >>= 1
    return crc


def CRCReturn(data):

    msg = bytes.fromhex(data)
    crc = modbusCrc(msg)
    #print("0x%04X"%(crc))            

    ba = crc.to_bytes(2, byteorder='little')
    #print(data+"%02x%02x"%(ba[0], ba[1]))
    return data+"%02x%02x"%(ba[0], ba[1])


if __name__ == "__main__":
    #run_robot_test('TestCase1.robot')
    receive_serial_data(SERIAL_PORT, BAUD_RATE)
