function DrawCirclesOnPlates(Img, circlesVec, InnerCirclesVec)
N = size(circlesVec,1);
figure; imshow(Img,'InitialMagnification','fit');
hold on
for i=1:N
    circle([circlesVec(i,1),circlesVec(i,2)],circlesVec(i,3) ,500,'r-');
    circle([circlesVec(i,1),circlesVec(i,2)],InnerCirclesVec(i) ,500,'y-');
end