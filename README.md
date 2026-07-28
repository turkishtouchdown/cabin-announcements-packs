# Cabin Announcements — sound packs catalog

This folder is a **template** for a separate GitHub repository that hosts downloadable airline sound packs for the Config Manager.

The main app reads `catalog.json` from this repo and downloads pack ZIPs listed there.

## 1. Create the GitHub repository

1. On GitHub, create a new **public** repository named `cabin-announcements-packs`.
2. Copy these files into it:
   - `catalog.json`
   - `README.md` (from this folder)
   - `build-pack-release.ps1`
3. Commit and push to the `main` branch.

## 2. Point the app at your catalog

Edit [`src/CabinAnnouncements.Core/PackCatalogDefaults.cs`](../src/CabinAnnouncements.Core/PackCatalogDefaults.cs) and replace `YOUR_GITHUB_USERNAME` with your GitHub username:

```csharp
public const string CatalogUrl =
    "https://raw.githubusercontent.com/<your-username>/cabin-announcements-packs/main/catalog.json";
```

Rebuild the Config Manager after changing this URL.

## 3. Publish a pack release

From your **local dev sounds folder** (for example `sounds/RYR/`):

```powershell
.\build-pack-release.ps1 -PackId RYR -Version 1.0.0 -SourceDirectory "..\sounds\RYR"
```

This script:

- Builds `RYR-1.0.0.zip` with the correct top-level folder layout
- Prints the file size and SHA-256 hash
- Shows the JSON snippet to paste into `catalog.json`

Then:

1. Create a GitHub Release tagged `RYR-1.0.0` in `cabin-announcements-packs`
2. Upload `RYR-1.0.0.zip` (and optional `RYR-icon.png`)
3. Copy the release asset download URL into `catalog.json`
4. Commit and push `catalog.json`

## Pack ZIP layout

```
RYR-1.0.0.zip
└── RYR/
    ├── pack.xml
    ├── icon.png
    ├── BoardingWelcome.wav
    └── ...
```

Example `pack.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<Pack>
  <Icao>RYR</Icao>
  <Name>Ryanair</Name>
  <Version>1.0.0</Version>
</Pack>
```

## Where packs install on users' PCs

Downloaded packs are installed to:

`%LocalAppData%\CabinAnnouncements\sounds\{packId}\`

Manual packs next to the app or in the dev `sounds/` folder still work; the user folder takes priority.

## Privacy

Do **not** put SimBrief IDs, personal settings, or private audio you do not have rights to distribute in this repository.
