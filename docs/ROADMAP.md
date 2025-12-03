# THE LIGHT - Development Roadmap

This roadmap outlines the remaining work needed to fully realize the vision of The Light as described in the mission statement. Items are organized by priority and logical development order.

## ✅ COMPLETED

### Core Mechanics
- [x] Light decay system with phase progression
- [x] Click-to-gain-light mechanic
- [x] Soul collection and currency system
- [x] Upgrade system (click power, auto-gather, capacity, memories)
- [x] Memory system with recall mechanic
- [x] Sacrifice mechanic (trade memories for power)
- [x] Rebirth system with permanent bonuses
- [x] Darkness phases (0-4)
- [x] Whisper system (negative voices during phase transitions)
- [x] Particle effects background
- [x] Enhanced rebirth sequence with emotional impact

### UI/UX
- [x] Stats display (light, souls, phase, rebirths)
- [x] Light bar visualization
- [x] Main click button with visual feedback
- [x] Upgrade buttons grid
- [x] Sacrifice button (conditional display)
- [x] Rebirth button (conditional display)
- [x] Story text per phase
- [x] Memory display system
- [x] Whisper display system
- [x] Dynamic background colors based on darkness

---

## 🔄 IN PROGRESS / NEEDS REFINEMENT

### Rebirth Experience
- [x] Multi-stage rebirth sequence created
- [ ] **Test and refine timing** - Ensure the sequence feels powerful and meaningful
- [ ] **Add sound effects** (optional) - Subtle audio to enhance the emotional impact
- [ ] **Consider haptic feedback** - Physical sensation during rebirth on supported devices

---

## 🎯 FIRST MAJOR UPDATE: "THE WEIGHT OF CHOICES"

**Priority: CRITICAL** - This update makes the core philosophical question FELT, not just asked.

**Status: ✅ COMPLETE** - All three parts implemented and tested!

### Overview
The sacrifice mechanic is the heart of the game's meaning - "how much of ourselves are we willing to lose to keep going?" - but currently feels transactional. This update transforms it into a meditation on choice, loss, and what we carry forward.

---

### Part 1: The Sacrifice Ritual ⚠️ MOST CRITICAL

**Goal:** Make sacrificing a memory feel like a real loss, not a transaction.

**Status: ✅ COMPLETE**

#### 1.1 Memory Preview Before Sacrifice
- [x] **Full-screen overlay** when "Sacrifice a Memory" is tapped
- [x] **Display the memory to be lost** in large, warm, centered text
- [x] **Pause for 2-3 seconds** - let the memory sink in
- [x] **Subtle background effect** - dark overlay with fade-in animation
- [x] **Typography choice** - warm, personal font styling

#### 1.2 Weighty Confirmation Dialog
- [x] **Not a simple Yes/No** - this is a moment of gravity
- [x] **Weighty text**: "You will forget this forever. But you will be stronger. Is this what you choose?"
- [x] **Two buttons with intentional design**:
  - "Burn It" - Red, weighty, prominent (the easy but heavy choice)
  - "Keep It" - Subtle, less prominent (the harder but preserving choice)
- [x] **Visual feedback** - scale and fade animations
- [x] **Animation**: Memory preview transitions to confirmation smoothly
- [ ] **Sound design**: Subtle, somber audio during this moment (pending audio assets)

#### 1.3 Aftermath Sequence
- [x] **Show the memory one last time** before it disappears
- [x] **Fade to ash effect** - the memory transforms visually with opacity animation
- [x] **Text appears**: "The memory is gone. The power remains."
- [x] **Brief pause** - 3.5 second animation sequence
- [x] **Track which memories were sacrificed** (persistently across cycles)
- [x] **Visual feedback** - full-screen dark overlay with fade effects

#### 1.4 Persistent Memory Tracking
- [x] **Data structure** to track all sacrificed memories across all cycles
- [x] **Save system** integration to persist this data ✅ COMPLETE
- [x] **Memory tracking** - `allSacrificedMemories` list and `totalMemoriesSacrificed` counter

---

### Part 2: The Journey Reflection Screen 🌱

**Goal:** A space for players to see their accumulated choices and reflect on their journey.

**Status: ✅ COMPLETE**

#### 2.1 Access Point
- [x] **"Your Journey" button** - small, unobtrusive, in stats header
- [x] **Icon**: Flower icon (local_florist) suggesting garden/memory
- [x] **Smooth transition** - full-screen overlay with close button

