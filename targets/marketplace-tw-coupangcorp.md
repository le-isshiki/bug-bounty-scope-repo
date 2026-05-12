# Target: marketplace.tw.coupangcorp.com

Type: Domain  
Technology: Salesforce Experience Cloud / Aura / Shepherd file servlet  
Priority: Medium-High if sensitive files or seller data are exposed; Low if only metadata/logo.

## Known attack surface

- `/tw/s/sfsites/aura`
- `/sfc/servlet.shepherd/document/download/<ContentDocumentId>`
- `/sfc/servlet.shepherd/version/download/<ContentVersionId>`
- `/sfc/servlet.shepherd/version/renditionDownload`
- Salesforce standard Aura controllers
- Custom Apex Aura controllers (`apex://.../ACTION$...`)

## High-value next checks

1. `ContentDocumentLink`
2. `FeedItem`
3. `FeedAttachment`
4. `CollaborationGroup`
5. `KnowledgeArticleVersion`
6. Custom Apex controllers in JS bundles
7. Record-specific retrieval via `RecordUiController/ACTION$getRecord`

## Severity escalators

Low → Medium if:
- non-public operational documents
- seller metadata
- support case content
- internal files
- business documents

Medium → High if:
- PII
- KYC documents
- financial records
- seller/customer cross-tenant data
- unauthenticated write/upload capability
