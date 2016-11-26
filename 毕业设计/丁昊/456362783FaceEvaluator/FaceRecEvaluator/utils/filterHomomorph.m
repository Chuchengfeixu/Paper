%http://groups.google.com/group/face-rec/browse_thread/thread/0e650b6ce934c880#
function im = filterHomomorph (I, varargin)

if nargin == 1
    varargin{1} = 0.25;
    varargin{2} = 1;
end

[r, c] = size(I);
I = im2double(I);

cutoff = varargin{1};
n = varargin{2};

%transfer funct.
u = 0:(r-1);
v = 0:(c-1);
idx = find (u > r/2);
u(idx) = u(idx) - r;
idy = find (v > c/2);
v(idy) = v(idy) - c;
[V,U] = meshgrid(v,u);
D = sqrt(U.^2 + V.^2);

%low pass
H = 1.0 ./ (1.0 + (D./cutoff).^(2*n));

%high pass
H = 1.0 - H;

%log FFT
Ilogfft = fft2(log(I + .01)); % .01 added to avoid log(0)

%filtering
im = Ilogfft .* H;

%inverse fft & exp
im = exp(real(ifft2(im))); 