#### 2.2 Journey Reflection View Layout
- [x] **Full-screen overlay** with dark, contemplative background
- [x] **Scrollable content** for longer journeys
- [x] **Visual hierarchy** - statistics at top, memories in middle, philosophy at bottom

#### 2.3 Statistics Display
- [x] **Total Memories Sacrificed** (across all cycles)
  - Format: Card display with icon and count
  - Visual: Clean card-based layout
- [x] **Total Memories Preserved** (across all cycles)
  - Format: Card display with icon and count
  - Visual: Counter display
- [x] **Total Cycles Completed**
  - Format: "X" with refresh icon
- [x] **Total Darkness Accumulated**
  - Format: Card with darkness value
  - Visual: Card-based display

#### 2.4 Memory Garden (Preserved Memories)
- [x] **Section title**: "The Memories You Kept"
- [x] **List of preserved memories** from current cycle
- [x] **Visual design**: 
  - Each memory in a card
  - Warm colors (yellow tones), gentle appearance
  - Layout: Wrap layout (flowing grid)
- [x] **Empty state**: "No memories yet. They will grow here as you remember."
- [x] **Philosophical text**: "These are the moments you chose to hold onto. They shaped you."

#### 2.5 Sacrificed Memories Archive
- [x] **Section title**: "The Memories You Burned"
- [x] **List of all sacrificed memories** (across all cycles)
- [x] **Visual design**:
  - Faded, ashen appearance
  - Crossed out text (TextDecoration.lineThrough)
  - Less prominent than preserved memories
  - Organized chronologically (as added)
- [x] **Empty state**: "You have preserved all your memories. The garden is full."
- [x] **Philosophical text**: "These were the costs. They are gone, but they were real."

#### 2.6 Balance Visualization
- [x] **Two-column layout**: "Lost" vs "Kept"
- [x] **Visual balance** - side-by-side comparison
- [x] **Ratio display**: Shows counts for both
- [x] **Color coding**: Red for lost, yellow for kept

#### 2.7 Context-Aware Philosophical Text
- [x] **Dynamic text based on journey**:
  - If many sacrifices: "You have given much to keep going. The cost is real. But you are still here."
  - If few sacrifices: "You have held tight to what matters. The struggle is harder, but you carry more of yourself forward."
  - If balanced: "You have walked the line between holding on and letting go. This is the eternal choice."
  - If no sacrifices: Handled in empty states
  - If all sacrificed: "You have given everything. The power is great, but what remains?"
- [x] **Position**: Bottom of reflection screen, prominent container
- [x] **Typography**: Italic, contemplative styling

#### 2.8 Additional Journey Insights
- [ ] **Longest cycle** - "Your longest struggle lasted X" (future enhancement)
- [ ] **Most memories in one cycle** - "You once held X memories at once" (future enhancement)
- [ ] **Darkness peaks** - "Your darkest moment reached X" (future enhancement)
- [ ] **Rebirth milestones** - "After X cycles, you carry forward..." (future enhancement)

---

### Part 3: Context-Aware Whispers 🗣️

**Goal:** Make whispers feel personal and cutting, referencing the player's specific journey.

**Status: ✅ COMPLETE**

#### 3.1 Dynamic Whisper Generation System
- [x] **Track context variables**:
  - Total sacrifices (across all cycles)
  - Current cycle number (rebornCount)
  - Memories currently held
  - Current darkness level
  - Current phase
  - Recent actions (just sacrificed via isShowingSacrificeAftermath)
- [x] **Whisper generation logic** - priority-based selection based on context

#### 3.2 Context-Specific Whisper Pools
- [x] **Many sacrifices whispers**:
  - "You've given up so much already... why keep going?"
  - "How many memories is enough? When do you stop?"
  - "You're burning yourself away. What's left?"
  - "Was it worth it? Do you even remember what you lost?"
  - "Another one gone. How many more?"
  - "You've sacrificed everything that mattered. Why continue?"
- [x] **Few sacrifices whispers**:
  - "You're holding on too tight. Let go. It's easier."
  - "Those memories are weighing you down. Burn them."
  - "You could be stronger. You choose to be weak."
  - "Why suffer when you could just let go?"
  - "Your memories are chains. Break them."
