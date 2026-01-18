import pyotp
import time

def lambda_handler(event, context):
    # Your shared secret (seed)
    shared_secret = "JBSWY3DPEHPK3PXP" 
    
    # 1. Standard TOTP Generation
    totp = pyotp.TOTP(shared_secret)
    current_code = totp.now()
    
    # 2. Manual "HOTP to TOTP" Logic
    # If you only have an HOTP function, calculate the counter manually:
    timestep = 30
    time_counter = int(time.time() / timestep)
    
    hotp = pyotp.HOTP(shared_secret)
    converted_code = hotp.at(time_counter)
    
    return {
        "totp_code": current_code,
        "manual_converted_code": converted_code
    }
