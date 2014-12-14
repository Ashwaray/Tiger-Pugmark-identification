clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
imtool close all;  % Close all imtool figures.
clear;  % Erase all existing variables.
workspace;  % Make sure the workspace panel is showing.
format longg;
format compact;
fontSize = 20;
 % Read in a color demo image.
 folder='C:\Users\hp\Desktop\';
 files = dir('C:\Users\hp\Desktop\fi2fynlpreprcessing.jpg');
 NumberOfFiles=length(files);
 for k=1:NumberOfFiles
 baseFileName = files(k).name;
 
 % Get the full filename, with path prepended.
 fullFileName = fullfile(folder, baseFileName);
 if ~exist(fullFileName, 'file')
 	% Didn't find it there.  Check the search path for it.
 	fullFileName = baseFileName; % No path this time.
 	if ~exist(fullFileName, 'file')
 		% Still didn't find it.  Alert user.
 		errorMessage = sprintf('Error: %s does not exist.', fullFileName);
 		uiwait(warndlg(errorMessage));
 		return;
 	end
 end
% originalImage = imread(fullFileName);

pug=imread(fullFileName);
pug=imresize(pug, [640 480]);
NameOfTiger=baseFileName; 

 % Get the dimensions of the image.  numberOfColorBands should be = 3.
 [rows, columns, numberOfColorBands] = size(pug);
 % Display the original color image.
%  subplot(2, 2, 1);
%  imshow(pug);
%  axis on;
%  title('Original Color Image', 'FontSize', fontSize);
%  % Enlarge figure to full screen.
%  set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
 

% % Binarize the image
% binaryImage = originalImage > 128;
 % Get rid of stuff near border.
%  pug1=imread('image1.jpg');
% pug1=imresize(pug1, [640 480]);
[m n p]=size(pug);
r=pug(:,:,1);
g=pug(:,:,2);
b=pug(:,:,3);
for i=1:m
for j=1:n
for k=1:p
if(r(i,j)>250 & g(i,j)>250 & b(i,j)>250)
b(i,j,k)=pug(i,j,k);
else
b(i,j,k)=0;
end
end
end
end
pug1bw=im2bw(b);

 binaryImage = imclearborder(pug1bw);
 % Get rid of small things
 binaryImage = bwareaopen(binaryImage, 50);
 % Do a morphological closing to smooth it some
 se = strel('disk', 3, 0);
 binaryImage = imclose(binaryImage, se);
 [L Num]=bwlabeln(binaryImage,8);
 numberOfBlobs = Num;
%  disp(numberOfBlobs);
 
 % Fill holes
 % binaryImage = imfill(binaryImage, 'holes');
 % Display image.
% subplot(2, 2, 2);
% imshow(binaryImage);
% axis on;
% title('Binary Image', 'FontSize', fontSize);
% Get the convex hull of each blob.
%binaryImage = bwconvhull(binaryImage, 'union');
% Display image.
% subplot(2, 2, 3);
% imshow(binaryImage);
% axis on;
% title('Convex Hull Image with Centroids', 'FontSize', fontSize);
% hold on;
measurements = regionprops(L, 'Area', 'Centroid','SubarrayIdx','PixelIdxList');
for k=1:numberOfBlobs    
  centroid(k)=[measurements(k).Centroid(1)];  
end

maxy=0;
for k=1:numberOfBlobs
    
    if maxy<measurements(k).Centroid(2)
        maxy=measurements(k).Centroid(2);
    end
end
% disp(maxy);

for k=1:numberOfBlobs
    if(measurements(k).Centroid(2)==maxy)
        padX=measurements(k).Centroid(1); 
        measurements(k).Centroid(1)=480;break
    end
end
% disp(k);disp(measurements(k).Centroid(1)); disp(measurements(k).Centroid(2)); disp(padX);
padY=measurements(k).Centroid(2);
for k=1:numberOfBlobs    
  centroid(k)=[measurements(k).Centroid(1)];  
end
% %disp(centroid);
[sorted, sort_order] = sort(centroid);
% disp(sorted);
s2 = measurements(sort_order);
 I = im2uint8(binaryImage);
 I(~binaryImage) = 200;
 I(binaryImage) = 240;
 set(gcf, 'Position', [100 100 400 300]);
 imshow(I, 'InitialMag', 'fit')
 hold on