- [x] **High cycle count whispers**:
  - "How many times will you do this? When does it end?"
  - "You've done this before. Nothing changes."
  - "The cycle repeats. Nothing matters."
  - "Again? Really? When will you learn?"
  - "You're stuck. This is all there is."
- [x] **Low light whispers**:
  - "This is it. This time, just let it fade."
  - "You're tired. You've earned the rest."
  - "It's okay to stop. Really. It's okay."
  - "Just let go. It's easier."
  - "The darkness is calling. Answer it."
- [x] **After sacrifice whispers**:
  - Handled via manySacrificesWhispers pool when just sacrificed
- [ ] **Memory-specific whispers** (future enhancement):
  - Reference specific memories: "Remember when you sacrificed [memory]? Was it worth it?"

#### 3.3 Whisper Intensity & Frequency
- [x] **Increase frequency** in later phases (0.3 + phase * 0.15)
- [x] **More whispers** when darkness is high (low light triggers)
- [x] **Whispers after sacrifices** - immediate, cutting (triggered after aftermath)
- [x] **Whispers during low light** - more desperate, more frequent (< 20% light)

#### 3.4 Visual Whisper Effects
- [x] **Fade in/out** more dramatically (TweenAnimationBuilder with opacity)
- [x] **Slight visual shake or distortion** when whispers appear (Transform.translate with random offset)
- [x] **Color variation** - whispers get redder/more intense in later phases (Color.lerp based on phase)
- [x] **Position variation** - whispers appear in different locations (random positioning)
- [x] **Size variation** - whispers larger in later phases (fontSize increases with intensity)
- [x] **Animation** - fade in with slight movement (TweenAnimationBuilder)

#### 3.5 Audio for Whispers (Future)
- [ ] **Whisper sound effects** - subtle, distorted voices
- [ ] **Volume/intensity** increases with phase
- [ ] **Different tones** for different whisper types

---

### Part 4: Supporting Systems

#### 4.1 Persistent Data Tracking
- [x] **Save system** for journey statistics ✅ COMPLETE
- [x] **Cross-cycle memory tracking** ✅ COMPLETE
- [x] **Statistics persistence** ✅ COMPLETE
- [x] **Data migration** (version system in place, migration logic can be added as needed)

#### 4.2 Visual Polish for Choices
- [ ] **Memory cards** - visual representation of memories
- [ ] **Sacrifice animation** - smooth, weighty transitions
- [ ] **Garden visualization** - how memories look in the garden
- [ ] **Ash/fade effects** - for sacrificed memories

#### 4.3 UI/UX Refinements
- [ ] **Journey button** design and placement
- [ ] **Reflection screen** layout and navigation
- [ ] **Back button** or close mechanism
- [ ] **Smooth transitions** between screens

---

### Implementation Timeline

**✅ COMPLETED:**
- **Part 1: Sacrifice Ritual** - Memory preview, confirmation dialog, aftermath sequence, persistent tracking
- **Part 2: Journey Reflection Screen** - Full UI, statistics, memory garden, archive, balance, context-aware text
- **Part 3: Context-Aware Whispers** - Dynamic generation, context pools, intensity/frequency, visual effects

**⏳ REMAINING:**
- **Save System Integration** - Persist journey data across app restarts
- **Audio Assets** - Sound effects for sacrifice ritual (pending asset collection)
- **Visual Polish** - Enhanced animations, particle effects (can be refined)
- **Additional Journey Insights** - Longest cycle, memory peaks, etc. (future enhancement)

---

### Success Metrics

This update succeeds if:
- [x] Players pause before sacrificing (the choice feels weighty) - ✅ Implemented with 3-second preview
- [x] Players visit the Journey Reflection screen regularly - ✅ Accessible via flower icon button
- [x] Whispers feel personal and impactful - ✅ Context-aware generation implemented
- [x] The sacrifice mechanic feels like a meditation, not a transaction - ✅ Full ritual sequence implemented
- [x] Players reflect on their choices, not just optimize - ✅ Journey Reflection screen provides reflection space

**Status: ✅ All core success metrics achieved!**

---

## 📋 HIGH PRIORITY - Core Experience Enhancement

### 1. Emotional Impact & Narrative Depth
**Priority: CRITICAL** - This is the heart of the game

- [ ] **Expand memory bank** - Add more diverse, emotionally resonant memories
  - Consider memories that span different life stages
  - Include both joyful and bittersweet memories
  - Memories that reflect different types of human connection

