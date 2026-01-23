# Fortify Automation Toolkit

A streamlined collection of PowerShell scripts to manage the **Fortify CLI (fcli)**, **ScanCentral Client**, and their core dependencies (**OpenJDK 21** and **Apache Maven**).

---

## 📂 File Directory & Descriptions

| File Name | Category | Description |
| --- | --- | --- |
| **`Setup-FortifyFCLI.ps1`** | **Setup** | **The Entry Point.** Downloads `fcli`, prompts for FoD credentials, performs a test login, and saves settings to your User Environment. |
| **`Install-FortifyDependencies.ps1`** | **Setup** | Installs **OpenJDK 21** and **Maven** locally to your home folder so you don't need to install Java system-wide. |
| **`Fortify-PackageAndUpload.ps1`** | **Workflow** | **The Master Script.** Automates downloading code, packaging it with ScanCentral, and uploading it to FoD. |
| **`Uninstall-FortifyTools.ps1`** | **Cleanup** | Deletes `fcli` and ScanCentral files and removes their locations from your Windows `PATH`. |
| **`Uninstall-FortifyDependencies.ps1`** | **Cleanup** | Deletes the local Java/Maven folders and clears the `JAVA_HOME` variable. |
| **`README.md`** | **Docs** | This manual. |

---

## 🖥️ Getting Started (For Beginners)

1. **Open PowerShell**: Press the **Windows Key**, type `PowerShell`, and click on **Windows PowerShell**.
2. **Navigate to your folder**: Type `cd`, followed by the path where you saved these files.
```powershell
cd "$HOME\Desktop\fcli_course"

```


3. **Enable Scripts**: If you have problem running any of these scripts then run this command to allow scripts to run in your current window:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process

```



---

## 🚀 The Three-Step Workflow

### Step 1: Tool Setup

```powershell
.\Setup-FortifyFCLI.ps1

```

* Asks for your **FoD URL**, **Client ID**, and **Secret**.
* It will test the login immediately. If it fails, it stops the install so you can fix your credentials.

### Step 2: Install Local Dependencies

```powershell
.\Install-FortifyDependencies.ps1

```

* Only run this if you don't already have Java 21 and Maven on your machine. It keeps the files inside your user profile.

### Step 3: Package and Upload

Open a new powershell instance in order to pick up the environmental changes first

```powershell
.\Fortify-PackageAndUpload.ps1

```

* This script handles everything: it grabs sample code, packages it, logs you in, and uploads it to the **Release ID** you provide.

---

## 🛠️ Configuration & Variables

Once the setup is complete, these variables are stored in your **User Environment Variables** for `fcli` to use automatically:

| Variable | Default Value | Purpose |
| --- | --- | --- |
| `FCLI_DEFAULT_FOD_URL` | `https://ams.fortify.com` | API endpoint for your tenant. |
| `FCLI_DEFAULT_CLIENT_ID` | (User Provided) | Your API Client ID. |
| `FCLI_DEFAULT_CLIENT_SECRET` | (User Provided) | Your API Client Secret (Masked). |

---

## 🧹 Cleanup

To remove all tools and files, run the uninstall scripts. They will delete the `$HOME\fortify` folder and clean up your `PATH` without requiring Administrator rights.

**Would you like me to generate a single "Check-Health" script that verifies all these files are present and correctly configured?**