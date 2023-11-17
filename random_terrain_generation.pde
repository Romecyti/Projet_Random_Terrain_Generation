//mettre commentaire pour indiquer par qui et pourquoi ce programme a été écrit
/*
*********************************************************************************************************
*                       auteurs : Ricoux Julie et Marchand Célestin                                     *
*                           date : 06/05/2023 (06 May 2023)                                             *
*                                                                                                       *
*               Ce programme à été écrit dans le cadre d'un cours de synthèse d'images                  *
*       et plus particulièrement dans sa partie modélisation présentée par monsieur TERRAZ Olivier.     *
*                                                                                                       *
*             Ce programme s'appuie sur la vidéo de la chaîne youtube "The Coding Train"                *
*                 sur la génération de terrain aléatoire grâce au "Perlin Noise"                        *
*                     lien : https://www.youtube.com/watch?v=IKB1hWWedMk                                *
*                                                                                                       *
*********************************************************************************************************
*/


//                                          !!!!!!!!!!!!!
//    Pour modifier la taille du terrain, il suffit de modifier les paramètres directement dans la classe parametre ci-dessous
//                De la même manière les paramètres modifiant le programme se trouvent dans cette clase

//Les lignes suivantes indiquent quelles touches utiliser lorsque l'application est lancé
/*
// affichage du texte : 
  touche 'H' : affiche/cache le texte affiché à l'écran

// gestion du terrain :
  touche 'R' : (raffiner) augmente le nombre de sommets du terrain en créant des sommets interpollé entre ceux existant déjà
  touche 'U' : (rustifier) réduit le nombre de sommets du terrain en enlevant 1 sommets sur 2 (ne peut être fait uniquement si le terrain a déjà été raffiné)

// affichage des différentes scènes : (faisable aussi grâce au checkbox disponnible dans l'application)
  touche '&' ou '1' : scène n°1 = affichage du terrain sans lumière ni couleur particulière
  touche 'é' ou '2' : scène n°2 = affichage du terrain avec une lumière plus les normales aux sommets (couleur fixe)
  touche '"' ou '3' : scène n°3 = affichage du terrain avec une lumière plus les normales aux sommets (couleur variant selon la direction de la normale)
  touche ''' ou '4' : scène n°4 = affichage du terrain stylisé en un paysage avec une couleur dépendant de la hauteur du sommet 

// gestion de l'animation :
  click droit de la souris  : pause/reprise du mouvement du terrain
  barre espace              : déplace le terrain d'un pas vers l'avant
  ctrl + barre espace       : déplace le terrain d'un pas vers l'arrière
  molette avant             : effectue un zoom vers l'avant (dirigé vers le centre du terrain)
  molette arrière           : effectue un zoom vers l'arrière (dirigé depuis le centre du terrain)
  click droit et déplacement 
    de la souris simultané  : effectue une rotation de la scène selon la direction dans laquelle la souris est déplacée

// gestion de l'affichage dite du "landscape" : (visible et utilisable uniquement dans la scène 4)
  touche '(' ou '5' : pause/reprise du cycle jour/nuit
  touche 'UP'       : augmente la distance de l'objet céleste par rapport au terrain affiché (de 10% de la distance actuelle)
  touche 'DOWN'     : réduit la distance de l'objet céleste par rapport au terrain affiché (de 10% de la distance actuelle)
  touche 'RIGHT'    : augmente la rapidité du cycle jour/nuit (de 10% de la vitesse actuelle)
  touche 'LEFT'     : réduit la rapidité du cycle jour/nuit (de 10% de la vitesse actuelle)

*/


//class parametre pour centraliser les options
class Parametre{

//variable pouvant être modifiées pour changer l'aspect de la simulation
  //variable de taille du terrain
  int cols = 200, rows = 200; //ces nombres régissent la taille du terrain affiché à l'écran
  int scale = 20; //ce nombre indique la distance entre deux points d'une même ligne ou d'une même colonne

  //variable de génération de la hauteur du terrain
  float mappingBas = -150; //variable indiquant la hauteur minimum qu'un point peut atteindre
  float mappingHaut = 150; //variable indiquant la hauteur maximum qu'un point peut atteindre

  //variable permettant de simuler le déplacement dans le temps
  float xoffstep = 0.07; //pas dans l'axe Y utilisé pour générer le terrain
  float yoffstep = 0.07; //pas dans l'axe Y utilisé pour générer le terrain 


//variable a ne pas modifier 
  float max_dezoom; 
  int widthMap; //indication de la largeur réelle du terrain
  int heightMap; //indication de la longueur réelle du terrain
  float flying_step; //pas utilisé pour faire avancer le terrain 
  float flying = 0; //indication de ou le pas est rendu dans la simulation
  boolean stopFlying = false; //variable qui indique si la simulation avance ou non
  float zoom=1.0; //variable retenant le zoom actuel
  float rotationZ=0; //variable retenant la rotation en Z actuelle
  float rotationX=0; //variable retenant la rotation en X actuelle


  Parametre(){
    heightMap = cols*scale;
    widthMap = rows*scale;
  }

}

//Classe permettant de créer un brin, prennant en paramètre les coordonnées x, y et z du brin
class Brin{
  float _x,_y,_z;
  ArrayList<Segment> _segment; //tableau de pointeur vers les segments auxquels le point appartient
  Brin(float p_x, float p_y, float p_z){
    _x = p_x;
    _y = p_y;
    _z = p_z;
    _segment  = new ArrayList<Segment>();
  } 
}

