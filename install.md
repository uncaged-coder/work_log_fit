
# 1. System setup

Install GTK 3.0 or newer:
sudo xbps-install gtk+3-devel

Install pkg-config:
sudo xbps-install pkg-config

Other necessary dependencies:
sudo xbps-install cmake ninja clang

# 2. Install Flutter

Download Flutter SDK:
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.13.9-stable.tar.xz

Extract the archive:
tar xf flutter_linux_3.13.9-stable.tar.xz

Add flutter to the PATH:
echo 'export PATH="$PATH:`pwd`/flutter/bin"' >> ~/.bashrc

Source the updated bashrc file:
source ~/.bashrc

Verify the Flutter installation:
flutter doctor

If flutter report missing things from android SDK, then check step 5.

# 3. Enable Desktop Support

Navigate to the flutter directory
cd flutter

Switch to the master channel (may change in the future as features stabilize):
flutter channel master

Upgrade Flutter:
flutter upgrade

Enable Linux desktop support:
flutter config --enable-linux-desktop

# 4. Create and Run Your App

Create a new Flutter project:
flutter create my_app

Navigate to the project directory:
cd my_app

Run your application:
flutter run -d linux

# 5. Install android studio

download and install it from [official web site](https://developer.android.com/studio)
follow the instruction and run it
> /opt/android-studio/bin/studio.sh
then
> sudo apt install sdkmanager
> sdkmanager --install "cmdline-tools;latest"

then setup your environement. In my case, I use fish. So I have in ~/.config/fish/config.fish:

set -gx ANDROID_SDK_ROOT /opt/android-sdk/
set -gx CHROME_EXECUTABLE /usr/bin/chromium
set -gx PATH $PATH /opt/flutter/bin /opt/android-sdk/cmdline-tools/latest/bin/

check that flutter is happy:
> flutter doctor -v
