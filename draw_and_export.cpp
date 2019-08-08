#include "TApplication.h"
#include "TGraph.h"
#include "TGraphErrors.h"
#include "TCanvas.h"
#include "TH1F.h"
#include "TAxis.h"
#include "TF1.h"
#include "TFormula.h"
#include "TLegend.h"
#include <iostream>
#include <vector>
#include <string>
#include <fstream>

using namespace std;
int main(int argc, char** argv){
  if(argc != 3){
    cout << "usage: [title] [number]";
    return 0;
  }
  string stitle = argv[1];
  string number=argv[2];
  string format(".ps");
  string sep("-");
  string sfile = number + sep + stitle + format;
  const char* file = sfile.c_str();
  const char* title = stitle.c_str();
  vector<double> xs;
  vector<double> ys;
  vector<double> yerrors;
  vector<double> xerrors;
  double sx, dx, point, error;
  ifstream ent("dummy.txt");

  ent >> sx;
  ent >> dx;
  ent >> point;
  ent >> error;
  while(!ent.eof()){
    xs.push_back((sx+dx)/2.);
    ys.push_back(point);
    yerrors.push_back(error);
    xerrors.push_back((dx-sx)/2.);
    ent >> sx;
    ent >> dx;
    ent >> point;
    ent >> error;
  }

  TCanvas * c1 = new TCanvas("c1", title, 1300, 1000);
  c1->SetFillColor(30);
  c1->SetGrid();
  TGraphErrors *gr = new TGraphErrors(ys.size(), &xs.front(), &ys.front(), &xerrors.front(), &yerrors.front());
  gr->SetTitle(title);
  gr->SetMarkerColor(2);
  gr->SetMarkerSize(1);
  gr->SetMarkerStyle(8);
  gr->Draw("AP");
  c1 -> Print(file);
  return 0;
}