for k = 1:length(s2)
    if(k==5)
    centroid(1)=padX;centroid(2)=padY;
 text(centroid(1),centroid(2),sprintf('%d',5));
    else
         centroid = s2(k).Centroid;
   text(centroid(1), centroid(2), sprintf('%d', k));
   end
    
end
% disp(padX); disp(padY);
% centroid(1)=padX;centroid(2)=padY;
%  text(centroid(1),centroid(2),sprintf('%d',5));
% hold off
for k = 1:numel(s2)
   kth_object_idx_list = s2(k).PixelIdxList; 
   L(kth_object_idx_list) = k;disp(k)
end
% for k = 1:5
%   figure(k), imshow(L == k)
% end
s = regionprops(L, 'BoundingBox', 'Extrema', 'Centroid','Area','PixelIdxList');
AT3=s(2).Area;
padarea=s(5).Area;
% disp(AT3);
% disp(padarea);
for k = 1 : numberOfBlobs
	thisCentroid = s2(k).Centroid
% 	plot(thisCentroid(1), thisCentroid(2), 'b+', 'MarkerSize', 10);
end
allAreas = [s.Area] % Get all areas into one vector.
% Display image in lower right.
% subplot(2, 2, 4);
%  imshow(pug);
%  axis on;
% title('Original Image', 'FontSize', fontSize);
% Find the distances between every pair of blobs.
distance = zeros(numberOfBlobs, numberOfBlobs);
for b1 = 1 : numberOfBlobs
	thisCentroid1 = s(b1).Centroid
	x1 = thisCentroid1(1);
	y1 = thisCentroid1(2);
	for b2 = (b1 + 1) : numberOfBlobs
		thisCentroid2 = s(b2).Centroid
		x2 = thisCentroid2(1);
		y2 = thisCentroid2(2);
		distance(b1,b2) = sqrt((x1-x2)^2+(y1-y2)^2);
		distance(b2,b1) = distance(b1,b2);
% 		line([x1 x2], [y1 y2], 'Color', 'r', 'LineWidth', 3);
%  		message = sprintf('This distance is %.3f', distance(b1,b2));
%  		uiwait(helpdlg(message));


	end
end

       % calculating area of toe 3 AT3
AT3=s(2).Area; disp(AT3);
%calculating DT2T3
thisCentroid3=s(2).Centroid;
x1=thisCentroid3(1);
y1=thisCentroid3(2);
thisCentroid4=s(3).Centroid;
x2=thisCentroid4(1);
y2=thisCentroid4(2);
DT2T3=sqrt((x1-x2)^2+(y1-y2)^2);
disp(DT2T3);
% toe3=bwselect(binaryImage,x1,y1);
% disp(toe3);
% Measure the image

Axismeasurements=regionprops(L,'MinorAxisLength','MajorAxisLength','Orientation');
% figure(5),imshow(binaryImage);
leadToeMajorAxis=0;count=1;
for k=1:numberOfBlobs
    minorAxis=Axismeasurements(k).MinorAxisLength;
    majorAxis=Axismeasurements(k).MajorAxisLength;
    if(leadToeMajorAxis<majorAxis & (majorAxis~=Axismeasurements(2).MajorAxisLength) )
        leadToeMajorAxis=majorAxis; count=count+1;
    end
    
end
MiT3=Axismeasurements(2).MinorAxisLength;
LT2=Axismeasurements(3).MinorAxisLength;
majorAxis2=Axismeasurements(2).MajorAxisLength;disp(majorAxis2);
angle=Axismeasurements(2).Orientation; 

biggestBlobIndex = find(allAreas == max(allAreas));

coloredLabels = label2rgb (L, 'hsv', 'k', 'shuffle'); % pseudo random color labels
% figure(2), imagesc(coloredLabels); title('Pseudo colored labels, from label2rgb()'); axis square;
blobmeasurements=regionprops(L,'BoundingBox','Area');
% figure(3),imshow(pug);
mina=480;minb=640;maxc=0;maxd=0;
% loop through all blobs, putting up BoundingBox
for k=1:numberOfBlobs
    boundingBox=blobmeasurements(k).BoundingBox;
    a=boundingBox(1);
    b=boundingBox(2);
    c=a+boundingBox(3)-1;
    d=b+boundingBox(4)-1;
    
    %calculate width 
    width=boundingBox(3); 
    wby2=width/2;
    %calculate height
    height=boundingBox(4);
    hby2=height/2;
    % aspect ratio
    aspectRatio=width/height;
   if(mina>a)
       mina=a;
   end
   if(minb>b)
       minb=b;
   end
   
   if(maxc<c)
       maxc=c;
   end
   if(maxd<d)
       maxd=d;
   end
   
