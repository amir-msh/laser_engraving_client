final kernel1 = <double>[1, 1, -1, 1, -3, 1, -1, 1, 1];
final outlinesKernel = <double>[-1, -1, -1, -1, 8, -1, -1, -1, -1];
final sharpeningKernel = <double>[0, -1, 0, -1, 5, -1, 0, -1, 0];
final topSobelKernel = <double>[1, 2, 1, 0, 0, 0, -1, -2, -1];
final bottomSobelKernel = <double>[-1, -2, -1, 0, 0, 0, 1, 2, 1];
final leftSobelKernel = <double>[1, 0, -1, 2, 0, -2, 1, 0, -1];
final rightSobelKernel = <double>[-1, 0, 1, -2, 0, 2, -1, 0, 1];
final ridgeDetectionKernel = <double>[-1, -1, -1, -1, 4, -1, -1, -1, -1];
final ridgeDetection2Kernel = <double>[-1, -1, -1, -1, 8, -1, -1, -1, -1];
final ridgeDetection3Kernel = <double>[-1, -1, -1, -1, 8.5, -1, -1, -1, -1];
final laplacianKernel = <double>[0, 1, 0, 1, 4, 1, 0, 1, 0];
final laplacian2Kernel = <double>[1, 1, 1, 1, -8, 1, 1, 1, 1];
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
