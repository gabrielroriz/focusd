![Status](https://img.shields.io/badge/status-active-success)
![Platform](https://img.shields.io/badge/platform-linux-lightgrey)
![Last Commit](https://img.shields.io/github/last-commit/gabrielroriz/focusd)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=flat-square&logo=linux&logoColor=black)
![Shell Script](https://img.shields.io/badge/Shell_Script-121011?style=flat-square&logo=gnu-bash&logoColor=white)
![systemd](https://img.shields.io/badge/systemd_service-3A3A3A?style=flat-square&logo=systemd&logoColor=white)
![D-Bus](https://img.shields.io/badge/D--Bus-2C2C2C?style=flat-square)

<p align="center">
  <img src="assets/focusd_icon--black.svg" alt="focusd banner" width="120" height="120">
</p>

<h1 align="center">
    <code>focusd</code>
</h1>

<p align="center">
  <quote>Linux productivity tool for blocking distractions and boosting focus.
</p>

## Welcome

`focusd` is a Linux productivity tool that helps users maintain focus by blocking distracting websites and services. It works by managing the `/etc/hosts` file with a two-tier blocking system:

- **Always-blocked sites**: Permanently blocked domains (e.g., adult content, extreme distractions) that cannot be unlocked
- **Conditionally-blocked sites**: Temporarily unlockable domains (e.g., social media, streaming, news) that can be accessed for short periods when needed

The system runs as a systemd service that monitors user sessions and enforces blocking rules. Users can temporarily unlock conditionally-blocked sites via CLI for a maximum of 10 minutes, while always-blocked sites remain inaccessible. Domain lists are organized by category (entertainment, gaming, shopping, streaming, social media) for easy customization.

## Table of contents

- [Welcome](#welcome)
- [Table of contents](#table-of-contents)
- [Getting started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installing \& deployment](#installing--deployment)
  - [How it works](#how-it-works)
- [CLI Usage](#cli-usage)
  - [Show unlock status](#show-unlock-status)
  - [Temporarily unlock conditionally-blocked sites](#temporarily-unlock-conditionally-blocked-sites)
  - [Immediately re-lock all sites](#immediately-re-lock-all-sites)
- [Roadmap](#roadmap)
  - [Completed Features](#completed-features)
  - [Done](#done)
  - [In Progress](#in-progress)
  - [Planned](#planned)
  - [Future Considerations](#future-considerations)

## Getting started

### Prerequisites

- **Linux operating system** with systemd support
- **Bash shell** (version 4.0 or higher)
- **systemd** for service management
- **D-Bus** for inter-process communication
- **Root/sudo privileges** for system file modifications
- **X11 or Wayland** desktop environment (for tray app)

### Installing & deployment

1. Clone the repository:

   ```bash
   git clone https://github.com/gabrielroriz/focusd.git
   cd focusd
   ```

2. Run the installation script:

   ```bash
   sudo ./scripts/start.sh
   ```

This script will:

- Create a dedicated user (`deep-worker`) and group (`deep-group`)
- Back up the original `/etc/hosts` file
- Set up configuration files in `/etc/focusd/` (`/etc/focusd/focusd.conf`)
- Generate dynamic host file profiles in `/etc/focusd/hosts_profiles/`:
  - `hosts.locked`: Full blocking mode (always-blocked + conditionally-blocked domains)
  - `hosts.unlocked`: Partial unlock mode (only always-blocked domains)
- Install the state manager library to `/usr/local/lib/focusd/`
- Install and enable the systemd service (`focusd.service`)
- Install the `focusd` CLI tool to `/usr/local/bin/focusd`

### How it works

1. **User Groups**: The system creates a special user (`deep-worker`) and group (`deep-group`). All users in this group will be subject to the blocking system.
2. **Two-tier blocking**:
   - **Always Blocked**: Sites that are never accessible (adult content, highly addictive platforms)
   - **Conditionally Blocked**: Sites blocked by default but can be temporarily unlocked for 5-10 minutes
3. **Dynamic hosts**: Host files are generated dynamically based on unlock state:
   - `hosts.locked`: All blocking categories active (always-blocked + conditionally-blocked)
   - `hosts.unlocked`: Only always-blocked sites restricted, conditionally-blocked sites temporarily accessible
4. **Automatic lock**: The systemd service monitors unlock timers and automatically re-locks after the specified duration

## CLI Usage

After installation, you can use the `focusd` command-line tool to manage focus modes:

### Show unlock status

```bash
sudo focusd status
```

Shows whether sites are currently locked or unlocked, time remaining if unlocked, and which categories are blocked.

### Temporarily unlock conditionally-blocked sites

```bash
sudo focusd unlock [seconds]
```

Unlocks conditionally-blocked sites for a specified duration (default: 300 seconds = 5 minutes, max: 600 seconds = 10 minutes).

Example:

```bash
sudo focusd unlock 300  # Unlock for 5 minutes
sudo focusd unlock 600  # Unlock for 10 minutes
```

### Immediately re-lock all sites

```bash
sudo focusd lock
```

Forces immediate re-lock of all conditionally-blocked sites, canceling any active unlock period.

## Roadmap

### Completed Features

### Done

- [x] Basic installation and setup scripts
- [x] Systemd service integration
- [x] Multiple host file profiles with dynamic generation
- [x] User and group management system
- [x] Domain list management for different categories
- [x] **Two-tier blocking system (always-blocked vs conditionally-blocked)** ✅ **(New!)**
- [x] **Temporary unlock functionality with automatic re-lock** ✅ **(New!)**
- [x] **Interactive CLI tool for configuration management** ✅
- [x] **Timer-based unlock expiry with notifications** ✅ **(New!)**

### In Progress

### Planned

- [ ] Per-category unlock (unlock only social media, not streaming, etc.)
- [ ] CLI upgrade: only outside group "deep-workers" will be possible to change focusd config
- [ ] Unlock history and analytics
- [ ] Tray App with unlock button
- [ ] Statistics and Analytics
- [ ] Configuration Web UI
- [ ] Time-based Scheduling
- [ ] Custom Domain Lists
- [ ] Multi-user Support
- [ ] Browser Extensions

### Future Considerations

- Support for additional Linux distributions
- Integration with popular productivity frameworks (Pomodoro, time blocking)
- Team/organization deployment tools

