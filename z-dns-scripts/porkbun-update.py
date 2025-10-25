#https://porkbun.com/api/json/v3/documentation
# Porkbun Nameserver Management Tool

import os
import requests
import json
import questionary
from dotenv import load_dotenv
from typing import List, Dict, Optional

# Load environment variables
env_path = os.path.join(os.path.dirname(__file__), '.env')
load_dotenv(env_path)

PORKBUN_API_KEY = os.getenv('PORKBUN_API_KEY')
PORKBUN_SECRET_KEY = os.getenv('PORKBUN_SECRET_KEY')
PORKBUN_API_URL = 'https://api.porkbun.com/api/json/v3'

def get_auth_payload() -> Dict[str, str]:
    """Returns the authentication payload for API requests."""
    return {
        'apikey': PORKBUN_API_KEY,
        'secretapikey': PORKBUN_SECRET_KEY
    }

def get_domain_details(domain: str) -> Dict:
    """Gets detailed information about a domain (alternative to getNs)."""
    if not all([PORKBUN_API_KEY, PORKBUN_SECRET_KEY]):
        return {'success': False, 'error': 'Missing Porkbun API credentials in .env file.'}

    # Try the domain details endpoint which might include nameserver info
    url = f"{PORKBUN_API_URL}/domain/listAll"
    payload = get_auth_payload()

    try:
        response = requests.post(url, json=payload)
        response.raise_for_status()
        data = response.json()

        if data.get('status') == 'SUCCESS':
            domains = data.get('domains', [])
            # Find the specific domain
            for dom in domains:
                if dom.get('domain') == domain:
                    return {'success': True, 'domain_info': dom}
            return {'success': False, 'error': f'Domain {domain} not found in account'}
        else:
            return {'success': False, 'error': 'Failed to retrieve domain details.', 'details': data}

    except requests.exceptions.RequestException as e:
        return {'success': False, 'error': str(e), 'details': e.response.json() if e.response else 'No response'}

def list_domains() -> Dict:
    """Retrieves all domains in the account."""
    if not all([PORKBUN_API_KEY, PORKBUN_SECRET_KEY]):
        return {'success': False, 'error': 'Missing Porkbun API credentials in .env file.'}

    url = f"{PORKBUN_API_URL}/domain/listAll"
    payload = get_auth_payload()

    try:
        response = requests.post(url, json=payload)
        response.raise_for_status()
        data = response.json()

        if data.get('status') == 'SUCCESS':
            domains = data.get('domains', [])
            return {'success': True, 'domains': domains}
        else:
            return {'success': False, 'error': 'Failed to retrieve domains.', 'details': data}

    except requests.exceptions.RequestException as e:
        return {'success': False, 'error': str(e), 'details': e.response.json() if e.response else 'No response'}

def get_nameservers(domain: str) -> Dict:
    """Gets the current nameservers for a domain."""
    if not all([PORKBUN_API_KEY, PORKBUN_SECRET_KEY]):
        return {'success': False, 'error': 'Missing Porkbun API credentials in .env file.'}

    url = f"{PORKBUN_API_URL}/domain/getNs/{domain}"
    payload = get_auth_payload()

    try:
        response = requests.post(url, json=payload)
        
        # Try to get response content even if status is not 200
        try:
            response_data = response.json()
        except:
            response_data = {'message': response.text}
        
        # Don't raise_for_status() immediately - check the response first
        if response.status_code == 200 and response_data.get('status') == 'SUCCESS':
            nameservers = response_data.get('ns', [])
            return {'success': True, 'nameservers': nameservers}
        else:
            return {'success': False, 'error': f'Failed to get nameservers for {domain}.', 'details': response_data}

    except requests.exceptions.RequestException as e:
        error_details = 'No response'
        try:
            if e.response:
                error_details = e.response.json()
        except:
            try:
                if e.response:
                    error_details = e.response.text
            except:
                pass
        return {'success': False, 'error': str(e), 'details': error_details}

def update_nameservers(domain: str, nameservers: List[str]) -> Dict:
    """Updates the nameservers for a domain."""
    if not all([PORKBUN_API_KEY, PORKBUN_SECRET_KEY]):
        return {'success': False, 'error': 'Missing Porkbun API credentials in .env file.'}

    url = f"{PORKBUN_API_URL}/domain/updateNs/{domain}"
    payload = get_auth_payload()
    payload['ns'] = nameservers

    try:
        response = requests.post(url, json=payload)
        response.raise_for_status()
        data = response.json()

        if data.get('status') == 'SUCCESS':
            return {'success': True, 'message': f'Nameservers updated successfully for {domain}'}
        else:
            return {'success': False, 'error': f'Failed to update nameservers for {domain}.', 'details': data}

    except requests.exceptions.RequestException as e:
        return {'success': False, 'error': str(e), 'details': e.response.json() if e.response else 'No response'}

def format_domain_info(domain: Dict) -> str:
    """Formats domain information for display."""
    domain_name = domain.get('domain', 'Unknown')
    status = domain.get('status', 'Unknown')
    expiry = domain.get('expiry', 'Unknown')
    
    return f"{domain_name} (Status: {status}, Expires: {expiry})"

