 function J = jetnew(m,type) 
%JETNEW colormap starting with black and ending with red
% 
%   m = jetnew(m,type)
% 
%   jetnew.m is currently locked by $Locker$ 
  
%   \\ANDREA2\davel 
%   27-May-2002 13:27:34 
%   D:\Frogs\swim\Matlab\jetnew.m 
% 
%   $Revision$ by $Author$ 
%   $Date$ 


if nargin < 1
  if ~isempty(get(0,'children'))
    m = size(get(gcf,'colormap'),1); 
  else
    m = 64;  
  end
end
if nargin < 2, type = 2; end


n = max(round(m/4),1);
x = (1:n)'/n;
e = ones(length(x),1);


switch type
case -1 % classic jet with more black
  y = (n/2:n)'/n;
  y1 = (0:2:n-1)'/n;
  r = [0*y1; 0*e; x; e; flipud(y)];
  g = [0*y1; x; e; flipud(x); 0*y];
  b = [y1; e; flipud(x); 0*e; 0*y];
  J = [r g b];
  while size(J,1) > m
    J(1,:) = [];
    if size(J,1) > m, J(size(J,1),:) = []; end
  end
  J(5,:)=J(4,:);  
  J(4,:)=J(3,:);  
  J(3,:)=J(2,:);  
  J(2,:)=J(1,:);  
  J(1,:)=[0 0 0];  % black
  
case 0 % classic jet
  y = (n/2:n)'/n;
  r = [0*y; 0*e; x; e; flipud(y)];
  g = [0*y; x; e; flipud(x); 0*y];
  b = [y; e; flipud(x); 0*e; 0*y];
  J = [r g b];
  while size(J,1) > m
    J(1,:) = [];
    if size(J,1) > m, J(size(J,1),:) = []; end
  end
  
case 1 % from black to red
  r = [0*e; 0*e; x; e];
  g = [0*e; x; e; flipud(x)];
  b = [x; e; flipud(x); 0*e];
  J = [r g b];
  while size(J,1) > m
    J(1,:) = [];
    if size(J,1) > m, J(size(J,1),:) = []; end
  end
  
case 2 % from black to red with less blue
  y2 = (1:2:n)'/n;
  p = n + n/2;
  y3 = (1:p)'/p;
  e3 = ones(length(y3),1);
  r = [0*y2; 0*e; y3; e];
  g = [0*y2; x; e3; flipud(x)];
  b = [y2; e; flipud(y3); 0*e];
  J = [r g b];
  while size(J,1) > m
    J(1,:) = [];
    if size(J,1) > m, J(size(J,1),:) = []; end
  end
  %J(1,:)=[1 1 1]; 
  
end