//Classe permettant de créer un segment, prennant en paramètre deux brins
class Segment{
  Brin _b1;
  Brin _b2;
  ArrayList<Face> _face; //tableau de pointeur vers les faces auxquelles le segments appartient
  Segment(Brin p_b1, Brin p_b2){
    _b1 = p_b1;
    _b2 = p_b2;
    if(! _b1._segment.contains(this)){
      _b1._segment.add(this);
    }
    if(! _b2._segment.contains(this)){
      _b2._segment.add(this);
    }
    _face = new ArrayList<Face>();
  } 
}

//Classe permettant de créer une face, prennant en paramètre une liste de segments
class Face{
  ArrayList<Segment> _segments; //liste des segment appartenant à une face
  Face(ArrayList<Segment> p_segments) {
    _segments = p_segments;
    for (int i = 0; i < _segments.size(); i++) {
      if(! _segments.get(i)._face.contains(this)){
         _segments.get(i)._face.add(this);
      }
    }
  } 
}

//Classe G2card permettant de créer une 2G carte du terrain
class G2cardTriangulaire{
  //Liste de brins composants la 2G carte
  ArrayList<Brin> _brins = new ArrayList<Brin>();
  //Liste de faces composants la 2G carte (ici des triangles)
  ArrayList<Face> _faces = new ArrayList<Face>();
  //Paramètres du terrain
  Parametre _param;
  //Nombre de fois que le terrain a été raffiné
  int _indiceRaffinnage;

  //Constructeur de la 2G carte
  G2cardTriangulaire(Parametre p_param){
    _param = p_param;
    _indiceRaffinnage = 0;
    
    //Création des brins
    _brins.ensureCapacity(_param.rows+1 * _param.cols+1);
    for (int column = 0; column < _param.cols+1; ++column) {
      for (int row = 0; row < _param.rows+1; ++row) {
        _brins.add(new Brin(row*_param.scale,
                            column*_param.scale, 
                            map(noise(row* _param.xoffstep, column*_param.yoffstep+ _param.flying),0,1,_param.mappingBas,_param.mappingHaut)));
      }
    }

    creationFaces();
  }
  
  //Création des faces de la 2G carte
  private void creationFaces() {
    //Création des segments composants chaque faces
    Segment[] segments = new Segment[_param.rows * _param.cols * 6];
    int idSegment = 0;
    for (int column = 0; column < _param.cols; ++column) {
      for (int row = 0; row < _param.rows; ++row) {
        if(column > 0)
        {
          //On récupère le segment de la face de la colonne précédente afin de ne pas recréer un segment déjà existant
          segments[idSegment] = segments[idSegment - 6*_param.rows + 4];
        }
        else{
          segments[idSegment] = new Segment(_brins.get(row), _brins.get(row +1));
        }

        segments[idSegment+1] = new Segment(_brins.get(row + 1 + column * _param.rows + column), _brins.get(row + 1 + (column + 1) * _param.rows + (column + 1)));
        segments[idSegment+2] = new Segment(_brins.get(row + 1 + (column + 1) * _param.rows + (column + 1)), _brins.get(row + column * _param.rows + column));
        
        if(row > 0)
        {
          //On récupère le segment de la face de la ligne précédente afin de ne pas recréer un segment déjà existant
          segments[idSegment+3] = segments[idSegment - 5];
        }
        else{
          segments[idSegment+3] = new Segment( _brins.get(column * _param.rows + column), _brins.get((column + 1) * _param.rows + (column + 1))); 
        }
        
        segments[idSegment+4] = new Segment(_brins.get(row + (column + 1) * _param.rows + (column + 1)), _brins.get(row + 1 + (column + 1) * _param.rows + (column + 1)));
        segments[idSegment+5] = segments[idSegment+2];
        idSegment += 6;
      }
    }
  
    //Création des faces de la 2G carte
    _faces = new ArrayList<Face>();
    idSegment = 0;
    for(int i = 0; i < (_param.rows) * ((_param.cols) * 2); i++){
      ArrayList<Segment> faceSegments = new ArrayList<Segment>();
      faceSegments.add(segments[idSegment]);
      faceSegments.add(segments[idSegment+1]);
      faceSegments.add(segments[idSegment+2]); 
      
      _faces.add(new Face(faceSegments));
      idSegment += 3;
    }
  }

  //Mise à jour du z de tous les brins (selon le paramètre flying actuel)
  void updateBrin(){
    for(Brin b : _brins){
      b._z = map(noise((b._x/_param.scale)* _param.xoffstep, (b._y/_param.scale)*_param.yoffstep+ _param.flying),0,1,_param.mappingBas,_param.mappingHaut);
    }
  }

