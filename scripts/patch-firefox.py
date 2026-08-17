#!/usr/bin/env python3
from __future__ import annotations

import argparse
from pathlib import Path


def replace_once(path: Path, old: str, new: str) -> None:
    text = path.read_text()
    if new and text.count(new) == 1:
        return
    count = text.count(old)
    if count == 1:
        path.write_text(text.replace(old, new))
        return
    if count == 0 and not new:
        return
    if count == 0 and text.count(new) == 1:
        return
    raise SystemExit(f"Expected one original or patched match in {path}")


def patch_gyp_executor_import(path: Path) -> None:
    text = path.read_text()
    marker = "from concurrent import futures as nebrowser_futures"
    replacement = (
        f"{marker}\n"
        "ProcessPoolExecutor = (\n"
        "    nebrowser_futures.ThreadPoolExecutor\n"
        "    if os.environ.get(\"NEBROWSER_GYP_THREAD_POOL\") == \"1\"\n"
        "    else nebrowser_futures.ProcessPoolExecutor\n"
        ")\n"
    )
    if marker in text:
        return

    start_marker = "from concurrent.futures.process import ProcessPoolExecutor"
    end_marker = "from io import StringIO"
    start = text.find(start_marker)
    end = text.find(end_marker, start)
    if start < 0 or end < 0:
        raise SystemExit(f"Expected ProcessPoolExecutor import region in {path}")
    path.write_text(text[:start] + replacement + text[end:])


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    args = parser.parse_args()

    replace_once(
        args.source / "browser/app/profile/firefox.js",
        'pref("browser.startup.homepage",            "about:home");',
        'pref("browser.startup.homepage",            "https://affpapa.org/");',
    )

    replace_once(
        args.source / "browser/app/macbuild/Contents/Info.plist.in",
        "\t<key>CFBundleIconName</key>\n\t<string>AppIcon</string>\n",
        "",
    )

    replace_once(
        args.source / "browser/moz.configure",
        'imply_option("MOZ_APP_VENDOR", "Mozilla")',
        'imply_option("MOZ_APP_VENDOR", "AffPapa")',
    )

    replace_once(
        args.source / "browser/moz.configure",
        'imply_option("MOZ_APP_ID", "{ec8030f7-c20a-464f-9b0e-13a3a9e97384}")',
        'imply_option("MOZ_APP_ID", "{5d43746d-4ca8-48d2-a934-12a85cfe8c6e}")',
    )

    # Browser builds enable the full developer-tool client by default.  The
    # lean product keeps only the remote debugging server required by browser
    # internals, so end users do not carry the DevTools UI chrome.
    replace_once(
        args.source / "browser/moz.configure",
        'imply_option("MOZ_DEVTOOLS", "all")',
        'imply_option("MOZ_DEVTOOLS", "server")',
    )

    # These are Mozilla product experimentation/reporting services, not the
    # Remote Settings and Safe Browsing security-data paths.  Compile them out
    # as well as disabling their runtime preferences in the branded defaults.
    replace_once(
        args.source / "browser/moz.configure",
        'imply_option("MOZ_SERVICES_HEALTHREPORT", True)',
        'imply_option("MOZ_SERVICES_HEALTHREPORT", False)',
    )
    replace_once(
        args.source / "browser/moz.configure",
        'imply_option("MOZ_NORMANDY", True)',
        'imply_option("MOZ_NORMANDY", False)',
    )

    # The upstream package manifest assumes the full DevTools client.  In a
    # server-only build its debugger preference file is intentionally absent;
    # retaining the manifest entry makes packaging fail after a clean build.
    replace_once(
        args.source / "browser/installer/package-manifest.in",
        "@RESPATH@/browser/@PREF_DIR@/debugger.js\n",
        "",
    )
    replace_once(
        args.source / "browser/installer/package-manifest.in",
        "@RESPATH@/browser/chrome/devtools@JAREXT@\n"
        "@RESPATH@/browser/chrome/devtools.manifest\n",
        "",
    )

    patch_gyp_executor_import(
        args.source / "python/mozbuild/mozbuild/frontend/reader.py"
    )

    replace_once(
        args.source / "dom/bindings/mozwebidlcodegen/__init__.py",
        'USE_THREADS = hasattr(sys, "_is_gil_enabled") and not sys._is_gil_enabled()',
        'USE_THREADS = os.environ.get("NEBROWSER_GYP_THREAD_POOL") == "1" or ('
        'hasattr(sys, "_is_gil_enabled") and not sys._is_gil_enabled())',
    )

    replace_once(
        args.source / "python/mozbuild/mozbuild/build_commands.py",
        "        os.nice(niceness)\n",
        "        try:\n"
        "            os.nice(niceness)\n"
        "        except PermissionError:\n"
        "            return False\n",
    )

    # A sandboxed macOS build can prohibit psutil from enumerating every host
    # process.  Finder CPU usage is advisory only, so omit that metric instead
    # of aborting the compiler before it reaches the actual build.
    replace_once(
        args.source / "python/mozbuild/mozbuild/controller/building.py",
        "        for proc in psutil.process_iter():\n"
        "            if proc.name != \"Finder\":\n",
        "        try:\n"
        "            processes = list(psutil.process_iter())\n"
        "        except (PermissionError, OSError):\n"
        "            return None\n"
        "\n"
        "        for proc in processes:\n"
        "            if proc.name != \"Finder\":\n",
    )

    # Resource profiling is not required to produce or package the browser.
    # In the managed macOS sandbox psutil cannot enumerate host processes, so
    # make it an explicit NeBrowser build opt-out and retain normal upstream
    # profiling behavior everywhere else.
    replace_once(
        args.source / "python/mozbuild/mozbuild/controller/building.py",
        "        record_usage = True\n",
        "        record_usage = (\n"
        "            os.environ.get(\"NEBROWSER_DISABLE_RESOURCE_MONITOR\") != \"1\"\n"
        "        )\n",
    )
    replace_once(
        args.source / "python/mozbuild/mozbuild/controller/building.py",
        "            monitor.start_resource_recording()\n"
        "\n"
        "            if self._check_clobber(self.mozconfig, os.environ):\n",
        "            if os.environ.get(\"NEBROWSER_DISABLE_RESOURCE_MONITOR\") != \"1\":\n"
        "                monitor.start_resource_recording()\n"
        "\n"
        "            if self._check_clobber(self.mozconfig, os.environ):\n",
    )


if __name__ == "__main__":
    main()