%     %draw the box
%    rectangle('Position',[a b width height],'EdgeColor','r');
    
end
Wpg=maxc-mina;
Lpg=maxd-minb;
aspectRatiop=Wpg/Lpg;
% disp(mina),disp(minb),disp(maxc),disp(maxd);
% disp(Wpg);disp(Lpg);disp(aspectRatiop);

%calculating property 5 (Distance between main pad top to toe base-line (H))
% figure(6),imshow(coloredLabels);
 boundingBox1=blobmeasurements(1).BoundingBox;
 a1=boundingBox1(1);
 b2=boundingBox1(2);
 c2=a1+boundingBox1(3)-1;
 d2=b2+boundingBox1(4)-1;
 hx1=(a1+c2)/2;
 hy1=d2;
 
 boundingBox4=blobmeasurements(4).BoundingBox;
 a5=boundingBox4(1);
 b5=boundingBox4(2);
 c5=a5+boundingBox4(3)-1;
 d5=b5+boundingBox4(4)-1;
 hx2=(a5+c5)/2;
 hy2=d5;
 
%  hmidx=(hx1+hx2)/2;
%  hmidy=(hy1+hy2)/2;

 a2=s(5).Centroid(1); disp(b2);
 b2=s(5).Centroid(2);
%  selecting the pad area for boundary pixels and calculating the top most
%  and bottom-most point
pad=bwselect(binaryImage,a2,b2);
boundaries = bwboundaries(pad);
thisBoundary = boundaries{1};
boundaryX=thisBoundary(:,2); 
boundaryY=thisBoundary(:,1);
[topPoint2, Ind1] = min(boundaryY);
[bottomPoint2, ind2]=max(boundaryY);
maxCoord2 = thisBoundary(Ind1, :);
minCoord2 = thisBoundary(ind2, :);

 hx3=maxCoord2(:,2);
 hy3=maxCoord2(:,1);

%  calculating intersection point between majoraxis and toe base line
 x=[hx1 hx3; hx2 a2];
 y=[hy1 hy3; hy2 b2];
dx = diff(x);  %# Take the differences down each column
dy = diff(y);
den = dx(1)*dy(2)-dy(1)*dx(2);  %# Precompute the denominator
ua = (dx(2)*(y(1)-y(3))-dy(2)*(x(1)-x(3)))/den;
ub = (dx(1)*(y(1)-y(3))-dy(1)*(x(1)-x(3)))/den;
xi = x(1)+ua*dx(1);
yi = y(1)+ua*dy(1);
 %calculating distance
 H=sqrt((hx3-xi)^2+(hy3-yi)^2);
%plotting lines
% line([hx1 hx2], [hy1 hy2], 'Color', 'r', 'LineWidth', 2);
%  line([xi hx3], [yi hy3], 'Color', 'r', 'LineWidth', 2);
% 		message = sprintf('This distance is %.3f', H);
% 		uiwait(helpdlg(message));
 
% calculating prop. Heel to lead toe length (HLTL)
% determining the lead toe
% figure(7),imshow(coloredLabels);
maxCoord=[640 480];
%toe1
a1=s(1).Centroid(1);
b1=s(1).Centroid(2);
toe1=bwselect(binaryImage,a1,b1);
boundariestoe1 = bwboundaries(toe1);
thisBoundary = boundariestoe1{1};
boundaryX=thisBoundary(:,2); 
boundaryY=thisBoundary(:,1);
[topPoint1, Ind1] = min(boundaryY);
[bottomPoint1, ind2]=max(boundaryY);
maxCoord1 = thisBoundary(Ind1, :);
minCoord1 = thisBoundary(ind2, :);
if(maxCoord(:,1)>maxCoord1(:,1))
    maxCoord=maxCoord1;
%      maxCoord(:,2)=maxCoord1(:,2);
end

%toe2
a3=s(2).Centroid(1);
b3=s(2).Centroid(2);
toe2=bwselect(binaryImage,a3,b3);
boundariestoe2 = bwboundaries(toe2);
thisBoundary = boundariestoe2{1};
boundaryX=thisBoundary(:,2); 
boundaryY=thisBoundary(:,1);
[topPoint3, Ind1] = min(boundaryY);
[bottomPoint3, ind2]=max(boundaryY);
maxCoord3 = thisBoundary(Ind1, :);
minCoord3 = thisBoundary(ind2, :);
if(maxCoord(:,1)>maxCoord3(:,1))
    maxCoord=maxCoord3;
