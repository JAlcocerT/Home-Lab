import os
import json
from dotenv import load_dotenv
from uptime_kuma_api import UptimeKumaApi, MonitorType
from uptime_kuma_api.api import _convert_monitor_input, Event

# Load environment variables
load_dotenv()

# Configuration
UPTIME_KUMA_URL = os.getenv("UPTIME_KUMA_URL", "http://192.168.1.2:3001")
USERNAME = os.getenv("UPTIME_KUMA_USERNAME")
PASSWORD = os.getenv("UPTIME_KUMA_PASSWORD")
MONITORS_FILE = "monitors.json"

def bulk_add_monitors():
    if not os.path.exists(MONITORS_FILE):
        print(f"Error: {MONITORS_FILE} not found.")
        return

    with open(MONITORS_FILE, 'r') as f:
        monitors_to_add = json.load(f)

    api = UptimeKumaApi(UPTIME_KUMA_URL)
    
    # Map friendly names to MonitorType enums
    type_map = {
        "http": MonitorType.HTTP,
        "ping": MonitorType.PING,
        "port": MonitorType.PORT,
        "dns": MonitorType.DNS
    }

    try:
        print(f"Connecting to {UPTIME_KUMA_URL}...")
        api.login(USERNAME, PASSWORD)
        
        # Get existing monitors to avoid duplicates
        existing_monitors = {m['name']: m for m in api.get_monitors()}

        for monitor_data in monitors_to_add:
            name = monitor_data.get("name")
            url = monitor_data.get("url")
            raw_type = monitor_data.get("type", "http").lower()
            
            if name in existing_monitors:
                print(f"Monitor '{name}' already exists. Skipping.")
                continue

            monitor_type = type_map.get(raw_type, MonitorType.HTTP)
            print(f"Adding '{name}' monitor [{raw_type}] ({url})...")
            
            # Build data with Uptime Kuma 2.0 patch
            # Note: For PING, 'hostname' is used instead of 'url' in some logic, 
            # but _build_monitor_data handles them correctly if we pass url for http 
            # and hostname for ping. We'll be flexible here.
            
            kwargs = {
                "type": monitor_type,
                "name": name,
                "interval": 600,
                "retryInterval": 60,
                "maxretries": 3
            }
            
            if monitor_type == MonitorType.PING:
                kwargs["hostname"] = url
            else:
                kwargs["url"] = url

            data = api._build_monitor_data(**kwargs)
            data["conditions"] = [] # Required by Uptime Kuma 2.0
            
            _convert_monitor_input(data)
            
            with api.wait_for_event(Event.MONITOR_LIST):
                api._call("add", data)
                
            print(f"Successfully added '{name}'.")

            
    except Exception as e:
        print(f"Error: {e}")
    finally:
        api.disconnect()

if __name__ == "__main__":
    bulk_add_monitors()