- [x] **Enhance whisper system** - Make whispers more impactful ✅ COMPLETE
  - [x] Increase whisper frequency in later phases
  - [x] Add visual effects to whispers (fade in/out, subtle animation)
  - [x] Consider whispers that reference player's specific journey (sacrifices made, cycles completed)
  - [x] Add variety - whispers that are more personal, more cutting

- [x] **Deepen sacrifice mechanic** - Make the choice more meaningful ✅ COMPLETE
  - [x] Show which memory will be sacrificed before confirming
  - [x] Add a confirmation dialog with weighty text
  - [x] Visual feedback that emphasizes the loss
  - [x] Track total memories sacrificed across all cycles (persistent stat)
  - [ ] Audio feedback (pending audio assets)

- [ ] **Story text evolution** - Make phase text more dynamic
  - [ ] Phase text that changes based on number of rebirths
  - [ ] Text that acknowledges sacrifices made
  - [ ] Text that reflects accumulated darkness
  - [ ] Consider adding interstitial text between phases

### 2. Visual Polish & Atmosphere
**Priority: HIGH** - Visuals support the emotional journey

- [ ] **Particle system enhancement**
  - [ ] Particles that respond more dramatically to light level
  - [ ] Particles that fade/glow based on light
  - [ ] Consider particle trails or effects when clicking
  - [ ] Particles that intensify during rebirth

- [ ] **Background gradient refinement**
  - [ ] More dramatic color shifts as darkness increases
  - [ ] Consider adding subtle texture or noise
  - [ ] Smooth transitions between phase changes

- [ ] **UI polish**
  - [ ] Better typography - consider custom fonts for story text
  - [ ] Smoother animations on button presses
  - [ ] Visual feedback for all interactions
  - [ ] Consider subtle glow effects on UI elements based on light level

- [ ] **Light visualization**
  - [ ] Make the main flame button more dynamic
  - [ ] Add pulsing/breathing effect based on light level
  - [ ] Consider particle effects emanating from the flame
  - [ ] Visual representation of light "flickering" when low

### 3. Gameplay Balance & Progression
**Priority: HIGH** - Ensure the journey feels meaningful

- [ ] **Balance testing**
  - [ ] Test soul economy - are costs balanced?
  - [ ] Test decay rates - is the struggle meaningful but not frustrating?
  - [ ] Test rebirth bonuses - do they feel rewarding?
  - [ ] Test sacrifice trade-offs - is the choice meaningful?

- [ ] **Progression feel**
  - [ ] Ensure each rebirth feels like meaningful progress
  - [ ] Consider adding milestones or achievements
  - [ ] Track meaningful statistics (total clicks, total time, etc.)

- [ ] **Phase difficulty curve**
  - [ ] Ensure phase transitions feel significant
  - [ ] Test that reaching phase 4 feels like an achievement
  - [ ] Consider phase-specific challenges or mechanics

---

## 📋 MEDIUM PRIORITY - Feature Enhancements

### 4. Persistence & Meta-Progression
**Priority: MEDIUM** - Support the "eternal return" theme

- [x] **Save system** ✅ COMPLETE
  - [x] Save game state locally (using shared_preferences)
  - [x] Persist across app restarts
  - [x] Save rebirth count, total sacrifices, memories, etc.
  - [x] Auto-save on upgrades, sacrifices, rebirths, and app close

- [ ] **Statistics tracking**
  - [ ] Total cycles completed
  - [ ] Total memories sacrificed (across all cycles)
  - [ ] Total memories preserved (across all cycles)
  - [ ] Total time played
  - [ ] Longest cycle
  - [ ] Most memories collected in one cycle

- [x] **Meta-progression visualization** ✅ COMPLETE
  - [x] Screen showing journey statistics
  - [x] Visual representation of accumulated wisdom/strength (Journey Reflection Screen)
  - [x] Memory garden and archive visualization
  - [ ] Cycle history log (future enhancement)

### 5. Accessibility & Polish
**Priority: MEDIUM** - Make the game accessible to all

- [ ] **Settings menu**
  - [ ] Option to adjust text size
  - [ ] Option to disable animations (for performance)
  - [ ] Option to adjust particle density
  - [ ] Sound/music toggle (if audio is added)

- [ ] **Performance optimization**
  - [ ] Optimize particle rendering
  - [ ] Ensure smooth 60fps on target devices
  - [ ] Battery usage optimization

