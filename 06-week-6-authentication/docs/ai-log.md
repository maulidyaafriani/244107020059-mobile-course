# Week 10 AI Feature Log

## Context

- Project: Campus Notify, Flutter, Riverpod, Dio, Gemini streaming.
- Scope: add an anonymous AI chat with image OCR/description and audio
  transcription to the existing app.
- No real API key, personal data, or user media is included in this log.

## System prompt

> Act as a senior Flutter engineer. Follow the existing feature structure and
> Riverpod/Dio patterns. Keep API keys out of source code and logs, do not send
> personal data, handle failures explicitly, and include tests. Make small
> changes and do not claim device/API behavior that has not been verified.

## User prompt

> Integrate Gemini chat into the existing Campus Notify app. Let users provide
> their own API key and store it securely. Stream model replies. Add image
> selection for OCR and image description, plus microphone recording for
> speech transcription. Add clear loading/error states, avoid personal data,
> document privacy/cost risks, and verify serialization with tests. Keep the
> existing architecture and do not commit a key.

## Initial AI output (summary)

The initial implementation proposal used a secure-storage key store, a
Gemini streaming service, and `inlineData` with base64 media for image/audio
requests. It also suggested asking Gemini to read visible text, describe
images, or transcribe a recording.

During implementation, the first media serialization draft represented
`inlineData` as a string instead of the nested JSON object required by the
Gemini request. Code inspection caught the mismatch; the code was corrected
and a unit test now checks the exact image/audio JSON shape. This initial draft
is summarized rather than presented as a verbatim transcript.

## Decisions and verification

| Suggestion / finding | Decision | Technical reason / evidence |
|---|---|---|
| Put the user-provided API key in secure storage | Accept | The key is never embedded in source; the client-side key still is not safe for a public production app. |
| Stream Gemini responses | Accept | The existing UI can display chunks and show a useful error when streaming fails. |
| Encode media as Gemini `inlineData` | Accept after correction | `test/ai_chat_test.dart` asserts nested `mimeType` and base64 `data` for image and audio. |
| Keep retry as a fake successful response while offline | Reject | That would misrepresent an AI response. The UI shows an error and lets the user retry. |
| Send user identifiers or documents for better answers | Reject | Personal and sensitive data must not be sent to a third-party AI service. |
| Keep the entire conversation for model context | Accept with disclosure | The current session history is sent with requests; users can clear it. This increases token use and privacy exposure. |

## Test evidence

Automated tests use a fake transport and do not call Gemini:

```powershell
flutter test test\ai_chat_test.dart
flutter analyze
```

Manual camera/microphone behavior and a real Gemini request must be recorded
only after testing on a device/browser with permissions and a user-owned key.
