import os
import plistlib
import sys

BASE = r"E:\ios调试和上线材料\mamikey"
FILES = {
    "mamikeyappstore.mobileprovision": "io.github.com.YaoHuan123.mamikey",
    "mamikeykeyboardappstore.mobileprovision": "io.github.com.YaoHuan123.mamikey.keyboard",
}
APP_GROUP = "group.io.github.YaoHuan123.mamikey"
CODEMagic_REF = {
    "mamikeyappstore.mobileprovision": "mamikey-appstore",
    "mamikeykeyboardappstore.mobileprovision": "mamikey-keyboard-appstore",
}


def decode_profile(path: str) -> dict:
    data = open(path, "rb").read()
    start = data.find(b"<?xml")
    if start == -1:
        start = data.find(b"<plist")
    if start == -1:
        raise ValueError("plist not found in profile file")
    plist_bytes = data[start:]
    end = plist_bytes.find(b"</plist>")
    if end != -1:
        plist_bytes = plist_bytes[: end + 8]
    return plistlib.loads(plist_bytes)


def main() -> int:
    all_ok = True
    for fn, expected_bundle in FILES.items():
        path = os.path.join(BASE, fn)
        print("=" * 60)
        print(f"FILE: {fn}")
        print(f"PATH: {path}")
        print(f"Codemagic reference name: {CODEMagic_REF[fn]}")
        if not os.path.exists(path):
            print("STATUS: FILE NOT FOUND")
            all_ok = False
            continue
        try:
            pl = decode_profile(path)
        except Exception as e:
            print(f"STATUS: DECODE ERROR - {e}")
            all_ok = False
            continue

        ent = pl.get("Entitlements", {})
        app_id = ent.get("application-identifier", "")
        groups = ent.get("com.apple.security.application-groups", [])
        suffix = app_id.split(".", 1)[1] if "." in app_id else app_id

        print(f"Name: {pl.get('Name', '')}")
        print(f"ExpirationDate: {pl.get('ExpirationDate', '')}")
        print(f"application-identifier: {app_id}")
        print(f"team-identifier: {ent.get('com.apple.developer.team-identifier', '')}")
        print(f"App Groups: {groups}")
        print(f"get-task-allow: {ent.get('get-task-allow')}")
        devices = pl.get("ProvisionedDevices")
        print(
            "Profile type: "
            + ("Development/AdHoc (has devices)" if devices else "App Store (no device list)")
        )

        ok_bundle = suffix == expected_bundle
        ok_group = APP_GROUP in (groups or [])
        print("--- CHECK ---")
        print(f"Bundle ID ({expected_bundle}): {'OK' if ok_bundle else 'FAIL'}")
        print(f"App Groups ({APP_GROUP}): {'OK' if ok_group else 'FAIL'}")
        if ok_bundle and ok_group:
            print("STATUS: OK for Mami Key Codemagic")
        else:
            print("STATUS: INVALID - fix in Apple Developer and regenerate")
            all_ok = False
        print()

    return 0 if all_ok else 1


if __name__ == "__main__":
    sys.exit(main())
