

# Install basic system dependencies

echo ""
echo "--------------------------------------------------"
echo ""
echo "(1 of 5) Installing system basics..."
echo ""
echo "--------------------------------------------------"
echo ""

sudo mkdir /home/ghost/hp_tmp

#sudo touch /home/ghost/hp_tmp/.hp_storage_
#sudo chown -R ghost:ghost /home/ghost/hp_tmp/.hp_storage_

#sudo touch /home/ghost/hp_tmp/.authtoken
#sudo chown -R ghost:ghost /home/ghost/hp_tmp/.authtoken

sudo apt-get update
sudo apt-get install --no-install-recommends -y git
sudo apt-get install --no-install-recommends -y chromium-browser

# Install NodeJS

sudo apt-get install --no-install-recommends -y nodejs
sudo apt-get install --no-install-recommends -y npm

# Run Driver install script

echo ""
echo "--------------------------------------------------"
echo ""
echo "(2 of 5) Starting Hackpack Driver install..."
echo ""
echo "--------------------------------------------------"
echo ""

sudo bash /home/ghost/firmware/drivers/bin/install.sh

# Run CLI install script

echo ""
echo "--------------------------------------------------"
echo ""
echo "(3 of 5) Starting Hackpack CLI install..."
echo ""
echo "--------------------------------------------------"
echo ""

sudo bash /home/ghost/firmware/cli/bin/install.sh

# Run Kiosk install

echo ""
echo "--------------------------------------------------"
echo ""
echo "(4 of 5) Installing Kiosk functionality..."
echo ""
echo "--------------------------------------------------"
echo ""

sudo apt-get install -y libgtk-3-dev
sudo apt-get install --no-install-recommends -y midori
sudo apt-get install --no-install-recommends -y scons
sudo apt-get install --no-install-recommends -y swig
sudo apt-get install --no-install-recommends -y swig
sudo apt-get install --no-install-recommends -y gir1.2-webkit-3.0
sudo apt-get install --no-install-recommends -y libgtk-3.0
sudo apt-get install --no-install-recommends -y matchbox

sudo pip install pywebview[gtk3]
sudo bash /home/ghost/firmware/kiosk/bin/install.sh

echo ""
echo "--------------------------------------------------"
echo ""
echo "(5 of 5) Optional games and input..."
echo ""
echo "--------------------------------------------------"
echo ""
sudo apt-get install --no-install-recommends -y micropolis
sudo apt-get install --no-install-recommends -y openttd
sudo cp -r /home/ghost/firmware/assets/chocolate-doom/chocolate-* /usr/local/bin/
sudo cp -r /home/ghost/firmware/assets/matchbox-keyboard/matchbox-keyboard /usr/local/bin/
mkdir /home/ghost/doom
cp /home/ghost/firmware/assets/chocolate-doom/DOOM1.WAD /home/ghost/doom
cp /home/ghost/firmware/assets/chocolate-doom/.chocolate-doom-config /home/ghost/doom
cp /home/ghost/firmware/assets/chocolate-doom/.chocolate-doom-extra-config /home/ghost/doom
sudo apt-get install -y libsdl1.2debian libsdl-image1.2 libsdl-mixer1.2 timidity
sudo apt-get install -y libsdl-mixer1.2-dev libsdl-net1.2 libsdl-net1.2-dev

echo ""
echo "--------------------------------------------------"
echo ""
echo "(6 of 5) Final steps and aesthetics"
echo ""
echo "--------------------------------------------------"
echo ""
# Own all the things!
sudo chown -R ghost:ghost /home/ghost/
chmod -R 755 /home/ghost/firmware/bin/

# Set wallpaper & aesthetics
pcmanfm --set-wallpaper /home/ghost/firmware/assets/images/wallpaper.png
sudo cp -r /home/ghost/firmware/assets/config /home/ghost/.config

# Cleanup
sudo apt-get purge -y libreoffice wolfram-engine sonic-pi scratch
sudo apt-get -y autoremove

echo ""
echo "--------------------------------------------------"
echo ""
echo "Finished installing Hackpack v4. Rebooting..."
echo ""
echo "--------------------------------------------------"
echo ""

sudo shutdown -r now