%      maxCoord(:,2)=maxCoord3(:,2);
end



%toe3
a4=s(3).Centroid(1);
b4=s(3).Centroid(2);
toe3=bwselect(binaryImage,a4,b4);
boundariestoe3 = bwboundaries(toe3);
thisBoundary = boundariestoe3{1};
boundaryX=thisBoundary(:,2); 
boundaryY=thisBoundary(:,1);
[topPoint4, Ind1] = min(boundaryY);
[bottomPoint4, ind2]=max(boundaryY);
maxCoord4 = thisBoundary(Ind1, :);
minCoord4 = thisBoundary(ind2, :);
if(maxCoord(:,1)>maxCoord4(:,1))
    maxCoord=maxCoord4;
%     maxCoord(:,2)=maxCoord4(:,2);
end

%toe4
a5=s(4).Centroid(1);
b5=s(4).Centroid(2);
toe4=bwselect(binaryImage,a5,b5);
boundariestoe4 = bwboundaries(toe4);
thisBoundary = boundariestoe4{1};
boundaryX=thisBoundary(:,2); 
boundaryY=thisBoundary(:,1);
[topPoint5, Ind1] = min(boundaryY);
[bottomPoint5, ind2]=max(boundaryY);
maxCoord5 = thisBoundary(Ind1, :);
minCoord5 = thisBoundary(ind2, :);
if(maxCoord(:,1)>maxCoord5(:,1))
    maxCoord=maxCoord5;
%      maxCoord(:,2)=maxCoord5(:,2);
end

leadtoe=bwselect(binaryImage,maxCoord(:,2),maxCoord(:,1));
boundariesLeadtoe = bwboundaries(leadtoe);
thisBoundary = boundariesLeadtoe{1};
boundaryX=thisBoundary(:,2); 
boundaryY=thisBoundary(:,1);
[bottomPoint, ind]=max(boundaryY);
minCoord= thisBoundary(ind, :);
% axis on;
% hold on;
HLTL=sqrt((minCoord(:,2)-minCoord2(:,2)).^2 + (minCoord(:,1)-minCoord2(:,1)).^2);
% plot(minCoord(:,2), minCoord(:,1), 'gx', 'MarkerSize', 5);
% plot(minCoord2(:,2), minCoord2(:,1), 'gx', 'MarkerSize', 5);
% message = sprintf('This distance is %.3f', HLTL);
% 		uiwait(helpdlg(message));

%   ANGLE BETWEEN TOE 2 AND TOE 3
T2T3=sqrt((a3-a4)^2+(b3-b4)^2);
T2P=sqrt((a2-a3)^2+(b2-b3)^2);
T3P=sqrt((a2-a4)^2+(b2-b4)^2);
cosOfAngle=((T2P^2+T3P^2-T2T3^2)/(2*T2P*T3P));
Angle=acosd(cosOfAngle);
  
 %  database connection

 javaaddpath([matlabroot,'\java\jarext\mysql-connector-java-5.1.18.jar']);
 %conn=database('tiger','system','1234','com.mysql.jdbc.Driver','jdbc:mysql://localhost:3306/tiger');
 conn = database('tiger', 'root', '1234', 'com.mysql.jdbc.Driver', 'jdbc:mysql://localhost:3306/tiger');
 
 exdata={NameOfTiger,AT3,MiT3,DT2T3,LT2,H,HLTL,Wpg,Lpg,Angle};
 disp(exdata(1,4));
 colnames={'NameOfTiger','AT3','MiT3','DT2T3','LT2','H','HLTL','Wpg','Lpg','Angle'};
 insert(conn,'pugmarks', colnames,exdata);
 close(conn);
 end
%  set(conn, 'AutoCommit', 'off')
%  exdata(1,4) = {DT2T3};
% whereclause = 'where NameOfTiger = "pug1"';
% update(conn, 'pugmarks', {'DT2T3'}, exdata, whereclause);
% rollback(conn);
        
% setdbprefs('DataReturnFormat','cellarray')
% results = fetch(conn, 'select * from tiger.pugmarks')  ;
% results