  //Fonction de raffinage de la 2G carte
  void raffiner(){
    //On recréait tous les brins (méthode brute)
    ArrayList<Brin> brins = new ArrayList<Brin>();
    
    int j;
    int i;
    for (j = 0; j < _param.cols; j++) {
      //première ligne de la face, avec ajout des nouveaux brins interpollés
      for (i= 0; i < _param.rows; i++) {
        brins.add(new Brin(_brins.get(j*(_param.rows+1)+i)._x,_brins.get(j*(_param.rows+1)+i)._y,_brins.get(j*(_param.rows+1)+i)._z));
        brins.add(new Brin(
          (_brins.get(j*(_param.rows+1)+ i)._x+_brins.get(j*(_param.rows+1)+ i+1)._x)/2.0,
          (_brins.get(j*(_param.rows+1)+ i)._y+_brins.get(j*(_param.rows+1)+ i+1)._y)/2.0,
          (_brins.get(j*(_param.rows+1)+ i)._z+_brins.get(j*(_param.rows+1)+ i+1)._z)/2.0));  //interpollation entre le point x et x+1  
      }
      brins.add(new Brin(_brins.get(j*(_param.rows+1)+i)._x,_brins.get(j*(_param.rows+1)+i)._y,_brins.get(j*(_param.rows+1)+i)._z)); //dernier point de la ligne
      
      //ligne centrale de la face
      for (i = 0; i < _param.rows; i++) {
          brins.add(new Brin(
          (_brins.get(j*(_param.rows+1)+ i)._x+_brins.get((j+1)*(_param.rows+1) + i)._x)/2.0,
          (_brins.get(j*(_param.rows+1)+ i)._y+_brins.get((j+1)*(_param.rows+1) + i)._y)/2.0,
          (_brins.get(j*(_param.rows+1)+ i)._z+_brins.get((j+1)*(_param.rows+1) + i)._z)/2.0));//interpollation entre le point j et j+1  

        brins.add(new Brin(
          (_brins.get(j*(_param.rows+1)+ i)._x+_brins.get((j+1)*(_param.rows+1) + i+1)._x)/2.0,
          (_brins.get(j*(_param.rows+1)+ i)._y+_brins.get((j+1)*(_param.rows+1) + i+1)._y)/2.0,
          (_brins.get(j*(_param.rows+1)+ i)._z+_brins.get((j+1)*(_param.rows+1) + i+1)._z)/2.0)); //interpollation entre les 2 point de la diagonale
      }
      brins.add(new Brin(
        (_brins.get(j*(_param.rows+1)+ i)._x+_brins.get((j+1)*(_param.rows+1)+ i)._x)/2.0,
        (_brins.get(j*(_param.rows+1)+ i)._y+_brins.get((j+1)*(_param.rows+1)+ i)._y)/2.0,
        (_brins.get(j*(_param.rows+1)+ i)._z+_brins.get((j+1)*(_param.rows+1)+ i)._z)/2.0));//dernier point de la ligne interpollé entre le point j et j+1  
    }

    //dernière ligne de la 2G carte
    for (i= 0; i < _param.rows; i++) {
      brins.add(new Brin(_brins.get(j*(_param.rows+1)+i)._x,_brins.get(j*(_param.rows+1)+i)._y,_brins.get(j*(_param.rows+1)+i)._z));
      brins.add(new Brin(
        (_brins.get(j*(_param.rows+1)+i)._x+_brins.get(j*(_param.rows+1)+ i+1)._x)/2.0,
        (_brins.get(j*(_param.rows+1)+i)._y+_brins.get(j*(_param.rows+1)+ i+1)._y)/2.0,
        (_brins.get(j*(_param.rows+1)+i)._z+_brins.get(j*(_param.rows+1)+ i+1)._z)/2.0));//interpollation entre le point x et x+1  
    }
    brins.add(new Brin(_brins.get(j*(_param.rows+1)+i)._x,_brins.get(j*(_param.rows+1)+i)._y,_brins.get(j*(_param.rows+1)+i)._z)); //dernier point de la ligne
    
    //Modification du nombre de ligne et de colonnes
    _param.rows = _param.rows *2;
    _param.cols = _param.cols *2;
    _brins = brins; //on enregistre la nouvelle liste des brins 

    //Recréation des faces
    creationFaces();

    _indiceRaffinnage ++; //on indique que l'on a raffiné une fois de plus
  }

  //Fonction de rustification (inverse du raffinage) de la 2G carte
  void rustifier(){
    //On ne fait rien si la 2G carte n'a pas été raffinée avant
    if(!(_indiceRaffinnage <= 0)){
      
      //On récupère un brin sur deux
      ArrayList<Brin> brins = new ArrayList<Brin>((_param.rows*2-1)*(_param.cols*2-1));
      for (int j = 0; j <= _param.cols; j +=2) {
        for (int i = 0; i <= _param.rows; i +=2) {
          brins.add(_brins.get(j*_param.rows + j+i));
        }
      }

      //Modification du nombre de ligne et de colonnes
      _param.rows = _param.rows/2;
      _param.cols = _param.cols/2;

      _brins = brins; //on enregistre la nouvelle liste des brins 
      
      //Recréation des faces
      creationFaces();

      _indiceRaffinnage --; //on indique que l'on enlevé une étape de raffinage
    }
  }

  //Calcul de la normale de la face (on considère toute face des triangles)
  private PVector NormalofSurface(Face p_face) {
    //on récupère le premier vecteur
    PVector cote1 = new PVector(p_face._segments.get(0)._b1._x - p_face._segments.get(0)._b2._x,
                              p_face._segments.get(0)._b1._y - p_face._segments.get(0)._b2._y, 
                              p_face._segments.get(0)._b1._z - p_face._segments.get(0)._b2._z);
    cote1.normalize();

    //on récupère le deuxième vecteur
    PVector cote2 = new PVector(p_face._segments.get(1)._b2._x - p_face._segments.get(1)._b1._x,
                              p_face._segments.get(1)._b2._y - p_face._segments.get(1)._b1._y, 
                              p_face._segments.get(1)._b2._z - p_face._segments.get(1)._b1._z);
    cote2.normalize();

    //on calcule ensuite le vecteur normal au deux vecteurs de la surface
    return cote1.cross(cote2) ;
  }

