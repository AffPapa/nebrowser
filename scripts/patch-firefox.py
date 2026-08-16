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


if __name__ == "__main__":
    main()
