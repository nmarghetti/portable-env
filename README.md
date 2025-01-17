# Portable env

## Introduction

This project is a wrapper around [common-env](https://github.com/nmarghetti/common_env) that allows to define different profiles.

Each profile will define its own list of application/settings to install.

## Installation

1. **Download archive**

   - Create a folder `C:\PortableEnv`.
   - Download and extract `portable-env.zip` into that folder (ensure to extract only the files and not to have a portable_env folder).

   You should end up with the following structure:

   ```text
   C:/PortableEnv
    ├── certificates
    │   └── ...
    ├── ini.bat
    ├── settings
    │   ├── certificates
    │   │   └── ...
    │   ├── extra
    │   │   └── upgrade_portable_env
    │   │       └── ...
    │   ├── profiles
    │   │   └── ...
    │   └── vscode
    │       └── ...
    ├── setup_install.cmd
    └── setup_user.ini
   ```

1. **Add CA certificates to trust**

   If you need to add some CA certificates, create one or several subfolders in `C:/PortableEnv/certificates` and put them there.

1. **Update configuration**

   - Fill all fields in `setup_user.ini` (you can avoid the user if the one from the system is fine).

     ```ini
     [install]
     ; Profile to install, it will look for <profile>.ini and settings/profile/<profile>.ini
     ; eg. profile = dev
     profile =
     [git]
     ; url to clone the repository with user and token, eg. https://<user>:<token>@github.com/owner/portable-env.git
     git-url =
     ; if left empty, it will be taken from your system
     user =
     ; put your email address
     email =
     ```

1. **Launch setup**

   Launch `setup_install.cmd` to install. You would have to run it several times and probably restart the computer if WSL has not been installed yet.

   You should end up with a folder like that:

   ```text
   C:/PortableEnv
   ├── AppData
   ├── Documents
   ├── home
   ├── PortableApps
   ├── extra
   ├── settings
   ├── ini.bat
   ├── PortableApps.exe
   ├── PortableApps.zip
   ├── PortableGit.exe
   ├── setup.cmd
   ├── setup.ini
   ├── setup_install.cmd
   ├── setup_user.ini
   ├── test.ini
   ├── test_setup.cmd
   └── Start.exe
   ```

   You can launch `Start.exe` to access to your portable env:

   ![Portable env](readme/portable_env.png)

   You can also install many portable applications from PortableApps.com. To do so, you can just click on `Apps` --> `Get More Apps` --> `By Category` and select the applications you want to add (eg. Chrome, Firefox, Notepad++, OBS).
