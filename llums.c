#include <math.h>
#include <stdlib.h>
#include <stdio.h>

#define PI 3.14159265
#define PRECISION 10000
double* sintable;
double* costable;

void inisintable(){
	sintable = (double*)malloc(PRECISION*sizeof(double));
	for (int i=0; i<PRECISION; ++i){
		sintable[i] = sin((double)i*2.0*PI/(double)PRECISION);
	}
}
void inicostable(){
	costable = (double*)malloc(PRECISION*sizeof(double));
	for (int i=0; i<PRECISION; ++i){
		costable[i] = cos((double)i*2.0*PI/(double)PRECISION);
	}
}

double getSin(double value){
	value = (value/(2.0*PI) - (int)(value/(2.0*PI)));
	if (value<0) value = 1-value;
	return sintable[(int)(((double)PRECISION*(double)value))];
}
double getCos(double value){
	value = (value/(2.0*PI) - (int)(value/(2.0*PI)));
	return costable[(int)(((double)PRECISION*(double)value))];
}

#define N 1024*10
#define maxint (1<<31)

#define fftcalc(_k,_i) \
	tmp2 = ((2*PI*_k*(_i))/(double)N); \
	tmp += getCos(tmp2)*adapt[_i]; \
	tmpi += getSin(tmp2)*adapt[_i];

void fft(int* in, int* out){

	double fft_mag[N];
	double adapt[N];
	for(int i=0; i<N; i+=1){
		double tmp = ((double)(in[i])/maxint)*(0.5-0.5*getCos((2.0*PI*i)/(N-1)));
		adapt[i] = tmp;
	}
	double tmp2;
	//int red = N/2; //values duplicate at the extremes
	for(int k=0; k<N; ++k){
		double tmp = 0.0;
		double tmpi = 0.0;
		for(int i=0; i<N-4; i+=4){
			fftcalc(k,i)
			fftcalc(k,i+1)
			fftcalc(k,i+2)
			fftcalc(k,i+3)
		}
		double d = tmp*tmp + tmpi*tmpi;
		if(d<0)d=0;
		fft_mag[k] = /*sqrt(d)*/d;
	}
	for(int i=0; i<N; ++i) printf("%d %lf\n",i,fft_mag[i]);
}



int main(){
	inisintable();
	inicostable();
	int* tmp = malloc(N*sizeof(int));
	int f = 600;
	int rate = N;
	double fd = (double)rate/(double)f;
//	printf("%lf\n",fd);
	for(int i=0; i<N; ++i) tmp[i]=getSin((2.0*PI*i)/fd)*(maxint-1);
	//for(int i=0; i<N; ++i) printf("%d %d\n",i,tmp[i]);
	fft(tmp,tmp);
}
