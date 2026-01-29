# Two-Tier Blocking System Implementation Summary

## Overview
Successfully implemented a granular focus control system with two-tier blocking and temporary unlock functionality.

## Key Features Implemented

### 1. Two-Tier Domain Categorization ✅
- **Always Blocked** (`domains/always-blocked/`): Adult content (~13,186 domains) - never unlockable
- **Conditionally Blocked** (`domains/conditionally-blocked/`): Can be temporarily unlocked
  - `social-media-heavy.txt` - Highly addictive platforms (TikTok, Instagram, Facebook, Twitter, Reddit, YouTube, Twitch)
  - `social-media-moderate.txt` - Less addictive (LinkedIn, Pinterest, Tumblr)
  - `streaming.txt` - Video/audio streaming (Netflix, Hulu, Disney+, Spotify, etc.)
  - `news.txt` - News websites (CNN, Fox News, BBC, NYTimes, etc.)
  - `gaming.txt` - Gaming platforms (Roblox, Steam, Epic Games, etc.)
  - `shopping.txt` - E-commerce (Amazon, eBay, AliExpress, etc.)
  - `entertainment.txt` - Remaining dopamine sites (~1,468 domains)
- **Whitelisted** (`domains/whitelisted/`): Communication tools never blocked (Discord, WhatsApp, Telegram, Slack)

### 2. State Management System ✅
- Created `/var/lib/focusd/unlock_state` for persistent state tracking
- Functions: `is_unlocked()`, `set_unlocked()`, `set_locked()`, `check_unlock_expired()`, `format_time_remaining()`
- State survives across sessions but resets on system reboot (boots locked for maximum focus)

### 3. Dynamic Hosts File Generation ✅
- New script: `scripts/hosts/generate_hosts_dynamic.sh`
- Generates two profiles:
  - `hosts.locked` - All blocks active (always-blocked + conditionally-blocked)
  - `hosts.unlocked` - Only always-blocked active
- Replaces static profile generation (`create_hosts_restricted.sh`, `create_hosts_default.sh`, `create_hosts_no_social.sh` - now obsolete)

### 4. Systemd Service Enhancement ✅
- Updated `scripts/systemd/focusd_script.sh` with:
  - Unlock expiry checking every 2 seconds
  - Automatic re-lock when timer expires
  - 60-second warning notification before re-lock
  - Dynamic profile application based on unlock state

### 5. Enhanced CLI Commands ✅
Extended `focusd` CLI with three new commands:

#### `sudo focusd unlock [seconds]`
- Unlocks conditionally-blocked sites for specified duration
- Default: 300 seconds (5 minutes)
- Maximum: 600 seconds (10 minutes)
- Minimum: 60 seconds (1 minute)
- Sends desktop notification on unlock
- Example: `sudo focusd unlock 300`

#### `sudo focusd lock`
- Immediately re-locks all conditionally-blocked sites
- Cancels any active unlock period
- Sends desktop notification on lock

#### `sudo focusd status`
- Shows current lock/unlock state
- Displays time remaining if unlocked
- Lists which categories are blocked/accessible
- Default command when running `focusd` without arguments

### 6. Installation Flow Updates ✅
- Modified `scripts/start.sh` to:
  - Source state management system
  - Generate dynamic hosts profiles
  - Initialize unlock state (default: locked)
- Updated `scripts/config/create_config.sh` to set `mode=locked` by default
- Added state manager library installation to `/usr/local/lib/focusd/`

## Technical Architecture

### File Structure Changes
```
domains/
├── always-blocked/
│   └── adult-content.txt (13,186 domains)
├── conditionally-blocked/
│   ├── social-media-heavy.txt
│   ├── social-media-moderate.txt
│   ├── streaming.txt
│   ├── news.txt
│   ├── gaming.txt
│   ├── shopping.txt
│   └── entertainment.txt
└── whitelisted/
    └── communication-tools.txt

scripts/
├── state/
│   └── state_manager.sh (NEW)
├── hosts/
│   ├── generate_hosts_dynamic.sh (NEW - replaces static generators)
│   └── update_etc_hosts.sh (UPDATED)
└── ...

/var/lib/focusd/
└── unlock_state (runtime state file)

/etc/focusd/hosts_profiles/
├── hosts.locked (dynamic - all blocks)
└── hosts.unlocked (dynamic - only always-blocked)
```

### State File Format
```
IS_UNLOCKED=true|false
UNLOCK_TIMESTAMP=<epoch_seconds>
UNLOCK_DURATION=<seconds>
UNLOCKED_CATEGORIES=all
```

### Workflow
1. User runs `sudo focusd unlock 300`
2. CLI sets `IS_UNLOCKED=true`, `UNLOCK_TIMESTAMP=<now>`, `UNLOCK_DURATION=300`
3. CLI copies `/etc/focusd/hosts_profiles/hosts.unlocked` to `/etc/hosts`
4. Desktop notification sent: "🔓 Temporary unlock active for 5 minutes"
5. Systemd service checks expiry every 2 seconds in main loop
6. At 60 seconds remaining: Warning notification sent
7. When expired: Service copies `hosts.locked` to `/etc/hosts`, sets `IS_UNLOCKED=false`
8. Desktop notification sent: "🔒 Focus mode re-enabled"

## What Always Stays Blocked
- Adult content (13,186 domains) - **NEVER unlockable**
- Ensures core focus protection even during unlock periods

## What Can Be Temporarily Unlocked
- Social media (Facebook, Instagram, TikTok, Twitter, LinkedIn, Reddit, YouTube, etc.)
- Streaming services (Netflix, Hulu, Disney+, Spotify, Twitch, etc.)
- News sites (CNN, BBC, NYTimes, Fox News, etc.)
- Gaming platforms (Roblox, Steam, Epic Games, etc.)
- Shopping sites (Amazon, eBay, AliExpress, etc.)
- Entertainment sites (~1,468 dopamine-inducing domains)

## Security Considerations
- Requires sudo for all unlock/lock operations
- State file writable only by root
- Service runs with systemd privileges
- Users with root access can still bypass (acceptable for self-imposed productivity tool)

## Testing Recommendations
1. Install with `sudo ./scripts/start.sh`
2. Verify default locked state: `sudo focusd status`
3. Test unlock: `sudo focusd unlock 120` (2 minutes for quick test)
4. Verify unlocked state: `sudo focusd status`
5. Wait for expiry and check automatic re-lock
6. Test manual re-lock: `sudo focusd lock`
7. Check notifications are displayed
8. Verify always-blocked sites remain blocked during unlock (test adult content domain)
9. Verify conditionally-blocked sites are accessible during unlock (test facebook.com)

## Future Enhancements
1. Per-category unlock (unlock only social-media, not streaming)
2. Unlock history/analytics
3. External authorization (authenticator app, second device)
4. Bypass prevention hardening (file immutability, SELinux policies)
5. Tray app with unlock button
6. Time-delayed unlock (5-minute delay before unlock activates)

## Migration Notes
- Old static profiles (`hosts.restricted`, `hosts.default`, `hosts.no_social`) are no longer generated
- Old scripts can be deleted: `create_hosts_restricted.sh`, `create_hosts_default.sh`, `create_hosts_no_social.sh`
- Config file now uses `mode=locked|unlocked` instead of `mode=restricted|default`
- Existing users should run `sudo ./scripts/start.sh` to regenerate profiles
