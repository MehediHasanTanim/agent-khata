# Play Console "Data safety" answers (draft)

Review against the final build before submitting.

| Question | Answer | Notes |
|---|---|---|
| Does the app collect or share any required user data types? | **No** | Records stay on the device. No server. No SDK sends data. |
| Is all user data encrypted in transit? | Not applicable | The app makes no network requests. |
| Do you provide a way for users to request data deletion? | Yes | Uninstall; data is local. Backups are user-held files. |
| Data collected | None | Customer numbers/names typed by the agent are stored locally only. |
| Data shared | None | Sharing is a user action via the system share sheet. |
| Analytics / crash SDKs | None | Local, opt-in counts and a local crash log, shared only by the user. |

Security practices to declare:

- Data is encrypted at rest (SQLCipher, key in Android Keystore).
- App lock with PIN, optional biometrics.
- Backups are encrypted with a user passphrase (AES-256-GCM, Argon2id).

## Declarations

- Financial features: the app is a bookkeeping tool; it does not provide
  payments, loans or money transfer. State this in the description (done).
- Not affiliated with any mobile financial service; do not use provider
  logos in the store assets.
- Target audience: adults (business owners).
