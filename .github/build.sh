# Clone Models
echo "Cloning Models..."
mkdir models
mkdir models/minecraft

# For some, unknown reason, it won't create a folder named 'models/arsenal'
mkdir models/arsenall
cd models

git clone https://github.com/GamerCoder215/Arsenal GitArsenal

modelFolders=( "block" "item" )

for folder in "${modelFolders[@]}"
do
  if [[ -d "GitArsenal/bukkit/src/generated/resources/assets/minecraft/models/$folder" ]]; then
    mkdir minecraft/$folder
    cp -rfv GitArsenal/bukkit/src/generated/resources/assets/minecraft/models/$folder/* ./minecraft/$folder
  fi

  if [[ -d "GitArsenal/core/src/generated/resources/assets/arsenal/models/$folder" ]]; then
    mkdir arsenall/$folder
    cp -rfv GitArsenal/core/src/generated/resources/assets/arsenal/models/$folder/* ./arsenall/$folder
  fi
done

rm -rf Arsenal
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
    mkdir $folder/assets/minecraft/models/

    for modelFolder in "${modelFolders[@]}"
    do
      if [[ ! -d "models/minecraft/$modelFolder" ]]; then 
        continue
      fi
      mkdir $folder/assets/minecraft/models/$modelFolder
      cp -rfv models/minecraft/$modelFolder/* $folder/assets/minecraft/models/$modelFolder
    done
  fi

  mkdir $folder/assets/arsenal/models/

  for modelFolder in "${modelFolders[@]}"
  do
    if [[ ! -d "models/arsenall/$modelFolder" ]]; then 
      continue
    fi

    mkdir $folder/assets/arsenal/models/$modelFolder
    cp -rfv models/arsenall/$modelFolder/* $folder/assets/arsenal/models/$modelFolder
  done

  mkdir $folder/assets/arsenal/lang
  cp -rfv lang/* $folder/assets/arsenal/lang/
done

echo "Zipping..."
(cd mod && zip -r ../Arsenal-Mod.zip .)
(cd bukkit && zip -r ../Arsenal-Bukkit.zip .)

exit 127

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