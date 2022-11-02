/*
readdply.pde allows a local search for a simple ply file
 and displays it in a 3d environment in which we may interactively vary camera angle perspective
 
 
 the maximum polygon size is 9 sides
 sept. 2022
 */


import peasy.*;
PeasyCam cam;


float r=0;
float rnc=0.01;
float xp=80;      // xp is a scale factor to be adjusted according to image
int i;

float[]  vertx=new float[20000];
int[] tri=new int[1000000];
int nv=0, fcs=0;




void setup() {

  cam = new PeasyCam(this, 100);
  size(800, 800, P3D);

  selectInput("Select a file to process:", "fileSelected");

  noFill();
  stroke(255, 255, 0);
  strokeWeight(2);

  //ortho();
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());

    BufferedReader reader = createReader(selection);
    String line = null;
    int il=0, ne=0;
    int status=0;
    try {
      while ((line = reader.readLine()) != null) {

        if (nv==0)
        {
          if (line.indexOf("vertex")!=-1) {
            String[] sl= splitTokens(line);
            int ix=0;
            while (sl[ix].equals("vertex")==false)
              ix+=1;
            nv=int(sl[ix+1]);
          }
        }
        if (fcs==0)
        {
          if (line.indexOf("face")!=-1) {
            String[] sl= splitTokens(line);
            int ix=0;
            while (sl[ix].equals("face")==false)
              ix+=1;
            fcs=int(sl[ix+1]);
            status =1;
          }
        }
        if (line.indexOf("end_header")!=-1)
        {
          status =2;
          il=0;
          line = reader.readLine();
          // println("status 2");
        }
        if ( status ==1)
          println("vertices ", nv, " ", "faces ", fcs);
        if (status==2)
        {
          line.trim();
          println(line);
          if (line.equals("")== false) {
            String[] sl= splitTokens(line);
            vertx[il*3]=float(sl[0]);
            vertx[il*3+1]=float(sl[1]);
            vertx[il*3+2]=float(sl[2]);
            il++;
            //println(il);
            if (il>nv)
            {
              status =3;
              il=0;
            }
          }
        }

        if (status==3)
        {
          line.trim();
          if (line.equals("")== false) {
            String[] sl= splitTokens(line);
            int sds= int(sl[0]);

            for (i=0; i<=sds; i++) {
              tri[il*10+i]=int(sl[i]);
            }
            il++;
            if (il>fcs)
              status =4;
          }
        }
      }
      reader.close();
      for (i=0; i<nv; i++)
        println(vertx[i*3], " \t ", vertx[i*3+1], " \t ", vertx[i*3+2]);
      for (i=0; i<fcs; i++)
      {
        for (int i2=1; i2<=tri[i*10]; i2++)
          print(tri[i*10+i2], " \t ");
        println("");
      }
    }
    catch (IOException e) {
      e.printStackTrace();
    }
  }
}

void draw() {
  if (r> 10.0 ||r<-10.0)
    rnc *= -1;
  int cb=255, cy =0, cr=120;
  //rotateZ(r);
  translate(0, 0, r*-4);
  background(0);
  for (i=0; i<fcs; i++)
  {
    int fc=i%10, fcm= 260/8;
    cb=fc*fcm;
    cy=260-cb;
    cr=cb/2;
    fill(120+cr+cy,cy,cb/2);
    beginShape();
    for (int i2=1; i2<=tri[i*10]; i2++)
      vertex(vertx[tri[i*10+i2]*3] *xp, vertx[tri[i*10+i2]*3+1] *xp, vertx[tri[i*10+i2]*3+2] *xp);

    endShape(CLOSE);
  }

  stroke(255, 0, 0);
  beginShape();    // scale
  vertex(50.0, 0, 0);
  vertex(0.0, 0, 0);
  stroke(0, 255, 0);
  vertex(0.0, 30.0, 0);
  vertex(0.0, 0, 0);
  stroke(0, 0, 255);
  vertex(0.0, 0.0, 30.0);
  endShape();
  r+=rnc;
}
