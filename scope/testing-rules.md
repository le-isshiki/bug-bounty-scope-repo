# Testing Rules

## Safe testing defaults

- Use minimal proof.
- Avoid bulk extraction.
- Stop after confirming one representative sensitive object/file.
- Record exact timestamps, request IDs, and nonces.
- Do not download or retain real customer/seller data.
- Do not test destructive mutations unless explicitly authorized.

## Report quality rules

Each finding must include:
- asset
- exact endpoint/function
- unauthenticated/authenticated state
- reproducible request
- observed response
- confirmed impact
- explicit non-claims
- recommended fix
