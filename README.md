<div align="center">

```
   _____ __  ____  ______  __  ______  _   ____  __    __  _____  _____ _________
  / ___// / / /  |/  / _ \/ / / / __ \/ | / / / / /   /  |/  / / / / ___//  _/ ____/
  \__ \/ /_/ / /|_/ / // / /_/ / / / /  |/ / /_/ /   / /|_/ / / / /\__ \ / // /     
 ___/ / __  / /  / / ____/\__, / /_/ / /|  /\__, /   / /  / / /_/ /___/ // // /___   
/____/_/ /_/_/  /_/_/    /____/\____/_/ |_/____/    /_/  /_/\____//____/___/\____/   
```

### 🛰️ Next-Generation Cybernetic Audio Engine for Android & Desktop

[![Release](https://img.shields.io/badge/Release-v1.12.3-00e5ff?style=for-the-badge&logo=android&logoColor=black)](https://github.com/Tanatos-theOnly/Symphony-Music/releases/latest)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Engine](https://img.shields.io/badge/Audio_Engine-Just_Audio_%2B_MediaKit-ff007f?style=for-the-badge&logo=apple-music&logoColor=white)](https://github.com/Tanatos-theOnly/Symphony-Music)
[![License](https://img.shields.io/badge/License-GPL_v3.0-00ff66?style=for-the-badge&logo=gnu&logoColor=black)](LICENSE)
[![Security](https://img.shields.io/badge/Signature-Signed_Keystore-blueviolet?style=for-the-badge&logo=google-authenticator&logoColor=white)](https://github.com/Tanatos-theOnly/Symphony-Music)

<p align="center">
  <a href="#-quick-download"><b>📥 Download APK</b></a> •
  <a href="#-core-features"><b>⚡ Key Features</b></a> •
  <a href="#-architecture"><b>🧠 Architecture</b></a> •
  <a href="#-troubleshooting"><b>🛠️ Troubleshooting</b></a>
</p>

---

</div>

## 📟 System Diagnostic & Initialization Log

```console
[SYS_BOOT]  Initializing Symphony Core Kernel v1.12.3...
[STREAM_OK] Native YouTube Explode chunked transport established.
[AUDIO_DSP] JNI Hardware 10-Band Equalizer: ACTIVE (com.rohannet.symphonymusic)
[BOLI_ALG]  Vibe-Vault Engine initialized: Dynamic Recommendation ready.
[SECURITY]  SHA-256 Release Keystore Verified. All systems nominal.
```

---

## ⚡ Core Features

| Feature | Description | Status |
| :--- | :--- | :---: |
| 🚀 **High-Speed Chunked Downloader** | Direct chunk-buffered download engine bypasses CDN timeouts and drops. | `STABLE` |
| 🧬 **BOLI Vibe Intelligence** | Smart local listening telemetry creates custom dynamic vibes. | `ACTIVE` |
| 🎚️ **JNI Hardware Equalizer** | Native low-latency DSP equalizer with bass boost and virtualizer. | `ACTIVE` |
| 🌐 **Zero Ads & Zero Login** | Pure streaming with no trackers, telemetry, or account barriers. | `ENABLED` |
| 📜 **Real-time Synced Lyrics** | Millisecond-accurate synchronized lyrics powered by LRCLIB. | `SYNCED` |
| 🛡️ **Self-Healing In-App Updater** | Automated GitHub Release detector with live progress and fallback. | `ACTIVE` |

---

## 📥 Quick Download

<div align="center">

| Release Target | Architecture | Direct Download |
| :--- | :---: | :---: |
| **Symphony Music v1.12.3** | Universal (`arm64-v8a`, `armeabi-v7a`, `x86_64`) | [**Download Signed APK**](https://github.com/Tanatos-theOnly/Symphony-Music/releases/latest) |

> **Note:** This APK is securely signed with our release keystore. If Android displays an *Unknown Sources* warning, tap **Settings ➔ Allow from this source** to proceed.

</div>

---

## 🧠 Architecture Overview

Symphony Music is built with a resilient, reactive multi-layer architecture:

```
┌────────────────────────────────────────────────────────┐
│                   Flutter Presentation UI              │
│       GetX State Management  •  Orbitron Sci-Fi Theme  │
└──────────────────────────┬─────────────────────────────┘
                           │
┌──────────────────────────▼─────────────────────────────┐
│                 Symphony Services Layer                │
│    Downloader (Chunked) • BOLI Engine • AudioHandler   │
└──────────────────────────┬─────────────────────────────┘
                           │
┌──────────────────────────▼─────────────────────────────┐
│              Native Platform Bridge (JNI)              │
│  com.rohannet.symphonymusic.Equalizer / FileProvider   │
└──────────────────────────┘
```

---

## 🛠️ Developer Setup

If you want to build the project locally from source:

```bash
# 1. Clone repository
git clone https://github.com/Tanatos-theOnly/Symphony-Music.git
cd Symphony-Music

# 2. Get dependencies
flutter pub get

# 3. Analyze code
flutter analyze

# 4. Compile signed release APK
flutter build apk --release
```

---

<div align="center">

### 👨‍💻 Lead Architect & Maintainer

**REDDY A. ROHAN** (`Tanatos-theOnly`)  
*Crafted on Earth • Designed for the Cosmos*

[![GitHub](https://img.shields.io/badge/GitHub-Tanatos--theOnly-181717?style=flat-square&logo=github)](https://github.com/Tanatos-theOnly)

</div>
