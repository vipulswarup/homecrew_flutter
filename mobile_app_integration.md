# HomeCrew Mobile App Integration Guide

This document describes how the Flutter app should integrate with the current HomeCrew backend and how to handle important client-side requirements (especially HEIC conversion).

## 1) Backend Base Setup

- Base URL (dev): `http://127.0.0.1:8000`
- API prefix: `/api/v1`
- Swagger: `/docs`
- Health check: `GET /health`

Always build API URLs as:

- `{BASE_URL}/api/v1/{route}`

## 2) Auth Flow (Current)

Implemented endpoints:

- `POST /auth/signup`
- `POST /auth/verify-email`
- `GET /auth/verify-email?token=...`
- `POST /auth/login`
- `POST /auth/refresh`
- `POST /auth/logout`
- `GET /me`

### Recommended mobile sequence

1. Signup with email/password:
   - `POST /auth/signup`
2. Wait for verification email and user clicks link:
   - `GET /api/v1/auth/verify-email?token=...`
3. Login:
   - `POST /auth/login`
4. Store `access_token` + `refresh_token` securely.
5. Call `GET /api/v1/me` to bootstrap user session.

### Token handling rules

- Send `Authorization: Bearer <access_token>` for all protected routes.
- If a protected route returns `401`, call `POST /auth/refresh` once and retry the original request exactly once.
- If multiple requests fail concurrently with `401`, ensure only one refresh call is in-flight at a time; queue/retry the rest after refresh completes.
- On refresh success, replace both tokens in secure storage immediately (refresh is rotated).
- On refresh failure (`401`), force logout and clear tokens.
- On explicit logout:
  - call `POST /auth/logout` with current refresh token
  - clear local tokens

### Refresh edge cases

- Do not attempt infinite refresh loops. Retry only once per failing request.
- If refresh succeeds but the retried request still returns `401`, treat session as invalid and force logout.
- If the app is offline, do not refresh; surface offline state and retry later.

### Current verification behavior

- Signup sends verification email via SMTP.
- Verification link endpoint (`GET`) and JSON endpoint (`POST`) are both supported.
- Account cannot login until verified (`403 Email not verified`).

## 3) Household Flow (Current)

Implemented endpoints:

- `GET /households`
- `POST /households`
- `PATCH /households/{id}`

### Rules

- Household creator is auto-added as `admin`.
- Household `currency` is required at creation time (3-letter code, for example `INR`, `USD`).
- `PATCH /households/{id}` is admin-only.
- If user is not a member of a household, backend returns not found for that household context.

### Suggested mobile UX

- After login, load households immediately.
- If none exist, show create-household screen.
- Store selected household id in app state for downstream modules (staff, docs).

## 4) Staff + Salary Flow (Current)

Implemented endpoints:

- `GET /households/{id}/staff`
- `POST /households/{id}/staff`
- `GET /staff/{id}`
- `PATCH /staff/{id}`
- `DELETE /staff/{id}`
- `POST /staff/{id}/salary-revisions`
- `GET /staff/{id}/salary-revisions`

### Create staff payload requirements

Required fields for first cut:

- `name`
- `nickname`
- `start_date`
- `total_leave_allocated`
- initial salary:
  - `salary_amount_monthly`
  - `salary_effective_from`
  - optional `salary_currency` (if omitted, backend uses household currency)

### Salary history behavior

- Salary amount is monthly (`amount_monthly`).
- Exactly one active salary revision per staff at a time.
- New salary revision automatically deactivates the previous active one.
- Salary revision write access is admin-only.

## 5) Documents Upload/Download Flow (Current)

Implemented endpoints:

- `POST /documents/upload-url`
- `GET /documents/{id}/download-url`
- `DELETE /documents/{id}`

### Upload flow (mobile)

1. Call `POST /documents/upload-url` with metadata:
   - `household_id`
   - `staff_id` (optional)
   - `file_name`
   - `file_type`
   - `file_size`
2. Backend returns:
   - `document_id`
   - `upload_url` (presigned PUT URL)
   - `file_key`
3. Mobile uploads bytes directly to returned `upload_url` using HTTP `PUT`.
4. Use `document_id` for future download/delete operations.

### Presigned PUT requirements (important)

- Use HTTP `PUT` to the exact `upload_url` returned by the backend.
- Set `Content-Type` header to match the `file_type` you sent when requesting the upload URL (for example `image/jpeg`).
- Do not add extra authentication headers to the presigned request (no Bearer token). The signature is in the URL.
- Do not change the URL, query string, or host.
- If you retry a failed PUT, retry the same URL only while it is still within its expiry window.

Common failure reasons:

- `403` from storage: URL expired, URL modified, or wrong headers.
- `SignatureDoesNotMatch`: most commonly due to mismatched `Content-Type` or URL encoding changes.

