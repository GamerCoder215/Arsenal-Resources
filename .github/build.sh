# Clone Models
echo "Cloning Models..."
mkdir models
cd models

git clone https://github.com/GamerCoder215/Arsenal arsenal

mkdir minecraft
cp -rfv arsenal/bukkit/src/generated/resources/assets/minecraft/models/* ./minecraft/

mkdir arsenal
cp -rfv arsenal/core/src/generated/resources/assets/arsenal/models/* ./arsenal/

rm -rf arsenal
cd ..

# Build ZIP
echo "Building Folders..."

declare -A folders=( [bukkit]=Bukkit [mod]=Mod )

for folder in "${!folders[@]}" 
do
  mkdir $folder

  cp -rfv pack.mcmeta pack.png LICENSE README.md $folder/

  mkdir $folder/assets/
  mkdir $folder/assets/arsenal/
  mkdir $folder/assets/arsenal/textures/
  cp -rfv textures/* $folder/assets/arsenal/textures/

  if [[ "$folder" == *"bukkit"* ]]; then
    mkdir $folder/assets/minecraft/
    cp -rfv models/minecraft/* $folder/assets/minecraft/models/
  fi

  cp -rfv models/arsenal/* $folder/assets/arsenal/models/
  mkdir $folder/assets/arsenal/lang
  cp -rfv lang/* $folder/assets/arsenal/lang/
done

echo "Zipping..."
(cd mod && zip -r ../Arsenal-Mod.zip .)
(cd bukkit && zip -r ../Arsenal-Bukkit.zip .)

echo "Removing Unused Files..."
# Remove Unused Files
shopt -s extglob
rm -rfv !(*.zip)

# Create ZIP Hashes
echo "Creating Hashes..."
for folderName in "${folders[@]}"
do
  echo "$(sha1sum Arsenal-$folderName.zip | cut -d ' ' -f 1)" > Arsenal-$folderName.zip.sha1
  echo "$(sha256sum Arsenal-$folderName.zip | cut -d ' ' -f 1)" > Arsenal-$folderName.zip.sha256
  echo "$(sha512sum Arsenal-$folderName.zip | cut -d ' ' -f 1)" > Arsenal-$folderName.zip.sha512
  echo "$(md5sum Arsenal-$folderName.zip | cut -d ' ' -f 1)" > Arsenal-$folderName.zip.md5
done

echo "Committing..."
# Commit ZIP
git config user.name github-actions[bot]
git config user.email 41898282+github-actions[bot]@users.noreply.github.com
git fetch origin download
git checkout download
git add ./

git branch -D download
git branch -m download
git commit -m "Update Resource Pack ($1)" -a
git push -f origin download

echo "Done!"