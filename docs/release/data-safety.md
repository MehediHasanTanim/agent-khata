# Play Console "Data safety" answers (draft)

Review against the final build and against Google's current AdMob data
disclosure guidance before submitting. The ad SDK's own data handling is
what Google documents for AdMob; verify each row in the Play Console.

| Question | Answer | Notes |
|---|---|---|
| Does the app collect or share any required user data types? | **Yes (by the ad SDK only)** | Business records stay on the device. Only the Google AdMob SDK transmits data. |
| Is all user data encrypted in transit? | Yes | Ad SDK traffic uses HTTPS. |
| Do you provide a way for users to request data deletion? | Yes | Uninstall; business data is local. Ad data is governed by Google. |
| Financial info, contacts, messages, location, photos | **Not collected** | Customer numbers and amounts typed by the agent never leave the phone. |
| Data collected by the ad SDK | Declare per Google's AdMob guidance: typically **App interactions**, **Diagnostics** and **Device or other IDs** (not the advertising ID: the app removes that permission) and **approximate location (IP)** | Purpose: **Advertising or marketing**, **Analytics**, **Fraud prevention, security, and compliance** |
| Data shared | Same categories, shared with Google as the ad provider | Not used for personalization (non-personalized requests only) |
| Analytics / crash SDKs | None other than AdMob | Local, opt-in counts and a local crash log, shared only by the user |

Security practices to declare:

- Data is encrypted at rest (SQLCipher, key in Android Keystore).
- App lock with PIN, optional biometrics.
- Backups are encrypted with a user passphrase (AES-256-GCM, Argon2id).

## Declarations

- **Contains ads: Yes.**
- **Ads personalization:** none. The app sends non-personalized ad requests
  and does not request the advertising ID, so the "advertising ID" question
  is answered accordingly (verify the form wording at submission).
- Financial features: the app is a bookkeeping tool; it does not provide
  payments, loans or money transfer. State this in the description (done).
- Not affiliated with any mobile financial service; do not use provider
  logos in the store assets.
- Target audience: adults (business owners). Not designed for children.
