# Cloudflare Security Guide for Home-Labs

Using a Cloudflare Tunnel is a great start, but you should use the **WAF (Web Application Firewall)** to block bots and malicious actors before they ever reach your server.

## Strategy: Geo-Blocking (Country Filtering)

For most home-labs, the "Whitelist" (Allow only one country) approach is the most secure.

### 1. The "Allow List" (Recommended)

This blocks every country in the world **except** yours. 

#### **Step-by-Step Navigation:**

1.  **Log in** to your [Cloudflare Dashboard](https://dash.cloudflare.com/).
2.  **Select your Domain** (e.g., `jalcocertech.com`).
3.  In the left sidebar, click **Security** (the shield icon).
4.  Click **Security Rules** in the dropdown.
5.  Click **+ Create rule**.
6.  **Rule name**: Give it a name (e.g., `Allow only Spain`).
7.  **If incoming requests match...**:
    *   **Field**: `Country`
    *   **Operator**: `does not equal`
    *   **Value**: `Spain`
8.  **Then... (Action)**: Select `Block`.
9.  Click **Deploy**!

#### **Whitelisting Multiple Countries (e.g., Spain + Poland)**

If you want to allow **more than one** country, you must use **AND** logic or a **LIST**.

*   **Logic**: `(ip.src.country ne "ES" and ip.src.country ne "PL")` more specific as `(http.host eq "nc.jalcocertech.com" and not ip.src.country in {"ES" "PL"})`
*   **Translation**: "Block if the user is NOT from Spain AND NOT from Poland."

> [!WARNING]
> **Do not use OR** for blocking. If you use `(NOT Spain) OR (NOT Poland)`, Cloudflare will block **everyone in the world** (including you), because everyone is either "not in Spain" or "not in Poland".

#### Using the Expression Editor
Click "Edit Expression" and paste this for multi-country support:
```bash
not (ip.src.country in {"ES" "PL"})
```

*Action: Block*

---

#### **Whitelisting for a Specific Subdomain**

If you only want this rule to apply to your Nextcloud (and leave your main site or other subdomains open), you need to add a **Hostname** condition.

*   **Logic**: `If Hostname equals "nc.example.com" AND Country is not in {"ES" "PL"} -> Block`

#### Using the Expression Editor
Paste this to protect **only** one subdomain:
```bash
(http.host eq "nc.jalcocertech.com" and not ip.src.country in {"ES" "PL"})
```

#### UI Steps:
1.  **Field**: `Hostname` | **Operator**: `equals` | **Value**: `nc.jalcocertech.com`
2.  Click **And**
3.  **Field**: `Country` | **Operator**: `is not in` | **Value**: `Spain`, `Poland`
4.  **Action**: `Block`

---

### 2. The "Block List"

---

## WAF vs. Zero Trust Access

| Feature | WAF Custom Rule | Zero Trust Access |
| :--- | :--- | :--- |
| **User Experience** | Shows a "403 Forbidden" page. | Requires a login (Email/OTP/SAML). |
| **Best For** | Blocking bots & generic traffic. | Access for yourself and family. |
| **Mobile Apps** | Works perfectly with Nextcloud App. | Can break some mobile app connections. |

### Pro-Tip for Nextcloud Mobile

Nextcloud's mobile app and desktop client often **struggle with Zero Trust login screens.** 

**Best setup:**

1.  Use **WAF Geo-blocking** for the main `nc.example.com` domain.
2.  Use **Zero Trust Access** only for administrative pages like `/admin` or for other sensitive tools like Portainer.

---

## Monitoring Attacks

Check the **Security > Events** tab in Cloudflare.

You will see a map and logs of everyone Cloudflare has blocked. If you see dozens of blocks from countries you don't live in, then the rules are working!
