
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
