# Company HTML Sharing Setup

This repository can share HTML updates across company PCs using GitHub.

## 1) On the editor PC (the person who modifies HTML)

After editing, run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\publish-changes.ps1 -Message "update report UI"
```

This stages target files, commits, and pushes to `origin/main`.

## 2) On other PCs (viewer PCs)

Run once to enable auto update every 3 minutes:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-auto-sync-task.ps1 -Minutes 3
```

Manual update (any time):

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\sync-latest.ps1
```

## 3) Remove auto update task

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\remove-auto-sync-task.ps1
```

## Notes

- Each PC should use a cloned git repository, not a copied ZIP folder.
- Viewer PCs should not edit files directly in this folder.
- If `sync-latest.ps1` reports local changes, clean/commit those changes first.
- Run `setup-hooks.ps1` once so `신성텍_부적합보고서.html` auto-syncs to `index.html` on commit.