- [ ] **Android-specific**
  - [ ] Test on various screen sizes
  - [ ] Handle different aspect ratios
  - [ ] Test on lower-end devices
  - [ ] Consider tablet layout optimizations

### 6. Audio (Optional but Recommended)
**Priority: MEDIUM-LOW** - Audio can significantly enhance atmosphere

- [ ] **Ambient soundscape**
  - [ ] Subtle background ambience that changes with phase
  - [ ] Sound that responds to light level
  - [ ] Consider subtle music (very minimal, atmospheric)

- [ ] **Sound effects**
  - [ ] Click sound (subtle, satisfying)
  - [ ] Memory recall sound (warm, nostalgic)
  - [ ] Sacrifice sound (weighty, somber)
  - [ ] Rebirth sound (powerful, transformative)
  - [ ] Phase transition sound (ominous)

- [ ] **Audio implementation**
  - [ ] Use appropriate audio library (e.g., audioplayers)
  - [ ] Ensure audio doesn't interfere with meditation aspect
  - [ ] Volume controls

---

## 📋 LOW PRIORITY - Nice to Have

### 7. Additional Content
**Priority: LOW** - Expand the experience

- [ ] **More memory types**
  - [ ] Seasonal memories
  - [ ] Achievement memories
  - [ ] Relationship memories
  - [ ] Growth/transformation memories

- [ ] **More whisper variations**
  - [ ] Context-aware whispers
  - [ ] Whispers that reference specific actions
  - [ ] More philosophical/poetic whispers

- [ ] **Additional story text**
  - [ ] More phase text variations
  - [ ] Text that appears at milestones
  - [ ] Easter eggs for high rebirth counts

### 8. Social/Sharing (Very Optional)
**Priority: VERY LOW** - Only if it serves the mission

- [ ] **Journey sharing** (if it makes sense)
  - [ ] Share cycle count
  - [ ] Share meaningful statistics
  - [ ] **IMPORTANT**: Only if it doesn't turn into a competition
  - [ ] The game should remain personal, not competitive

---

## 🎯 PHILOSOPHICAL GUIDELINES

When implementing features, always ask:

1. **Does this serve the meditation on persistence?**
   - Does it reinforce that the struggle itself is meaningful?
   - Does it honor the choice to continue?

2. **Does this respect the player's journey?**
   - Does it acknowledge their sacrifices without judgment?
   - Does it celebrate their persistence?

3. **Does this avoid "gamification" that undermines the message?**
   - No leaderboards (defeats the purpose)
   - No achievements that feel like checkboxes
   - No "winning" - only continuing

4. **Does this feel authentic to the experience?**
   - The game is about life, not about gaming
   - Every feature should feel like it's part of a larger meditation

---

## 📝 NOTES

### Current State Assessment

**Strengths:**
- Core mechanics are solid and functional
- Rebirth sequence is now more impactful
- Visual foundation is in place
- The philosophical framework is clear

**Areas Needing Attention:**
- Emotional impact needs to be deepened
- Visual polish will enhance the experience
- Balance testing is crucial
- Persistence/save system is important for the "eternal return" theme

### Development Philosophy

Remember: This is not a game to "beat." It's a meditation tool. Every feature should:
- Support reflection
- Honor the player's choices (even sacrifices)
- Reinforce that persistence itself is the victory
- Never judge or shame the player
- Always offer the choice to continue

The goal is to create an experience that players return to not because they need to "finish" it, but because it offers them a moment of reflection, a reminder of their own resilience, and a space to contemplate the choices they make in their own lives.

---

## 🚀 NEXT STEPS (Recommended Order)

1. **Test and refine rebirth sequence** - Ensure it feels powerful
2. **Expand memory bank** - More emotional depth
3. **Enhance whisper system** - Make it more impactful
4. **Deepen sacrifice mechanic** - Make the choice weightier
5. **Visual polish** - Particles, gradients, UI refinements
6. **Balance testing** - Ensure the journey feels right
7. **Save system** - Support the eternal return theme
8. **Statistics tracking** - Help players see their journey
9. **Audio (if desired)** - Enhance atmosphere
10. **Polish and optimization** - Performance and accessibility

---

*This roadmap is a living document. As the game evolves and we learn what resonates with players, priorities may shift. The mission statement remains the north star.*