### Download flow (mobile)

1. Call `GET /documents/{document_id}/download-url`.
2. Backend returns short-lived `download_url`.
3. Download bytes directly from that URL.

### Security/storage behavior

- Bucket is expected private.
- URLs are short-lived (`PRESIGNED_URL_EXPIRE_SECONDS`).
- Upload requests include server-side encryption requirement (`AES256` by default).

## 6) Error Handling Contract

Expect:

- `401` for invalid/expired access token
- `403` for role restrictions or unverified email
- `404` for non-member or missing resources
- `409` for signup email conflict
- `422` for invalid request payloads

Show validation errors from response `detail` where available.

## 7) HEIC Handling Requirement (Mobile-Side)

Decision: convert HEIC/HEIF in mobile app before upload.

### Required behavior

- Detect HEIC/HEIF selected files.
- Convert to JPEG (preferred for speed/compatibility) or PNG.
- Upload converted output file, not the original HEIC.
- Send final MIME type and file extension matching converted file.

### Practical recommendations

- Prefer JPEG conversion for photos:
  - faster encode
  - smaller files
  - good compatibility
- Preserve orientation from EXIF during conversion.
- Cap upload dimensions/quality to control bandwidth (for example, max long side and JPEG quality target).
- Keep original locally only if product needs it; backend should receive converted asset.

### Metadata expectations for converted files

- `file_name`: should end in `.jpg` or `.png`
- `file_type`: should be `image/jpeg` or `image/png`
- `file_size`: actual converted size in bytes

## 8) Security Notes For Mobile

- Store tokens in secure keychain/keystore only.
- Never cache presigned URLs long-term; treat them as ephemeral.
- Do not embed B2 keys in mobile app.
- All upload/download access must go through backend-issued presigned URLs.

## 9) Implementation Checklist (Mobile Team)

- [ ] Central API client with `/api/v1` base prefix
- [ ] Auth interceptor for access token header
- [ ] Single refresh-and-retry strategy on `401`
- [ ] Secure token storage
- [ ] Email verification status UX (pending -> verified)
- [ ] Household list/create/edit screens wired
- [ ] Household currency selection at creation
- [ ] Staff CRUD wired (admin write, member read)
- [ ] Salary revision screen wired via dedicated endpoint
- [ ] HEIC/HEIF detection + conversion to JPEG/PNG before upload
- [ ] Upload pipeline uses converted file metadata consistently
- [ ] Document upload: request URL -> PUT file -> track `document_id`
- [ ] Document download/delete wired with auth

## 10) End-to-End Runbook (Mobile First Cut)

This is a practical sequence to validate the full first-cut flow in the app.

### Step A: Signup

`POST /api/v1/auth/signup`

```json
{
  "email": "admin@example.com",
  "password": "Password123",
  "name": "Admin User"
}
```

### Step B: Verify email

User clicks link received by email:

- `GET /api/v1/auth/verify-email?token=...`

### Step C: Login

`POST /api/v1/auth/login`

```json
{
  "email": "admin@example.com",
  "password": "Password123",
  "device_info": "mobile"
}
```

Store `access_token` and `refresh_token`.

### Step D: Create household (currency required)

`POST /api/v1/households`

```json
{
  "name": "Primary Home",
  "type": "villa",
  "currency": "INR"
}
```

Store returned `household.id`.

### Step E: Create staff (includes initial salary)

`POST /api/v1/households/{householdId}/staff`

```json
{
  "name": "Ravi",
  "nickname": "R",
  "role": "nanny",
  "start_date": "2026-04-01",
  "total_leave_allocated": 12,
  "salary_amount_monthly": 25000,
  "salary_currency": "INR",
  "salary_effective_from": "2026-04-01"
}
```

Store returned `staff.id`.

### Step F: Add salary revision (history)

`POST /api/v1/staff/{staffId}/salary-revisions`

```json
{
  "amount_monthly": 28000,
  "currency": "INR",
  "effective_from": "2026-07-01"
}
```

### Step G: Upload a staff document

Before calling upload-url:

- If source is HEIC/HEIF, convert in mobile to JPEG/PNG.
- Ensure `file_name`, `file_type`, `file_size` reflect the converted output.

1) Request upload URL:

`POST /api/v1/documents/upload-url`

```json
{
  "household_id": "<householdId>",
  "staff_id": "<staffId>",
  "file_name": "passport.jpg",
  "file_type": "image/jpeg",
  "file_size": 245678
}
```

2) Upload bytes:

- `PUT <upload_url>`
- Header: `Content-Type: image/jpeg`
- Body: raw bytes of the converted file

3) Download bytes later:

- `GET /api/v1/documents/{documentId}/download-url`
- `GET <download_url>` (no auth headers on the presigned download request)