  //Calcul de la normale du sommet
  private PVector normalOfSommet(Brin p_b) {

    ArrayList<Face> facesList = new ArrayList<Face>();
    
    //On récupère toutes les faces liées au sommet
    for(Segment seg : p_b._segment){
      for(Face fa : seg._face)
        if(!facesList.contains(fa))
          facesList.add(fa);
    }

    PVector result = new PVector(0.0,0.0,0.0);
    PVector direction = new PVector(0,0,-1);
    //On récupère la normale de toutes les faces liées au sommet
    for(Face fa : facesList) {
      //Calcul de la normale de la face
      PVector normalFace = NormalofSurface(fa);

      //On inverse la normale si elle n'est pas dirigée vers l'axe z (vers la caméra) 
      float dotresult = direction.dot(normalFace);  
      if(dotresult >= 0.0){
        normalFace = new PVector(-normalFace.x, -normalFace.y, -normalFace.z);
      }

      //On l'ajoute aux autres normales
      result.add(normalFace);
    }

    result.normalize(); 
    return result;
  }

  //affichage du terrain basique avec ou sans bordure (couleur des bordure à définir avant)
  void draw(PVector p_fillColor, boolean stroke){
    fill(p_fillColor.x,p_fillColor.y,p_fillColor.z);
    if(!stroke){
      noStroke();
    }
    for(Face face : _faces){
      beginShape(TRIANGLE_STRIP);
      for(Segment segment : face._segments)
      {
        vertex(segment._b1._x, segment._b1._y, segment._b1._z);
      }
      endShape();
    }    
  }

  //Affichage du terrain basique avec bordure des faces
  void drawWithStroke(PVector p_fillColor, PVector p_strokeColor){
    stroke(p_strokeColor.x,p_strokeColor.y,p_strokeColor.z);
    draw(p_fillColor, true);
  }

  //Affichage du terrain avec les normales ayant une couleur fixe
  void drawNormaleWithFixedColor(PVector p_fillColor, PVector p_normalFixedColor){
    pointLight(51, 102, 126, 140, 160, 144);
    draw(p_fillColor, false);


    for(Face face : _faces){
      for(Segment segment : face._segments)
      {
        //Calcul de la normale du brin
        PVector normalSommet = normalOfSommet(segment._b1);
        
        stroke(p_normalFixedColor.x, p_normalFixedColor.y, p_normalFixedColor.z);
        //affichage de la normale par une simple ligne de longueur 10
        line(segment._b1._x, segment._b1._y, segment._b1._z, segment._b1._x+normalSommet.x*10, segment._b1._y+normalSommet.y*10, segment._b1._z+normalSommet.z*10);
      }
    }    
  }

  //Affichage du terrain avec les normales ayant une couleur basée sur leur valeur
  void drawNormale(PVector p_fillColor){
    pointLight(51, 102, 126, 140, 160, 144);
    draw(p_fillColor, false);

    for(Face face : _faces){
      for(Segment segment : face._segments)
      {
        //Calcul de la normale du brin
        PVector normalSommet = normalOfSommet(segment._b1);
        //calcule de la couleur de la normale selon celle-ci
        PVector corlorNormal = normalSommet.copy();
        corlorNormal.x = abs(corlorNormal.x);
        corlorNormal.y = abs(corlorNormal.y);
        corlorNormal.z = abs(corlorNormal.z);
        
        stroke(corlorNormal.x*255,corlorNormal.y*255,corlorNormal.z * 255);
        line(segment._b1._x, segment._b1._y, segment._b1._z, segment._b1._x+normalSommet.x*10, segment._b1._y+normalSommet.y*10, segment._b1._z+normalSommet.z*10);
      }
    }    
  }

