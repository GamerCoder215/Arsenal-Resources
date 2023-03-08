# Checkout GIT
git config user.name github-actions[bot]
git config user.email 41898282+github-actions[bot]@users.noreply.github.com
git fetch origin download
git checkout download

# Build ZIP
echo "Building ZIP..."

folders=( bukkit mod )

for folder in "${folders[@]}" 
do
  mkdir $folder

  cp -rfv pack.mcmeta pack.png LICENSE README.md $folder/
  cp -rfv "textures/*" $folder/assets/arsenal/textures/

#   if [[ "$folder" == *"bukkit"* ]]; then
#     mkdir $folder/assets/minecraft/
#     cp -rfv models/minecraft/* $folder/assets/minecraft/models/
#   fi

#   cp -rfv models/arsenal/* $folder/assets/arsenal/models/
done

cp -rfv lang/* mod/assets/arsenal/lang/

zip -r Arsenal-Mod.zip mod
zip -r Arsenal-Bukkit.zip bukkit

echo "Removing Unused Files..."
# Remove Unused Files
shopt -s extglob
rm -rfv !(*.zip)

echo "Creating Hashes..."
# Create ZIP Hashes
MOD_HASH=$(sha1sum Arsenal-Mod.zip | cut -d ' ' -f 1)
BUKKIT_HASH=$(sha1sum Arsenal-Bukkit.zip | cut -d ' ' -f 1)

echo "$MOD_HASH" > Arsenal-Mod.zip.sha1
echo "$BUKKIT_HASH" > Arsenal-Bukkit.zip.sha1

echo "Committing..."
# Commit ZIP

git add ./

git branch -D download
git branch -m download
git commit -m "Update Resource Pack ($1)" -a
git push -f origin download

echo "Done!"