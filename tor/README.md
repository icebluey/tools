```
if patchelf --help 2>&1 | grep -q '\--add-rpath'; then patchelf --force-rpath --add-rpath '$ORIGIN' tor; else patchelf --force-rpath --set-rpath '$ORIGIN' tor; fi
```