  //fonction qui map la position en z vers une couleur pour un rendu de type paysage
  private PVector colorFromPosition(float p_z) {
    PVector colorz = new PVector(255,0,0);

    //du bleu (abysse)
    PVector abbysseColor = new PVector(19,24,52);
    //du bleu (rivière)
    PVector riviereColor = new PVector(61,85,134);
    //du jaune/beige (sable)
    PVector sableColor = new PVector(225,198,153);
    //du marron (terre)
    PVector terreColor = new PVector(118,85,43);
    //du vert (arbre)
    PVector arbreColor = new PVector(13,91,40);
    //du gris (montagne)
    PVector montagneColor = new PVector(110,110,110);
    //du blanc (neige)
    PVector neigeColor = new PVector(255,255,255);

    //calcule du pourcentage (appartenance du point à une catégorie)
    float mappingpoint = abs(p_z+ abs(_param.mappingBas));
    float totalmapping = abs(_param.mappingBas) + abs(_param.mappingHaut);
    float pourcent = mappingpoint/totalmapping*100.0;

    //tout calcule avec transition et couleur pleine
    if (pourcent <= 20.0) {           // cas abysse
      colorz = new PVector(abbysseColor.x,abbysseColor.y, abbysseColor.z);

    }else if (pourcent <= 25.0) {     // cas transition abysse et eaux-basse
      float indice = (pourcent-20.0)/5.0;
      colorz = new PVector((1-indice)*abbysseColor.x+indice*riviereColor.x,
                                (1-indice)*abbysseColor.y+indice*riviereColor.y,
                                (1-indice)*abbysseColor.z+indice*riviereColor.z);
    }else if (pourcent <= 30.0) {     // cas rivière
      colorz = new PVector(riviereColor.x,riviereColor.y, riviereColor.z);
    }else if (pourcent <= 32.5) {     // cas transition eaux-basse et sable
      float indice = (pourcent-30.0)/2.5;
      colorz = new PVector((1-indice)*riviereColor.x+indice*sableColor.x,
                                (1-indice)*riviereColor.y+indice*sableColor.y,
                                (1-indice)*riviereColor.z+indice*sableColor.z);
    }
    /*
    else if (pourcent <= 35.0) {     // cas sable (enlever car est trop grand)
      colorz = new PVector(sableColor.x,sableColor.y, sableColor.z);
    }*/
    else if (pourcent <= 35.0) {     // cas transition sable et terre
      float indice = (pourcent-32.5)/2.5;
      colorz = new PVector((1-indice)*sableColor.x+indice*terreColor.x,
                                (1-indice)*sableColor.y+indice*terreColor.y,
                                (1-indice)*sableColor.z+indice*terreColor.z);
    }else if (pourcent <= 37.5) {     // cas terre
      colorz = new PVector(terreColor.x,terreColor.y, terreColor.z);
    }else if (pourcent <= 42.5) {       // cas transition terre et arbre
      float indice = (pourcent-37.5)/5.0;
      colorz = new PVector((1-indice)*terreColor.x+indice*arbreColor.x,
                                (1-indice)*terreColor.y+indice*arbreColor.y,
                                (1-indice)*terreColor.z+indice*arbreColor.z);
    }else if (pourcent <= 55.0) {     // cas arbre
      colorz = new PVector(arbreColor.x,arbreColor.y, arbreColor.z);
    }else if (pourcent <= 60.0) {       // cas transition arbre et montagne
      float indice = (pourcent-55.0)/5.0;
      colorz = new PVector((1-indice)*arbreColor.x+indice*montagneColor.x,
                                (1-indice)*arbreColor.y+indice*montagneColor.y,
                                (1-indice)*arbreColor.z+indice*montagneColor.z);
    }else if (pourcent <= 70.0) {     // cas montagne
      colorz = new PVector(montagneColor.x,montagneColor.y, montagneColor.z);
    }else{// (pourcent <= 100.0)      //cas neige (pas de transition pour avoir un meilleur effet)
      colorz = neigeColor;
    }

    return colorz;
  }

  //Affichage du terrain en mode paysage
  void drawLandscape(){
    noStroke();
    for(Face face : _faces){
      beginShape(TRIANGLE_STRIP);
      for(Segment segment : face._segments)
      {
        //Calcul de la couleur suivant la hauteur du brin
        PVector colorz = colorFromPosition(segment._b1._z);
        fill(colorz.x,colorz.y,colorz.z);
        vertex(segment._b1._x, segment._b1._y, segment._b1._z);
      }
      endShape();
    }    
  }

}

Parametre params = new Parametre();
G2cardTriangulaire g2Card;

// paramètres liés uniquement à l'affichage
int rectSize = 30;     // Size of rect
color rectColor;
color rectHighlight;
color rectSelectionne;
boolean[] rectOver = new boolean[5];
int sceneToDraw = 0;
String textes[] = new String[5];
boolean rightMouseClicked = false;
boolean controlDown = false;
boolean hideText = true;
PVector pointLightColor = new PVector(255,255,255);
PVector positionPointLight;

//paramètre liés à la simulation du cycle jour nuit pour le landscape
PVector dayColor = new PVector(150, 220, 255);
PVector nightColor = new PVector(0, 0, 50);
PVector sunRiseColor = new PVector(220, 150, 200);
int frameCountCycle = 0; //utile pour que le cycle jour nuit reprenne là où on là laissé
PVector skyColor = new PVector(0,0,0);
boolean cycleActivated = true;
float cycleSpeed = 1.0; //représente la vitesse du cycle jour/nuit
float cycleMaxSpeed = 10.0; //représente la vitesse maximum du cycle jour/nuit
float cycleMinSpeed = 0.1; //représente la vitesse minimum du cycle jour/nuit
float angleTheta = 0.0; //réprésente l'angle auquel l'objet du ciel doit être mis

PVector directionnalLightColorCycle = new PVector(255,255,255); //représentant lune ou soleil
PVector vecPositionSkyObject;
float radiusSkyObject;
float radiusMoon = 1;
float radiusSun = 1;
float distanceSkyObject; //représente la distance à laquelle l'objet se situe par rapport à la surface
float distanceMinSkyObject; //représente la distance minimum à laquelle l'objet peut se situe par rapport à la surface
float distanceMaxSkyObject; //représente la distance maximum à laquelle l'objet peut se situe par rapport à la surface

