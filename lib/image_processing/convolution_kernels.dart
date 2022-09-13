const kernel1 = <double>[1, 1, -1, 1, -3, 1, -1, 1, 1];
const outlinesKernel = <double>[-1, -1, -1, -1, 8, -1, -1, -1, -1];
const sharpeningKernel = <double>[0, -1, 0, -1, 5, -1, 0, -1, 0];
const topSobelKernel = <double>[1, 2, 1, 0, 0, 0, -1, -2, -1];
const bottomSobelKernel = <double>[-1, -2, -1, 0, 0, 0, 1, 2, 1];
const leftSobelKernel = <double>[1, 0, -1, 2, 0, -2, 1, 0, -1];
const rightSobelKernel = <double>[-1, 0, 1, -2, 0, 2, -1, 0, 1];
const ridgeDetection1Kernel = <double>[-1, -1, -1, -1, 4, -1, -1, -1, -1];
const ridgeDetection2Kernel = <double>[-1, -1, -1, -1, 8, -1, -1, -1, -1];
const ridgeDetection3Kernel = <double>[-1, -1, -1, -1, 8.5, -1, -1, -1, -1];
const laplacian1Kernel = <double>[0, 1, 0, 1, 4, 1, 0, 1, 0];
const laplacian2Kernel = <double>[1, 1, 1, 1, -8, 1, 1, 1, 1];
const boxBlurKernel = [
  1 / 9,
  1 / 9,
  1 / 9,
  1 / 9,
  1 / 9,
  1 / 9,
  1 / 9,
  1 / 9,
  1 / 9
];
