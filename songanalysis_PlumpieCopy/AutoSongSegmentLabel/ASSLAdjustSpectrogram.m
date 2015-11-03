function [] = ASSLAdjustSpectrogram(SpectFloor, SpectCeil, SpectRange, SpectCmapName, SpectGammaType, PlotAxes)

axes(PlotAxes);
colormap(make_map(SpectFloor, SpectCeil, SpectRange, SpectCmapName, SpectGammaType));