//fonction d'initialisation de l'application processing
void setup(){
  size(900,600, P3D); //taille de la fenêtre originale
  textMode(SHAPE); //permet de dessiner les lettres commes des objet et donc de ne pas avoir de carré noir autour
  params.flying_step = 0.1/frameRate; //on décrit le flying step pour correspondre au frame rate
  params.max_dezoom = min(20.0/(params.cols + params.rows),1.0); //détermine le dézoom max (max à 1 pour éviter les problèmes avec les petites structures)

  //affectation des divers paramêtres
  g2Card = new G2cardTriangulaire(params);
  rectColor = color(100);
  rectHighlight = color(200);
  rectSelectionne = color(255);

  positionPointLight= new PVector( width/2, height/2, 144);

  //calcule des paramètre pour le landscape (lumière)
  vecPositionSkyObject = new PVector( width/2, height/2, 144); //a refaire
  distanceMinSkyObject = (max(g2Card._param.mappingHaut,g2Card._param.widthMap))*0.5;
  distanceMaxSkyObject = (max(g2Card._param.mappingHaut,max(g2Card._param.heightMap,g2Card._param.widthMap)))*1.5;
  radiusMoon = (g2Card._param.widthMap+ g2Card._param.heightMap)/55.0;//faire calcule pour size l'objet selon la taille de la grille
  radiusSun = (g2Card._param.widthMap+ g2Card._param.heightMap)/40.0;//faire calcule pour size l'objet selon la taille de la grille
  
  radiusSkyObject = radiusSun;
  distanceSkyObject = distanceMinSkyObject;

  ellipseMode(CENTER);
  //création de quatres boutons permettant de changer entre les différents affichages possible pour le terrain 
  for (int i = 0; i < 5; i++)
  {
    rectOver[i] = false;
  }
  textes[0] = "Scene sans normales";
  textes[1] = "Scene avec normales et couleur fixe";
  textes[2] = "Scene avec normales et couleur de la normale";
  textes[3] = "Scene de paysage";
  textes[4] = "Cycle jour/nuit";
}

//fonction exécutée automatiquement par processing  pour générer chaque image
void draw(){

  update(mouseX, mouseY);
  
  updateCycleJourNuit();

  if(sceneToDraw == 3 ) {
    background(skyColor.x, skyColor.y, skyColor.z);
  }
  else{
    background(0, 0, 0);
  }
  
  affichageText();

  if(rightMouseClicked) //si la bouton droit de la souris est enfoncé, alors on calcule les différentes rotation à effectuer avec la caméra
  {
    //permet de faire la rotation autour du terrain en suivant le mouvement de la souris lorsque le click droit est pressé
    float distanceX = pmouseX - mouseX;
    float radiantenplusY = ((distanceX/(float)width)*540.0)*(3.14159/180);
    params.rotationZ += radiantenplusY;

    //permet de faire la rotation au-dessus du terrain en suivant le mouvement de la souris lorsque le click droit est pressé
    //  rotation entre(0 et 50)
    float distanceY = pmouseY - mouseY;
    float radiantenplusX = ((distanceY/(float)width)*120.0)*(3.14159/180);
    params.rotationX += radiantenplusX;
    //on clippe la valeur dans l'intervalle
    if (params.rotationX < -0.872665) {
      params.rotationX = -0.872665;
    }else if (params.rotationX > 0.436332) {
      params.rotationX = 0.436332;
    }
  }
  
  if (!params.stopFlying) { //si la simulation est en cours, alors on incrémente le paramêtre de vol (permettant de simuler la progression dans l'univers)
    g2Card._param.flying -= g2Card._param.flying_step;
    g2Card.updateBrin(); //on update les brins (points) de la G2card pour faire avancer la simulation
  }

  drawG2card();

}

//fonction qu se charge de l'affichage de la g2card selon les paramètres sélectionnés
void drawG2card(){
  if(sceneToDraw != 0 && sceneToDraw != 3)
  { //si la scene à afficher n'est pas la première ni la dernière(landscape), alors on place une lumière au dessus du terrain pour le styliser
    pointLight(pointLightColor.x, pointLightColor.y, pointLightColor.z, positionPointLight.x, positionPointLight.y, positionPointLight.z);
  }
  //lignes des transformations pour afficher le terrain au bon endroit selon les différentes rotations, déplacement
  translate(width/2.0, height/2.0);
  rotateX(PI/3.0+params.rotationX);
  rotateZ(params.rotationZ);
  scale(params.zoom,params.zoom,params.zoom); // utilise le zoom comme scale
  translate(-g2Card._param.widthMap/2.0, -g2Card._param.heightMap/2.0);
  
  //on dessine maintenant la G2card selon l'affichage désiré
  if(sceneToDraw == 0)
  { //scene avec juste les triangles pleins et les lignes les joignant
    g2Card.drawWithStroke(new PVector(255,255,255), new PVector(255,0,0));
  } 
  else if(sceneToDraw == 1) 
  { //scene avec les triangles pleins, avec les normales aux sommets (dans une couleur choisie) et sans les lignes les joignant 
    g2Card.drawNormaleWithFixedColor(new PVector(255,255,255), new PVector(0,0,255));
  }
  else if(sceneToDraw == 2) 
  { //scene avec les triangles pleins, avec les normales aux sommets (dans une couleur fixe) et sans les lignes les joignant 
    g2Card.drawNormale(new PVector(255,255,255));
  }
  else if(sceneToDraw == 3) 
  { //scene stylisé avec un mapping des hauteurs des sommets sur une échelle de couleurs

    //création de la lune ou du soleil comme des objets émisifs
    translate(vecPositionSkyObject.x+g2Card._param.widthMap/2.0,vecPositionSkyObject.y+g2Card._param.heightMap/2.0,vecPositionSkyObject.z); 
    fill(directionnalLightColorCycle.x,directionnalLightColorCycle.y,directionnalLightColorCycle.z);
    noStroke();
    sphere(radiusSkyObject);
    pointLight(directionnalLightColorCycle.x,directionnalLightColorCycle.y,directionnalLightColorCycle.z, 0, 0, 0); //for the normal behaviour of the sun light
    lightFalloff(0, 0, 0.01); //light falls off right behind the surface of the sun
    ambientLight(directionnalLightColorCycle.x,directionnalLightColorCycle.y,directionnalLightColorCycle.z, 0, 0, 0); //ambientLight in the center of the sun
    //directionalLight(directionnalLightColorCycle.x,directionnalLightColorCycle.y,directionnalLightColorCycle.z,-vecPositionSkyObject.x, -vecPositionSkyObject.y, -vecPositionSkyObject.z); //directionalLight from the center of the sun to the universe's center (2GCardcenter)
    lightFalloff(1.0, 0.0, 0.0);
    translate(-(vecPositionSkyObject.x+g2Card._param.widthMap/2.0),-(vecPositionSkyObject.y+g2Card._param.heightMap/2.0),-vecPositionSkyObject.z);

    g2Card.drawLandscape();
  }
}

