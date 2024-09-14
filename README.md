This is an Autohotkey script designed to assist with modding work, locating field triangles & help speed up sthe cripting work adding dynamic footstep to FF8.

This script was written for Autohotkey v2. See https://autohotkey.com/v2/

Imageput by Edison Hua (iseahound): https://github.com/iseahound/ImagePut

Deling Final Fantasy VIII field archive editor: https://github.com/myst6re/deling/

Inspired by the amazing modding work being done by the Tsunamods teams: https://www.tsunamods.com/

Run "Start FF8 Step Triangulator.cmd" to start!


Triangle Steps text creator:

1. Enter the Field file name under "Field Name". 
2. Use the dropdown list to the right to select the Step Sounds you need.
3. Enter the triangle numbers required under "Triagle Numbers" separated by commas or spaces.
4. Output should automatically update as you enter data.
5. Click the "Copy to clipboard" button to save the output to the clipboard. 


Deling triangle locator:

While running, FF8 Step Triangulator adds a hotkey for Deling. 
Ctrl+Click on a walkmesth triangle will try to locate the triangle number using a brute-force color match search in that area.

1. Start Deling (tested with v0.12.0) and open the FF8 "field.fs" file located in the directory "\Data\lang-en".
2. Select the Walkmesh tab at the top of Deling. 
3. Switch to the Walkmesh tab in the bottom section of Deling to display the Triangles list. 
4. Hold Ctrl and Click on one of the lines or intersections of the triangle you want to find. 
5. The macro will jump to the last triangle in the list, then scan UP until it (hopefully) finds a pixel of the "selected triangle" color near the mouse.
6. If a colored triangle is located, the triangle number will be added to your FF8 Step Triangulator Triangles list and saved to the clipboard.
