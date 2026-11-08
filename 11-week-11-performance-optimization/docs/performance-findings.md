# Performance findings

## Scope and measurement status

This review covers the available `campus_notify` workspace, currently on the
week 6 authentication project with the week 10 AI chat feature. It does not
contain the week 7–10 announcement-list project described in the exercise.
Findings below are from code inspection, not a DevTools recording.

No before/after frame-time measurements, heap snapshots, or Flame Chart
screenshots have been captured. The workspace has no `screenshots/before-profile.png`
or `screenshots/after-profile.png`; these should be added after recording the
same interaction scenario on a running profile build.

## Findings and changes

1. **Image decode size exceeded display size.** Chat attachments were displayed
   at 220 logical pixels (64 in the pending preview), while `Image.memory`
   decoded using the source dimensions. Both views now request a decode width
   sized to their logical width and the current device-pixel ratio.
2. **Streaming replies repeatedly restarted scroll animations.** Each Gemini
   response chunk requested a new 180 ms animation. Scroll updates are now
   coalesced until the next frame and use a direct jump while text is streaming;
   the completed reply retains a single smooth scroll.
3. **Chat history uses a lazy list.** The conversation already uses
   `ListView.builder`, so off-screen message widgets are not eagerly built.
   This behavior was verified and retained; it does not by itself bound the
   in-memory conversation history.

## Profiling follow-up

Run the app with `flutter run --profile`, record the same list/chat navigation
and scrolling scenario before and after these changes, and compare frame timing
and raster-thread image decode activity in DevTools. Capture heap snapshots
before and after repeated navigation if checking for retained objects. Do not
attribute numeric improvements to these changes until those measurements have
been collected.
