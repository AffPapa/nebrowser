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

// NeBrowser is intentionally local-first.  It has no Mozilla Account/Sync
// product surface, no account toolbar, and no cross-device setup prompts.
// Local bookmarks, history, passwords, downloads and session restore remain.
pref("identity.fxaccounts.enabled", false);
pref("identity.fxaccounts.toolbar.enabled", false);
pref("identity.fxaccounts.toolbar.defaultVisible", false);
pref("browser.profiles.enabled", false);

// Start with a calm, local browser instead of Mozilla campaigns, sponsored
// material, weather, wallpaper and AI affordances.  Search, history,
// bookmarks, open tabs, translation and all security controls stay available.
pref("browser.preferences.moreFromMozilla", false);
pref("browser.preferences.aiControls", false);
pref("browser.shell.checkDefaultBrowser", false);
pref("sidebar.revamp", false);
pref("sidebar.verticalTabs", false);
pref("browser.ml.chat.enabled", false);
pref("browser.ml.chat.menu", false);
pref("browser.ml.chat.page", false);
pref("browser.ml.chat.shortcuts", false);
pref("browser.ml.chat.sidebar", false);
pref("browser.ml.linkPreview.enabled", false);
pref("browser.tabs.splitView.enabled", false);
pref("browser.toolbars.share-button.enabled", false);
pref("screenshots.browser.component.enabled", false);
pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
pref("browser.newtabpage.activity-stream.showSponsored", false);
pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
pref("browser.newtabpage.activity-stream.showWeather", false);
pref("browser.newtabpage.activity-stream.newtabWallpapers.enabled", false);
pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false);
pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false);
