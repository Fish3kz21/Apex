# Apex AI Pets - Maps & Packaging Setup (Steps 5-6)

This guide covers the final two production steps: **creating custom maps** and **updating packaging script references**.

---

## Step 5: Create Custom Maps in Unreal Editor

### 5.1 Launch Unreal Editor

```bat
Scripts\03_OpenEditor_Win64.bat
```

The editor will open with your project loaded.

### 5.2 Create the APEX_Startup Map

This is your **primary deployment map** — the first thing players see when they launch the game.

#### Create the Map File

1. Open **Content Browser** (Window → Content Browser, or Ctrl+4)
2. Navigate to: `Content/Maps/`
3. **Right-click** in the empty space
4. Select: **New Level**
5. Choose: **Empty Level** (no template needed)
6. Rename it: `APEX_Startup`
7. Save: **File → Save** (Ctrl+S)
   - Location: `Content/Maps/APEX_Startup.umap`

#### Add Essential Actors

**Add Floor Platform:**
1. Click **Place Actors** (top-right, or Shift+1)
2. Search: `Floor`
3. Drag a **Floor** into the viewport
4. Position it as your ground plane
5. Scale if needed: Set **Scale** to (10, 10, 1) in Details panel

**Add Lighting:**
1. Click **Place Actors** again
2. Search: `Directional Light`
3. Drag into viewport
4. Position: Move up so light comes from above
5. Set brightness: In Details, find **Light Intensity**, set to `1.5`

**Add Camera Start Point:**
1. **Place Actors** → Search: `Player Start`
2. Drag into viewport
3. Position where your pet will spawn
4. This is where the camera pawn begins

#### Optional: Add Visual Polish

- Add a **Sphere** actor from Place Actors to represent the pet spawn point initially
- Add a **Box** around the play area to define boundaries
- Set **Floor Color** in Details → **Material** for visual feedback

**Save the map:** Ctrl+S

### 5.3 Create Additional Maps (Optional but Recommended)

Repeat the process for these maps:

#### APEX_MainMenu
- Purpose: Pet selection and save slot UI
- Should contain UI canvas and menu widgets
- No gameplay mechanics needed

#### APEX_Gameplay
- Purpose: Active pet interaction
- Should contain larger play area
- Add interactive elements for pet interaction

#### APEX_Settings
- Purpose: In-game settings/pause menu
- Simple layout with UI elements
- Can be blank — UI widgets handle the visual content

### 5.4 Set Default Map in Project Settings

1. Go to: **Edit → Project Settings**
2. Search: `Map`
3. Find **Maps & Modes** section
4. Set:
   - **Game Default Map**: `/Game/Maps/APEX_Startup`
   - **Server Default Map**: `/Game/Maps/APEX_Startup`
   - **Editor Startup Map**: `/Game/Maps/APEX_Startup`
5. Click **Save** (bottom-right)
6. Close Project Settings

---

## Step 6: Update Packaging Script References

### 6.1 Verify DefaultGame.ini Configuration

The packaging system reads from `Config/DefaultGame.ini` (already created in this guide).

**Key sections:**
```ini
[/Script/Engine.GameMapsSettings]
GameDefaultMap=/Game/Maps/APEX_Startup
ServerDefaultMap=/Game/Maps/APEX_Startup

[/Script/UnrealEd.ProjectPackagingSettings]
+MapsToCook=(Path="/Game/Maps/APEX_Startup")
+MapsToCook=(Path="/Game/Maps/APEX_MainMenu")
+MapsToCook=(Path="/Game/Maps/APEX_Gameplay")
+MapsToCook=(Path="/Game/Maps/APEX_Settings")
```

This tells the packager:
- Which map loads first (`APEX_Startup`)
- Which maps to include in the final `.exe` (all listed in `MapsToCook`)

### 6.2 Update Packaging Script (Scripts\04_Package_Windows11_Win64.bat)

Find these lines in the script (usually near the end):

**Before:**
```bat
REM Example - may vary based on template
"%UE_ROOT%\Engine\Build\BatchFiles\RunUAT.bat" BuildCookRun ^
  -project="%CD%\ApexAIPets.uproject" ^
  -targetplatforms=Win64 ^
  -clientconfig=Shipping ^
  -build -cook -package
```

**After (Updated):**
```bat
REM Production packaging with custom maps
"%UE_ROOT%\Engine\Build\BatchFiles\RunUAT.bat" BuildCookRun ^
  -project="%CD%\ApexAIPets.uproject" ^
  -targetplatforms=Win64 ^
  -clientconfig=Shipping ^
  -archivedirectory="%CD%\Windows11_Package" ^
  -maps=/Game/Maps/APEX_Startup ^
  -build -cook -package -stage ^
  -createchunkinstall
```

