## https://github.com/JAlcocerT/Streamlit_PoC/blob/main/flask_dnsupdater.py
#https://developers.cloudflare.com/api/

import questionary
import os
import requests
from dotenv import load_dotenv
import json

# Load environment variables from .env file
env_path = os.path.join(os.path.dirname(__file__), '.env')
load_dotenv(env_path)

CLOUDFLARE_API = 'https://api.cloudflare.com/client/v4'
CLOUDFLARE_API_TOKEN = os.getenv('CLOUDFLARE_API_TOKEN')
CLOUDFLARE_ZONE_ID = os.getenv('CLOUDFLARE_ZONE_ID')
DOMAIN = os.getenv('CLOUDFLARE_DOMAIN')  # e.g., example.com

def update_dns_logic(record_name, record_type, ip_address, proxied):
    if not all([record_name, ip_address, CLOUDFLARE_API_TOKEN, CLOUDFLARE_ZONE_ID, DOMAIN]):
        return {'success': False, 'error': 'Missing required parameters or environment variables'}, 400

    headers = {
        'Authorization': f'Bearer {CLOUDFLARE_API_TOKEN}',
        'Content-Type': 'application/json'
    }
    
    # Use '@' for the root domain
    fqdn = DOMAIN if record_name == '@' else f"{record_name}.{DOMAIN}"

    # Get DNS record ID
    get_url = f"{CLOUDFLARE_API}/zones/{CLOUDFLARE_ZONE_ID}/dns_records"
    params = {'name': fqdn, 'type': record_type}
    get_resp = requests.get(get_url, headers=headers, params=params)
    if not get_resp.ok:
        return {'success': False, 'error': 'Failed to query DNS records', 'details': get_resp.text}, 500
    records = get_resp.json().get('result', [])

    if records:
        # Update existing record
        record_id = records[0]['id']
        update_url = f"{CLOUDFLARE_API}/zones/{CLOUDFLARE_ZONE_ID}/dns_records/{record_id}"
        payload = {
            'type': record_type,
            'name': fqdn,
            'content': ip_address,
            'ttl': 1,
            'proxied': proxied
        }
        upd_resp = requests.put(update_url, headers=headers, json=payload)
        if upd_resp.ok:
            return {'success': True, 'action': 'updated', 'record': fqdn, 'response': upd_resp.json()}, 200
        else:
            return {'success': False, 'error': 'Failed to update record', 'details': upd_resp.text}, 500
    else:
        # Create new record
        create_url = f"{CLOUDFLARE_API}/zones/{CLOUDFLARE_ZONE_ID}/dns_records"
        payload = {
            'type': record_type,
            'name': fqdn,
            'content': ip_address,
            'ttl': 1,
            'proxied': proxied
        }
        crt_resp = requests.post(create_url, headers=headers, json=payload)
        if crt_resp.ok:
            return {'success': True, 'action': 'created', 'record': fqdn, 'response': crt_resp.json()}, 201
        else:
            return {'success': False, 'error': 'Failed to create record', 'details': crt_resp.text}, 500

def main():
    """Main function to run the interactive DNS updater."""
    print("Cloudflare DNS Updater")
    print("----------------------")

    if not all([CLOUDFLARE_API_TOKEN, CLOUDFLARE_ZONE_ID, DOMAIN]):
        print("\nError: Missing required environment variables.")
        print("Please ensure CLOUDFLARE_API_TOKEN, CLOUDFLARE_ZONE_ID, and CLOUDFLARE_DOMAIN are set in your .env file.")
        return

    record_name = questionary.text(
        "Enter the subdomain (e.g., 'www', or '@' for the root domain):"
    ).ask()
    if not record_name:
        print("Operation cancelled: Subdomain cannot be empty.")
        return

    record_type = questionary.select(
        "Select the record type:",
        choices=['A', 'AAAA', 'CNAME', 'TXT', 'MX']
    ).ask()

    content = questionary.text(f"Enter the content for the {record_type} record:").ask()
    if not content:
        print("Operation cancelled: Content cannot be empty.")
        return

    proxied = questionary.confirm("Should the record be proxied by Cloudflare?", default=True).ask()

    print("\nUpdating DNS record...")
    result, status_code = update_dns_logic(record_name, record_type, content, proxied)

    print(f"\nResult (Status: {status_code}):")
    print(json.dumps(result, indent=2))

if __name__ == '__main__':
    main()