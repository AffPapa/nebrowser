/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

// NeBrowser does not consume Mozilla's application-update service. Updates
// remain disabled at build time until the independently operated update
// channel has its own signed MAR pipeline.
pref("startup.homepage_override_url", "");
pref("startup.homepage_welcome_url", "");
pref("startup.homepage_welcome_url.additional", "");
pref("app.update.url.manual", "https://affpapa.org/nebrowser/");
pref("app.update.url.details", "https://affpapa.org/nebrowser/");
pref("devtools.selfxss.count", 5);

// An independent fork must not submit product telemetry or enroll users in
// Mozilla-operated experiments under a different product identity.
pref("datareporting.healthreport.uploadEnabled", false);
pref("datareporting.policy.dataSubmissionEnabled", false);
pref("toolkit.telemetry.enabled", false);
pref("toolkit.telemetry.unified", false);
pref("toolkit.telemetry.archive.enabled", false);
pref("toolkit.telemetry.shutdownPingSender.enabled", false);
pref("browser.ping-centre.telemetry", false);
pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
pref("browser.newtabpage.activity-stream.telemetry", false);
pref("app.normandy.enabled", false);
pref("app.shield.optoutstudies.enabled", false);