**Key additions:**
- `-archivedirectory`: Where the final package goes
- `-maps`: Which map to load first
- `-stage`: Prepares files for packaging
- `-createchunkinstall`: Optional — enables chunk-based installation

### 6.3 Add Map Verification Step

Add this to the end of your packaging script (after the `BuildCookRun` command):

```bat
REM Verify maps were cooked into the package
if not exist "%CD%\Windows11_Package\Windows\Content\Maps" (
    echo.
    echo ERROR: Maps directory not found in packaged build!
    echo The game will not run without compiled map data.
    echo.
    pause
    exit /b 1
)

echo.
echo SUCCESS: Maps cooked into the package.
echo Maps directory verified:
dir "%CD%\Windows11_Package\Windows\Content\Maps"
echo.
echo Package location: %CD%\Windows11_Package\Windows\ApexAIPets.exe
echo.
pause
```

### 6.4 Create a Map-Loading Helper (C++ or Blueprint)

**If using C++ (ApexAIPetsGameMode.cpp):**

```cpp
void AApexAIPetsGameMode::BeginPlay()
{
    Super::BeginPlay();
    
    UE_LOG(LogTemp, Warning, TEXT("GameMode: Starting on map %s"), 
        *GetWorld()->GetMapName());
    
    // Load pet from save or create new
    USaveManager* SaveMgr = GetGameInstance()->GetSubsystem<USaveManager>();
    if (SaveMgr && SaveMgr->DoesSaveExist())
    {
        UApexAIPetsSaveGame* LoadedPet = SaveMgr->LoadPetData();
        SpawnPetFromData(LoadedPet);
    }
    else
    {
        SpawnDefaultPet();
    }
}

void AApexAIPetsGameMode::TransitionToMap(const FString& MapName)
{
    FString FullMapPath = FString::Printf(TEXT("/Game/Maps/APEX_%s"), *MapName);
    GetWorld()->ServerTravel(*FullMapPath);
}
```

**Blueprint version:**
1. Create Blueprint from `ApexAIPetsGameMode`: **BP_ApexGameMode**
2. In **Event BeginPlay**:
   - Get SaveManager subsystem
   - Call "Load Pet Data"
   - If valid, spawn pet actor with loaded data
3. Create custom event: **Travel to Map**
   - Input: Map name (string)
   - Execute: **Open Level** node with map path

### 6.5 Test the Packaging Pipeline

Run the complete packaging process:

```bat
REM Clean build
Scripts\VERIFY_SOURCE_LAYOUT.bat

REM Generate project files
Scripts\01_GenerateProjectFiles_Win64.bat

REM Build editor
Scripts\02_BuildEditor_Win64.bat

REM Test in editor (optional)
Scripts\03_OpenEditor_Win64.bat

REM Package for distribution
Scripts\04_Package_Windows11_Win64.bat

REM Run the packaged game
Scripts\05_RunPackagedGame_Win64.bat
```

### 6.6 Verify Packaging Output

After packaging completes, check:

```
Windows11_Package/
├── Windows/
│   ├── ApexAIPets.exe          ← Main executable
│   ├── Content/
│   │   ├── Maps/
│   │   │   ├── APEX_Startup.umap
│   │   │   ├── APEX_MainMenu.umap
│   │   │   └── ...
│   │   └── ...
│   ├── Binaries/
│   └── ...
```

**Expected behavior when running `ApexAIPets.exe`:**
1. Game loads `APEX_Startup` map
2. Camera pawn initializes
3. Pet actor spawns (Nebulynx holographic character)
4. HUD overlay displays
5. Game is interactive

---

## Troubleshooting

### "Map not found" error on launch
- Verify `Config/DefaultGame.ini` has correct map path
- Ensure map was created and saved in Unreal Editor
- Check `Windows11_Package\Windows\Content\Maps\` exists and contains `.umap` files

### "Unreal Engine not found" on packaging
- Run: `setx UE_ROOT "C:\Program Files\Epic Games\UE_5.4"`
- Open new terminal and retry packaging

### Game crashes with "Pet actor failed to spawn"
- Verify `ApexAIPetsGameMode` correctly initializes pet
- Check SaveManager subsystem is registered
- Test in Editor first: `Scripts\03_OpenEditor_Win64.bat`

### Maps not cooking into package
- Verify entries in `Config/DefaultGame.ini` `MapsToCook`
- Try `FullRebuild=True` in `DefaultGame.ini`
- Delete `Windows11_Package` directory and retry

---

## Next Steps After Packaging

1. **Distribute the packaged `.exe`** from `Windows11_Package\Windows\ApexAIPets.exe`
2. **Add pet meshes and materials** to `Content/Meshes/Pets/` and `Content/Materials/`
3. **Implement pet AI behaviors** in the game mode or pet actor class
4. **Add audio and UI widgets** to enhance gameplay
5. **Iterate and repackage** using `Scripts\04_Package_Windows11_Win64.bat`

