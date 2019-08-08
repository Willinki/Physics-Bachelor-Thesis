#include "TGraph.h"
#include "TF1.h"
#include "TCanvas.h"
#include <iostream>
#include <vector>
#include <string>
#include <fstream>
#include "TAxis.h"

using namespace std;
int main(int argc, char** argv){
  vector<double> xs;
  vector<double> ys;
  double x, y;
  ifstream ent("chi2-values.txt");

  ent >> x;
  ent >> y;
  while(!ent.eof()){
    xs.push_back(x);
    ys.push_back(y);
    ent >> x;
    ent >> y;
  }

  TCanvas * c1 = new TCanvas("c1", "chi2 values", 1300, 1000);
  c1->SetFillColor(30);
  c1->SetGrid();
  TGraph *gr = new TGraph(ys.size(), &xs.front(), &ys.front());
  gr->Fit("pol2", "q");
  TF1 *g = (TF1*)gr -> GetListOfFunctions() -> FindObject("pol2");
  double A = g -> GetParameter("2");
  double B = g -> GetParameter("1");
  cout << -B/(2*A) << endl;
  gr->SetTitle("chi2 values");
  gr->GetXaxis() -> SetTitle("sin2-eff");
  gr->GetYaxis() -> SetTitle("chi2");
  gr->SetMarkerColor(2);
  gr->SetMarkerSize(1);
  gr->SetMarkerStyle(8);
  gr->Draw("AP");
  c1 -> Print("chi2-values.ps");
  return 0;
}
