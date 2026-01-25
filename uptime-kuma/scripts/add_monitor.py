import os
from dotenv import load_dotenv
from uptime_kuma_api import UptimeKumaApi, MonitorType

# Load environment variables
load_dotenv()

# Configuration
UPTIME_KUMA_URL = os.getenv("UPTIME_KUMA_URL", "http://192.168.1.2:3001")
USERNAME = os.getenv("UPTIME_KUMA_USERNAME")
PASSWORD = os.getenv("UPTIME_KUMA_PASSWORD")


def add_web_audit_monitor():
    api = UptimeKumaApi(UPTIME_KUMA_URL)
    
    try:
        print(f"Connecting to {UPTIME_KUMA_URL}...")
        api.login(USERNAME, PASSWORD)
        
        # Check if monitor already exists
        monitors = api.get_monitors()
        for monitor in monitors:
            if monitor['name'] == "GenBI":
                print("Monitor 'GenBI' already exists. Skipping.")
                return

        print("Adding 'GenBI' monitor...")
        
        # Patch for Uptime Kuma 2.0 compatibility
        # We manually build the data and add the required 'conditions' field
        data = api._build_monitor_data(
            type=MonitorType.HTTP,
            name="GenBI",
            url="https://genbi.jalcocertech.com/",
            interval=600,
            retryInterval=60,
            maxretries=3
        )
        data["conditions"] = [] # Required by Uptime Kuma 2.0
        
        # Call the internal API method directly
        from uptime_kuma_api.api import _convert_monitor_input, Event
        _convert_monitor_input(data)
        
        with api.wait_for_event(Event.MONITOR_LIST):
            api._call("add", data)
            
        print("Success!")
        
    except Exception as e:
        print(f"Error: {e}")
    finally:
        api.disconnect()


if __name__ == "__main__":
    add_web_audit_monitor()