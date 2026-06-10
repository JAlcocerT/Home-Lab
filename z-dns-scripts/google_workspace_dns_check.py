#!/usr/bin/env python3
"""Check whether a domain is ready for Google Workspace DNS setup.

The script inspects public DNS and reports:
- NS records
- MX records
- SPF TXT record at the root domain
- DKIM TXT record(s) for one or more selectors
- DMARC TXT record at _dmarc.<domain>

It is intentionally read-only and safe to run repeatedly.
"""

from __future__ import annotations

import argparse
import json
import sys
from dataclasses import dataclass, field
from typing import Any, Iterable, Optional

import requests


DOH_URL = "https://dns.google/resolve"


@dataclass
class CheckResult:
    name: str
    status: str
    details: list[str] = field(default_factory=list)

    def to_dict(self) -> dict[str, Any]:
        return {"name": self.name, "status": self.status, "details": self.details}


def query_dns(name: str, record_type: str, timeout: float = 10.0) -> list[str]:
    """Query DNS using Google's DNS-over-HTTPS JSON API."""
    response = requests.get(
        DOH_URL,
        params={"name": name, "type": record_type},
        timeout=timeout,
    )
    response.raise_for_status()
    payload = response.json()
    answers = payload.get("Answer", []) or []
    records: list[str] = []
    for item in answers:
        data = item.get("data")
        if isinstance(data, str):
            records.append(data.strip())
    return records


def normalize_txt(record: str) -> str:
    """Remove surrounding quotes and join TXT fragments if needed."""
    if not record:
        return ""
    return record.replace('" "', "").replace('"', "").strip()


def get_root_txt_records(domain: str) -> list[str]:
    return [normalize_txt(record) for record in query_dns(domain, "TXT")]


def check_ns(domain: str) -> CheckResult:
    records = query_dns(domain, "NS")
    if not records:
        return CheckResult("NS", "missing", [f"No NS records found for {domain}."])
    return CheckResult("NS", "ok", [f"NS records: {', '.join(records)}"])


def check_mx(domain: str) -> CheckResult:
    records = query_dns(domain, "MX")
    if not records:
        return CheckResult("MX", "missing", [f"No MX records found for {domain}."])

    google_ready = any(record.endswith(" smtp.google.com.") or record == "1 smtp.google.com." for record in records)
    details = [f"MX records: {', '.join(records)}"]

    if google_ready and all("smtp.google.com." in record for record in records):
        return CheckResult("MX", "ok", details)

    if google_ready:
        return CheckResult(
            "MX",
            "warning",
            details + [
                "Google MX is present, but there are additional MX records. Google Workspace usually works best with only the Google MX target."
            ],
        )

    return CheckResult(
        "MX",
        "missing",
        details + ["No Google Workspace MX record found. Expected: priority 1, destination smtp.google.com."],
    )


def check_spf(domain: str) -> CheckResult:
    txt_records = get_root_txt_records(domain)
    spf_records = [record for record in txt_records if record.lower().startswith("v=spf1")]

    if not spf_records:
        return CheckResult(
            "SPF",
            "missing",
            ["No SPF TXT record found at the root domain.", "Expected value for Google Workspace only: v=spf1 include:_spf.google.com ~all"],
        )

    if len(spf_records) > 1:
        return CheckResult(
            "SPF",
            "warning",
            [f"Multiple SPF records found: {', '.join(spf_records)}", "Keep only one SPF record per domain."],
        )

    spf = spf_records[0]
    details = [f"SPF record: {spf}"]
    if "include:_spf.google.com" in spf:
        return CheckResult("SPF", "ok", details)

    return CheckResult(
        "SPF",
        "warning",
        details + ["SPF exists, but it does not include Google Workspace. For Google-only mail, use: v=spf1 include:_spf.google.com ~all"],
    )


def check_dkim(domain: str, selectors: Iterable[str]) -> CheckResult:
    found: list[str] = []
    missing: list[str] = []

    for selector in selectors:
        name = f"{selector}._domainkey.{domain}"
        txt_records = get_root_txt_records(name)
        dkim_records = [record for record in txt_records if "v=DKIM1" in record]
        if dkim_records:
            found.append(f"{name}: {dkim_records[0]}")
        else:
            missing.append(name)

    if found and not missing:
        return CheckResult("DKIM", "ok", found)

    if found and missing:
        return CheckResult("DKIM", "warning", found + [f"Missing DKIM selector(s): {', '.join(missing)}"])

    return CheckResult(
        "DKIM",
        "missing",
        [f"No DKIM record found for the requested selector(s): {', '.join(selectors)}"],
    )


def parse_dmarc_policy(record: str) -> Optional[str]:
    for part in record.split(";"):
        piece = part.strip()
        if piece.startswith("p="):
            return piece[2:].strip()
    return None


def check_dmarc(domain: str) -> CheckResult:
    records = get_root_txt_records(f"_dmarc.{domain}")
    dmarc_records = [record for record in records if record.lower().startswith("v=dmarc1")]

    if not dmarc_records:
        return CheckResult(
            "DMARC",
            "missing",
            ["No DMARC TXT record found at _dmarc." + domain, "Recommended starting point: v=DMARC1; p=none; rua=mailto:dmarc@" + domain],
        )

    record = dmarc_records[0]
    policy = parse_dmarc_policy(record)
    if policy:
        return CheckResult("DMARC", "ok", [f"DMARC record: {record}", f"Policy: {policy}"])

    return CheckResult("DMARC", "warning", [f"DMARC record found, but no p= policy was detected: {record}"])


def check_google_workspace(domain: str, selectors: list[str]) -> dict[str, Any]:
    checks = [
        check_ns(domain),
        check_mx(domain),
        check_spf(domain),
        check_dkim(domain, selectors),
        check_dmarc(domain),
    ]

    verdict = "ready"
    if any(check.status == "missing" for check in checks):
        verdict = "not ready"
    elif any(check.status == "warning" for check in checks):
        verdict = "partially ready"

    return {
        "domain": domain,
        "verdict": verdict,
        "checks": [check.to_dict() for check in checks],
    }


def print_human_report(result: dict[str, Any]) -> None:
    print(f"Domain: {result['domain']}")
    print(f"Verdict: {result['verdict']}")
    print()

    for check in result["checks"]:
        status = check["status"].upper()
        print(f"[{status}] {check['name']}")
        for line in check["details"]:
            print(f"  - {line}")
        print()


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Check Google Workspace DNS readiness for a domain.")
    parser.add_argument("domain", help="Root domain to inspect, for example getslubnechwile.com")
    parser.add_argument(
        "--selector",
        dest="selectors",
        action="append",
        default=[],
        help="DKIM selector to check. Can be repeated. Defaults to google and default.",
    )
    parser.add_argument("--json", action="store_true", help="Print JSON instead of a human report.")
    return parser.parse_args(argv)


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    selectors = args.selectors or ["google", "default"]

    try:
        result = check_google_workspace(args.domain.strip().lower(), selectors)
    except requests.RequestException as exc:
        print(f"DNS lookup failed: {exc}", file=sys.stderr)
        return 2

    if args.json:
        print(json.dumps(result, indent=2))
    else:
        print_human_report(result)

    return 0 if result["verdict"] == "ready" else 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