def get_nameserver_input() -> List[str]:
    """Gets nameserver input from user with validation."""
    nameservers = []
    
    print("\nEnter nameservers (you can enter 2-4 nameservers):")
    print("Press Enter without typing anything to finish entering nameservers.")
    
    for i in range(4):  # Maximum 4 nameservers
        if i < 2:
            prompt = f"Enter nameserver {i+1} (required): "
        else:
            prompt = f"Enter nameserver {i+1} (optional): "
            
        ns = questionary.text(prompt).ask()
        
        if not ns:
            if i < 2:
                print("At least 2 nameservers are required!")
                return get_nameserver_input()  # Restart input
            else:
                break
        
        # Basic validation
        if '.' not in ns:
            print(f"Invalid nameserver format: {ns}")
            return get_nameserver_input()  # Restart input
            
        nameservers.append(ns)
    
    return nameservers

def main():
    """Main function to run the nameserver management tool."""
    print("Porkbun Nameserver Management Tool")
    print("==================================")

    if not all([PORKBUN_API_KEY, PORKBUN_SECRET_KEY]):
        print("\nError: Missing Porkbun API credentials.")
        print("Please add PORKBUN_API_KEY and PORKBUN_SECRET_KEY to your .env file.")
        return

    # Get all domains
    print("\nRetrieving your domains...")
    domains_result = list_domains()
    
    if not domains_result.get('success'):
        print(f"\nError: {domains_result.get('error')}")
        if domains_result.get('details'):
            print(f"Details: {json.dumps(domains_result.get('details'), indent=2)}")
        return

    domains = domains_result.get('domains', [])
    
    if not domains:
        print("No domains found in your account.")
        return

    print(f"\nFound {len(domains)} domain(s) in your account:")
    
    # Create choices for domain selection
    domain_choices = []
    for domain in domains:
        formatted_info = format_domain_info(domain)
        domain_choices.append({
            'name': formatted_info,
            'value': domain.get('domain')
        })

    # Let user select a domain
    selected_domain = questionary.select(
        "Select a domain to manage nameservers:",
        choices=domain_choices
    ).ask()

    if not selected_domain:
        print("No domain selected. Exiting.")
        return

    print(f"\nSelected domain: {selected_domain}")

    # Get current nameservers - try multiple approaches
    print("Retrieving current nameservers...")
    
    # First try the getNs endpoint
    ns_result = get_nameservers(selected_domain)
    current_ns = []
    
    if not ns_result.get('success'):
        error_details = ns_result.get('details', {})
        
        # Check if it's the "not opted in" error
        if isinstance(error_details, dict) and "not opted in to API access" in str(error_details.get('message', '')).lower():
            print(f"\n❌ API Access Not Enabled")
            print(f"The domain '{selected_domain}' is not opted in for API access.")
            print("\n📋 To enable API access for this domain:")
            print("1. Go to https://porkbun.com/account/domainsSpeedy")
            print("2. Find your domain and click 'Details'")
            print("3. Look for 'API Access' section")
            print("4. Enable 'API Access' for the domain")
            print("5. Wait a few minutes for the changes to take effect")
            print("6. Run this script again")
            print("\n💡 Note: You need to enable API access for each domain individually.")
            return
        else:
            print(f"\nWarning: getNs endpoint failed: {ns_result.get('error')}")
            if ns_result.get('details'):
                print(f"Details: {json.dumps(ns_result.get('details'), indent=2)}")
        
        # For other errors, we can still try to proceed with nameserver updates
        current_ns = []
        print(f"\n⚠️  Could not retrieve current nameservers, but you can still set new ones.")
    else:
        current_ns = ns_result.get('nameservers', [])
    
    print(f"\nCurrent nameservers for {selected_domain}:")
    if current_ns:
        for i, ns in enumerate(current_ns, 1):
            print(f"  {i}. {ns}")
    else:
        print("  No nameservers found or using default Porkbun nameservers.")

    # Ask if user wants to change nameservers
    change_ns = questionary.confirm(
        f"\nDo you want to change the nameservers for {selected_domain}?",
        default=False
    ).ask()

    if not change_ns:
        print("No changes made. Exiting.")
        return

    # Get new nameservers
    print(f"\nEntering new nameservers for {selected_domain}:")
    new_nameservers = get_nameserver_input()
    
    if not new_nameservers:
        print("No nameservers entered. Exiting.")
        return

    print(f"\nNew nameservers to set:")
    for i, ns in enumerate(new_nameservers, 1):
        print(f"  {i}. {ns}")

    # Confirm the change
    confirm_update = questionary.confirm(
        f"\nConfirm updating nameservers for {selected_domain}?",
        default=False
    ).ask()

    if not confirm_update:
        print("Update cancelled.")
        return

    # Update nameservers
    print(f"\nUpdating nameservers for {selected_domain}...")
    update_result = update_nameservers(selected_domain, new_nameservers)
    
    if update_result.get('success'):
        print(f"\n✅ Success! {update_result.get('message')}")
        print("\nNote: DNS changes may take up to 48 hours to propagate globally.")
    else:
        print(f"\n❌ Error: {update_result.get('error')}")
        if update_result.get('details'):
            print(f"Details: {json.dumps(update_result.get('details'), indent=2)}")

if __name__ == '__main__':
    main()