% �p�����[�^�ݒ�
dt = 0.1;
vel = 10.0;

% ���̓ǂݍ���
prob = imread('problem.png');
% �Ǘ̈�̐ݒ�
wall = 1 - (prob(:,:,1).*prob(:,:,2).*prob(:,:,3) > 0);
% �S�̗̈�̑傫��
[h,w] = size(wall);
[gx,gy] = meshgrid(1:w,1:h);

% ���m�����܂ރZ�������߂�
cells = find(wall);
m=numel(cells);
unknowns = zeros(h,w);
unknowns(cells) = [1:m];
L = sparse(m,m);

% �m�C�}���������Ń��v���V�A���s��𐶐�����
for n=1:m
    for k=[-h 1 h -1]
        nei = unknowns(cells(n)+k);
        if(nei>0)
            L(n,nei) = 1;
            L(n,n) = L(n,n)-1;
        end
    end
end

% ���E�����𖄂ߍ���
fall = unknowns(find(prob(:,:,3)>0));
fall = fall(find(fall));
L(fall,1:m) = zeros(numel(fall),m);
L(fall+(fall-1).*m) = 1;

% ���x��̏�����
u=zeros(h,w);
v=zeros(h,w);

% �ȉ����[�v�Ŏ��Ԕ��W������
for t=1:200
    % ���̗����Z���ŗ������Œ肷��
    pour = find((prob(:,:,1)>0).*wall);
    falldown = find((prob(:,:,3)>0).*wall);
    u(pour) = vel;
    
    % ���U���v�Z����
    div = (gradient(u)+gradient(v')').*wall;
    div(pour) = 0;
    div(falldown) = 0;
    div = div(cells);
    
    % ���`�������������C���͂����߂�
    p = L \ div;
   
    % �O���b�h�Ɏʑ�����
    pg = zeros(h,w);
    pg(cells) = p;
    
    % ���͂�ǃZ���ɃR�s�[����
    npg = zeros(h,w);
    npg_sum = zeros(h,w);
    for i=1:4
        dir = [0 1; 0 -1; 1 0; -1 0];
        npg = npg + (1-wall).*(circshift(pg,dir(i,:)));
        npg_sum = npg_sum + (1-wall).*circshift(wall,dir(i,:));
    end
    pg = npg./max(npg_sum,1)+pg;
    
    % �񈳏k������߂�
    u = u - gradient(pg).*wall;
    v = v - gradient(pg')'.*wall;
    
    % �ڗ�
    sx = max(min(gx-dt*u,w),1);
    sy = max(min(gy-dt*v,h),1);
    u = interp2(gx,gy,u,sx,sy);
    v = interp2(gx,gy,v,sx,sy);
    
    % ����
    clf;
    axis([1 w+2 1 h]);
    title(sprintf('TimeStep = %d', t));
    hold on;
    axis equal;
	contour(wall);
    quiver(u,v,4);
    hold off;
    drawnow;
end