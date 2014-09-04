clear;
kmean_num=500;
total=0;
%Feature Description
for object=1:4
    total1=0;
    if (object==1)
        num=165;
        name1='bike';
        base=0;
    elseif(object==2)
        num=220;
        name1='cars';
        base=0;
    elseif(object==3)
        num=111;
        name1='person';
        base=0;
    else 
        num=180;
        name1='none';
        base=0;
    end
    for number=1:num
        total1=total1+1;
        if (object==1) 
            if total1<10
                name2='bike_00';
            elseif total1<100
                name2='bike_0';
            else
                name2='bike_';
            end
        elseif (object==2) 
            if total1<10
                name2='carsgraz_00';
            elseif total1<100
                name2='carsgraz_0';
            else
                name2='carsgraz_';
            end
        elseif (object==3) 
            if total1<10
                name2='person_00';
            elseif total1<100
                name2='person_0';
            else
                name2='person_';
            end
        else
            if total1<10
                name2='bg_graz_00';
            elseif total1<100
                name2='bg_graz_0';
            else
                name2='bg_graz_';
            end
        end
        name=strcat('Train\',name1,'\',name2,num2str(base+number),'.bmp');
        total=total+1;
        A=imread(name);
        B=rgb2hsv(A);
        C=B(:,:,3);
        %SIFT, 4 direction only
        [Ix,Iy]=gradient(C);
        [size1,size2]=size(C);
        for i=(size1-10)/10:(size1-10)/10:size1-10
            for j=(size2-10)/10:(size2-10)/10:size2-10
                for m=0:1
                    for n=0:1
                        for p=1:4
                            for q=1:4
                                Ix0(p,q)=Ix(i+p+m*4,j+q+n*4);
                                Iy0(p,q)=Iy(i+p+m*4,j+q+n*4);
                            end
                        end
                        keypoint0(m*2+n+1,1)=sum(Iy0(Iy0>0));
                        keypoint0(m*2+n+1,2)=sum(Iy0(Iy0<0));
                        keypoint0(m*2+n+1,3)=sum(Ix0(Ix0<0));
                        keypoint0(m*2+n+1,4)=sum(Ix0(Ix0>0));                
                    end
                end
                for m=1:4
                    for n=1:4
                        keypoint((total-1)*100+(i/(size1-10)*10-1)*10+j/(size2-10)*10,(m-1)*4+n)=keypoint0(m,n);
                    end
                end
            end
        end
        %end of SIFT
    end
end
% end of Feature Description
%Dictionary Computation
%k-means clustering
for i=1:size(keypoint,1)
    lable(i)=i;
end
for i=1:kmean_num
    ran=ceil(size(keypoint,1)*rand);
    centers(i,:)=keypoint(ran,:);
    centers_record(i,:)=[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1];
end
change=1;
step=0;
while (change>0)
    change=0;
    for i=1:size(keypoint,1)
        mindis=100;
        for j=1:kmean_num
            if centers_record(j,:)==centers(j,:)
                dis=dis_record(i,j);
            else
                dis=pdist2(keypoint(i,(1:16)),centers(j,(1:16)));
            end
            dis_record(i,j)=dis;
            if dis<mindis
                mindis=dis;
                minpos=j;
            end
        end
        if (lable(i)~=minpos)
            lable(i)=minpos;
            change=change+1;
        end
    end
    for i=1:kmean_num
        centers_record(i,:)=centers(i,:);
        centers(i,(1:16))=mean(keypoint((lable(:)==i),(1:16)));
    end
    step=step+1;
    disp(step);
    disp(change);
end

%Image Representation
%Training data
total=0;
train_histo=zeros(676,kmean_num);
for object=1:4
    total1=0;
    if (object==1)
        num=165;
        name1='bike';
        base=0;
    elseif(object==2)
        num=220;
        name1='cars';
        base=0;
    elseif(object==3)
        num=111;
        name1='person';
        base=0;
    else 
        num=180;
        name1='none';
        base=0;
    end
    for number=1:num
        total1=total1+1;
        if (object==1) 
            if total1<10
                name2='bike_00';
            elseif total1<100
                name2='bike_0';
            else
                name2='bike_';
            end
        elseif (object==2) 
            if total1<10
                name2='carsgraz_00';
            elseif total1<100
                name2='carsgraz_0';
            else
                name2='carsgraz_';
            end
        elseif (object==3) 
            if total1<10
                name2='person_00';
            elseif total1<100
                name2='person_0';
            else
                name2='person_';
            end
        else
            if total1<10
                name2='bg_graz_00';
            elseif total1<100
                name2='bg_graz_0';
            else
                name2='bg_graz_';
            end
        end
        name=strcat('Test\',name1,'\',name2,num2str(base+number),'.bmp');
        total=total+1;
        A=imread(name);
        B=rgb2hsv(A);
        C=B(:,:,3);
	train_lable(total)=object;
	for i=1:100
	    mindis=100;
	    for j=1:kmean_num
		dis=pdist(keypoint(100*(total-1)+i,:),centers(j,:));
		if dis<mindis
		    mindis=dis;
		    minpos=j;
		end
	    end
	    train_histo(total,minpos)=train_histo(total,minpos)+1;
	end
    end
end
%end of Training data

%Validation data
total=0;
valid_histo=zeros(400,kmean_num);
for object=1:4
    total1=0;
    if (object==1)
        num=100;
        name1='bike';
        base=265;
    elseif(object==2)
        num=100;
        name1='cars';
        base=220;
    elseif(object==3)
        num=100;
        name1='person';
        base=111;
    else 
        num=100;
        name1='none';
        base=180;
    end
    for number=1:num
        total1=total1+1;
        if (object==1) 
            if total1<10
                name2='bike_00';
            elseif total1<100
                name2='bike_0';
            else
                name2='bike_';
            end
        elseif (object==2) 
            if total1<10
                name2='carsgraz_00';
            elseif total1<100
                name2='carsgraz_0';
            else
                name2='carsgraz_';
            end
        elseif (object==3) 
            if total1<10
                name2='person_00';
            elseif total1<100
                name2='person_0';
            else
                name2='person_';
            end
        else
            if total1<10
                name2='bg_graz_00';
            elseif total1<100
                name2='bg_graz_0';
            else
                name2='bg_graz_';
            end
        end
        name=strcat('Test\',name1,'\',name2,num2str(base+number),'.bmp');
	total=total+1;
        A=imread(name);
        B=rgb2hsv(A);
        C=B(:,:,3);
	valid_lable(total)=object;
	%SIFT, 4 direction only
        [Ix,Iy]=gradient(C);
        [size1,size2]=size(C);
        for i=(size1-10)/10:(size1-10)/10:size1-10
            for j=(size2-10)/10:(size2-10)/10:size2-10
                for m=0:1
                    for n=0:1
                        for p=1:4
                            for q=1:4
                                Ix0(p,q)=Ix(i+p+m*4,j+q+n*4);
                                Iy0(p,q)=Iy(i+p+m*4,j+q+n*4);
                            end
                        end
                        keypoint0(m*2+n+1,1)=sum(Iy0(Iy0>0));
                        keypoint0(m*2+n+1,2)=sum(Iy0(Iy0<0));
                        keypoint0(m*2+n+1,3)=sum(Ix0(Ix0<0));
                        keypoint0(m*2+n+1,4)=sum(Ix0(Ix0>0));                
                    end
                end
                for m=1:4
                    for n=1:4
                        keypoint((total-1)*100+(i/(size1-10)*10-1)*10+j/(size2-10)*10,(m-1)*4+n)=keypoint0(m,n);
                    end
                end
            end
        end
        %end of SIFT
	for i=1:100
	    mindis=100;
	    for j=1:kmean_num
		dis=pdist(keypoint(100*(total-1)+i,:),centers(j,:));
		if dis<mindis
		    mindis=dis;
		    minpos=j;
		end
	    end
	    valid_histo(total,minpos)=valid_histo(total,minpos)+1;
	end
    end
end
%end of Validation data

%Testing data
total=0;
valid_histo=zeros(400,kmean_num);
for object=1:4
    total1=0;
    if (object==1)
        num=100;
        name1='bike';
        base=165;
    elseif(object==2)
        num=100;
        name1='cars';
        base=320;
    elseif(object==3)
        num=100;
        name1='person';
        base=211;
    else 
        num=100;
        name1='none';
        base=280;
    end
    for number=1:num
        total1=total1+1;
        if (object==1) 
            if total1<10
                name2='bike_00';
            elseif total1<100
                name2='bike_0';
            else
                name2='bike_';
            end
        elseif (object==2) 
            if total1<10
                name2='carsgraz_00';
            elseif total1<100
                name2='carsgraz_0';
            else
                name2='carsgraz_';
            end
        elseif (object==3) 
            if total1<10
                name2='person_00';
            elseif total1<100
                name2='person_0';
            else
                name2='person_';
            end
        else
            if total1<10
                name2='bg_graz_00';
            elseif total1<100
                name2='bg_graz_0';
            else
                name2='bg_graz_';
            end
        end
        name=strcat('Test\',name1,'\',name2,num2str(base+number),'.bmp');
	total=total+1;
        A=imread(name);
        B=rgb2hsv(A);
        C=B(:,:,3);
	test_lable(total)=object;
	%SIFT, 4 direction only
        [Ix,Iy]=gradient(C);
        [size1,size2]=size(C);
        for i=(size1-10)/10:(size1-10)/10:size1-10
            for j=(size2-10)/10:(size2-10)/10:size2-10
                for m=0:1
                    for n=0:1
                        for p=1:4
                            for q=1:4
                                Ix0(p,q)=Ix(i+p+m*4,j+q+n*4);
                                Iy0(p,q)=Iy(i+p+m*4,j+q+n*4);
                            end
                        end
                        keypoint0(m*2+n+1,1)=sum(Iy0(Iy0>0));
                        keypoint0(m*2+n+1,2)=sum(Iy0(Iy0<0));
                        keypoint0(m*2+n+1,3)=sum(Ix0(Ix0<0));
                        keypoint0(m*2+n+1,4)=sum(Ix0(Ix0>0));                
                    end
                end
                for m=1:4
                    for n=1:4
                        keypoint((total-1)*100+(i/(size1-10)*10-1)*10+j/(size2-10)*10,(m-1)*4+n)=keypoint0(m,n);
                    end
                end
            end
        end
        %end of SIFT
	for i=1:100
	    mindis=100;
	    for j=1:kmean_num
		dis=pdist(keypoint(100*(total-1)+i,:),centers(j,:));
		if dis<mindis
		    mindis=dis;
		    minpos=j;
		end
	    end
	    test_histo(total,minpos)=test_histo(total,minpos)+1;
	end
    end
end
%end of Testing data
%end of Image Representation

%knn
knn_num=7;
for i=1:676
    for j=1:500
        if train_histo(i,j)>0
            train_histo(i,j)=1;
        else
            train_histo(i,j)=0;
        end
    end
end
for i=1:400
    for j=1:500
        if valid_histo(i,j)>0
            valid_histo(i,j)=1;
        else
            valid_histo(i,j)=0;
        end
        if test_histo(i,j)>0
            test_histo(i,j)=1;
        else
            test_histo(i,j)=0;
        end
    end
end
%Validation data
test_valid_lable=zeros(400);
for i=1:size(valid_histo,1)
    for j=1:knn_num
        knnmaxdis(j)=0;
        knnmaxpos(j)=0;
    end
    for j=1:size(train_histo,1)
	dis=sum(min(valid_histo(i,:),train_histo(j,:)));
        for k=1:knn_num
            if dis>knnmaxdis(k)
                for m=knn_num:-1:k+1
                    knnmaxdis(m)=knnmaxdis(m-1);
                    knnmaxpos(m)=knnmaxpos(m-1);
                end
                knnmaxdis(k)=dis;
                knnmaxpos(k)=j;
                break;
            end
        end
    end
    vote=zeros(1,4);
    for j=1:knn_num
        if knnmaxpos(j)<=165
            vote(1)=vote(1)+1;
        elseif knnmaxpos(j)<=165+220
            vote(2)=vote(2)+1;
        elseif knnmaxpos(j)<=165+220+111
            vote(3)=vote(3)+1;
        else 
            vote(4)=vote(4)+1;
        end
    end
    for q=1:4
        if vote(q)==max(vote)
            p=q;
        end
    end
    test_valid_lable(i)=p;
end
correct=0;
incorrect=0;
bike_valid_corr=0;
bike_valid_inco=0;
car_valid_corr=0;
car_valid_inco=0;
person_valid_corr=0;
person_valid_inco=0;
none_valid_corr=0;
none_valid_inco=0;
for i=1:size(test_valid_lable,1)
    if test_valid_lable(i)==valid_lable(i)
        correct=correct+1;
        if i<=100
            bike_valid_corr=bike_valid_corr+1;
        elseif i<=200
            car_valid_corr=car_valid_corr+1;
        elseif i<=300
            person_valid_corr=person_valid_corr+1;
        else
            none_valid_corr=none_valid_corr+1;
        end
    else
        incorrect=incorrect+1;
        if i<=100
            bike_valid_inco=bike_valid_inco+1;
        elseif i<=200
            car_valid_inco=car_valid_inco+1;
        elseif i<=300
            person_valid_inco=person_valid_inco+1;
        else
            none_valid_inco=none_valid_inco+1;
        end
    end
end
accuracy(1,1)=correct/(correct+incorrect);
accuracy(1,2)=bike_valid_corr/(bike_valid_corr+bike_valid_inco);
accuracy(1,3)=car_valid_corr/(car_valid_corr+car_valid_inco);
accuracy(1,4)=person_valid_corr/(person_valid_corr+person_valid_inco);
accuracy(1,5)=none_valid_corr/(none_valid_corr+none_valid_inco);
%end of Validation data

test_test_lable=zeros(400);
%Testing data
for i=1:size(test_histo,1)
    for j=1:knn_num
        knnmaxdis(j)=0;
        knnmaxpos(j)=0;
    end
    for j=1:size(train_histo,1)
	dis=sum(min(test_histo(i,:),train_histo(j,:)));
        for k=1:knn_num
            if dis>knnmaxdis(k)
                for m=knn_num:-1:k+1
                    knnmaxdis(m)=knnmaxdis(m-1);
                    knnmaxpos(m)=knnmaxpos(m-1);
                end
                knnmaxdis(k)=dis;
                knnmaxpos(k)=j;
                break;
            end
        end
    end
    vote=zeros(1,4);
    for j=1:knn_num
        if knnmaxpos(j)<=165
            vote(1)=vote(1)+1;
        elseif knnmaxpos(j)<=165+220
            vote(2)=vote(2)+1;
        elseif knnmaxpos(j)<=165+220+111
            vote(3)=vote(3)+1;
        else
            vote(4)=vote(4)+1;
        end
    end
    for q=1:4
        if vote(q)==max(vote)
            p=q;
        end
    end
    test_test_lable(i)=p;
end
correct=0;
incorrect=0;
bike_test_corr=0;
bike_test_inco=0;
car_test_corr=0;
car_test_inco=0;
person_test_corr=0;
person_test_inco=0;
none_test_corr=0;
none_test_inco=0;
treat=zeros(4,4);
for i=1:size(test_test_lable,1)
    if test_test_lable(i)==test_lable(i)
        correct=correct+1;
        if i<=100
            bike_test_corr=bike_test_corr+1;
        elseif i<=200
            car_test_corr=car_test_corr+1;
        elseif i<=300
            person_test_corr=person_test_corr+1;
        else
            none_test_corr=none_test_corr+1;
        end
    else
        incorrect=incorrect+1;
        if i<=100
            bike_test_inco=bike_test_inco+1;
        elseif i<=200
            car_test_inco=car_test_inco+1;
        elseif i<=300
            person_test_inco=person_test_inco+1;
        else
            none_test_inco=none_test_inco+1;
        end
    end
    treat(test_lable(i),test_test_lable(i))=treat(test_lable(i),test_test_lable(i))+1;
end
accuracy(2,1)=correct/(correct+incorrect);
accuracy(2,2)=bike_test_corr/(bike_test_corr+bike_test_inco);
accuracy(2,3)=car_test_corr/(car_test_corr+car_test_inco);
accuracy(2,4)=person_test_corr/(person_test_corr+person_test_inco);
accuracy(2,5)=none_test_corr/(none_test_corr+none_test_inco);
accuracy
%end of Testing data
%end of knn