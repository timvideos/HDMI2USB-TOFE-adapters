#!/bin/bash

set -x
set -e

if git diff-index --quiet HEAD --; then
	echo "Clean repo, good!"
else
	echo "Dirty repo, commit before running."
	exit 1
fi

VERSION=$(git describe --long)

echo "Current version: $VERSION"

# Work out the next version
OUTDIR=gerbers/$VERSION/
mkdir $OUTDIR

# Update the version embedded in the PCB
sed -e"s/(gr_text [\$]Desc[\$]/(gr_text \"$VERSION\"/" --in-place=.bak TOFEAdapter.kicad_pcb

# Generate the gerber files
python ../third_party/gen_gerber_and_drill_files_board.py TOFEAdapter.kicad_pcb $OUTDIR/
git add $OUTDIR/*

git commit -m "Creating gerbers $VERSION for male-to-male"

cd $OUTDIR/
ZIP="male-to-male-$VERSION.zip"
zip -r ../$ZIP .

cd ..; md5sum $ZIP

git reset --hard

exit 0
