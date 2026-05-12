# Priority Notes

## Current finding status

The uploaded report is strong as a Low / Medium-low Salesforce access-control report because it demonstrates:
- unauthenticated Aura listing
- guest access to `User`, `ContentVersion`, `ContentDocument`, and `Network`
- Shepherd file download by exposed `ContentDocument` ID
- bounded negative testing against high-risk objects

## Escalation plan

Focus on data impact, not theory.

Highest value:
1. Find whether `ContentDocumentLink` is guest-readable.
2. Find whether any non-logo `ContentDocument` or `ContentVersion` is exposed.
3. Search JS bundles for custom Aura/Apex controllers.
4. Test direct record retrieval only for IDs already exposed.
5. Check Shepherd alternate download/rendition endpoints.

Do not inflate:
- Org ID leak
- Network ID leak
- generic Salesforce Aura exposure
- schema-only access
