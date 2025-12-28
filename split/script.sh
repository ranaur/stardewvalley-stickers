#!/bin/bash
#DATABASE="$(readlink -f "$(dirname "${BASH_SOURCE[0]}")../Content\ \(unpacked\)/")"
OUTPUT_DIR="$(readlink -f "$(dirname "${BASH_SOURCE[0]}")/images/")"
GEOMETRIES="$(readlink -f "$(dirname "${BASH_SOURCE[0]}")/geometries.txt")"
INPUT="$1"
pathname="$(dirname -- "$INPUT")"
filename="$(basename -- "$INPUT")"
extension="${filename##*.}"
filename="${filename%.*}"
OUTPUT="$OUTPUT_DIR/$filename/$filename-%02d.$extension"

if [ -z "$2" ] ; then
    LOOKUP="$(grep "^$filename:" "$GEOMETRIES")"
    if [ ! -z "$LOOKUP" ] ; then
        GEOMETRY=${LOOKUP##*:}@
    else
        width=$(identify -ping -format '%w' "$INPUT")
        height=$(identify -ping -format '%h' "$INPUT")

        w=0
        [ $(( width % 64 )) = 0 ] && w=64
        [ $(( width % 32 )) = 0 ] && w=32
        [ $(( width % 16 )) = 0 ] && w=16
        h=0
        [ $(( height % 64 )) = 0 ] && h=64
        [ $(( height % 32 )) = 0 ] && h=32
        [ $(( height % 16 )) = 0 ] && h=16

        min=$((w<h ? w : h))

        if [ $min = 0 ] ; then
            echo Cannot infer image from size $width X $height
            exit 0
        fi

        GEOMETRY=$((width / min))X$((height / min))
        echo $filename:$GEOMETRY >> "$GEOMETRIES"
    fi
else
    GEOMETRY="$2"
fi
[ ! -d "$(dirname $OUTPUT)" ] && mkdir -p "$(dirname $OUTPUT)"

convert "$INPUT" +repage -crop "$GEOMETRY@" +repage "$OUTPUT"
