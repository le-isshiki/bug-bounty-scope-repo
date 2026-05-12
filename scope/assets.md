# Assets

## Current extracted target

# targets/coupang_salesforce.py

TARGET = {
    "host": "marketplace.tw.coupangcorp.com",
    "platform": "salesforce",
    "guest_access": True,
    "attack_surface": [
        "Aura",
        "ContentDocument",
        "Shepherd",
        "RecordUiController"
    ],
    "known_vectors": [
        "Guest User Misconfiguration",
        "Aura Enumeration",
        "ContentDocument Exposure"
    ]
}

## Add full program scope here

Paste each asset in this format:

```md
### asset.example.com
Type: Domain/API/Mobile/Smart contract/Source code
Coverage: Critical/High/Medium/Low
Bounty eligible: Yes/No
Allowed testing:
- Web testing
- API testing
Restrictions:
- No DoS
- No social engineering
- No third-party providers
Notes:
- ...
```