//fonction qui se charge de l'affichage du text de l'ATH
void affichageText(){
  textSize(18);
  stroke(0);
  textAlign(LEFT);
  //affichage du texte s'il n'est pas réduit
  if (!hideText)
  {
    //on affiche les boutons
    for (int i = 0; i < 4; i++)
    {
      if(i == sceneToDraw){
        fill(rectSelectionne);
      } else if (rectOver[i]) {
        fill(rectHighlight);
      } else {
        fill(rectColor);
      }
      rect(0, rectSize * i, rectSize, rectSize);
      text(textes[i], 40, rectSize * i + 25); 
    }
    //on ajoute le dernier correspondant au cycle jour nuit (décalé lergèrement) (uniquement si la scene landscape est actuellement affichée)
    if(sceneToDraw == 3){
      if(cycleActivated){
        fill(rectSelectionne);
      } else if (rectOver[4]) {
        fill(rectHighlight);
      } else {
        fill(rectColor);
      }
      rect(30, rectSize * 4, rectSize/2, rectSize/2);
      textSize(12);
      text(textes[4], 50, rectSize * 4 + 13);
    }


    fill(rectColor);
    textAlign(RIGHT); 
    //on affiche les différentes informations des touches 
    String texte = "Clique gauche pour arrêter le défilement du terrain\n" + 
                    "R pour raffiner la carte\n" +
                    "U pour rustifier la carte\n";
    
    if(sceneToDraw == 3){ 
      texte += "Flèche gauche ou droit pour modifier la vitesse du cycle jour/nuit\n" +
               "Flèche haut ou bas pour modifier la hauteur de l'objet céleste\n";
    }
    texte += "Barre espace pour avancer dans la simulation\n" +
             "H pour cacher l'interface";
    if(sceneToDraw == 3){ 
      text(texte, width - 15, 25); 
      
      textAlign(CENTER);
      String indication = "Vitesse du cycle jour/nuit : " + cycleSpeed + " \n" + 
                          "Hauteur de l'objet céleste : " + distanceSkyObject; 
                          
      text(indication, int(width/2.0-15), 25); 
    }
    else{
      text(texte, width - 15, 25); 
    }
  }
  else
  { //cas si le texte est réduits
    textSize(15);
    fill(rectColor);
    textAlign(RIGHT);  
    String texte = "H pour afficher l'interface"; //on indique à l'utilisateur quel touche utiliser pour remettre les boutons et le texte
    text(texte, width - 10, 25);
  }
}

//fonction qui fait le mapping entre 2 couleur selon un indice (un peu particulier car plus joli pour la couleur du ciel)
PVector mappingSkyColor(PVector p_c1, PVector p_c2, float p_pourcentPc2){
  if (p_pourcentPc2 >= 0.1){
    return p_c2;
  }
  //on map (0,0.2) sur (0,1)
  float pourcentc2 = sqrt(p_pourcentPc2*10.0);
  float pourcentC1 = 1 -pourcentc2;
  return new PVector(int(p_c1.x*pourcentC1+ p_c2.x * pourcentc2),
              int(p_c1.y*pourcentC1+ p_c2.y * pourcentc2),
              int(p_c1.z*pourcentC1+ p_c2.z * pourcentc2)) ;
}

//on va faire l'update des valeurs lié au cycle jour/nuit
void updateCycleJourNuit(){ //a revoir pour synchroniser le cycle avec le mouvement de la sphere
  if(cycleActivated && sceneToDraw == 3){
    //adapté du code se trouvant https://editor.p5js.org/BarneyCodes/sketches/GMnG2jvHG (05/05/2023)
    angleTheta += ((1.0/(180.0) * cycleSpeed));
    angleTheta = angleTheta % (2*PI);
    float cosThetaSkyObject = cos(angleTheta);
    PVector calculatedColor;
    if(angleTheta < PI) {
      // if we are in the 0 to 180.0 range
      // it is day time, so we want to map
      // between the day and sunrise colour
      calculatedColor = mappingSkyColor(sunRiseColor, dayColor, 1.0-abs(cosThetaSkyObject));
      directionnalLightColorCycle = new PVector(251,234,184); //soleil
      radiusSkyObject = radiusSun; //soleil 
    } else {
      // if we are in the 180 to 360 range
      // it is night time, so we want to map
      // between the night and the sunrise colour
      calculatedColor = mappingSkyColor(sunRiseColor, nightColor, 1.0-abs(cosThetaSkyObject));
      directionnalLightColorCycle = new PVector(213, 213, 213); //représentant lune 
      radiusSkyObject = radiusMoon; //lune 
      cosThetaSkyObject = -cosThetaSkyObject;
    }
    skyColor = calculatedColor;
    //on calcule la position de l'objet du ciel par rapport au centre de la map dessinée
    vecPositionSkyObject = new PVector(cosThetaSkyObject, 0, sin(acos(cosThetaSkyObject) ));
  }
  vecPositionSkyObject.normalize();
  vecPositionSkyObject.mult(distanceSkyObject+(radiusSun*2.0));
}

