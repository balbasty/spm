/* returns the global mean for a memory mapped volume image
  FORMAT [G] = spm_global(V)
  V   - memory mapped volume
  G   - mean global activity
 ____________________________________________________________________________
 
  spm_global returns the mean counts integrated over all the  
  slices from the volume
 
  The mean is estimated after discounting voxels outside the object
  using a criteria of greater than > (global mean)/8
*/

#ifndef lint
static char sccsid[]="%W% anon %E%";
#endif

#include <math.h>
#include "mex.h"
#include "spm_vol_utils.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	int i, j, m, n;
	double s1=0.0, s2=0.0;
	double *dat;
	MAPTYPE *map, *get_maps();
	static double M[] = {1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1};

	if (nrhs != 1 || nlhs > 1)
	{
		mexErrMsgTxt("Inappropriate usage.");
	}

	map = get_maps(prhs[0], &j);
	if (j != 1)
	{
		free_maps(map, j);
		mexErrMsgTxt("Inappropriate usage.");
	}
	n = map->dim[0]*map->dim[1];
	dat = (double *)mxCalloc(n, sizeof(double));

	s1 = 0.0;
	for (i=0; i<map->dim[2]; i++)
	{
		M[14] = i;
		slice(M, dat, map->dim[0],map->dim[1], map, 0,0);
		for(j=0;j<n; j++)
			s1 += dat[j];
	}
	s1/=(8.0*map->dim[2]*n);

	s2=0.0;
	m =0;
	for (i=0; i<map->dim[2]; i++)
	{
		M[14] = i;
		slice(M, dat, map->dim[0],map->dim[1], map, 0,0);
		for(j=0;j<n; j++)
			if (dat[j]>s1)
			{
				m++;
				s2+=dat[j];
			}
	}
	s2/=m;

	plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
	mxGetPr(plhs[0])[0]=s2;
	free_maps(map, 1);
}
