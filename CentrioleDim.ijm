showMessage("click on *OK* to choose input folder");
dir1 = getDirectory("choose input folder"); // Choose the folder with base images
print(dir1);

// Choisir le dossier où enregistrer le fichier CSV
showMessage("Click on *OK* to choose output folder for CSV");
outputDir = getDirectory("Choose output folder for CSV");  // Choisir le dossier où enregistrer le fichier CSV

print(outputDir);

protnumber = getNumber("How many prot to quantify ?", 1);

options = newArray( "1", "2", "3", "4", "5", "none");

Dialog.create("Choose prot channel");
Dialog.addMessage("Choose prot channel");
Dialog.addChoice("Tubulin channel", options, options[5]);
for (k = 0; k < protnumber ; k++) {
Dialog.addChoice("prot"+ (k + 1) + "channel", options, options[5]);
}
Dialog.show();
                   
channelprot = newArray();
channelprot[0] = Dialog.getChoice();
for (k = 1; k <= protnumber ; k++) {
channelprot[k] = Dialog.getChoice();
}

// Définir le chemin du fichier CSV dans le dossier choisi
filePath = outputDir + "resultats.csv";  // Nom du fichier CSV

// Ouvrir ou créer le fichier CSV
csvContent = "";
if (File.exists(filePath)) {
    // Si le fichier existe, ne pas ajouter l'en-tête, on va juste ajouter les nouvelles données à la fin
    csvContent = File.openAsString(filePath);
} else {
    // Si le fichier n'existe pas, on crée l'en-tête avec les noms de colonnes
csvContent = "Imagename,tub-start,tub-end";
   for (k = 0; k < protnumber ; k++) {
        csvContent += ",prot" + (k + 1) + "-start,prot" + (k + 1) + "-end";
}
   csvContent += "\n"; 
}

list1 = getFileList(dir1);

// Définir une liste d'images à traiter
for (i=0; i<list1.length; i++){
    if (endsWith(list1[i], ".tif")) {
      run("Close All");
      open(dir1 + list1[i]);

imageName = getTitle();

        if (imageName.contains("SVCC")){
close();
continue;
}       
         getDimensions(width, height, channels, slices, frames);
        // Resize the image
        run("Canvas Size...", "width=" + width*6 +" height=" + width*6 +" position=Center zero");
        // Scale the image
        run("Scale...", "x=6 y=6 z=1.0 interpolation=Bilinear average" );
        run("Set Scale...", "known=" + 1/6 +" pixel=1");
        
        
        run("Clear Results");
        // Tracer la ligne sur l'image
        
        savetitle = replace(imageName, ".tif", "");        

        setTool("line");
        waitForUser("Tracez une ligne sur l'image et appuyez sur OK");

type = selectionType();
  if (type==-1){
            print("Aucune ligne tracée");
            continue;  // Skip this image if no line is drawn or ROI is not a line
        }

csvContent += savetitle;

for (k = 0; k <= protnumber ; k++) {
run("Clear Results");
setSlice(channelprot[k]);
selectImage(imageName); 
        run("Plot Profile");

        setTool("multipoint");
        // Demander à l'utilisateur de sélectionner deux points sur le profil
         waitForUser("Veuillez positionner deux points sur le profil et appuyez sur OK.\nPour supprimer les points, appuyez sur Shift + A.");

do {
    run("Measure");
    
    if (nResults() == 2) {
        x1 = getResult("X", 0);
        x2 = getResult("X", 1);
    } else {
        x1 = NaN;
        x2 = NaN;
    }

    if (isNaN(x1) || isNaN(x2)) {
        print("Un ou plusieurs points sont invalides pour l'image: " + imageName);
        run("Select None");
        run("Clear Results");
        waitForUser("Un ou plusieurs points sont invalides pour l'image\nVeuillez positionner deux points sur le profil et appuyez sur OK.\nPour supprimer les points, appuyez sur Shift + A.");
    }
    
} while (isNaN(x1) || isNaN(x2));


        print(imageName);
        print(x1);
        print(x2);

        // Organiser les résultats sous forme horizontale et les ajouter à la variable csvContent
        csvContent += ", " + x1 + ", " + x2;  // Valeurs sur une seule ligne
        close;
    
}
csvContent += "\n";
File.saveString(csvContent, filePath);
run("Close All");
}
}
// Enregistrer les résultats dans le fichier CSV (ajout à la fin du fichier)
File.saveString(csvContent, filePath);

run("Clear Results");
run("Close All");