//fonction de processing qui capte les events du clavier (appuie d'une touche)
void keyPressed() {
  if (key == 'R' || key == 'r') {
    g2Card.raffiner();
  }
  if (key == 'U' || key == 'u') {
    g2Card.rustifier();
  }
  if (key == 'H' || key == 'h') {
    hideText = !hideText;
  }

  if (key == ' ') { //barre espace
    if (controlDown){
      g2Card._param.flying += g2Card._param.flying_step*g2Card._param.rows*10;
    }else{
      g2Card._param.flying -= g2Card._param.flying_step*g2Card._param.rows*10;
    }
    if (params.stopFlying) {
      g2Card.updateBrin();
    }
  }

  // on s'occupe maintenant des touches pour les scènes
  if ( key == '&'|| key == '1'){ //touche pour mettre la scène sans normales
    sceneToDraw = 0;
  }if ( key == 'é'|| key == '2'){ //touche pour mettre la scène avec les normales de couleurs fixes
    sceneToDraw = 1;
  }if ( key == '\"'|| key == '3'){ //touche pour mettre la scène avec les normales de couleurs changeantes
    sceneToDraw = 2;
  }if ( key == '\''|| key == '4'){ //touche pour mettre la scène dite "landscape" (paysage)
    sceneToDraw = 3;
  }if (sceneToDraw == 3 &( key == '('|| key == '5')){ //touche pour activer/desactiver le cycle jour/nuit (pour la scène "landscape)
    cycleActivated = ! cycleActivated;
  }

  if (key == CODED) { //vérification si ce sont des touches spéciales
    if (keyCode == CONTROL){
      controlDown = true;
    }

    if (sceneToDraw == 3){ // on vérifie que la scene landscape est affichée, sinon on ne fait rien 
      //keys liées à la position de l'objet céleste
      if (keyCode == UP) {
        distanceSkyObject *= 1.10;
        if (distanceSkyObject > distanceMaxSkyObject) {
          distanceSkyObject = distanceMaxSkyObject;
        }
      }
      if (keyCode == DOWN) {
        distanceSkyObject *= 0.90;
        if (distanceSkyObject < distanceMinSkyObject) {
          distanceSkyObject = distanceMinSkyObject;
        }
      }
      //keys liées à la vitesse du cycle jour/nuit
      if (keyCode == RIGHT) {
        cycleSpeed *= 1.10;
        if (cycleSpeed > cycleMaxSpeed){
          cycleSpeed = cycleMaxSpeed;
        }
      }
      if (keyCode == LEFT) {
        cycleSpeed *= 0.90;
        if (cycleSpeed < cycleMinSpeed){
          cycleSpeed = cycleMinSpeed;
        }
      }

    }
  }

}

//fonction de processing qui capte les events du clavier (relachement d'une touche)
void keyReleased() {
  if (key == CODED) { //vérification si ce sont des touches spéciales
    if (keyCode == CONTROL){
      controlDown = false;
    }
  }
}

//fonction qui capte l'emplacement de la souris et permet de dire si un bouton est sous la souris ou non
void update(int x, int y) {
  if(!hideText){ //on ne calcule pas lorsque le text n'est pas affiché
    for (int i = 0; i < 4; i++)
    {
      if(overRect(0, rectSize * i, rectSize, rectSize))
      {
        rectOver[i] = true;
      }
      else
      {
        rectOver[i] = false;
      }
    }
    if(sceneToDraw == 3 && overRect(30, rectSize * 4, rectSize/2, rectSize/2)) //cas pour le petit carré du cycle jour/nuit
    {
      rectOver[4] = true;
    }
    else
    {
      rectOver[4] = false;
    }
  }
}

//fonction qui capte les event de click des boutons de la souris
void mousePressed() {
  if ( mouseButton == LEFT ) {
    boolean isOverRec = false;
    for (int i = 0; i < 4; i++)
    {
      if (rectOver[i]) {
        sceneToDraw = i;
        isOverRec = true;
      }
    }
    if (rectOver[4]){
      cycleActivated = !cycleActivated;
      isOverRec = true;
    }
    if (! isOverRec)
    {
      params.stopFlying = !params.stopFlying;
    }
  }
  if ( mouseButton == RIGHT ) {
    rightMouseClicked = true;
  }
}

//fonction qui capte les event de laché des boutons de la souris
void mouseReleased() {
  if ( mouseButton == RIGHT ) {
    rightMouseClicked = false;
  }
}

//fonction qui capte les event de la molette de la souris
void mouseWheel(MouseEvent event) {
  //on se sert de la molette pour faire un zoom
  //on essaie de faire un mouvement fluide pour rendre appréciable le zoom
  float mouvement = -event.getCount();
  if (mouvement > 0.0) { //on zoom
    params.zoom *= 1.10;
  }else { //on dezoom
    params.zoom *= 0.90;
  }
  //on clip le zoom entre 
  if(params.zoom < params.max_dezoom){
    params.zoom = params.max_dezoom;
  } else if (params.zoom > 5) {
    params.zoom = 5;
  }
}

//fonction qui renvoie vrai si la souris est au dessus d'un bouton (dont les paramètres sont passés en arguments)
boolean overRect(int x, int y, int width, int height)  {
  if (!hideText)
  {
    if (mouseX >= x && mouseX <= x+width && 
        mouseY >= y && mouseY <= y+height) {
      return true;
    } else {
      return false;
    }
  }
  return false;
}


