# Sound-to-Speech Processing

This repository demonstrates **speech segmentation and annotation** using Praat scripts.  

It includes:
- Raw audio files
- Scripts to generate **TextGrid annotations** from sound
- Scripts to split audio into smaller chunks using TextGrid
- Example segmented outputs (audio + logs)

---

## Project Structure
- `audio/` → raw speech audio files  
  - `lei0M0rin0Tang1.wav`  
- `output/` → segmentation results  
  - `lei0M0rin0Tang1_SegmentData/` → segmented audio files  
  - `lei0M0rin0Tang1.TextGrid` → TextGrid annotation of the segmented audio  
  - `segmentation.txt` → text log of the segmentation process  
- `segmented_file/` → intermediate files (during processing)  
- `praat_scripts/` → Praat scripts  
  - `Data_spliter_based on textgrid.praat`  
  - `Generate_textgrid_from_sound.praat`

---

## Usage

### 1. Generate TextGrid
- Open **Praat**
- Run `praat_scripts/Generate_textgrid_from_sound.praat`  
- Input: `audio/lei0M0rin0Tang1.wav`  
- Output: `output/lei0M0rin0Tang1.TextGrid`  

### 2. Split Audio Using TextGrid
- Run `praat_scripts/Data_spliter_based on textgrid.praat`  
- Input: `audio/lei0M0rin0Tang1.wav` + `output/lei0M0rin0Tang1.TextGrid`  
- Output:  
  - Segmented audio files → `output/lei0M0rin0Tang1_SegmentData/`  
  - Segmentation log → `output/segmentation.txt`  

---

## Example
- **Input Audio**: `audio/lei0M0rin0Tang1.wav`  
- **Generated TextGrid**: `output/lei0M0rin0Tang1.TextGrid`  
- **Segmented Output Files**: `output/lei0M0rin0Tang1_SegmentData/`  
- **Segmentation Log**: `output/segmentation.txt`  

---

## Requirements
- [Praat](https://www.fon.hum.uva.nl/praat/)  

(Optional Python tools for future work:)  
- `praatio` (to parse TextGrid)  
- `librosa` (to analyze audio features)  
- `matplotlib` (for visualization)

---

## License
MIT License
