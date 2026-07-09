**BP_ApexGameMode - Sovereign Hybrid AI Pet Orchestrator**

## Core Blueprint Structure (v4 ACT Compliant)

### Event BeginPlay
- Get GameInstance Subsystem: SaveManager
- Check if save exists: LoadPetData() -> SpawnPetFromData()
- Else: SpawnDefaultPet() with procedural Nebulynx base
- Initialize Holographic Effects: Niagara System for neon particles, PostProcess for cyberpunk glow
- Set Authority Gate: Human override flag for evolution/monetization

### Custom Events
- SpawnPetFromData(SaveGameData)
  - Create Actor: BP_NebulynxPet (cyborg + interdimensional mesh)
  - Apply Procedural Genetics: Scale, color, abilities from genetic algo
  - Bind Memory: Episode learning system (local RAM-like storage)
  - Attach ARCore Anchor (if mobile)

- SpawnDefaultPet()
  - Default holographic cat-like entity with bright neon cyborg upgrades

- TransitionToMap(MapName)
  - ServerTravel to /Game/Maps/APEX_[MapName]

- EvolvePet(GeneticParams, MemoryEpisode)
  - Trigger genetic mutation + AI memory integration
  - Update SaveGame
  - Visual: Enhanced particle burst + frequency UI update

### Authority & Sovereignty Nodes
- Explicit Human Authority Check before any autonomous evolution or IAP trigger
- Failure-as-Default: If AI overreach detected, revert to human control
- Pseudonym Rotation Hook: For multi-user local sessions

## Integration with APEX_Startup Map
- Player Start -> Camera Pawn cinematic entry
- Pet Spawn Volume -> Trigger BeginPlay spawn
- HUD Widget: Neural Circuits + Dual Dimension Overlay (Physical vs Digital Form)

## Quantum Fortress Memory Vault Integration (Future Merge)
- Local AES-GCM encrypted save for pet memory
- FTS5 searchable knowledge vault for perpetual AI-enhanced learning
- Self-auditing security layer

**Next Steps:** Implement in UE Blueprint Editor. Test with packaging pipeline.