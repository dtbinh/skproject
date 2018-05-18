
% �ϐ��̏�����
clear all;

gauss_plot;

% �`�惂�[�h�̐ݒ�
figure(1);
hold on;
axis([0 300 0 15]);

% �X�p�C�N���Ύ����̃f�[�^�i�S���s���j
trial1 = [51 55 60 70 78];
trial2 = [51 58 65 75 110 150];
trial3 = [52 57 66 80 100 160 180];
trial4 = [54 62 70 77 105 125 140];

% �X�p�C�N���Ύ�����S���s�ł܂Ƃ߂�
all_trial = [trial1 trial2 trial3 trial4];
%sort(all_trial);

% 1���s�ڂł̃X�p�C�N���Ύ����̃��X�^�[�\���i���ۂP�i�ځj
y1(1:5) = 14;
plot(trial1, y1, 'ko');

% �Q�`�S���s�ڂł̃X�p�C�N���Ύ����̃��X�^�[�\���i���ۂQ�`�S�i�ځj
y2(1:6) = 13;
y3(1:7) = 12;
y4(1:7) = 11;
plot(trial2, y2, 'ko');
plot(trial3, y3, 'ko');
plot(trial4, y4, 'ko');

% �S���s�ł܂Ƃ߂��X�p�C�N���Ύ����̃��X�^�[�\���i�S���s���A�Ԋہj
yall(1:25) = 9;
plot(all_trial, yall, 'ro');

% �X�p�C�N���̃J�E���g
%hist(all_trial);
for i=1:30
    hist_edge(i) = (i-1)*10;
end
hist(all_trial, hist_edge);

% �o�r�s�g�̕`��
figure(2);
hold on;
axis([0 300 0 150]);

[n,xout] = hist(all_trial, hist_edge);
stairs(hist_edge, n/4*100, '-r');

hist_bin(1:300) = [1:300];
figure(1);
hist(all_trial, hist_bin);
figure(2);
spk_time = hist(all_trial, hist_bin)*1000/4;
sdf = conv(gauss_function, spk_time);
t(1:400) = [-50:349];
plot(t,sdf);