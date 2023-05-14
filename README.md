# DeepLabCut to predict stroke on mice
The codes utilized for processing and analyzing data obtained from DeepLabCut (https://github.com/DeepLabCut/DeepLabCut) are stored in this repository. They calculate 20 behavioral parameters of mice, computed from recordings of the tape removal test in the laboratory.
There are 3 folders based on 3 main steps:
## 01_Features: 
Process raw data from 2 DeepLabCut, one that gets the coordinates of the mouse box, and the second that estimates the position of several body parts of the mouse (nose, neck, bottom, the four paws, middle tail point, end tail point, and the sticker from the tape removal test). After processing, mouse's behavioural variables are extracted: distance travelled, moving time, mean velocity of the nose, bottom, the four paws, and end tail, mean velocity when moving, mean distance between front paws, between hind paws, and from the bottom to the neck, also fraction of frame with the tail and body turn to each side. Time to remove the sticker is also measured.
## 02_Analyses:
One-way ANOVA test is computed for the variables extracted, and a stroke prediction model based on significant features is built based on multivariate binomial regression using backaward selection technique. Codes contain also the adjustment of a prediction model based on hand-made measured paramateres.
## 03_Reporting:
Generate figures to visualize results.
